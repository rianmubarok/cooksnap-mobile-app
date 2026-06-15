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

/**
 * Calculates the Levenshtein distance between two strings.
 * @param {string} a 
 * @param {string} b 
 * @returns {number} Distance
 */
function calculateLevenshteinDistance(a, b) {
  if (a.length === 0) return b.length;
  if (b.length === 0) return a.length;

  const matrix = [];

  for (let i = 0; i <= b.length; i++) {
    matrix[i] = [i];
  }
  for (let j = 0; j <= a.length; j++) {
    matrix[0][j] = j;
  }

  for (let i = 1; i <= b.length; i++) {
    for (let j = 1; j <= a.length; j++) {
      if (b.charAt(i - 1) === a.charAt(j - 1)) {
        matrix[i][j] = matrix[i - 1][j - 1];
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1, // substitution
          Math.min(
            matrix[i][j - 1] + 1,   // insertion
            matrix[i - 1][j] + 1    // deletion
          )
        );
      }
    }
  }

  return matrix[b.length][a.length];
}

