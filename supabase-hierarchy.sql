-- ============================================================
-- ProjectPro — 4-Layer Hierarchy: Project Group → Project → Task → Subtask
-- วิธีใช้: คัดลอกทั้งหมดวางใน Supabase → SQL Editor → Run
-- ============================================================

-- 1. PROJECT GROUPS
create table if not exists public.project_groups (
  id         bigserial primary key,
  name       text not null,
  color      text default '#6366f1',
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

-- 2. เพิ่ม group_id ในตาราง projects (ถ้ามีอยู่แล้ว)
alter table public.projects add column if not exists group_id bigint references public.project_groups(id) on delete set null;

-- 3. SUBTASKS
create table if not exists public.subtasks (
  id          bigserial primary key,
  name        text not null,
  task_id     bigint references public.tasks(id) on delete cascade,
  assignee_id bigint references public.team_members(id) on delete set null,
  status      text default 'todo',   -- todo | inprogress | done
  due_date    date,
  created_by  uuid references public.profiles(id),
  created_at  timestamptz default now()
);

-- 4. เปิด RLS
alter table public.project_groups enable row level security;
alter table public.subtasks       enable row level security;

-- 5. Policies
create policy "project_groups_policy" on public.project_groups
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "subtasks_policy" on public.subtasks
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- ✅ เสร็จแล้ว! ระบบพร้อมใช้งาน 4 ชั้น
