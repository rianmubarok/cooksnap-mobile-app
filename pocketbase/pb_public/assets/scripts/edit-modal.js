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
      } else if (window.currentEditCollection === 'ingredients' && key === 'category') {
        fieldEl          = document.createElement('select');
        fieldEl.className = 'w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none transition-all bg-white';
        
        const categories = window.INGREDIENT_CATEGORIES || [];
        let optionsHtml = '';
        
        // Pastikan nilai saat ini ada dalam opsi
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
