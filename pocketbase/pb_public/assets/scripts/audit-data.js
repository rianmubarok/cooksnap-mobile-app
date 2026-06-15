let auditModal;

function initAuditModalDOM() {
  if (!auditModal) {
    auditModal = document.getElementById('audit-modal');
  }
}

window.openAuditModal = async () => {
  initAuditModalDOM();
  if (auditModal) auditModal.classList.remove('hidden');
  await runDataAudit();
};

window.closeAuditModal = () => {
  initAuditModalDOM();
  if (auditModal) auditModal.classList.add('hidden');
};

window.runDataAudit = async () => {
  const loadingState = document.getElementById('audit-loading');
  const contentState = document.getElementById('audit-content');
  const masterEmpty = document.getElementById('audit-master-empty');
  const masterList = document.getElementById('audit-master-list');
  const recipesEmpty = document.getElementById('audit-recipes-empty');
  const recipesList = document.getElementById('audit-recipes-list');

  contentState.classList.add('hidden');
  loadingState.classList.remove('hidden');

  try {
    // 1. Audit Master Ingredients
    const ingredients = await pb.collection('ingredients').getFullList({ sort: 'name' });
    const normalizedMap = new Map();
    const masterDuplicates = [];

    ingredients.forEach(ing => {
      // Normalize by lowercasing and trimming excessive spaces
      const normName = (ing.name || '').toLowerCase().trim().replace(/\s+/g, ' ');
      if (!normName) return;

      if (!normalizedMap.has(normName)) {
        normalizedMap.set(normName, []);
      }
      normalizedMap.get(normName).push(ing);
    });

    normalizedMap.forEach((items, normName) => {
      if (items.length > 1) {
        masterDuplicates.push(items);
      }
    });

    // 2. Audit Recipes
    const recipes = await pb.collection('recipes').getFullList({ fields: 'id,recipe_name,ingredients' });
    const recipeDuplicates = [];

    recipes.forEach(r => {
      if (Array.isArray(r.ingredients)) {
        const nameMap = new Map();
        
        r.ingredients.forEach(ing => {
          if (ing && ing.name) {
            const n = ing.name.trim();
            if (!nameMap.has(n)) {
              nameMap.set(n, []);
            }
            nameMap.get(n).push(ing);
          }
        });

        const duplicatesObj = {};
        let hasDuplicate = false;
        
        nameMap.forEach((ingList, n) => {
          if (ingList.length > 1) {
            duplicatesObj[n] = ingList;
            hasDuplicate = true;
          }
        });

        if (hasDuplicate) {
          recipeDuplicates.push({
            recipe: r,
            duplicates: duplicatesObj
          });
        }
      }
    });

    loadingState.classList.add('hidden');
    contentState.classList.remove('hidden');

    // Render Master Duplicates
    masterList.innerHTML = '';
    if (masterDuplicates.length === 0) {
      masterEmpty.classList.remove('hidden');
    } else {
      masterEmpty.classList.add('hidden');
      masterDuplicates.forEach(group => {
        // Assume the first one is the "keeper", the rest are duplicates
        const keeper = group[0];
        const duplicates = group.slice(1);

        duplicates.forEach(dup => {
          const row = document.createElement('div');
          row.className = 'flex flex-col sm:flex-row items-center justify-between p-4 bg-white border border-gray-200 rounded-xl gap-4';
          
          row.innerHTML = `
            <div class="flex flex-col flex-1">
              <span class="text-sm font-medium text-gray-900">
                <span class="text-red-500 line-through mr-2">"${dup.name}"</span>
                <i data-feather="arrow-right" class="w-4 h-4 inline text-gray-400 mx-1"></i>
                <span class="text-cookgreen-700 ml-2">"${keeper.name}"</span>
              </span>
              <span class="text-xs text-gray-500 mt-1">Sistem mendeteksi bahwa kedua bahan ini sebenarnya sama.</span>
            </div>
            <button onclick="mergeMasterIngredients('${dup.id}', '${keeper.id}', '${dup.name.replace(/'/g, "\\'")}', '${keeper.name.replace(/'/g, "\\'")}')" class="px-4 py-2 bg-orange-100 text-orange-700 hover:bg-orange-200 rounded-lg text-sm font-medium transition-colors whitespace-nowrap">
              Gabung & Hapus Duplikat
            </button>
          `;
          masterList.appendChild(row);
        });
      });
    }

    // Render Recipe Duplicates
    recipesList.innerHTML = '';
    if (recipeDuplicates.length === 0) {
      recipesEmpty.classList.remove('hidden');
    } else {
      recipesEmpty.classList.add('hidden');
      recipeDuplicates.forEach(item => {
        const r = item.recipe;
        
        Object.entries(item.duplicates).forEach(([dupName, ingList], idxLoop) => {
          const container = document.createElement('div');
          container.className = 'flex flex-col p-4 bg-white border border-gray-200 rounded-xl gap-4';
          
          let detailsHtml = '<ul class="mt-2 text-sm text-gray-500 list-disc pl-5">';
          ingList.forEach((ing, idx) => {
             detailsHtml += `<li>Entri ${idx + 1}: ${ing.quantity || '-'} ${ing.unit || '-'}</li>`;
          });
          detailsHtml += '</ul>';

          const uniqueId = r.id + '-' + idxLoop;

          container.innerHTML = `
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
              <div class="flex flex-col flex-1">
                <span class="text-sm font-medium text-gray-900 mb-1">
                  Resep: <span class="text-blue-600">"${r.recipe_name}"</span>
                </span>
                <span class="text-xs text-gray-600">
                  Bahan <strong class="text-red-500">"${dupName}"</strong> disebut ${ingList.length} kali di dalam komposisi:
                </span>
                ${detailsHtml}
              </div>
              <button onclick="document.getElementById('form-${uniqueId}').classList.toggle('hidden')" class="px-4 py-2 bg-blue-50 text-blue-600 hover:bg-blue-100 border border-blue-200 rounded-lg text-sm font-medium transition-colors whitespace-nowrap self-start sm:self-auto">
                Selesaikan Gandaan
              </button>
            </div>
            
            <div id="form-${uniqueId}" class="hidden mt-3 pt-4 border-t border-gray-100 flex flex-col sm:flex-row gap-3 items-end bg-gray-50 p-4 rounded-xl">
              <div class="flex-1 w-full">
                <label class="block text-xs font-medium text-gray-700 mb-1">Kuantitas Akhir <span class="text-gray-400 font-normal">(Kosongkan jika tak pasti)</span></label>
                <input type="number" step="any" id="qty-${uniqueId}" class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none" placeholder="misal: 1.25">
              </div>
              <div class="flex-1 w-full">
                <label class="block text-xs font-medium text-gray-700 mb-1">Satuan Akhir <span class="text-gray-400 font-normal">(Wajib)</span></label>
                <input type="text" id="unit-${uniqueId}" class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none" placeholder="misal: sdt, secukupnya">
              </div>
              <div class="flex gap-2 w-full sm:w-auto">
                <button onclick="document.getElementById('form-${uniqueId}').classList.add('hidden')" class="px-4 py-2 bg-white text-gray-600 border border-gray-200 hover:bg-gray-50 rounded-lg text-sm font-medium transition-colors flex-1 sm:flex-none">
                  Batal
                </button>
                <button onclick="submitDuplicateResolution('${r.id}', '${dupName.replace(/'/g, "\\'")}', 'qty-${uniqueId}', 'unit-${uniqueId}')" class="px-4 py-2 bg-cookgreen-600 text-white hover:bg-cookgreen-700 border border-cookgreen-600 rounded-lg text-sm font-medium transition-colors flex-1 sm:flex-none">
                  Simpan
                </button>
              </div>
            </div>
          `;
          recipesList.appendChild(container);
        });
      });
    }

    if (window.feather) feather.replace();

  } catch (err) {
    console.error(err);
    showToast('Gagal menjalankan audit: ' + err.message, 'error');
    loadingState.classList.add('hidden');
  }
};

window.mergeMasterIngredients = async (idKehilangan, idDipertahankan, nameDibuang, nameDisimpan) => {
  if (!confirm(`Tindakan ini akan:\n1. Menghapus bahan "${nameDibuang}".\n2. Mengganti semua resep yang menggunakan "${nameDibuang}" menjadi "${nameDisimpan}".\n\nLanjutkan?`)) return;

  try {
    showToast(`Menggabungkan ${nameDibuang} ke ${nameDisimpan}...`, 'info');

    // 1. Update recipes
    const recipes = await pb.collection('recipes').getFullList({ fields: 'id,ingredients' });
    let updatedCount = 0;
    for (const r of recipes) {
      if (Array.isArray(r.ingredients)) {
        let hasChanged = false;
        const newIngredients = r.ingredients.map(ing => {
          if (ing && ing.name && ing.name.trim() === nameDibuang) {
            hasChanged = true;
            return { ...ing, name: nameDisimpan };
          }
          return ing;
        });

        if (hasChanged) {
          await pb.collection('recipes').update(r.id, { ingredients: newIngredients });
          updatedCount++;
        }
      }
    }

    // 2. Delete the duplicate ingredient
    await pb.collection('ingredients').delete(idKehilangan);

    showToast(`Berhasil digabung! ${updatedCount} resep diperbarui.`, 'success');
    
    // Refresh Audit
    runDataAudit();
    
    // If we are currently viewing ingredients, refresh the list behind the modal
    if (typeof loadData === 'function' && window.state && window.state.collection === 'ingredients') {
      loadData();
    }

  } catch (err) {
    console.error(err);
    showToast('Gagal menggabungkan: ' + err.message, 'error');
  }
};

window.submitDuplicateResolution = async (recipeId, duplicateName, qtyInputId, unitInputId) => {
  const qtyVal = document.getElementById(qtyInputId).value;
  const unitVal = document.getElementById(unitInputId).value;

  if (!unitVal.trim()) {
    showToast('Satuan tidak boleh kosong. Ketik "secukupnya" jika tidak pasti.', 'error');
    return;
  }

  try {
    showToast(`Menyatukan "${duplicateName}"...`, 'info');

    const recipe = await pb.collection('recipes').getOne(recipeId);
    if (!recipe || !Array.isArray(recipe.ingredients)) return;

    let seen = false;
    const newIngredients = [];

    for (const ing of recipe.ingredients) {
      if (ing && ing.name && ing.name.trim() === duplicateName) {
        if (!seen) {
          seen = true;
          newIngredients.push({
            ...ing,
            quantity: qtyVal ? Number(qtyVal) : null,
            unit: unitVal.trim()
          });
        } else {
          // Skip subsequent occurrences
        }
      } else {
        newIngredients.push(ing);
      }
    }

    await pb.collection('recipes').update(recipeId, { ingredients: newIngredients });
    
    showToast(`Berhasil menggabungkan entri ganda!`, 'success');
    runDataAudit();

  } catch (err) {
    console.error(err);
    showToast('Gagal menyatukan gandaan: ' + err.message, 'error');
  }
};
