-- ============================================================
-- ProjectPro — Seed Data
-- Run in: Supabase Dashboard > SQL Editor
-- ============================================================

BEGIN;

-- ─── 1. TEAM MEMBERS (5 คน บทบาทต่างกัน) ───────────────────
INSERT INTO public.team_members (id, name, role_title, member_type) VALUES
  (1, 'สมชาย วงศ์ใหญ่',   'Project Manager',      'manager'),
  (2, 'วิภา รักษาดี',      'Design Engineer',      'member'),
  (3, 'ประวิทย์ สุขสม',    'Production Supervisor', 'member'),
  (4, 'นันทนา เจริญผล',    'QA Inspector',         'member'),
  (5, 'ธนากร พัฒนา',       'CNC Operator',         'member')
ON CONFLICT (id) DO NOTHING;

-- sync sequence
SELECT setval('public.team_members_id_seq', 5);

-- ─── 2. PROJECTS (5 โปรเจค สถานะต่างกัน) ────────────────────
-- โปรเจค id=1 มีอยู่แล้ว เพิ่ม id 2-5
INSERT INTO public.projects (id, name, description, status, start_date, end_date, custom_fields) VALUES
  (2,
   'JIG FIXTURE ASSY — TOYOTA DAIHATSU TRQ-7821',
   'ออกแบบและผลิต Jig สำหรับ Assembly Line Toyota Daihatsu',
   'completed',
   '2026-01-10', '2026-02-28',
   '{"Job":"26-0112","Customer":"TOYOTA DAIHATSU","Price":"145,000","PO":"TDM-2026-0112","เลขรับ":"26.01.008"}'
  ),
  (3,
   'CHECKING FIXTURE — HONDA MANUFACTURING HCF-3302',
   'ผลิต Checking Fixture ตรวจสอบชิ้นงาน Body Panel Honda',
   'active',
   '2026-02-15', '2026-03-30',
   '{"Job":"26-0198","Customer":"HONDA MANUFACTURING","Price":"92,500","PO":"HMT-0198","เลขรับ":"26.02.015"}'
  ),
  (4,
   'WELDING JIG — MITSUBISHI ELECTRIC WJ-1145',
   'ออกแบบ Welding Jig สำหรับ Bracket Assembly Mitsubishi',
   'planning',
   '2026-03-15', '2026-05-10',
   '{"Job":"26-0241","Customer":"MITSUBISHI ELECTRIC","Price":"210,000","PO":"","เลขรับ":"26.03.018"}'
  ),
  (5,
   'DRILLING JIG — ISUZU MOTORS DJ-5509',
   'Drilling Jig สำหรับ Cylinder Head Isuzu 4JJ3',
   'on_hold',
   '2026-02-01', '2026-04-15',
   '{"Job":"26-0163","Customer":"ISUZU MOTORS","Price":"78,000","PO":"ISZ-163","เลขรับ":"26.02.010"}'
  )
ON CONFLICT (id) DO NOTHING;

SELECT setval('public.projects_id_seq', 5);

-- ─── 3. TASKS (20 tasks กระจายทุก stage) ─────────────────────
-- status: todo | in_progress | review | done | blocked
-- priority: low | medium | high
-- tag: design | production | qa | assembly | inspection | cnc | weld

INSERT INTO public.tasks (id, name, project_id, assignee_id, status, priority, tag, start_date, due_date) VALUES

  -- Project 1: APPICO HITECH (active) — 4 tasks
  (1,  'รับ Drawing และวิเคราะห์ชิ้นงาน',             1, 2, 'done',        'high',   'design',     '2026-03-05', '2026-03-06'),
  (2,  'ออกแบบ 3D Model Fixture',                    1, 2, 'done',        'high',   'design',     '2026-03-06', '2026-03-07'),
  (3,  'ตัด CNC Base Plate',                          1, 5, 'in_progress', 'high',   'cnc',        '2026-03-07', '2026-03-08'),
  (4,  'ตรวจสอบความเที่ยงตรง (Final Inspection)',     1, 4, 'todo',        'medium', 'inspection', '2026-03-08', '2026-03-09'),

  -- Project 2: TOYOTA DAIHATSU (completed) — 5 tasks
  (5,  'รับ PO และเอกสารจากลูกค้า',                   2, 1, 'done', 'medium', 'design',     '2026-01-10', '2026-01-11'),
  (6,  'ออกแบบ Layout Jig Assembly',                  2, 2, 'done', 'high',   'design',     '2026-01-12', '2026-01-20'),
  (7,  'ผลิตชิ้นส่วน Locating Pin & Clamp',           2, 5, 'done', 'high',   'cnc',        '2026-01-21', '2026-02-05'),
  (8,  'Weld & Assembly Jig Structure',               2, 3, 'done', 'high',   'weld',       '2026-02-06', '2026-02-18'),
  (9,  'QA ตรวจสอบ & ส่งมอบลูกค้า',                   2, 4, 'done', 'high',   'inspection', '2026-02-19', '2026-02-28'),

  -- Project 3: HONDA MANUFACTURING (active) — 5 tasks
  (10, 'ประชุม Kick-off และรับ Spec',                  3, 1, 'done',        'high',   'design',     '2026-02-15', '2026-02-16'),
  (11, 'ออกแบบ Checking Fixture ตาม Drawing',         3, 2, 'done',        'high',   'design',     '2026-02-17', '2026-02-25'),
  (12, 'CNC Machining ชิ้นส่วนหลัก',                  3, 5, 'in_progress', 'high',   'cnc',        '2026-02-26', '2026-03-12'),
  (13, 'Assembly และ Adjustment',                     3, 3, 'todo',        'medium', 'assembly',   '2026-03-13', '2026-03-22'),
  (14, 'ทดสอบกับชิ้นงานจริง & แก้ไข',                  3, 4, 'todo',        'high',   'qa',         '2026-03-23', '2026-03-30'),

  -- Project 4: MITSUBISHI (planning) — 3 tasks
  (15, 'รอรับ Drawing อย่างเป็นทางการ',                4, 1, 'blocked',     'high',   'design',     '2026-03-15', '2026-03-20'),
  (16, 'วางแผนวัสดุและต้นทุน',                         4, 1, 'todo',        'medium', 'design',     '2026-03-21', '2026-03-25'),
  (17, 'ออกแบบ Concept Welding Jig',                  4, 2, 'todo',        'low',    'design',     '2026-03-26', '2026-04-10'),

  -- Project 5: ISUZU (on_hold) — 3 tasks
  (18, 'รับ Drawing & วิเคราะห์ Cylinder Head',        5, 2, 'done',        'high',   'design',     '2026-02-01', '2026-02-03'),
  (19, 'ออกแบบ Drilling Template',                    5, 2, 'review',      'high',   'design',     '2026-02-04', '2026-02-15'),
  (20, 'รอ Confirm แบบจากลูกค้า (On Hold)',            5, 1, 'blocked',     'high',   'qa',         '2026-02-16', '2026-03-01')

ON CONFLICT (id) DO NOTHING;

SELECT setval('public.tasks_id_seq', 20);

-- ─── 4. ACTIVITIES (10 รายการ) ───────────────────────────────
INSERT INTO public.activities (id, text, type, created_at) VALUES
  (1,  'สร้างโปรเจค "APPICO HITECH — MB3B" เรียบร้อยแล้ว',                    'project_created',  '2026-03-05 09:00:00+07'),
  (2,  'อัปโหลด Drawing และเริ่มวิเคราะห์ชิ้นงาน (Project #1)',               'task_updated',     '2026-03-05 10:30:00+07'),
  (3,  'สร้างโปรเจค "TOYOTA DAIHATSU TRQ-7821" และส่งมอบสำเร็จ',             'project_created',  '2026-02-28 16:00:00+07'),
  (4,  'QA ตรวจสอบ Jig Toyota ผ่านเกณฑ์ ส่งมอบลูกค้าแล้ว',                   'task_done',        '2026-02-28 14:00:00+07'),
  (5,  'เริ่มโปรเจค "HONDA MANUFACTURING HCF-3302" — Kick-off meeting',       'project_created',  '2026-02-15 09:00:00+07'),
  (6,  'CNC Machining ชิ้นส่วนหลัก Honda เริ่มแล้ว (Task #12)',               'task_updated',     '2026-02-26 08:00:00+07'),
  (7,  'โปรเจค "ISUZU DJ-5509" ถูกพักชั่วคราว — รอ Confirm แบบจากลูกค้า',   'project_updated',  '2026-02-16 15:00:00+07'),
  (8,  'เพิ่มสมาชิกทีม: ธนากร พัฒนา (CNC Operator)',                          'member_added',     '2026-01-05 09:00:00+07'),
  (9,  'สร้างโปรเจค "MITSUBISHI ELECTRIC WJ-1145" — อยู่ระหว่างวางแผน',      'project_created',  '2026-03-07 10:00:00+07'),
  (10, 'Design Review ผ่าน: Checking Fixture Honda อนุมัติแบบแล้ว (Task #11)', 'task_done',       '2026-02-25 17:00:00+07')
ON CONFLICT (id) DO NOTHING;

SELECT setval('public.activities_id_seq', 10);

COMMIT;

-- ✅ Seed data เสร็จแล้ว!
-- projects: 5 | team_members: 5 | tasks: 20 | activities: 10
