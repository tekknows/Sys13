window.__APP_CONFIG__ = window.__APP_CONFIG__ || {};
window.__APP_CONFIG__.supabaseUrl = 'https://osmkugikczvodaipasnh.supabase.co';
window.__APP_CONFIG__.supabaseAnonKey = 'sb_publishable_SEVnPTPAtpbFkkuBSGOsEQ_qEF1RdWn';

if (window.supabase && typeof window.supabase.createClient === 'function') {
  window.__APP_CONFIG__.supabaseClient = window.supabase.createClient(
    window.__APP_CONFIG__.supabaseUrl,
    window.__APP_CONFIG__.supabaseAnonKey,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    }
  );
}
