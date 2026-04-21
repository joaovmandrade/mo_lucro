-- ============================================================
-- Mo Lucro — Supabase SQL Schema  (v3 — production ready)
-- Run this in the Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. OPERATIONS TABLE
-- ─────────────────────────────────────────────────────────────

create table if not exists public.operations (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  type        text not null check (type in ('buy', 'sell', 'dividend')),
  asset       text not null,
  category    text not null default 'others'
              check (category in ('stocks', 'crypto', 'fixed_income', 'fiis', 'others')),
  quantity    numeric(18, 8) not null check (quantity >= 0),
  price       numeric(18, 2) not null check (price >= 0),
  total       numeric(18, 2) not null check (total >= 0),
  date        timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

-- Safe migrations for existing tables
alter table public.operations
  add column if not exists category text not null default 'others';

alter table public.operations
  drop constraint if exists operations_type_check;
alter table public.operations
  add constraint operations_type_check check (type in ('buy', 'sell', 'dividend'));

-- Indexes
create index if not exists operations_user_id_idx  on public.operations (user_id);
create index if not exists operations_asset_idx    on public.operations (asset);
create index if not exists operations_date_idx     on public.operations (date desc);
create index if not exists operations_type_idx     on public.operations (type);

-- Row Level Security
alter table public.operations enable row level security;

drop policy if exists "operations_select_own" on public.operations;
create policy "operations_select_own"
  on public.operations for select
  using (user_id = auth.uid());

drop policy if exists "operations_insert_own" on public.operations;
create policy "operations_insert_own"
  on public.operations for insert
  with check (user_id = auth.uid());

drop policy if exists "operations_update_own" on public.operations;
create policy "operations_update_own"
  on public.operations for update
  using (user_id = auth.uid());

drop policy if exists "operations_delete_own" on public.operations;
create policy "operations_delete_own"
  on public.operations for delete
  using (user_id = auth.uid());


-- ─────────────────────────────────────────────────────────────
-- 2. TRANSACTIONS TABLE
-- ─────────────────────────────────────────────────────────────

create table if not exists public.transactions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  type        text not null check (type in ('income', 'expense')),
  amount      numeric(18, 2) not null check (amount > 0),
  category    text not null default 'others',
  description text not null default '',
  date        timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

-- Indexes
create index if not exists transactions_user_id_idx on public.transactions (user_id);
create index if not exists transactions_date_idx    on public.transactions (date desc);
create index if not exists transactions_type_idx    on public.transactions (type);
create index if not exists transactions_category_idx on public.transactions (category);

-- Row Level Security
alter table public.transactions enable row level security;

drop policy if exists "transactions_select_own" on public.transactions;
create policy "transactions_select_own"
  on public.transactions for select
  using (user_id = auth.uid());

drop policy if exists "transactions_insert_own" on public.transactions;
create policy "transactions_insert_own"
  on public.transactions for insert
  with check (user_id = auth.uid());

drop policy if exists "transactions_update_own" on public.transactions;
create policy "transactions_update_own"
  on public.transactions for update
  using (user_id = auth.uid());

drop policy if exists "transactions_delete_own" on public.transactions;
create policy "transactions_delete_own"
  on public.transactions for delete
  using (user_id = auth.uid());


-- ─────────────────────────────────────────────────────────────
-- 3. GOALS TABLE
-- Column names aligned with Flutter GoalService:
--   name          → goal title
--   target        → target amount
--   current       → current saved amount
-- ─────────────────────────────────────────────────────────────

create table if not exists public.goals (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  name          text not null,
  target        numeric(18, 2) not null check (target > 0),
  current       numeric(18, 2) not null default 0 check (current >= 0),
  deadline      timestamptz,
  created_at    timestamptz not null default now()
);

-- Indexes
create index if not exists goals_user_id_idx on public.goals (user_id);
create index if not exists goals_created_at_idx on public.goals (created_at desc);

-- Row Level Security
alter table public.goals enable row level security;

drop policy if exists "goals_select_own" on public.goals;
create policy "goals_select_own"
  on public.goals for select
  using (user_id = auth.uid());

drop policy if exists "goals_insert_own" on public.goals;
create policy "goals_insert_own"
  on public.goals for insert
  with check (user_id = auth.uid());

drop policy if exists "goals_update_own" on public.goals;
create policy "goals_update_own"
  on public.goals for update
  using (user_id = auth.uid());

drop policy if exists "goals_delete_own" on public.goals;
create policy "goals_delete_own"
  on public.goals for delete
  using (user_id = auth.uid());


-- ─────────────────────────────────────────────────────────────
-- 4. USER PROFILES TABLE (investor quiz results)
-- ─────────────────────────────────────────────────────────────

create table if not exists public.user_profiles (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null unique references auth.users(id) on delete cascade,
  investor_profile text check (investor_profile in ('conservative', 'moderate', 'aggressive')),
  quiz_answers  jsonb,
  updated_at    timestamptz not null default now()
);

-- Indexes
create index if not exists user_profiles_user_id_idx on public.user_profiles (user_id);

-- Row Level Security
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
  using (user_id = auth.uid());

drop policy if exists "profiles_delete_own" on public.user_profiles;
create policy "profiles_delete_own"
  on public.user_profiles for delete
  using (user_id = auth.uid());


-- ─────────────────────────────────────────────────────────────
-- DONE ✅
-- Tables:   operations, transactions, goals, user_profiles
-- RLS:      Enabled on all tables
-- Policy:   user_id = auth.uid() on all CRUD operations
-- Indexes:  All high-cardinality columns indexed
-- ─────────────────────────────────────────────────────────────
