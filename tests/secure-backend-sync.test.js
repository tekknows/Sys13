const assert = require('node:assert/strict');

const { resolveSupabaseConfig, createSyncRequestPayload } = require('../backend/supabase-sync');

const config = resolveSupabaseConfig({
  SUPABASE_URL: 'https://example.supabase.co',
  SUPABASE_SERVICE_ROLE_KEY: 'service-role-secret-key',
  API_BASE_URL: 'http://localhost:3000',
});

assert.equal(config.url, 'https://example.supabase.co');
assert.equal(config.serviceRoleKey, 'service-role-secret-key');
assert.equal(config.apiBaseUrl, 'http://localhost:3000');

const payload = createSyncRequestPayload({
  employees: [{ id: 'emp-1', name: 'Alice' }],
  settings: { retentionDate: '2026-10-29' },
});

assert.equal(payload.employees[0].name, 'Alice');
assert.equal(payload.settings.retentionDate, '2026-10-29');

console.log('Secure backend sync checks passed.');
