-- QC Records table
create table if not exists public.qc_records (
  id         bigserial primary key,
  project_id bigint references public.projects(id) on delete cascade,
  part_name  text not null default '',
  drawing_no text default '',
  revision   text default '',
  inspect_date date default current_date,
  inspector  text default '',
  equipment  text[] default '{}',
  dimensions jsonb default '[]',
  result     text default 'PASS',
  notes      text default '',
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz default now()
);
alter table public.qc_records enable row level security;
create policy "Users can manage qc_records" on public.qc_records for all using (auth.uid() is not null);

-- Production stage column for tasks
alter table public.tasks add column if not exists production_stage text default 'backlog';
