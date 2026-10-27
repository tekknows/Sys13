# Centralized Website Blocking and Usage Analytics System

This project provides a browser-extension-based website control system for managed computers, together with a centralized web dashboard for administrators. It is designed for a VA or computer shop environment, where a single admin can manage blocking policies, schedules, device assignments, and analytics across registered devices.

## Architecture overview

This workspace contains four major parts:

- `extension/`: Chrome Manifest V3 browser extension that enforces blocking policies locally and records minimal usage metadata.
- `dashboard/`: static admin dashboard that lets an administrator view devices, policy assignments, scheduled blocking, and usage analytics.
- `supabase/`: SQL migrations and RLS policies for device records, policies, analytics, and audit trails.
- `docs/`: operational and security documentation, including Incognito management guidance and deployment notes.

Because the workspace started empty, the project has been scaffolded from scratch rather than modified from an existing codebase.

## Core features

- Centralized management of devices and policies from one dashboard
- Website blocklist with categorization and recurring schedules
- Device- and group-level policy assignments
- Chrome Manifest V3 enforcement using `declarativeNetRequest`
- Minimal usage data collection: domain, timestamp, visit duration, policy ID, blocking status, device ID
- Audit logs and policy versioning
- Supabase Auth and database RLS guidance for security
- Privacy controls and documentation for Incognito restrictions

## Local setup

1. Copy `.env.example` to a local file such as `.env.local` and fill in your Supabase values.
2. Start a local web server for the dashboard:

   ```bash
   python -m http.server 8000
   ```

3. Open the dashboard at `http://localhost:8000/dashboard/`.
4. Load the extension in Chrome by visiting `chrome://extensions`, enabling Developer mode, and selecting the `extension/` directory.
5. Configure the extension by entering the Supabase URL and anon key in the extension options page or via storage values.

## Prerequisites

- Chrome/Chromium browser with extension loading enabled
- Supabase project with Auth and Postgres enabled
- Optional: a managed Chrome environment for enterprise policy enforcement of Incognito restrictions

## Project structure

```text
.
├── README.md
├── .env.example
├── extension/
│   ├── manifest.json
│   ├── background.js
│   ├── options.html
│   ├── options.js
│   └── styles.css
├── dashboard/
│   ├── index.html
│   ├── app.js
│   └── styles.css
├── supabase/
│   ├── schema.sql
│   ├── rls.sql
│   └── seed.sql
├── docs/
│   ├── admin-guide.md
│   ├── deployment-guide.md
│   └── privacy-security-audit.md
├── tests/
│   └── test-cases.md
└── .gitignore
```

## Notes on browser capabilities

Some requirements only work when the browser or OS is centrally managed:

- Restricting Incognito mode is not something a normal extension can do on all environments. The implementation documents the supported enterprise path using Chrome policies such as `IncognitoModeAvailability`.
- Hiding Chrome's built-in extension controls is not supported. The code clearly explains that the standard Chrome Reload button and Developer mode are Chrome UI features, not extension-controlled ones.
- The extension is not tamper-proof on unmanaged devices. The project documents the limits and enterprise controls that can increase enforcement.

## Privacy notice

This extension does not capture or transmit login form contents, passwords, typing data, cookies, or page text. It records only domain-level analytics data needed to create website usage and enforcement reports.

## License

This project is intended as a demonstrator and education scaffold. Adapt the code and policies for your own deployment and legal review.
