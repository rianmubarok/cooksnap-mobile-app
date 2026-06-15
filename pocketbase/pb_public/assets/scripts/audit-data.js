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
        const seen = new Set();
        const duplicates = new Set();
        
        r.ingredients.forEach(ing => {
          if (ing && ing.name) {
            const n = ing.name.trim();
            if (seen.has(n)) {
              duplicates.add(n);
            }
            seen.add(n);
          }
        });

        if (duplicates.size > 0) {
          recipeDuplicates.push({
            recipe: r,
            duplicateNames: Array.from(duplicates)
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
        
        item.duplicateNames.forEach(dupName => {
          const row = document.createElement('div');
          row.className = 'flex flex-col sm:flex-row items-center justify-between p-4 bg-white border border-gray-200 rounded-xl gap-4';
          
          row.innerHTML = `
            <div class="flex flex-col flex-1">
              <span class="text-sm font-medium text-gray-900 mb-1">
                Resep: <span class="text-blue-600">"${r.recipe_name}"</span>
              </span>
              <span class="text-xs text-gray-600">
                Bahan <strong class="text-red-500">"${dupName}"</strong> disebut lebih dari 1 kali di dalam komposisi.
              </span>
            </div>
            <button onclick="removeDuplicateFromRecipe('${r.id}', '${dupName.replace(/'/g, "\\'")}')" class="px-4 py-2 bg-blue-50 text-blue-600 hover:bg-blue-100 border border-blue-200 rounded-lg text-sm font-medium transition-colors whitespace-nowrap">
              Hapus Gandaan
            </button>
          `;
          recipesList.appendChild(row);
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

window.removeDuplicateFromRecipe = async (recipeId, duplicateName) => {
  try {
    showToast(`Menghapus gandaan "${duplicateName}"...`, 'info');

    const recipe = await pb.collection('recipes').getOne(recipeId);
    if (!recipe || !Array.isArray(recipe.ingredients)) return;

    let seen = false;
    const newIngredients = [];

    // Keep the first occurrence, remove subsequent ones
    for (const ing of recipe.ingredients) {
      if (ing && ing.name && ing.name.trim() === duplicateName) {
        if (!seen) {
          seen = true;
          newIngredients.push(ing);
        } else {
          // This is a duplicate occurrence, skip it (effectively deleting it)
        }
      } else {
        newIngredients.push(ing);
      }
    }

    await pb.collection('recipes').update(recipeId, { ingredients: newIngredients });
    
    showToast(`Berhasil menghapus gandaan dari resep!`, 'success');
    
    // Refresh Audit
    runDataAudit();

  } catch (err) {
    console.error(err);
    showToast('Gagal menghapus gandaan: ' + err.message, 'error');
  }
};
