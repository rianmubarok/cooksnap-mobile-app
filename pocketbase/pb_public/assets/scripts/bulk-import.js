// ─── Bulk Import ──────────────────────────────────────────────────────────────
let bulkModal, jsonInput, modalCollectionName, importProgressContainer;
let importProgressBar, importStats, importLog, btnStartImport;

// Initialize bulk modal DOM elements only when opening to ensure they exist
window.initBulkModalDOM = function() {
  if (!bulkModal) {
    bulkModal               = document.getElementById('bulk-modal');
    jsonInput               = document.getElementById('json-input');
    modalCollectionName     = document.getElementById('modal-collection-name');
    importProgressContainer = document.getElementById('import-progress-container');
    importProgressBar       = document.getElementById('import-progress-bar');
    importStats             = document.getElementById('import-stats');
    importLog               = document.getElementById('import-log');
    btnStartImport          = document.getElementById('btn-start-import');
  }
}

window.normalizeRecipePayload = function(rawItem) {
  const payload = { ...rawItem };
  const errors  = [];

  // Normalise difficulty (accept English aliases too)
  const difficultyMap = {
    easy: 'Mudah', medium: 'Sedang', hard: 'Sulit',
    mudah: 'Mudah', sedang: 'Sedang', sulit: 'Sulit',
  };
  const diffRaw        = `${payload.difficulty ?? ''}`.trim();
  const diffNormalized = difficultyMap[diffRaw.toLowerCase()] ?? diffRaw;
  if (!['Mudah', 'Sedang', 'Sulit'].includes(diffNormalized)) {
    errors.push(`difficulty tidak valid: "${diffRaw}"`);
  } else {
    payload.difficulty = diffNormalized;
  }

  // Normalise ingredients — supports both string items and object items.
  // Keeps quantity optional so "secukupnya" items are handled correctly.
  if (!Array.isArray(payload.ingredients)) {
    errors.push('ingredients harus array');
  } else {
    payload.ingredients = payload.ingredients
      .map((ing) => {
        if (typeof ing === 'string') {
          return { name: ing.trim(), unit: 'pcs' };
        }
        if (typeof ing === 'object' && ing !== null) {
          const item = {
            name: `${ing.name ?? ''}`.trim(),
            unit: `${ing.unit ?? 'pcs'}`.trim() || 'pcs',
          };
          if (ing.quantity != null && ing.quantity !== '') {
            item.quantity = Number(ing.quantity);
          }
          return item;
        }
        return null;
      })
      .filter(Boolean);
  }

  // Normalise steps
  if (!Array.isArray(payload.steps)) {
    errors.push('steps harus array');
  } else {
    payload.steps = payload.steps.map((s) => `${s}`.trim()).filter(Boolean);
  }

  // Normalise tags (optional)
  if (payload.tags != null) {
    if (!Array.isArray(payload.tags)) {
      errors.push('tags harus array');
    } else {
      payload.tags = payload.tags.map((t) => `${t}`.trim()).filter(Boolean);
    }
  }

  // Validate cooking_time
  if (payload.cooking_time != null) {
    const time = Number(payload.cooking_time);
    if (!Number.isInteger(time) || time <= 0) {
      errors.push('cooking_time harus angka bulat > 0');
    } else {
      payload.cooking_time = time;
    }
  }

  // Required field check
  const required = ['recipe_name', 'description', 'ingredients', 'steps', 'cooking_time', 'difficulty'];
  for (const key of required) {
    const v     = payload[key];
    const empty = v == null || (typeof v === 'string' && !v.trim()) || (Array.isArray(v) && v.length === 0);
    if (empty) errors.push(`${key} wajib diisi`);
  }

  return { payload, errors };
}

window.openBulkModal = () => {
  initBulkModalDOM();
  modalCollectionName.textContent = state.collection;
  jsonInput.value = '';
  importProgressContainer.classList.add('hidden');
  importLog.innerHTML = '';
  bulkModal.classList.remove('hidden');
  btnStartImport.disabled = false;
  btnStartImport.classList.remove('opacity-50', 'cursor-not-allowed', 'bg-emerald-600');
  btnStartImport.classList.add('bg-cookgreen-900');
  btnStartImport.innerHTML = `<i data-feather="play" class="w-4 h-4"></i> Jalankan Import`;
  feather.replace();
};

window.insertBulkExample = () => {
  initBulkModalDOM();
  // We use the global RECIPE_EXAMPLE_JSON / INGREDIENT_EXAMPLE_JSON from dashboard.js
  jsonInput.value = state.collection === 'recipes' ? RECIPE_EXAMPLE_JSON : INGREDIENT_EXAMPLE_JSON;
};

window.closeBulkModal = () => {
  initBulkModalDOM();
  if (state.isImporting) {
    if (!confirm('Import sedang berjalan! Yakin ingin menutup? (Proses di background mungkin tetap berjalan)')) return;
  }
  bulkModal.classList.add('hidden');
};

window.startBulkImport = async () => {
  initBulkModalDOM();
  const rawVal = jsonInput.value.trim();
  if (!rawVal) { showToast('JSON tidak boleh kosong', 'error'); return; }

  let dataArr = [];
  try {
    dataArr = JSON.parse(rawVal);
    if (!Array.isArray(dataArr)) throw new Error('Data utama harus berbentuk Array: []');
  } catch (e) {
    showToast('Format JSON tidak valid: ' + e.message, 'error');
    return;
  }

  if (dataArr.length === 0) { showToast('Array JSON kosong', 'error'); return; }
  if (!confirm(`Terdapat ${dataArr.length} data. Yakin ingin mengimpor sekarang?`)) return;

  state.isImporting = true;
  importProgressContainer.classList.remove('hidden');
  btnStartImport.disabled = true;
  btnStartImport.classList.add('opacity-50', 'cursor-not-allowed');
  jsonInput.disabled = true;

  let success = 0;
  let failed  = 0;
  importLog.innerHTML = '';

  const appendLog = (msg, isError = false) => {
    const div = document.createElement('div');
    div.textContent = msg;
    if (isError) div.classList.add('text-red-500');
    importLog.appendChild(div);
    importLog.scrollTop = importLog.scrollHeight;
  };

  appendLog(`Memulai import ${dataArr.length} data ke '${state.collection}'...`);

  for (let i = 0; i < dataArr.length; i++) {
    const item = dataArr[i];
    try {
      let payload = { ...item };

      if (state.collection === 'recipes') {
        const normalized = normalizeRecipePayload(item);
        if (normalized.errors.length > 0) throw new Error(normalized.errors.join('; '));
        payload = normalized.payload;
      }

      await pb.collection(state.collection).create(payload);
      success++;
      appendLog(`[${i + 1}] Sukses: ${item.recipe_name || item.name || 'Data'}`);
    } catch (err) {
      failed++;
      appendLog(`[${i + 1}] Gagal: ${err.message}`, true);
    }

    const percent = Math.round(((i + 1) / dataArr.length) * 100);
    importProgressBar.style.width = `${percent}%`;
    importStats.textContent       = `${i + 1}/${dataArr.length}`;
  }

  state.isImporting   = false;
  jsonInput.disabled  = false;
  appendLog(`SELESAI. Sukses: ${success}, Gagal: ${failed}`);
  showToast(`Import selesai. ${success} berhasil.`, success > 0 ? 'success' : 'error');

  state.page = 1;
  loadData();

  btnStartImport.innerHTML = `<i data-feather="check" class="w-4 h-4"></i> Selesai`;
  btnStartImport.classList.remove('bg-cookgreen-900');
  btnStartImport.classList.add('bg-cookgreen-800');
  feather.replace();
};
