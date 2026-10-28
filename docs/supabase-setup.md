# Supabase setup for MINDLOCK

## 1) Inspect the current app and database assumptions

The current project is not a React or Vite app. It is a static browser dashboard and a Chrome extension that read and write through raw REST calls and browser storage. The app already references the following data groups:

- settings
- employees
- devices
- replacements
- policies
- schedules
- usage
- analytics_snapshot
- notifications
- ticket_settings
- tickets
- user_credentials
- admin_access_assignments
- blocking_policies
- usage_events

The workspace does not currently contain live database schema files or a populated Supabase project, so the SQL below creates the missing structures only.

## 2) Create a new Supabase project

1. Open your Supabase project.
2. In the SQL editor, run the contents of [supabase/schema.sql](../supabase/schema.sql).
3. Run the contents of [supabase/rls.sql](../supabase/rls.sql).
4. Open Authentication > Users and create at least:
   - one Administrator account
   - one IT Staff account
   - one Employee account
5. Update each employee row with the matching `auth_user_id` so the RLS policies can resolve the user correctly.

## 3) Add the required environment variables

Create a local `.env` file (or use your deployment environment) and set:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_PUBLISHABLE_KEY=your_publishable_key
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your_publishable_key
```

Do not put `SUPABASE_SERVICE_ROLE_KEY` in browser code or extension storage. Keep it server-side only.

## 4) Configure the extension

Open the Chrome extension options page and enter:

- the Supabase URL
- the anonymous publishable key
- the device ID
- the device secret

This matches the current extension logic in [extension/background.js](../extension/background.js) and [extension/options.js](../extension/options.js).

## 5) Post-setup verification checklist

After running the SQL in Supabase, confirm that:

- the tables exist in the database explorer
- RLS is enabled on the protected tables
- `auth_users` and `employees.auth_user_id` are linked correctly
- a root admin can read all tables
- IT staff can read supported records but not elevate permissions
- employees can access only their own tickets and records
- blocked domains are written to `blocking_policies`
- usage rows are inserted into `usage_events`

## 6) Important security note

The project currently uses browser-side configuration and custom credential checks. That means the real end-to-end auth and authorization model should be migrated to Supabase Auth and explicit `auth.uid()` linkage before treating the system as production-grade.

The SQL above creates a secure baseline, but it still requires the app to authenticate with Supabase Auth and store each employee’s own `auth_user_id` to enforce least-privilege access properly.
