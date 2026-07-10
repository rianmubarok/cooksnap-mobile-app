// ─── Edit Modal ───────────────────────────────────────────────────────────────
window.openEditModal = async (id, overrideCollection = null) => {
  try {
    const col = overrideCollection || state.collection;
    const record = await pb.collection(col).getOne(id);
    window.currentEditRecord = record;
    window.currentEditCollection = col; // Save for saveEditRecord
    editRecordId.value             = record.id;
    editCollectionName.textContent = col;
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
    const col = window.currentEditCollection || state.collection;
    
    if (col === 'ingredients' && window.currentEditRecord) {
      const oldName = (window.currentEditRecord.name || '').trim();
      const newName = (payload.name || '').trim();
      
      if (oldName !== newName) {
        const existingList = await pb.collection('ingredients').getFullList({ fields: 'id,name' });
        const duplicate = existingList.find(ing => ing.name.trim().toLowerCase() === newName.toLowerCase() && ing.id !== id);

        if (duplicate) {
           await updateRecipesIngredientName(oldName, duplicate.name);
           await pb.collection('ingredients').delete(id);
           showToast(`Bahan digabungkan dengan ${duplicate.name} dan dihapus`, 'success');
           closeEditModal();
           loadData();
        } else {
           await pb.collection('ingredients').update(id, payload);
           await updateRecipesIngredientName(oldName, newName);
           showToast('Data berhasil diperbarui dan resep disinkronkan', 'success');
           closeEditModal();
           loadData();
        }
        return;
      }
    }

    // Jika mengedit Kategori Bahan dan namanya berubah, sinkronkan ke semua bahan
    if (col === 'ingredient_categories' && window.currentEditRecord) {
      const oldName = (window.currentEditRecord.name || '').trim();
      const newName = (payload.name || '').trim();
      
      if (oldName && newName && oldName !== newName) {
         // Temukan semua bahan yang menggunakan kategori lama
         const existingIngredients = await pb.collection('ingredients').getFullList({ 
            filter: `category = '${oldName.replace(/'/g, "\\'")}'` 
         });
         
         let updatedIngCount = 0;
         for (const ing of existingIngredients) {
            await pb.collection('ingredients').update(ing.id, { category: newName });
            updatedIngCount++;
         }
         
         if (updatedIngCount > 0) {
            showToast(`Telah menyinkronkan kategori untuk ${updatedIngCount} bahan!`, 'info');
         }
      }
    }

    await pb.collection(col).update(id, payload);
    showToast('Data berhasil diperbarui', 'success');
    closeEditModal();
    
    if (col === 'ingredient_categories') {
      await loadIngredientCategories(); // reload categories dynamically
      setupFilterOptions();
    }
    
    loadData(); 
  } catch (err) {
    console.error(err);
    showToast('Gagal menyimpan perubahan: ' + err.message, 'error');
  } finally {
    btnSaveEdit.disabled  = false;
    btnSaveEdit.innerHTML = orig;
    feather.replace();
  }
};

async function updateRecipesIngredientName(oldName, newName) {
    if (!oldName || !newName) return;
    const recipes = await pb.collection('recipes').getFullList({ fields: 'id,ingredients' });
    let updatedCount = 0;
    for (const r of recipes) {
       if (Array.isArray(r.ingredients)) {
          let hasChanged = false;
          const newIngredients = r.ingredients.map(ing => {
             if (ing && ing.name && ing.name.trim() === oldName) {
                hasChanged = true;
                return { ...ing, name: newName };
             }
             return ing;
          });

          if (hasChanged) {
             await pb.collection('recipes').update(r.id, { ingredients: newIngredients });
             updatedCount++;
          }
       }
    }
    if (updatedCount > 0) {
       showToast(`Telah menyinkronkan ${updatedCount} resep!`, 'info');
    }
}

// ─── Ingredient Unit Options ──────────────────────────────────────────────────
const UNIT_OPTIONS = [
  'gram', 'kg', 'ml', 'liter', 'sdm', 'sdt', 'cangkir',
  'siung', 'buah', 'batang', 'lembar', 'butir', 'ikat', 'potong', 'slice',
  'sachet', 'bungkus', 'kaleng', 'botol',
  'secukupnya', 'sesuai selera',
];

function isSystemField(key) {
  return ['id', 'created', 'updated', 'collectionId', 'collectionName', 'expand'].includes(key);
}

// ─── Ingredient Repeater ──────────────────────────────────────────────────────

/**
 * Render ingredient repeater rows (name autocomplete + quantity + unit dropdown).
 * @param {HTMLElement} container  – the wrapper element
 * @param {Array}       rows       – array of {name, quantity, unit}
 */
function renderIngredientRepeater(container, rows) {
  container.innerHTML = '';
  if (window.ensureIngredientNamesLoaded) {
    window.ensureIngredientNamesLoaded();
  }

  const addRow = (ing = {}) => {
    const idx      = container.children.length;
    const idPrefix = `ing-row-${idx}`;

    const unitOpts = UNIT_OPTIONS
      .map(u => `<option value="${u}"></option>`)
      .join('');

    const row = document.createElement('div');
    row.className = 'ing-repeater-row flex items-center gap-2 mb-2';
    row.innerHTML = `
      <div class="flex-1 relative">
        <input
          type="text"
          id="${idPrefix}-name"
          value="${(ing.name ?? '').replace(/"/g, '&quot;')}"
          placeholder="Nama bahan..."
          autocomplete="off"
          class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-cookgreen-500 outline-none transition-all"
        >
        <ul id="${idPrefix}-suggestions"
            class="absolute z-50 left-0 right-0 bg-white border border-gray-200 rounded-xl shadow-lg mt-1 max-h-44 overflow-y-auto hidden text-sm"></ul>
      </div>
      <input
        type="number"
        id="${idPrefix}-qty"
        value="${ing.quantity ?? ''}"
        placeholder="Jml"
        min="0" step="any"
        class="w-20 px-2 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-cookgreen-500 outline-none transition-all text-center"
      >
      <input
        type="text"
        id="${idPrefix}-unit"
        list="${idPrefix}-unit-list"
        value="${(ing.unit ?? '').replace(/"/g, '&quot;')}"
        placeholder="Satuan..."
        class="w-36 px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-cookgreen-500 outline-none transition-all"
      >
      <datalist id="${idPrefix}-unit-list">
        ${unitOpts}
      </datalist>
      <button type="button" onclick="this.closest('.ing-repeater-row').remove()"
              class="text-red-400 hover:text-red-600 p-1 rounded-lg hover:bg-red-50 transition-all flex-shrink-0" title="Hapus baris">
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
      </button>
    `;

    container.appendChild(row);

    // ── Autocomplete wiring & unregistered highlight ──
    const nameInput = row.querySelector(`#${idPrefix}-name`);
    const sugList   = row.querySelector(`#${idPrefix}-suggestions`);

    const getSuggestions = () =>
      window._ingredientAllNames || window._ingredientMasterNames || [];

    const checkRegistrationStatus = () => {
      const val = nameInput.value.trim();
      if (!val) {
        nameInput.classList.remove('border-amber-400', 'bg-amber-50', 'text-amber-900', 'font-medium');
        nameInput.classList.add('border-gray-200', 'bg-white');
        nameInput.title = '';
        return;
      }
      const allKnown = getSuggestions();
      const isRegistered = allKnown.some(n => n.toLowerCase() === val.toLowerCase());
      if (!isRegistered) {
        nameInput.classList.remove('border-gray-200', 'bg-white');
        nameInput.classList.add('border-amber-400', 'bg-amber-50', 'text-amber-900', 'font-medium');
        nameInput.title = 'Bahan ini belum terdaftar di database utama';
      } else {
        nameInput.classList.remove('border-amber-400', 'bg-amber-50', 'text-amber-900', 'font-medium');
        nameInput.classList.add('border-gray-200', 'bg-white');
        nameInput.title = 'Bahan terdaftar di database';
      }
    };

    const showSuggestions = () => {
      const q = nameInput.value.trim().toLowerCase();
      const allSuggestions = getSuggestions();
      const matches = q
        ? allSuggestions.filter(n => n.toLowerCase().includes(q)).slice(0, 20)
        : allSuggestions.slice(0, 20);

      if (!matches.length) {
        sugList.classList.add('hidden');
        return;
      }

      sugList.innerHTML = matches.map(n =>
        `<li class="px-3 py-2 cursor-pointer hover:bg-cookgreen-50 hover:text-cookgreen-900 transition-colors">${n}</li>`
      ).join('');
      sugList.classList.remove('hidden');

      sugList.querySelectorAll('li').forEach(li => {
        li.addEventListener('mousedown', e => {
          e.preventDefault();
          nameInput.value = li.textContent;
          checkRegistrationStatus();
          sugList.classList.add('hidden');
        });
      });
    };

    nameInput.addEventListener('input', () => {
      showSuggestions();
      checkRegistrationStatus();
    });

    nameInput.addEventListener('focus', () => {
      showSuggestions();
      checkRegistrationStatus();
    });

    nameInput.addEventListener('blur', () => {
      setTimeout(() => sugList.classList.add('hidden'), 150);
      checkRegistrationStatus();
    });

    nameInput.addEventListener('keydown', e => {
      if (e.key === 'Escape') sugList.classList.add('hidden');
    });

    setTimeout(checkRegistrationStatus, 50);
  };

  if (Array.isArray(rows) && rows.length > 0) {
    rows.forEach(r => addRow(r));
  } else {
    addRow(); // one empty row to start
  }

  // ── "Tambah Bahan" button ──
  const addBtn = document.createElement('button');
  addBtn.type = 'button';
  addBtn.className = 'mt-1 flex items-center gap-1.5 text-sm text-cookgreen-700 hover:text-cookgreen-900 font-medium px-3 py-1.5 rounded-lg hover:bg-cookgreen-50 transition-all';
  addBtn.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg> Tambah Bahan`;
  addBtn.addEventListener('click', () => addRow());
  container.appendChild(addBtn);
}

/**
 * Collect ingredients from the repeater rows.
 * @param {HTMLElement} container
 * @returns {Array} array of {name, quantity, unit}
 */
function collectIngredientRepeater(container) {
  const result = [];
  container.querySelectorAll('.ing-repeater-row').forEach((row, idx) => {
    const nameEl = row.querySelector(`[id$="-name"]`);
    const qtyEl  = row.querySelector(`[id$="-qty"]`);
    const unitEl = row.querySelector(`[id$="-unit"]`);
    if (!nameEl) return;

    const name = (nameEl.value || '').trim();
    if (!name) return; // skip empty rows

    const qty  = qtyEl?.value !== '' && qtyEl?.value != null ? Number(qtyEl.value) : null;
    const unit = (unitEl?.value || '').trim();

    result.push({ name, quantity: qty, unit });
  });
  return result;
}

window.ensureIngredientNamesLoaded = async function() {
  if (window._ingredientAllNames && window._ingredientAllNames.length > 0) {
    return window._ingredientAllNames;
  }
  try {
    const [masterItems, correctionItems] = await Promise.all([
      pb.collection('ingredients').getFullList({ fields: 'name', sort: 'name' }),
      pb.collection('ingredient_corrections').getFullList({ fields: 'original_name,corrected_name' }).catch(() => []),
    ]);

    const masterNames = masterItems.map(i => i.name).filter(Boolean);
    window._ingredientMasterNames = masterNames;

    const correctionNames = correctionItems.flatMap(c => [
      c.original_name,
      c.corrected_name,
    ]).filter(Boolean);

    window._ingredientAllNames = Array.from(new Set([...masterNames, ...correctionNames]))
      .sort((a, b) => a.localeCompare(b, 'id'));
    return window._ingredientAllNames;
  } catch (e) {
    window._ingredientMasterNames = [];
    window._ingredientAllNames = [];
    return [];
  }
};
window.ensureIngredientNamesLoaded();

window.renderDynamicEditFields = function(record) {
  editFieldsContainer.innerHTML = '';
  editFieldMeta = []; // assumes editFieldMeta is global

  Object.keys(record)
    .filter((key) => !isSystemField(key))
    .forEach((key) => {
      const value     = record[key];
      const isArray   = Array.isArray(value);
      // Detect ingredients field: array of objects with a 'name' property
      const isIngredientsField =
        window.currentEditCollection === 'recipes' &&
        key === 'ingredients' &&
        isArray &&
        (value.length === 0 || (typeof value[0] === 'object' && value[0] !== null && 'name' in value[0]));
      const isComplex = typeof value === 'object' && value !== null && !isIngredientsField;

      const wrapper   = document.createElement('div');
      wrapper.className = 'mb-4';

      const label = document.createElement('label');
      label.className   = 'block text-sm font-medium text-gray-700 mb-2 capitalize';
      label.textContent = key.replace(/_/g, ' ');

      let fieldEl;

      if (isIngredientsField) {
        // ── Ingredient Repeater ──
        fieldEl = document.createElement('div');
        fieldEl.id = `edit-field-${key}`;
        fieldEl.className = 'ingredient-repeater-container';

        // Column headers
        const header = document.createElement('div');
        header.className = 'flex items-center gap-2 mb-2 text-xs text-gray-500 font-medium px-1';
        header.innerHTML = `<span class="flex-1">Nama Bahan</span><span class="w-20 text-center">Jml</span><span class="w-36 text-center">Satuan</span><span class="w-6"></span>`;
        wrapper.appendChild(label);
        wrapper.appendChild(header);
        wrapper.appendChild(fieldEl);
        editFieldsContainer.appendChild(wrapper);
        editFieldMeta.push({ key, isComplex: false, isIngredients: true });
        renderIngredientRepeater(fieldEl, value);
        return; // skip default append below
      } else if (isComplex) {
        fieldEl          = document.createElement('textarea');
        fieldEl.rows     = 4;
        fieldEl.className = 'w-full p-3 border border-gray-200 rounded-xl font-mono text-sm bg-gray-50 focus:bg-white focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none transition-all';
        fieldEl.value    = JSON.stringify(value, null, 2);
      } else if (window.currentEditCollection === 'ingredients' && key === 'category') {
        fieldEl          = document.createElement('select');
        fieldEl.className = 'w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none transition-all bg-white';

        const categories = window.INGREDIENT_CATEGORIES || [];
        let optionsHtml = '';

        if (value && !categories.includes(value)) {
          optionsHtml += `<option value="${value}">${value}</option>`;
        }

        optionsHtml += categories.map(c => `<option value="${c}">${c}</option>`).join('');

        fieldEl.innerHTML = optionsHtml;
        fieldEl.value = value ?? '';
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
      editFieldMeta.push({ key, isComplex, isIngredients: false });
    });
}

window.collectDynamicEditPayload = function() {
  const payload = {};
  for (const field of editFieldMeta) {
    if (field.isIngredients) {
      const container = document.getElementById(`edit-field-${field.key}`);
      if (container) {
        payload[field.key] = collectIngredientRepeater(container);
      }
      continue;
    }

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
