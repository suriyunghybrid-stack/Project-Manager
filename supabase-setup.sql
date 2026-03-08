-- ============================================================
-- ProjectPro — Supabase Database Setup
-- วิธีใช้: คัดลอกทั้งหมดแล้ว วางใน Supabase → SQL Editor → Run
-- ============================================================

-- 1. PROFILES (auto-linked to auth users)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  email text,
  created_at timestamptz default now()
);

-- 2. TEAMS
create table if not exists public.teams (
  id bigserial primary key,
  name text not null,
  color text default '#6366f1',
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

-- 3. TEAM MEMBERS (manual entries)
create table if not exists public.team_members (
  id bigserial primary key,
  name text not null,
  role_title text,
  team_id bigint references public.teams(id) on delete cascade,
  member_type text default 'member',
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

-- 4. PROJECTS
create table if not exists public.projects (
  id bigserial primary key,
  name text not null,
  description text,
  status text default 'planning',
  start_date date,
  end_date date,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

-- 5. TASKS
create table if not exists public.tasks (
  id bigserial primary key,
  name text not null,
  project_id bigint references public.projects(id) on delete cascade,
  assignee_id bigint references public.team_members(id) on delete set null,
  status text default 'todo',
  priority text default 'medium',
  tag text default 'feature',
  start_date date,
  due_date date,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

-- เพิ่ม start_date ในตารางที่มีอยู่แล้ว (รันบรรทัดนี้หากสร้างตารางไปแล้ว)
alter table public.tasks add column if not exists start_date date;

-- 6. ACTIVITIES
create table if not exists public.activities (
  id bigserial primary key,
  text text not null,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

-- ─── ENABLE ROW LEVEL SECURITY ───────────────────────────────
alter table public.profiles enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.projects enable row level security;
alter table public.tasks enable row level security;
alter table public.activities enable row level security;

-- ─── RLS POLICIES (ผู้ใช้ที่ login แล้วเข้าถึงได้ทั้งหมด) ───
create policy "profiles_policy" on public.profiles
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "teams_policy" on public.teams
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "team_members_policy" on public.team_members
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "projects_policy" on public.projects
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "tasks_policy" on public.tasks
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "activities_policy" on public.activities
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- ─── AUTO-CREATE PROFILE เมื่อ USER สมัครใหม่ ───────────────
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ✅ Setup เสร็จแล้ว! พร้อมใช้งานครับ

-- ─── เพิ่ม type column ใน activities (สำหรับ Audit Log) ────────────────
alter table public.activities add column if not exists type text default '';
