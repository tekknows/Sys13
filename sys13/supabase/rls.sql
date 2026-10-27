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
alter table public.activity_log enable row level security;
alter table public.changelog enable row level security;

create policy "settings are admin managed" on public.settings
for all using (public.is_admin()) with check (public.is_admin());

create policy "employees are admin managed" on public.employees
for all using (public.is_admin()) with check (public.is_admin());

create policy "devices are admin managed" on public.devices
for all using (public.is_admin()) with check (public.is_admin());

create policy "replacements are admin managed" on public.replacements
for all using (public.is_admin()) with check (public.is_admin());

create policy "policies are admin managed" on public.policies
for all using (public.is_admin()) with check (public.is_admin());

create policy "schedules are admin managed" on public.schedules
for all using (public.is_admin()) with check (public.is_admin());

create policy "usage is admin readable" on public.usage
for select using (public.is_admin());

create policy "usage records can be inserted by admin" on public.usage
for insert with check (public.is_admin());

create policy "analytics snapshot is admin managed" on public.analytics_snapshot
for all using (public.is_admin()) with check (public.is_admin());

create policy "notifications are admin managed" on public.notifications
for all using (public.is_admin()) with check (public.is_admin());

create policy "ticket settings are admin managed" on public.ticket_settings
for all using (public.is_admin()) with check (public.is_admin());

create policy "tickets are admin managed" on public.tickets
for all using (public.is_admin()) with check (public.is_admin());

create policy "activity log is admin managed" on public.activity_log
for all using (public.is_admin()) with check (public.is_admin());

create policy "changelog is admin readable" on public.changelog
for select using (public.is_admin());

create policy "changelog can be updated by admin" on public.changelog
for insert with check (public.is_admin());

create policy "changelog updates are admin managed" on public.changelog
for update using (public.is_admin()) with check (public.is_admin());
