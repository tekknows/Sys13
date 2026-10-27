insert into public.groups (name, created_by)
values ('Front Desk', null), ('Students', null)
on conflict do nothing;

insert into public.blocklist_entries (domain, category, is_active)
values
  ('youtube.com', 'entertainment', true),
  ('facebook.com', 'social', true),
  ('steamcommunity.com', 'gaming', true)
on conflict (domain) do nothing;
