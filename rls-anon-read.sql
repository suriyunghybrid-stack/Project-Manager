-- ============================================================
-- RLS Policy: Allow anon key to SELECT all rows
-- Tables: projects, tasks, activities, team_members
-- Run this in: Supabase Dashboard > SQL Editor
-- ============================================================

-- 1. Enable RLS on all tables
ALTER TABLE projects      ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks         ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities    ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members  ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing read policies (ป้องกัน duplicate error)
DROP POLICY IF EXISTS "anon_read_projects"     ON projects;
DROP POLICY IF EXISTS "anon_read_tasks"        ON tasks;
DROP POLICY IF EXISTS "anon_read_activities"   ON activities;
DROP POLICY IF EXISTS "anon_read_team_members" ON team_members;

-- 3. Create SELECT policies for anon role
CREATE POLICY "anon_read_projects"
  ON projects FOR SELECT TO anon USING (true);

CREATE POLICY "anon_read_tasks"
  ON tasks FOR SELECT TO anon USING (true);

CREATE POLICY "anon_read_activities"
  ON activities FOR SELECT TO anon USING (true);

CREATE POLICY "anon_read_team_members"
  ON team_members FOR SELECT TO anon USING (true);
