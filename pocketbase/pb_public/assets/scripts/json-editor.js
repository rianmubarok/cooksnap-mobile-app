let jsonEditorModal;
let jsonEditorTextarea;
let btnSaveJson;

document.addEventListener('DOMContentLoaded', () => {
  // Tunggu sejenak hingga komponen ter-inject oleh boot.js
  setTimeout(() => {
    jsonEditorModal = document.getElementById('json-editor-modal');
    jsonEditorTextarea = document.getElementById('json-editor-textarea');
    btnSaveJson = document.getElementById('btn-save-json');
  }, 500);
});

window.openJsonEditorModal = async () => {
  if (!jsonEditorModal) jsonEditorModal = document.getElementById('json-editor-modal');
  if (!jsonEditorTextarea) jsonEditorTextarea = document.getElementById('json-editor-textarea');
  
  const colNameEl = document.getElementById('json-editor-collection');
  if (colNameEl) colNameEl.textContent = state.collection;
  
  jsonEditorModal.classList.remove('hidden');
  jsonEditorTextarea.value = "Memuat data...";
  jsonEditorTextarea.disabled = true;
  
  try {
    const items = await pb.collection(state.collection).getFullList();
    // Bersihkan system fields
    const cleanedItems = items.map(item => {
      const { collectionId, collectionName, created, updated, expand, ...rest } = item;
      return rest;
    });
    let jsonStr = '';
    if (state.collection === 'ingredients') {
      const grouped = {};
      cleanedItems.forEach(item => {
        const cat = item.category || 'Lainnya';
        if (!grouped[cat]) grouped[cat] = [];
        if (item.name) grouped[cat].push(item.name);
      });
      // Urutkan abjad
      Object.keys(grouped).forEach(k => grouped[k].sort());
      jsonStr = JSON.stringify(grouped, null, 2);
    } else {
      jsonStr = JSON.stringify(cleanedItems, null, 2);
    }
    
    jsonEditorTextarea.value = jsonStr;
    jsonEditorTextarea.disabled = false;
  } catch (err) {
    console.error(err);
    jsonEditorTextarea.value = "Gagal memuat data.";
    showToast('Gagal memuat data JSON', 'error');
  }
};

window.closeJsonEditorModal = () => {
  if (jsonEditorModal) jsonEditorModal.classList.add('hidden');
};

window.saveJsonEditor = async () => {
  const rawJson = jsonEditorTextarea.value;
  let parsedData;
  try {
    if (state.collection === 'ingredients') {
      const rawObj = JSON.parse(rawJson);
      if (typeof rawObj !== 'object' || Array.isArray(rawObj)) {
        throw new Error('Untuk bahan, format harus berupa Object (Kategori: [Bahan...])');
      }
      parsedData = [];
      for (const [category, names] of Object.entries(rawObj)) {
        if (!Array.isArray(names)) throw new Error(`Kategori ${category} harus berisi Array nama bahan.`);
        names.forEach(name => {
          parsedData.push({ name: name.trim(), category: category });
        });
      }
    } else {
      parsedData = JSON.parse(rawJson);
      if (!Array.isArray(parsedData)) throw new Error('Data harus berupa Array []');
    }
  } catch (err) {
    showToast('Format JSON tidak valid: ' + err.message, 'error');
    return;
  }

  if (!btnSaveJson) btnSaveJson = document.getElementById('btn-save-json');
  const orig = btnSaveJson.innerHTML;
  btnSaveJson.innerHTML = `<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div> Menyimpan...`;
  btnSaveJson.disabled = true;

  try {
    const existingRecords = await pb.collection(state.collection).getFullList();
    let updatedCount = 0;
    let createdCount = 0;

    if (state.collection === 'ingredients') {
      const existingMapByName = new Map();
      existingRecords.forEach(r => existingMapByName.set(r.name.toLowerCase().trim(), r));

      for (const item of parsedData) {
        if (!item.name) continue;
        const existing = existingMapByName.get(item.name.toLowerCase());
        if (existing) {
          // Update jika kategori berubah
          if (existing.category !== item.category) {
            await pb.collection(state.collection).update(existing.id, { category: item.category });
            updatedCount++;
          }
        } else {
          // Create baru
          await pb.collection(state.collection).create(item);
          createdCount++;
        }
      }
    } else {
      // Logika normal untuk recipes
      const existingMap = new Map();
      existingRecords.forEach(r => existingMap.set(r.id, r));

      for (const item of parsedData) {
        if (item.id && existingMap.has(item.id)) {
          // Update
          const old = existingMap.get(item.id);
          let hasChanges = false;
          const payload = {};
          for (const key of Object.keys(item)) {
            if (key === 'id') continue;
            if (JSON.stringify(item[key]) !== JSON.stringify(old[key])) {
              hasChanges = true;
              payload[key] = item[key];
            }
          }
          if (hasChanges) {
            await pb.collection(state.collection).update(item.id, payload);
            updatedCount++;
          }
        } else {
          // Create
          const payload = { ...item };
          delete payload.id;
          await pb.collection(state.collection).create(payload);
          createdCount++;
        }
      }
    }

    showToast(`Berhasil! ${updatedCount} diupdate, ${createdCount} ditambahkan.`, 'success');
    closeJsonEditorModal();
    loadData();
  } catch (err) {
    console.error(err);
    showToast('Gagal menyimpan: ' + err.message, 'error');
  } finally {
    btnSaveJson.innerHTML = orig;
    btnSaveJson.disabled = false;
  }
};
