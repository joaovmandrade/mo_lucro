-- ============================================================
-- Mo Lucro — cria a tabela user_profiles no banco em uso.
--
-- Contexto: supabase/schema.sql declara a tabela, mas ela não existe no
-- projeto Supabase em produção (a API responde PGRST205). Sem ela o app
-- guarda o perfil do investidor apenas no aparelho.
--
-- Como aplicar: Supabase Dashboard > SQL Editor > colar e executar.
-- O script é idempotente (pode ser executado mais de uma vez).
-- ============================================================

create table if not exists public.user_profiles (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null unique references auth.users(id) on delete cascade,
  investor_profile text check (investor_profile in ('conservative', 'moderate', 'aggressive')),
  quiz_answers     jsonb,
  updated_at       timestamptz not null default now()
);

alter table public.user_profiles enable row level security;

drop policy if exists "profiles_select_own" on public.user_profiles;
create policy "profiles_select_own"
  on public.user_profiles for select
  using (user_id = auth.uid());

drop policy if exists "profiles_insert_own" on public.user_profiles;
create policy "profiles_insert_own"
  on public.user_profiles for insert
  with check (user_id = auth.uid());

drop policy if exists "profiles_update_own" on public.user_profiles;
create policy "profiles_update_own"
  on public.user_profiles for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "profiles_delete_own" on public.user_profiles;
create policy "profiles_delete_own"
  on public.user_profiles for delete
  using (user_id = auth.uid());

-- Faz o PostgREST enxergar a tabela nova sem esperar o recarregamento.
notify pgrst, 'reload schema';
