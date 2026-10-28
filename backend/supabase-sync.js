function resolveSupabaseConfig(env = process.env) {
  const url = String(env.SUPABASE_URL || env.VITE_SUPABASE_URL || '').trim();
  const serviceRoleKey = String(env.SUPABASE_SERVICE_ROLE_KEY || env.SUPABASE_SERVICE_ROLE || '').trim();
  const apiBaseUrl = String(env.API_BASE_URL || env.VITE_API_BASE_URL || '/api/supabase-sync').trim();

  if (!url) {
    throw new Error('SUPABASE_URL is required.');
  }

  if (!serviceRoleKey) {
    throw new Error('SUPABASE_SERVICE_ROLE_KEY is required for secure backend writes.');
  }

  return {
    url,
    serviceRoleKey,
    apiBaseUrl,
  };
}

function normalizeRecords(value) {
  if (!value) return [];
  return Array.isArray(value) ? value.filter(Boolean) : [value].filter(Boolean);
}

function createSyncRequestPayload(input = {}) {
  const state = input && input.state ? input.state : input;

  return {
    settings: state.settings || {},
    employees: normalizeRecords(state.employees),
    devices: normalizeRecords(state.devices),
    replacements: normalizeRecords(state.replacements),
    policies: normalizeRecords(state.policies),
    schedules: normalizeRecords(state.schedules),
    usage: normalizeRecords(state.usage),
    analytics_snapshot: state.analytics || {},
    notifications: normalizeRecords(state.notifications),
    ticket_settings: state.ticketSettings || {},
    tickets: normalizeRecords(state.tickets),
    changelog: normalizeRecords(state.changelog),
  };
}

module.exports = {
  resolveSupabaseConfig,
  createSyncRequestPayload,
};
