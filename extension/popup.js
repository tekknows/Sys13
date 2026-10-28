const DEFAULT_EMAIL = 'it.support@company.com';
const SHARED_TICKETS_KEY = 'mindlock-shared-tickets';
const EXTENSION_VERSION = chrome.runtime.getManifest().version;

const form = document.getElementById('issue-popup-form');
const statusBox = document.getElementById('popup-status');
const issueThread = document.getElementById('issue-thread');
const ticketList = document.getElementById('issue-ticket-list');
const versionLabel = document.getElementById('extension-version');

if (versionLabel) {
  versionLabel.textContent = `v${EXTENSION_VERSION}`;
}

function setStatus(message, isError = false) {
  statusBox.textContent = message;
  statusBox.classList.toggle('error', isError);
}

function renderIssueThread(messages = []) {
  if (!issueThread) return;

  if (!messages.length) {
    issueThread.innerHTML = '<div class="thread-empty">No messages yet.</div>';
    return;
  }

  issueThread.innerHTML = messages.map((message) => `
    <div class="thread-message ${message.sender === 'admin' ? 'admin' : 'employee'}">
      <div class="thread-label">${message.sender === 'admin' ? 'Admin' : 'Employee'}</div>
      <div class="thread-text">${String(message.text || '').replace(/</g, '&lt;').replace(/>/g, '&gt;')}</div>
    </div>
  `).join('');
}

function renderIssueTicketList(reports = []) {
  if (!ticketList) return;

  if (!reports.length) {
    ticketList.innerHTML = '<div class="thread-empty">No recent tickets.</div>';
    return;
  }

  const retentionDays = 30;
  ticketList.innerHTML = reports.slice(0, 5).map((report) => {
    const createdAt = report?.createdAt ? new Date(report.createdAt).getTime() : null;
    const expired = createdAt && Date.now() - createdAt > retentionDays * 24 * 60 * 60 * 1000;
    return `
      <div class="ticket-list-item ${expired ? 'retention-expired' : ''}">
        <div class="ticket-list-item__header">
          <strong>${report.laptopId || 'Laptop not assigned'}</strong>
          <span>${report.priority || 'Medium'}</span>
        </div>
        <div class="ticket-list-item__meta">${report.category || 'General'} • ${expired ? 'Archived by retention' : 'Active'}</div>
        <div class="ticket-list-item__summary">${String(report.description || report.messages?.[0]?.text || 'No summary available').slice(0, 80)}</div>
      </div>
    `;
  }).join('');
}

function mergeTicketLists(primaryTickets = [], secondaryTickets = []) {
  const merged = [...(Array.isArray(primaryTickets) ? primaryTickets : []), ...(Array.isArray(secondaryTickets) ? secondaryTickets : [])];
  const ticketMap = new Map();

  merged.forEach((ticket) => {
    if (!ticket || !ticket.id) return;
    const existing = ticketMap.get(ticket.id) || {};
    ticketMap.set(ticket.id, {
      ...existing,
      ...ticket,
      messages: Array.isArray(ticket.messages) && ticket.messages.length
        ? ticket.messages
        : Array.isArray(existing.messages)
          ? existing.messages
          : [],
    });
  });

  return Array.from(ticketMap.values()).sort((a, b) => new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime());
}

async function loadSharedTickets() {
  const storageResult = await chrome.storage.local.get([SHARED_TICKETS_KEY, 'issueReports']);
  const sharedTickets = Array.isArray(storageResult[SHARED_TICKETS_KEY]) ? storageResult[SHARED_TICKETS_KEY] : [];
  const legacyReports = Array.isArray(storageResult.issueReports) ? storageResult.issueReports : [];

  try {
    const serialized = localStorage.getItem(SHARED_TICKETS_KEY);
    const localTickets = serialized ? JSON.parse(serialized) : [];
    return mergeTicketLists(sharedTickets, mergeTicketLists(legacyReports, localTickets));
  } catch (error) {
    return mergeTicketLists(sharedTickets, legacyReports);
  }
}

async function persistSharedTickets(tickets) {
  const normalized = (Array.isArray(tickets) ? tickets : []).map((ticket) => ({
    ...ticket,
    messages: Array.isArray(ticket.messages) ? ticket.messages : [],
    createdAt: ticket.createdAt || new Date().toISOString(),
  }));

  await chrome.storage.local.set({ [SHARED_TICKETS_KEY]: normalized });
  try {
    localStorage.setItem(SHARED_TICKETS_KEY, JSON.stringify(normalized));
  } catch (error) {
    // Ignore localStorage fallback failures in extension contexts.
  }

  return normalized;
}

async function loadIssueThread() {
  const reports = await loadSharedTickets();
  const latest = reports[0];
  renderIssueThread(latest && Array.isArray(latest.messages) ? latest.messages : []);
  renderIssueTicketList(reports);
}

async function getAdminEmail() {
  const data = await chrome.storage.local.get(['itManagerEmail']);
  return data.itManagerEmail || DEFAULT_EMAIL;
}

async function getAssignedDeviceContext() {
  const result = await chrome.storage.local.get(['deviceId', 'deviceContext', 'assignedDevice']);
  const deviceContext = result.deviceContext || result.assignedDevice || {};
  const deviceId = result.deviceId || deviceContext.deviceId || '';
  const employeeName = deviceContext.employeeName || 'Not assigned';
  const employeeEmail = deviceContext.employeeEmail || '';
  const laptopId = deviceContext.laptopId || deviceContext.deviceName || 'Not available';

  return {
    deviceId,
    employeeName,
    employeeEmail,
    laptopId,
  };
}

async function populateIssueContext() {
  const employeeInput = document.getElementById('issue-employee');
  const laptopInput = document.getElementById('issue-laptop');
  const deviceIdInput = document.getElementById('issue-device-id');
  const context = await getAssignedDeviceContext();

  if (employeeInput) {
    employeeInput.value = context.employeeName;
  }

  if (laptopInput) {
    laptopInput.value = context.laptopId;
  }

  if (deviceIdInput) {
    deviceIdInput.value = context.deviceId;
  }

  if (!context.deviceId || context.laptopId === 'Not available' || context.employeeName === 'Not assigned') {
    const submitButton = form?.querySelector('button[type="submit"]');
    if (submitButton) {
      submitButton.disabled = true;
      submitButton.title = 'This device is not assigned to a company laptop. Please contact the administrator.';
    }
  }
}

async function saveIssue(issue) {
  const result = await chrome.storage.local.get(['issueReports']);
  const reports = Array.isArray(result.issueReports) ? result.issueReports : [];
  const normalizedIssue = { ...issue, createdAt: new Date().toISOString() };
  reports.unshift(normalizedIssue);
  await chrome.storage.local.set({ issueReports: reports });

  const sharedTickets = await loadSharedTickets();
  const mergedTickets = mergeTicketLists([normalizedIssue], sharedTickets);
  await persistSharedTickets(mergedTickets);
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();

  const description = document.getElementById('issue-description').value.trim();
  const context = await getAssignedDeviceContext();

  if (!description) {
    setStatus('Please include the issue details before submitting.', true);
    return;
  }

  if (!context.deviceId || context.laptopId === 'Not available' || context.employeeName === 'Not assigned') {
    setStatus('No assigned laptop was found for this device. Please contact your administrator.', true);
    return;
  }

  const issue = {
    id: `issue-${Date.now()}`,
    deviceId: context.deviceId,
    employeeName: context.employeeName,
    employeeEmail: context.employeeEmail,
    laptopId: context.laptopId,
    category: document.getElementById('issue-category').value,
    priority: document.getElementById('issue-priority').value,
    description,
    messages: [{ sender: 'employee', text: description, createdAt: new Date().toISOString() }],
  };

  const adminEmail = await getAdminEmail();
  const subject = encodeURIComponent(`IT Support Request - ${issue.laptopId} - ${issue.priority}`);
  const body = encodeURIComponent(
    `Hello IT Manager,\n\n` +
    `Employee: ${issue.employeeName}\n` +
    `Email: ${issue.employeeEmail || 'Not provided'}\n` +
    `Laptop ID: ${issue.laptopId}\n` +
    `Device ID: ${issue.deviceId}\n` +
    `Category: ${issue.category}\n` +
    `Priority: ${issue.priority}\n\n` +
    `Issue description:\n${issue.description}\n\n` +
    `Please review and update the ticket status.`
  );

  await saveIssue(issue);
  renderIssueThread(issue.messages);
  setStatus('Ticket saved and email opened.');
  window.location.href = `mailto:${adminEmail}?subject=${subject}&body=${body}`;
  form.reset();
  await populateIssueContext();
});

loadIssueThread();
populateIssueContext();
