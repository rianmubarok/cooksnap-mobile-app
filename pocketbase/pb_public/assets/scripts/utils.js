/**
 * CookSnap — Shared Utilities
 *
 * Used by: dashboard.html, reset-password.html
 * Load this BEFORE page-specific scripts.
 */

/**
 * Display a toast notification.
 * @param {string} message
 * @param {'success'|'error'|'info'} type
 */
function showToast(message, type = 'info') {
  const container = document.getElementById('toast-container');
  if (!container) return;

  const bgMap   = { success: 'bg-cookgreen-900', error: 'bg-red-500', info: 'bg-gray-800' };
  const iconMap = { success: 'check-circle',      error: 'alert-circle', info: 'info'     };

  const toast = document.createElement('div');
  toast.className = [
    'flex items-center gap-3 px-4 py-3 rounded-xl shadow-lg',
    'text-white font-medium animate-slide-up transition-all duration-300 transform',
    bgMap[type] ?? bgMap.info,
  ].join(' ');
  toast.innerHTML = `<i data-feather="${iconMap[type] ?? 'info'}" class="w-5 h-5"></i><span>${message}</span>`;

  container.appendChild(toast);
  if (window.feather) feather.replace();

  setTimeout(() => {
    toast.style.opacity   = '0';
    toast.style.transform = 'translateY(-10px)';
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}
