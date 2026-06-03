/**
 * CookSnap — Dashboard Bootloader
 * Memuat komponen HTML eksternal secara asinkron sebelum menginisialisasi dashboard logic.
 */

document.addEventListener('DOMContentLoaded', async () => {
  const components = [
    { id: 'component-login', url: 'assets/components/login-view.html' },
    { id: 'component-sidebar', url: 'assets/components/sidebar.html' },
    { id: 'component-bulk-modal', url: 'assets/components/bulk-modal.html' },
    { id: 'component-edit-modal', url: 'assets/components/edit-modal.html' },
    { id: 'component-unregistered-modal', url: 'assets/components/unregistered-modal.html' },
    { id: 'component-json-editor-modal', url: 'assets/components/json-editor-modal.html' }
  ];

  try {
    for (const comp of components) {
      const container = document.getElementById(comp.id);
      if (container) {
        const response = await fetch(comp.url);
        if (response.ok) {
          const html = await response.text();
          container.outerHTML = html;
        } else {
          console.error(`Gagal memuat komponen ${comp.url}: ${response.status}`);
        }
      }
    }
    
    // Setelah semua komponen berhasil dimuat dan disuntikkan ke DOM, inisialisasi dashboard
    if (window.initDashboard) {
      window.initDashboard();
    } else {
      console.error('initDashboard tidak ditemukan. Pastikan dashboard.js sudah dimuat.');
    }
  } catch (error) {
    console.error('Terjadi kesalahan saat memuat komponen:', error);
  }
});
