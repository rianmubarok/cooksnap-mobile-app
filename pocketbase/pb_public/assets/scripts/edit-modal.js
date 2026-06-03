// ─── Edit Modal ───────────────────────────────────────────────────────────────
window.openEditModal = async (id) => {
  try {
    const record = await pb.collection(state.collection).getOne(id);
    editRecordId.value             = record.id;
    editCollectionName.textContent = state.collection;
    renderDynamicEditFields(record);
    editModal.classList.remove('hidden');
    feather.replace();
  } catch (err) {
    console.error(err);
    showToast('Gagal memuat data untuk edit', 'error');
  }
};

window.closeEditModal = () => { editModal.classList.add('hidden'); };

window.saveEditRecord = async () => {
  const id = editRecordId.value;
  if (!id) return;

  const orig         = btnSaveEdit.innerHTML;
  btnSaveEdit.disabled  = true;
  btnSaveEdit.innerHTML = `<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div> Menyimpan...`;

  try {
    const payload = collectDynamicEditPayload();
    await pb.collection(state.collection).update(id, payload);
    showToast('Data berhasil diperbarui', 'success');
    closeEditModal();
    loadData(); // assumes loadData is available globally
  } catch (err) {
    console.error(err);
    showToast('Gagal menyimpan perubahan: ' + err.message, 'error');
  } finally {
    btnSaveEdit.disabled  = false;
    btnSaveEdit.innerHTML = orig;
    feather.replace();
  }
};

function isSystemField(key) {
  return ['id', 'created', 'updated', 'collectionId', 'collectionName', 'expand'].includes(key);
}

window.renderDynamicEditFields = function(record) {
  editFieldsContainer.innerHTML = '';
  editFieldMeta = []; // assumes editFieldMeta is global

  Object.keys(record)
    .filter((key) => !isSystemField(key))
    .forEach((key) => {
      const value     = record[key];
      const isComplex = typeof value === 'object' && value !== null;
      const wrapper   = document.createElement('div');
      wrapper.className = 'mb-4';

      const label = document.createElement('label');
      label.className   = 'block text-sm font-medium text-gray-700 mb-2 capitalize';
      label.textContent = key.replace(/_/g, ' ');

      let fieldEl;
      if (isComplex) {
        fieldEl          = document.createElement('textarea');
        fieldEl.rows     = 4;
        fieldEl.className = 'w-full p-3 border border-gray-200 rounded-xl font-mono text-sm bg-gray-50 focus:bg-white focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none transition-all';
        fieldEl.value    = JSON.stringify(value, null, 2);
      } else {
        fieldEl          = document.createElement('input');
        fieldEl.type     = 'text';
        fieldEl.className = 'w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none transition-all';
        fieldEl.value    = value ?? '';
      }

      fieldEl.id = `edit-field-${key}`;
      wrapper.appendChild(label);
      wrapper.appendChild(fieldEl);
      editFieldsContainer.appendChild(wrapper);
      editFieldMeta.push({ key, isComplex });
    });
}

window.collectDynamicEditPayload = function() {
  const payload = {};
  for (const field of editFieldMeta) {
    const inputEl = document.getElementById(`edit-field-${field.key}`);
    if (!inputEl) continue;
    const rawValue = inputEl.value;

    if (field.isComplex) {
      if (!rawValue.trim()) { payload[field.key] = null; continue; }
      try {
        payload[field.key] = JSON.parse(rawValue);
      } catch {
        throw new Error(`Field "${field.key}" harus berupa JSON valid`);
      }
    } else {
      payload[field.key] = rawValue;
    }
  }
  return payload;
}
