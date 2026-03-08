-- ============================================================
-- ProjectPro — Medium Features: Time Tracking + Recurring Tasks
-- วิธีใช้: คัดลอกทั้งหมดวางใน Supabase → SQL Editor → Run
-- ============================================================

-- 1. TIME LOGS TABLE
create table if not exists public.time_logs (
  id            bigserial primary key,
  task_id       bigint references public.tasks(id) on delete cascade,
  user_id       uuid references public.profiles(id) on delete set null,
  started_at    timestamptz not null default now(),
  ended_at      timestamptz,
  duration_minutes int default 0,
  created_at    timestamptz default now()
);

alter table public.time_logs enable row level security;

create policy "time_logs_policy" on public.time_logs
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- 2. RECURRING TASKS — add column to tasks
alter table public.tasks add column if not exists recurrence text default 'none';
-- values: none | daily | weekly | monthly | yearly

-- 3. ACTIVITY LOG — type column (ถ้ายังไม่ได้รัน)
alter table public.activities add column if not exists type text default '';

-- ✅ เสร็จแล้ว! พร้อมใช้งาน
