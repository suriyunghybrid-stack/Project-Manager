-- ══════════════════════════════════════════════════════════════════
--  ASSEMBLY TRACKER — Supabase SQL Setup
--  Project: 712545-X7A09 | FRAME, RR SEAT BACK SIDE, RH
--  Customer: TOYOTA BOSHOKU | PDC: 25-0815 | Job: SO25-0678
--
--  STEP 1: Run this entire script in Supabase SQL Editor
--  STEP 2: (Optional) Set up Supabase Storage bucket "parts-images"
--          and upload part photos named by part_no (e.g. "A001.jpg")
-- ══════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────
--  TABLE 1: assembly_jobs
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS assembly_jobs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_no      text NOT NULL,
  part_no     text NOT NULL,
  part_name   text NOT NULL,
  customer    text,
  pdc_no      text,
  quantity    int  DEFAULT 1,
  status      text DEFAULT 'in_progress',
  notes       text,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- ─────────────────────────────────────────
--  TABLE 2: assembly_parts
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS assembly_parts (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id       uuid REFERENCES assembly_jobs(id) ON DELETE CASCADE,
  seq_no       int,
  part_no      text,
  part_name    text NOT NULL,
  material     text,
  mat_size     text,
  qty_required int  DEFAULT 1,
  image_url    text,
  notes        text,
  created_at   timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS assembly_parts_job_id_idx ON assembly_parts(job_id);

-- ─────────────────────────────────────────
--  TABLE 3: part_progress
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS part_progress (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  part_id        uuid REFERENCES assembly_parts(id) ON DELETE CASCADE,
  step           text NOT NULL,   -- saw | lathe | drill | ht | assy | qc
  status         text DEFAULT 'queue',  -- queue | in_progress | done | problem | na
  qty_passed     int  DEFAULT 0,
  qty_rejected   int  DEFAULT 0,
  planned_hours  numeric(6,2),
  actual_hours   numeric(6,2),
  planned_start  date,
  planned_end    date,
  actual_start   date,
  actual_end     date,
  notes          text,
  updated_by     text,
  updated_at     timestamptz DEFAULT now(),
  UNIQUE(part_id, step)
);
CREATE INDEX IF NOT EXISTS part_progress_part_id_idx ON part_progress(part_id);

-- Enable Row Level Security (open read/write for authenticated users)
ALTER TABLE assembly_jobs    ENABLE ROW LEVEL SECURITY;
ALTER TABLE assembly_parts   ENABLE ROW LEVEL SECURITY;
ALTER TABLE part_progress    ENABLE ROW LEVEL SECURITY;

-- RLS Policies (allow authenticated users full access)
CREATE POLICY "assembly_jobs_auth"  ON assembly_jobs    FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "assembly_parts_auth" ON assembly_parts   FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "part_progress_auth"  ON part_progress    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Also allow anon read (for the app's anon key)
CREATE POLICY "assembly_jobs_anon"  ON assembly_jobs    FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "assembly_parts_anon" ON assembly_parts   FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "part_progress_anon"  ON part_progress    FOR ALL TO anon USING (true) WITH CHECK (true);


-- ══════════════════════════════════════════════════════════════════
--  SEED DATA: Assembly Job 712545-X7A09
-- ══════════════════════════════════════════════════════════════════

-- Insert the assembly job
INSERT INTO assembly_jobs (id, job_no, part_no, part_name, customer, pdc_no, quantity, status)
VALUES (
  'a0000000-0001-0001-0001-000000000001',
  'SO25-0678',
  '712545-X7A09',
  'FRAME, RR SEAT BACK SIDE, RH',
  'TOYOTA BOSHOKU',
  '25-0815',
  1,
  'in_progress'
)
ON CONFLICT (id) DO NOTHING;

-- ─────────────────────────────────────────
--  SEED DATA: 61 Parts from Material Size Order
--  Source: 2D_25-0815_712545-X7A09_REV_00.pdf (pages 63-66)
-- ─────────────────────────────────────────

INSERT INTO assembly_parts (job_id, seq_no, part_no, part_name, material, mat_size, qty_required)
VALUES
  ('a0000000-0001-0001-0001-000000000001',  1, 'A001', 'BASE PLATE',        'S50C',      '20x250x390',   1),
  ('a0000000-0001-0001-0001-000000000001',  2, 'A002', 'MAIN BLOCK',        'SS400',     '46x71x97',     1),
  ('a0000000-0001-0001-0001-000000000001',  3, 'A003', 'LOCATING PIN',      'SKD11',     'Ø20x25',       1),
  ('a0000000-0001-0001-0001-000000000001',  4, 'A004', 'CLAMP COLLAR',      'SKD11',     'Ø18x20',       1),
  ('a0000000-0001-0001-0001-000000000001',  5, 'A005', 'LOCATING CONE',     'SKD11',     'Ø26x37',       1),
  ('a0000000-0001-0001-0001-000000000001',  6, 'A006', 'LOCATING BUSH',     'SKD11',     'Ø16x25',       1),
  ('a0000000-0001-0001-0001-000000000001',  7, 'A007', 'ROUND PIN',         'SKD11',     'Ø9x33',        1),
  ('a0000000-0001-0001-0001-000000000001',  8, 'A008', 'KNOB',              'SS400',     'Ø20x23',       1),
  ('a0000000-0001-0001-0001-000000000001',  9, 'A009', 'LOCATING PLATE',    'S50C',      '6x30x45',      1),
  ('a0000000-0001-0001-0001-000000000001', 10, 'A010', 'LOCATING BLOCK',    'SKD11',     '9x31x39',      1),
  ('a0000000-0001-0001-0001-000000000001', 11, 'A011', 'BUSH',              'SKD11',     'Ø14x20',       1),
  ('a0000000-0001-0001-0001-000000000001', 12, 'A012', 'LOCATING PIN (L)',  'SKD11',     'Ø20x60',       1),
  ('a0000000-0001-0001-0001-000000000001', 13, 'A013', 'ROUND KNOB',        'SS400',     'Ø12x22',       2),
  ('a0000000-0001-0001-0001-000000000001', 14, 'A014', 'SUPPORT BLOCK',     'SS400',     '25x56x100',    1),
  ('a0000000-0001-0001-0001-000000000001', 15, 'A015', 'LOCATING BUSH',     'SKD11',     'Ø17x33',       1),
  ('a0000000-0001-0001-0001-000000000001', 16, 'A016', 'STRAIGHT PIN',      'SKD11',     'Ø7x52',        1),
  ('a0000000-0001-0001-0001-000000000001', 17, 'A017', 'STOPPER KNOB',      'SS400',     'Ø17x30',       1),
  ('a0000000-0001-0001-0001-000000000001', 18, 'A018', 'VERTICAL POST',     'S50C',      '30x58x166',    2),
  ('a0000000-0001-0001-0001-000000000001', 19, 'A019', 'SLIDE PLATE',       'S50C',      '10x60x155',    1),
  ('a0000000-0001-0001-0001-000000000001', 20, 'A020', 'CLAMP PLATE',       'S50C',      '10x34x155',    1),
  ('a0000000-0001-0001-0001-000000000001', 21, 'A021', 'WASHER',            'S50C',      'Ø26x3',        2),
  ('a0000000-0001-0001-0001-000000000001', 22, 'A022', 'STUD',              'S50C',      'Ø16x40',       2),
  ('a0000000-0001-0001-0001-000000000001', 23, 'A023', 'BODY BLOCK',        'S50C',      '44x68x110',    1),
  ('a0000000-0001-0001-0001-000000000001', 24, 'A024', 'LOCATING BUSH',     'SKD11',     'Ø20x27',       2),
  ('a0000000-0001-0001-0001-000000000001', 25, 'A025', 'PIN',               'SKD11',     'Ø10x48',       2),
  ('a0000000-0001-0001-0001-000000000001', 26, 'A026', 'KNOB STUD',         'SS400',     'Ø20x30',       1),
  ('a0000000-0001-0001-0001-000000000001', 27, 'A027', 'BRACKET',           'SS400',     '24x72x75',     1),
  ('a0000000-0001-0001-0001-000000000001', 28, 'A028', 'CLAMP BUSH',        'SKD11',     'Ø25x24',       1),
  ('a0000000-0001-0001-0001-000000000001', 29, 'A029', 'TAPER PIN',         'SKD11',     'Ø12x32',       1),
  ('a0000000-0001-0001-0001-000000000001', 30, 'A030', 'HANDLE KNOB',       'SS400',     'Ø20x26',       1),
  ('a0000000-0001-0001-0001-000000000001', 31, 'A031', 'BLOCK',             'S50C',      '34x50x77',     1),
  ('a0000000-0001-0001-0001-000000000001', 32, 'A032', 'BRACKET',           'SS400',     '14x48x106',    1),
  ('a0000000-0001-0001-0001-000000000001', 33, 'A033', 'SMALL BLOCK',       'S50C',      '15x21x44',     1),
  ('a0000000-0001-0001-0001-000000000001', 34, 'A034', 'SUPPORT BLOCK',     'SS400',     '30x63x110',    1),
  ('a0000000-0001-0001-0001-000000000001', 35, 'A035', 'KNOB',              'SS400',     'Ø20x30',       1),
  ('a0000000-0001-0001-0001-000000000001', 36, 'A036', 'LOCATING BLOCK',    'SS400',     '36x52x75',     1),
  ('a0000000-0001-0001-0001-000000000001', 37, 'A037', 'FLAT PLATE',        'SKD11',     '5x20x36',      1),
  ('a0000000-0001-0001-0001-000000000001', 38, 'A038', 'BUSH',              'SKD11',     'Ø16x20',       1),
  ('a0000000-0001-0001-0001-000000000001', 39, 'A039', 'TAPER BUSH',        'SKD11',     'Ø10x32',       1),
  ('a0000000-0001-0001-0001-000000000001', 40, 'A040', 'BRACKET',           'SS400',     '31x40x78',     1),
  ('a0000000-0001-0001-0001-000000000001', 41, 'A041', 'BASE BLOCK',        'S50C',      '24x36x50',     1),
  ('a0000000-0001-0001-0001-000000000001', 42, 'A042', 'SIDE BLOCK',        'S50C',      '24x44x77',     1),
  ('a0000000-0001-0001-0001-000000000001', 43, 'A043', 'SUPPORT POST',      'SS400',     '30x47x92',     1),
  ('a0000000-0001-0001-0001-000000000001', 44, 'A044', 'STOPPER BLOCK',     'S50C',      '20x30x35',     2),
  ('a0000000-0001-0001-0001-000000000001', 45, 'A045', 'LATCH PLATE',       'S50C',      '37x13x70',     1),
  ('a0000000-0001-0001-0001-000000000001', 46, 'A046', 'HANDLE KNOB',       'SS400',     'Ø20x30',       2),
  ('a0000000-0001-0001-0001-000000000001', 47, 'A047', 'POST',              'SS400',     '30x47x100',    1),
  ('a0000000-0001-0001-0001-000000000001', 48, 'A048', 'CLAMP SLIDE',       'S50C',      '10x38x107',    1),
  ('a0000000-0001-0001-0001-000000000001', 49, 'A049', 'GO GAUGE (28.0/27.4)',   'SKD11', '5x30x45',    1),
  ('a0000000-0001-0001-0001-000000000001', 50, 'A050', 'NO-GO GAUGE (26.2/25.6)','SKD11', '5x28x45',   1),
  ('a0000000-0001-0001-0001-000000000001', 51, 'A051', 'TAPER GAUGE',       'SKD11',     '4x20x40',      1),
  ('a0000000-0001-0001-0001-000000000001', 52, 'A052', 'GO/NOGO PIN Ø8.0',  'SKD11',     'Ø12x80',       1),
  ('a0000000-0001-0001-0001-000000000001', 53, 'A053', 'GO/NOGO PIN Ø5.0',  'SKD11',     'Ø12x80',       1),
  ('a0000000-0001-0001-0001-000000000001', 54, 'A054', 'GO/NOGO PIN Ø20.3', 'SKD11',     'Ø21x100',      1),
  ('a0000000-0001-0001-0001-000000000001', 55, 'A055', 'GO/NOGO PIN Ø10.0', 'SKD11',     'Ø12x80',       1),
  ('a0000000-0001-0001-0001-000000000001', 56, 'A056', 'GO/NOGO PIN 6.8x11.8','SKD11',   'Ø14x80',       1),
  ('a0000000-0001-0001-0001-000000000001', 57, 'A057', 'GO/NOGO PIN Ø8.5',  'SKD11',     'Ø12x80',       1),
  ('a0000000-0001-0001-0001-000000000001', 58, 'A058', 'SHAFT',             'SS400',     'Ø14x80',       1),
  ('a0000000-0001-0001-0001-000000000001', 59, 'A059', 'SPRING PIN KRBSDP 3-60',   'STD', '—',          1),
  ('a0000000-0001-0001-0001-000000000001', 60, 'A060', 'SPRING PIN KRBSDP 3.5-60', 'STD', '—',          1),
  ('a0000000-0001-0001-0001-000000000001', 61, 'A061', 'EPOXY BASE',        'EPOXY GRAY','40x150x340',   1)
ON CONFLICT DO NOTHING;


-- ══════════════════════════════════════════════════════════════════
--  OPTIONAL: Supabase Storage Setup
--  Run in Supabase Dashboard → Storage → New Bucket
--  Bucket name: "parts-images"  (Public)
--
--  Upload part images as: A001.jpg, A002.jpg, ... A061.jpg
--  Then update image_url column:
--
--  UPDATE assembly_parts
--  SET image_url = 'https://rsprwdtbcfagieduwkon.supabase.co/storage/v1/object/public/parts-images/' || part_no || '.jpg'
--  WHERE job_id = 'a0000000-0001-0001-0001-000000000001';
-- ══════════════════════════════════════════════════════════════════


-- ══════════════════════════════════════════════════════════════════
--  USEFUL QUERIES
-- ══════════════════════════════════════════════════════════════════

-- View all parts with their current progress summary:
-- SELECT p.seq_no, p.part_name, p.material, p.mat_size,
--        COUNT(r.id) as steps_recorded,
--        COUNT(CASE WHEN r.status='done' THEN 1 END) as steps_done,
--        COUNT(CASE WHEN r.status='problem' THEN 1 END) as problems
-- FROM assembly_parts p
-- LEFT JOIN part_progress r ON r.part_id = p.id
-- WHERE p.job_id = 'a0000000-0001-0001-0001-000000000001'
-- GROUP BY p.id, p.seq_no, p.part_name, p.material, p.mat_size
-- ORDER BY p.seq_no;

-- Mark all STD (purchased) parts as 'na' for machining steps:
-- INSERT INTO part_progress (part_id, step, status)
-- SELECT p.id, unnest(ARRAY['saw','lathe','drill','ht']), 'na'
-- FROM assembly_parts p
-- WHERE p.job_id = 'a0000000-0001-0001-0001-000000000001'
-- AND p.material IN ('STD','EPOXY GRAY')
-- ON CONFLICT (part_id, step) DO UPDATE SET status = 'na';
