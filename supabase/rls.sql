-- Row Level Security for MINDLOCK tables.
-- These policies assume Supabase Auth is used and employees.auth_user_id is linked to auth.users.id.

alter table public.settings enable row level security;
alter table public.employees enable row level security;
alter table public.devices enable row level security;
alter table public.replacements enable row level security;
alter table public.policies enable row level security;
alter table public.schedules enable row level security;
alter table public.usage enable row level security;
alter table public.analytics_snapshot enable row level security;
alter table public.notifications enable row level security;
alter table public.ticket_settings enable row level security;
alter table public.tickets enable row level security;
alter table public.ticket_messages enable row level security;
alter table public.user_credentials enable row level security;
alter table public.admin_access_assignments enable row level security;
alter table public.blocking_policies enable row level security;
alter table public.usage_events enable row level security;

create or replace function public.current_user_role()
returns text
language sql
stable
as $$
  select coalesce(
    (auth.jwt() ->> 'role'),
    (select role from public.user_credentials where email = (auth.jwt() ->> 'email') limit 1),
    'Employee'
  );
$$;

create or replace function public.is_admin_or_it()
returns boolean
language sql
stable
as $$
  select public.current_user_role() in ('Administrator', 'IT Staff');
$$;

create or replace function public.is_current_employee(employee_uuid uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.employees e
    where e.id = employee_uuid
      and e.auth_user_id = auth.uid()
  );
$$;

create policy "Admin read/write access to settings"
on public.settings
for all
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Employees can read their own record"
on public.employees
for select
using (
  auth.uid() = auth_user_id
  or public.is_admin_or_it()
  or email = coalesce(current_setting('request.jwt.claims', true)::json->>'email', '')
);

create policy "Admin and IT can manage employees"
on public.employees
for insert with check (public.is_admin_or_it());
create policy "Admin and IT can update employees"
on public.employees
for update
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Admin and IT can manage devices"
on public.devices
for all
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Employee can read assigned device"
on public.devices
for select
using (
  public.is_admin_or_it()
  or employee_id in (
    select id from public.employees where auth_user_id = auth.uid()
  )
);

create policy "Admin and IT can manage policies"
on public.policies
for all
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Admin and IT can manage schedules"
on public.schedules
for all
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Admin and IT can read usage"
on public.usage
for select using (public.is_admin_or_it());
create policy "Authenticated devices can insert usage records"
on public.usage
for insert with check (auth.role() = 'authenticated');

create policy "Admin and IT can manage analytics snapshots"
on public.analytics_snapshot
for all
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Users can read their own notifications"
on public.notifications
for select
using (
  auth.uid() = user_id
  or public.is_admin_or_it()
  or user_email = coalesce(current_setting('request.jwt.claims', true)::json->>'email', '')
);

create policy "Users can insert their own notifications"
on public.notifications
for insert
with check (auth.uid() = user_id or public.is_admin_or_it());

create policy "Admin and IT can manage ticket settings"
on public.ticket_settings
for all using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Employees can read their own tickets"
on public.tickets
for select
using (
  public.is_admin_or_it()
  or employee_id in (
    select id from public.employees where auth_user_id = auth.uid()
  )
  or reporter_email = coalesce(current_setting('request.jwt.claims', true)::json->>'email', '')
);

create policy "Employees can create their own tickets"
on public.tickets
for insert
with check (
  public.is_admin_or_it()
  or reporter_email = coalesce(current_setting('request.jwt.claims', true)::json->>'email', '')
);

create policy "Employees and admins can update tickets they own"
on public.tickets
for update
using (
  public.is_admin_or_it()
  or employee_id in (
    select id from public.employees where auth_user_id = auth.uid()
  )
  or reporter_email = coalesce(current_setting('request.jwt.claims', true)::json->>'email', '')
)
with check (
  public.is_admin_or_it()
  or employee_id in (
    select id from public.employees where auth_user_id = auth.uid()
  )
  or reporter_email = coalesce(current_setting('request.jwt.claims', true)::json->>'email', '')
);

create policy "Employees can read own ticket messages"
on public.ticket_messages
for select
using (
  public.is_admin_or_it()
  or ticket_id in (
    select id from public.tickets where employee_id in (
      select id from public.employees where auth_user_id = auth.uid()
    )
  )
);

create policy "Users can create ticket messages for their ticket"
on public.ticket_messages
for insert
with check (
  public.is_admin_or_it()
  or ticket_id in (
    select id from public.tickets where reporter_email = coalesce(current_setting('request.jwt.claims', true)::json->>'email', '')
  )
  or ticket_id in (
    select id from public.tickets where employee_id in (
      select id from public.employees where auth_user_id = auth.uid()
    )
  )
);

create policy "Admin and IT can manage credentials"
on public.user_credentials
for all
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Admin and IT can manage access assignments"
on public.admin_access_assignments
for all
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Admin and IT can manage blocking policies"
on public.blocking_policies
for all
using (public.is_admin_or_it())
with check (public.is_admin_or_it());

create policy "Authenticated devices can insert usage events"
on public.usage_events
for insert
with check (auth.role() = 'authenticated');

create policy "Admin and IT can read usage events"
on public.usage_events
for select using (public.is_admin_or_it());
