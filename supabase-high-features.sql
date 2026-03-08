-- ══════════════════════════════════════════════════════════════
--  HIGH PRIORITY FEATURES MIGRATION
--  รัน SQL นี้ใน Supabase SQL Editor
-- ══════════════════════════════════════════════════════════════

-- ── 1. Task Dependency ────────────────────────────────────────
alter table public.tasks
  add column if not exists depends_on_id bigint
  references public.tasks(id) on delete set null;

-- ── 2. Task Comments ──────────────────────────────────────────
create table if not exists public.task_comments (
  id          bigserial primary key,
  task_id     bigint references public.tasks(id) on delete cascade,
  user_id     uuid   references auth.users(id) on delete set null,
  user_name   text   default '',
  text        text   not null,
  created_at  timestamptz default now()
);

alter table public.task_comments enable row level security;
drop policy if exists "task_comments_all" on public.task_comments;
create policy "task_comments_all" on public.task_comments
  for all using (true) with check (true);

-- ── 3. Task File Attachments ──────────────────────────────────
create table if not exists public.task_attachments (
  id          bigserial primary key,
  task_id     bigint references public.tasks(id) on delete cascade,
  file_name   text   not null,
  file_url    text   not null,
  file_size   int    default 0,
  created_at  timestamptz default now()
);

alter table public.task_attachments enable row level security;
drop policy if exists "task_attachments_all" on public.task_attachments;
create policy "task_attachments_all" on public.task_attachments
  for all using (true) with check (true);

-- ══════════════════════════════════════════════════════════════
--  SUPABASE STORAGE — สร้าง Bucket สำหรับ File Attachments
--  ทำใน Supabase Dashboard → Storage → New Bucket
--    Bucket name : task-files
--    Public      : ✅ (เปิด Public)
-- ══════════════════════════════════════════════════════════════
