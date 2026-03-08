-- ============================================================
-- เปิด Supabase Realtime สำหรับตารางทั้งหมด
-- Run ใน: Supabase Dashboard > SQL Editor (รันครั้งเดียว)
-- ============================================================

ALTER PUBLICATION supabase_realtime
  ADD TABLE public.projects,
            public.tasks,
            public.activities,
            public.team_members;
