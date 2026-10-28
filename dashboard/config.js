window.__APP_CONFIG__ = window.__APP_CONFIG__ || {};
window.__APP_CONFIG__.supabaseUrl = 'https://uwjsmxvdsdozzimukael.supabase.co';
window.__APP_CONFIG__.supabaseAnonKey = 'sb_publishable_BU7kYL8KZuFAa06SglHykw_6U1044Ud';

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
