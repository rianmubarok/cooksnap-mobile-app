// ─── Settings ─────────────────────────────────────────────────────────────────
window.loadSettingsView = async () => {
  try {
    const records = await pb.collection('app_config').getList(1, 1);
    let config;

    if (records.items.length === 0) {
      config = await pb.collection('app_config').create({
        latest_version:       '1.0.0',
        minimum_version:      '1.0.0',
        force_update:         false,
        update_message:       'Versi baru CookSnap tersedia untuk pengalaman yang lebih baik.',
        apk_url:              '',
        is_maintenance:       false,
        maintenance_message:  'Server sedang dalam perbaikan. Silakan coba lagi nanti.',
      });
    } else {
      config = records.items[0];
    }

    state.appConfigId = config.id;

    document.getElementById('cfg-latest').value     = config.latest_version        || '';
    document.getElementById('cfg-minimum').value    = config.minimum_version       || '';
    document.getElementById('cfg-force').checked    = config.force_update          || false;
    document.getElementById('cfg-updmsg').value     = config.update_message        || '';
    document.getElementById('cfg-apkurl').value     = config.apk_url               || '';
    document.getElementById('cfg-maint').checked    = config.is_maintenance        || false;
    document.getElementById('cfg-maintmsg').value   = config.maintenance_message   || '';

    setView('settings');
  } catch (err) {
    console.error(err);
    showToast('Gagal memuat pengaturan app', 'error');
    setView('empty');
  }
};

window.saveSettings = async () => {
  if (!state.appConfigId) return;

  const btn  = document.getElementById('btn-save-settings');
  const orig = btn.innerHTML;
  btn.disabled  = true;
  btn.innerHTML = `<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div> Menyimpan...`;

  const payload = {
    latest_version:      document.getElementById('cfg-latest').value,
    minimum_version:     document.getElementById('cfg-minimum').value,
    force_update:        document.getElementById('cfg-force').checked,
    update_message:      document.getElementById('cfg-updmsg').value,
    apk_url:             document.getElementById('cfg-apkurl').value,
    is_maintenance:      document.getElementById('cfg-maint').checked,
    maintenance_message: document.getElementById('cfg-maintmsg').value,
  };

  try {
    await pb.collection('app_config').update(state.appConfigId, payload);
    showToast('Pengaturan berhasil disimpan', 'success');
  } catch (err) {
    console.error(err);
    showToast('Gagal menyimpan pengaturan', 'error');
  } finally {
    btn.disabled  = false;
    btn.innerHTML = orig;
    feather.replace();
  }
};
