-- ============================================================
-- ProjectPro — Analyses / Review Board Table
-- วิธีใช้: คัดลอกทั้งหมดแล้ว วางใน Supabase → SQL Editor → Run
-- ============================================================

-- สร้างตาราง analyses
create table if not exists public.analyses (
  id            bigserial primary key,
  name          text not null,
  project_id    bigint references public.projects(id) on delete cascade,
  stage         text default 'planning',       -- ideation | planning | review | decision
  go_no_go      text default 'pending',         -- pending | approved | rejected | hold
  risk_level    text default 'medium',          -- low | medium | high | critical
  horizon       int,                            -- ระยะเวลา (ปี)
  discount_rate numeric(5,2),                   -- อัตราคิดลด (%)
  type          text[],                         -- ['Simple','Technical','Complex','Compliance']
  created_by    uuid references public.profiles(id),
  created_at    timestamptz default now()
);

-- เปิด RLS
alter table public.analyses enable row level security;

-- Policy: ผู้ใช้ที่ login แล้วเข้าถึงได้
create policy "analyses_policy" on public.analyses
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- ✅ พร้อมใช้งาน! รันไฟล์นี้ใน Supabase → SQL Editor ครับ
