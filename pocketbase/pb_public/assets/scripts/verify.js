/**
 * CookSnap — Email Verification Page Logic
 * Extracted from the inline <script> in verify.html
 */

// Replace static icons immediately (spinner is visible on load)
feather.replace();

document.addEventListener('DOMContentLoaded', async () => {
  const pb         = new PocketBase('/');
  const urlParams  = new URLSearchParams(window.location.search);
  const token      = urlParams.get('token');

  const titleEl        = document.getElementById('status-title');
  const msgEl          = document.getElementById('status-message');
  const iconContainer  = document.getElementById('icon-container');
  const iconEl         = document.getElementById('status-icon');

  if (!token) {
    titleEl.textContent      = 'Token Tidak Valid';
    msgEl.textContent        = 'Link verifikasi tidak lengkap atau tidak valid.';
    iconContainer.className  = 'bg-red-100 p-4 rounded-full text-red-600';
    iconEl.setAttribute('data-feather', 'x-circle');
    iconEl.classList.remove('animate-spin');
    feather.replace();
    return;
  }

  try {
    await pb.collection('users').confirmVerification(token);

    titleEl.textContent     = 'Verifikasi Berhasil!';
    msgEl.textContent       = 'Akun Anda telah berhasil diverifikasi. Silakan klik tombol di bawah ini untuk kembali ke aplikasi.';
    iconContainer.className = 'bg-cookgreen-100 p-4 rounded-full text-cookgreen-600';
    iconEl.setAttribute('data-feather', 'check-circle');
    iconEl.classList.remove('animate-spin');

    // Swap "Kembali ke Beranda" with deep-link button
    const actionBtn = document.querySelector('a[href="/"]');
    if (actionBtn) {
      actionBtn.textContent = 'Buka Aplikasi CookSnap';
      actionBtn.href        = 'cooksnap://login';
      actionBtn.className   =
        'inline-block bg-cookgreen-500 text-white font-medium py-3 px-6 rounded-xl ' +
        'shadow-lg shadow-cookgreen-500/30 hover:bg-cookgreen-600 hover:-translate-y-1 transition-all';

      // Auto-redirect after 2 seconds
      setTimeout(() => { window.location.href = 'cooksnap://login'; }, 2000);
    }

    feather.replace();
  } catch (error) {
    console.error(error);
    titleEl.textContent     = 'Verifikasi Gagal';
    msgEl.textContent       = 'Link verifikasi mungkin sudah kadaluarsa atau tidak valid lagi.';
    iconContainer.className = 'bg-red-100 p-4 rounded-full text-red-600';
    iconEl.setAttribute('data-feather', 'alert-circle');
    iconEl.classList.remove('animate-spin');
    feather.replace();
  }
});
