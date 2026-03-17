const toggle = document.getElementById("enabled-toggle");
const statusText = document.getElementById("status-text");

function updateStatus(enabled) {
  statusText.textContent = enabled ? "Enabled" : "Disabled";
}

async function loadState() {
  const { enabled = true } = await chrome.storage.sync.get("enabled");
  toggle.checked = enabled;
  updateStatus(enabled);
}

async function saveState() {
  const enabled = toggle.checked;
  await chrome.storage.sync.set({ enabled });
  updateStatus(enabled);
}

toggle.addEventListener("change", saveState);

loadState();
