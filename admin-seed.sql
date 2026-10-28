-- Restore the default administrator record and its access credentials.
-- Admin login: admin@sys13.com
-- Password hash: SHA-256 of admin123

insert into public.settings (admin_email, retention_date, accent_color, ticket_retention_days, disposal_retention_days)
select 'admin@sys13.com', current_date, '#8e6a5e', 3, 30
where not exists (
  select 1 from public.settings where admin_email = 'admin@sys13.com'
);

insert into public.employees (
  employee_id,
  name,
  surname,
  email,
  department,
  role,
  account_role
)
values (
  'ADMIN-001',
  'System',
  'Administrator',
  'admin@sys13.com',
  'Management',
  'Administrator',
  'Administrator'
)
on conflict (email) do update set
  employee_id = excluded.employee_id,
  name = excluded.name,
  surname = excluded.surname,
  department = excluded.department,
  role = excluded.role,
  account_role = excluded.account_role,
  updated_at = now();

insert into public.user_credentials (employee_id, email, password_hash, role, is_active)
select e.id, e.email, encode(digest('admin123', 'sha256'), 'hex'), 'Administrator', true
from public.employees e
where e.email = 'admin@sys13.com'
on conflict (email) do update set
  employee_id = excluded.employee_id,
  password_hash = excluded.password_hash,
  role = excluded.role,
  is_active = excluded.is_active,
  updated_at = now();

insert into public.admin_access_assignments (employee_id, email, full_name, role, assigned_by, is_active)
select e.id, e.email, concat(e.name, ' ', e.surname), 'Administrator', 'System Administrator', true
from public.employees e
where e.email = 'admin@sys13.com'
on conflict (email) do update set
  employee_id = excluded.employee_id,
  full_name = excluded.full_name,
  role = excluded.role,
  assigned_by = excluded.assigned_by,
  is_active = excluded.is_active,
  updated_at = now();

-- Example employee access record for admin interface access.
-- Replace the employee email below with the real person you want to grant access.
insert into public.admin_access_assignments (employee_id, email, full_name, role, assigned_by, is_active)
select e.id, e.email, concat(e.name, ' ', e.surname), 'IT Staff', 'System Administrator', true
from public.employees e
where e.email = 'employee@sys13.com'
on conflict (email) do update set
  employee_id = excluded.employee_id,
  full_name = excluded.full_name,
  role = excluded.role,
  assigned_by = excluded.assigned_by,
  is_active = excluded.is_active,
  updated_at = now();
