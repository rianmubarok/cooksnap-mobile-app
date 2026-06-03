/**
 * CookSnap — Reset Password Page Logic
 * Extracted from the inline <script> in reset-password.html
 * Requires: utils.js (for showToast)
 */

// Replace static icons immediately
feather.replace();

document.addEventListener('DOMContentLoaded', async () => {
  const pb              = new PocketBase('/');
  const urlParams       = new URLSearchParams(window.location.search);
  const token           = urlParams.get('token');

  const formContainer   = document.getElementById('form-container');
  const statusContainer = document.getElementById('status-container');
  const titleEl         = document.getElementById('status-title');
  const msgEl           = document.getElementById('status-message');
  const iconContainer   = document.getElementById('icon-container');
  const iconEl          = document.getElementById('status-icon');

  if (!token) {
    statusContainer.classList.remove('hidden');
    titleEl.textContent      = 'Token Tidak Valid';
    msgEl.textContent        = 'Link reset kata sandi tidak lengkap atau tidak valid.';
    iconContainer.className  = 'bg-red-100 p-4 rounded-full text-red-600';
    iconEl.setAttribute('data-feather', 'x-circle');
    iconEl.classList.remove('animate-spin');
    feather.replace();
    return;
  }

  // Show the form
  formContainer.classList.remove('hidden');

  const form      = document.getElementById('reset-form');
  const submitBtn = document.getElementById('submit-btn');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const password        = document.getElementById('password').value;
    const passwordConfirm = document.getElementById('password-confirm').value;

    if (password !== passwordConfirm) {
      showToast('Kata sandi tidak cocok.', 'error');
      return;
    }

    if (password.length < 8) {
      showToast('Kata sandi minimal 8 karakter.', 'error');
      return;
    }

    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i data-feather="loader" class="w-5 h-5 animate-spin"></i> Menyimpan...';
    feather.replace();

    try {
      await pb.collection('users').confirmPasswordReset(token, password, passwordConfirm);

      formContainer.classList.add('hidden');
      statusContainer.classList.remove('hidden');

      titleEl.textContent      = 'Berhasil!';
      msgEl.textContent        = 'Kata sandi Anda telah berhasil diperbarui. Silakan buka kembali aplikasi CookSnap dan login dengan kata sandi baru.';
      iconContainer.className  = 'bg-cookgreen-100 p-4 rounded-full text-cookgreen-600';
      iconEl.setAttribute('data-feather', 'check-circle');
      iconEl.classList.remove('animate-spin');
      feather.replace();
    } catch (error) {
      console.error(error);
      showToast(error?.response?.message || 'Gagal mengubah kata sandi. Link mungkin kadaluarsa.', 'error');
      submitBtn.disabled = false;
      submitBtn.innerHTML = 'Simpan Kata Sandi';
    }
  });
});
