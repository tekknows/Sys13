create extension if not exists pgcrypto;

create table if not exists public.settings (
  id uuid primary key default gen_random_uuid(),
  admin_email text not null default 'admin@sys13.com',
  retention_date date not null default current_date,
  accent_color text not null default '#8e6a5e',
  ticket_retention_days integer not null default 3,
  disposal_retention_days integer not null default 30,
  updated_at timestamptz not null default now()
);

create table if not exists public.employees (
  id uuid primary key default gen_random_uuid(),
  employee_id text not null unique,
  name text not null,
  surname text,
  email text not null unique,
  department text,
  role text,
  account_role text not null default 'Employee',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_credentials (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references public.employees(id) on delete cascade,
  email text not null unique,
  password_hash text not null,
  role text not null default 'Employee' check (role in ('Administrator', 'IT Staff', 'Employee')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.admin_access_assignments (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references public.employees(id) on delete cascade,
  email text not null unique,
  full_name text,
  role text not null default 'Employee' check (role in ('Administrator', 'IT Staff', 'Employee')),
  assigned_by text not null default 'System Administrator',
  is_active boolean not null default true,
  granted_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.devices (
  id uuid primary key default gen_random_uuid(),
  user_name text,
  surname text,
  email text,
  employee_id text,
  laptop_id text,
  laptop_name text,
  brand text,
  specs text,
  purchased_at date,
  mac_address text,
  status text not null default 'available' check (status in ('available', 'working', 'taken', 'defective', 'disposal', 'offline')),
  last_sync timestamptz,
  policy_version integer not null default 0,
  is_registered boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.replacements (
  id uuid primary key default gen_random_uuid(),
  employee text not null,
  old_laptop_id text not null,
  new_laptop_id text,
  reason text,
  status text not null default 'Pending' check (status in ('Pending', 'Approved', 'Rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.policies (
  id uuid primary key default gen_random_uuid(),
  domain text not null,
  category text not null default 'custom',
  enabled boolean not null default true,
  scope text not null default 'all' check (scope in ('all', 'specific')),
  user_ids jsonb not null default '[]'::jsonb,
  schedule jsonb not null default '{"type":"daily","days":["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],"start":"08:00","end":"17:00"}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.schedules (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  days text[] not null default '{Mon,Tue,Wed,Thu,Fri,Sat,Sun}',
  start_time time not null default '08:00',
  end_time time not null default '17:00',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.usage (
  id uuid primary key default gen_random_uuid(),
  user_name text not null,
  laptop text not null,
  mb_used integer not null default 0,
  online_hours numeric(6,2) not null default 0,
  recorded_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.analytics_snapshot (
  id uuid primary key default gen_random_uuid(),
  daily jsonb not null default '[]'::jsonb,
  categories jsonb not null default '[]'::jsonb,
  weekly_usage jsonb not null default '[]'::jsonb,
  asset_status jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  action text not null,
  entity text not null,
  detail text not null,
  timestamp timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.ticket_settings (
  id uuid primary key default gen_random_uuid(),
  enabled boolean not null default true,
  default_status text not null default 'Open',
  default_priority text not null default 'Medium',
  ticket_id_format text not null default 'TKT-2026-0001',
  default_assignment text not null default 'IT Support',
  support_instructions text not null default 'Contact the IT support desk...',
  categories jsonb not null default '[{"id":"hardware","name":"Hardware","active":true},{"id":"software","name":"Software","active":true},{"id":"browser-extension","name":"Browser Extension","active":true},{"id":"website-blocking","name":"Website Blocking","active":true},{"id":"network","name":"Network / Internet","active":true},{"id":"other","name":"Other","active":true}]'::jsonb,
  priorities jsonb not null default '["Low","Medium","High","Critical"]'::jsonb,
  statuses jsonb not null default '[{"name":"Open","order":1,"allowedNext":["In Progress","Waiting for Employee","Closed"]},{"name":"In Progress","order":2,"allowedNext":["Waiting for Employee","Resolved","Closed"]},{"name":"Waiting for Employee","order":3,"allowedNext":["In Progress","Resolved","Closed"]},{"name":"Resolved","order":4,"allowedNext":["Closed","Reopened"]},{"name":"Closed","order":5,"allowedNext":["Reopened"]}]'::jsonb,
  message_retention_days integer not null default 30,
  history_retention_days integer not null default 90,
  resolved_ticket_retention_days integer not null default 3,
  keep_messages_indefinitely boolean not null default false,
  auto_cleanup_enabled boolean not null default true,
  last_cleanup_date timestamptz,
  next_scheduled_cleanup timestamptz,
  last_cleanup_execution_key text,
  cleanup_history jsonb not null default '[]'::jsonb,
  notifications jsonb not null default '{"newTicket":true,"highPriority":true,"newEmployeeMessage":true,"ticketAssigned":true,"statusChanged":true,"ticketResolved":true}'::jsonb,
  workflow jsonb not null default '{"defaultITStaff":"IT Support","allowEmployeeReopen":true,"allowEmployeeMessagesAfterClose":false,"allowITReopen":true,"requireResolutionNotes":false}'::jsonb,
  security jsonb not null default '{"adminOnlySettings":true,"restrictManagementByRole":true}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  employee text not null,
  email text not null,
  laptop_id text,
  category text,
  priority text not null default 'Medium',
  description text not null,
  status text not null default 'Open',
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  updated_at timestamptz not null default now(),
  messages jsonb not null default '[]'::jsonb
);

create table if not exists public.activity_log (
  id uuid primary key default gen_random_uuid(),
  action text not null,
  entity text not null,
  detail text not null,
  timestamp timestamptz not null default now()
);

create table if not exists public.changelog (
  id uuid primary key default gen_random_uuid(),
  version text not null,
  date date not null,
  title text not null,
  changes jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  claims jsonb;
begin
  begin
    claims := nullif(current_setting('request.jwt.claims', true), '')::jsonb;
  exception when invalid_text_representation or invalid_parameter_value then
    return false;
  end;

  return coalesce(lower(claims ->> 'role') = 'admin', false);
end;
$$;

create or replace function public.is_it_staff()
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  claims jsonb;
begin
  begin
    claims := nullif(current_setting('request.jwt.claims', true), '')::jsonb;
  exception when invalid_text_representation or invalid_parameter_value then
    return false;
  end;

  return coalesce(lower(replace(claims ->> 'role', ' ', '_')) in ('it_staff', 'it-staff'), false);
end;
$$;

create or replace function public.is_employee()
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  claims jsonb;
begin
  begin
    claims := nullif(current_setting('request.jwt.claims', true), '')::jsonb;
  exception when invalid_text_representation or invalid_parameter_value then
    return false;
  end;

  return coalesce(lower(claims ->> 'role') = 'employee', false);
end;
$$;

