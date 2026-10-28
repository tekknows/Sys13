insert into public.settings (
  admin_email,
  retention_date,
  accent_color,
  ticket_retention_days,
  disposal_retention_days
)
values
  ('admin@sys13.com', current_date, '#8e6a5e', 3, 30);

-- Seeded system admin account.
-- Email: admin@sys13.com
-- Password: admin123
-- Note: the app stores the runtime password hash in local storage on first run, not in this SQL schema.
insert into public.employees (
  employee_id,
  name,
  surname,
  email,
  department,
  role,
  account_role
)
values
  ('ADMIN-001', 'System', 'Administrator', 'admin@sys13.com', 'Management', 'Administrator', 'Administrator')
on conflict (email) do nothing;

insert into public.policies (
  domain,
  category,
  enabled,
  scope,
  user_ids,
  schedule
)
values
  (
    'youtube.com',
    'entertainment',
    true,
    'all',
    '[]'::jsonb,
    '{"type":"daily","days":["Mon","Tue","Wed","Thu","Fri"],"start":"09:00","end":"17:00"}'::jsonb
  ),
  (
    'facebook.com',
    'social',
    true,
    'all',
    '[]'::jsonb,
    '{"type":"daily","days":["Mon","Tue","Wed","Thu","Fri"],"start":"09:00","end":"17:00"}'::jsonb
  ),
  (
    'steamcommunity.com',
    'gaming',
    true,
    'all',
    '[]'::jsonb,
    '{"type":"daily","days":["Mon","Tue","Wed","Thu","Fri"],"start":"09:00","end":"17:00"}'::jsonb
  );

insert into public.schedules (name, days, start_time, end_time)
values
  ('Business Hours', ARRAY['Mon','Tue','Wed','Thu','Fri'], '09:00', '17:00'),
  ('Weekend Lock', ARRAY['Sat','Sun'], '00:00', '23:59');
