const DEFAULTS = {
  supabaseUrl: '',
  supabaseAnonKey: '',
  deviceId: '',
  deviceSecret: '',
  itManagerEmail: '',
};

const form = document.getElementById('settings-form');
const statusBox = document.getElementById('status');

function updateStatus(message, isError = false) {
  statusBox.textContent = message;
  statusBox.classList.toggle('error', isError);
}

async function loadSettings() {
  const data = await chrome.storage.local.get(Object.keys(DEFAULTS));
  document.getElementById('supabase-url').value = data.supabaseUrl || '';
  document.getElementById('supabase-anon-key').value = data.supabaseAnonKey || '';
  document.getElementById('device-id').value = data.deviceId || '';
  document.getElementById('device-secret').value = data.deviceSecret || '';
  document.getElementById('it-manager-email').value = data.itManagerEmail || '';
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();

  const data = {
    supabaseUrl: document.getElementById('supabase-url').value.trim(),
    supabaseAnonKey: document.getElementById('supabase-anon-key').value.trim(),
    deviceId: document.getElementById('device-id').value.trim(),
    deviceSecret: document.getElementById('device-secret').value.trim(),
    itManagerEmail: document.getElementById('it-manager-email').value.trim(),
  };

  await chrome.storage.local.set(data);
  updateStatus('Saved. The extension will synchronize with the admin dashboard when it next refreshes policies.');
});

loadSettings().catch((error) => {
  updateStatus(error.message || 'Unable to load settings.', true);
});
