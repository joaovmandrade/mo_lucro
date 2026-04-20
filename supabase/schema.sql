-- ============================================================
-- Mo Lucro — Supabase SQL Schema
-- Run this in the Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. OPERATIONS TABLE
-- ─────────────────────────────────────────────────────────────

create table if not exists public.operations (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  type        text not null check (type in ('buy', 'sell')),
  asset       text not null,
  category    text not null default 'others'
              check (category in ('stocks', 'crypto', 'fixed_income', 'others')),
  quantity    numeric(18, 8) not null check (quantity > 0),
  price       numeric(18, 2) not null check (price >= 0),
  total       numeric(18, 2) not null check (total >= 0),
  date        timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

-- Add category column if upgrading from previous schema (safe to run)
alter table public.operations
  add column if not exists category text not null default 'others'
  check (category in ('stocks', 'crypto', 'fixed_income', 'others'));

-- Indexes
create index if not exists operations_user_id_idx  on public.operations (user_id);
create index if not exists operations_asset_idx    on public.operations (asset);
create index if not exists operations_date_idx     on public.operations (date desc);

-- Row Level Security
alter table public.operations enable row level security;

-- Policies
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
-- ─────────────────────────────────────────────────────────────

create table if not exists public.goals (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  title         text not null,
  target_value  numeric(18, 2) not null check (target_value > 0),
  current_value numeric(18, 2) not null default 0 check (current_value >= 0),
  created_at    timestamptz not null default now()
);

-- Indexes
create index if not exists goals_user_id_idx on public.goals (user_id);

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
-- DONE ✅
-- Tables: operations, transactions, goals
-- RLS:    Enabled on all tables
-- Policy: user_id = auth.uid() on all CRUD operations
-- ─────────────────────────────────────────────────────────────
