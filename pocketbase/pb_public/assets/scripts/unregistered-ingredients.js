let unregisteredModal;

function initUnregisteredModalDOM() {
  if (!unregisteredModal) {
    unregisteredModal = document.getElementById('unregistered-modal');
  }
}

window.openUnregisteredModal = async () => {
  initUnregisteredModalDOM();
  unregisteredModal.classList.remove('hidden');
  await scanUnregisteredIngredients();
};

window.closeUnregisteredModal = () => {
  initUnregisteredModalDOM();
  unregisteredModal.classList.add('hidden');
  // refresh the list underneath if we added something
  if (state.collection === 'ingredients') {
    loadData();
  }
};

window.scanUnregisteredIngredients = async () => {
  const listContainer = document.getElementById('unregistered-list');
  const emptyState = document.getElementById('unregistered-empty');
  const loadingState = document.getElementById('unregistered-loading');
  const countBadge = document.getElementById('unregistered-count');

  if (countBadge) countBadge.classList.add('hidden');
  listContainer.classList.add('hidden');
  emptyState.classList.add('hidden');
  loadingState.classList.remove('hidden');

  try {
    // 1. Fetch all master ingredients (just their names)
    const masterItems = await pb.collection('ingredients').getFullList({ fields: 'name' });
    const masterNames = new Set(masterItems.map(m => (m.name || '').trim().toLowerCase()));

    // 2. Fetch all recipes
    const recipes = await pb.collection('recipes').getFullList({ fields: 'id,recipe_name,ingredients' });
    
    // 3. Extract unique ingredient names from all recipes and their usages
    const recipeIngredientMap = new Map();
    recipes.forEach(r => {
      if (Array.isArray(r.ingredients)) {
        r.ingredients.forEach(ing => {
          if (ing && ing.name) {
            const n = ing.name.trim();
            if (!recipeIngredientMap.has(n)) {
              recipeIngredientMap.set(n, new Set());
            }
            if (r.recipe_name) {
              recipeIngredientMap.get(n).add(r.recipe_name);
            }
          }
        });
      }
    });

    // 4. Find the difference
    const unregistered = [];
    recipeIngredientMap.forEach((recipesSet, name) => {
      if (!masterNames.has(name.toLowerCase())) {
        unregistered.push({ name, usages: Array.from(recipesSet) });
      }
    });

    unregistered.sort((a, b) => {
      const diff = b.usages.length - a.usages.length;
      if (diff !== 0) return diff;
      return a.name.localeCompare(b.name);
    });

    loadingState.classList.add('hidden');

    if (unregistered.length === 0) {
      if (countBadge) {
        countBadge.textContent = '0';
        countBadge.classList.remove('hidden');
      }
      emptyState.classList.remove('hidden');
      return;
    }

    if (countBadge) {
      countBadge.textContent = unregistered.length.toString();
      countBadge.classList.remove('hidden');
    }

    // 5. Render list
    listContainer.innerHTML = '';
    const categoryOptions = (window.INGREDIENT_CATEGORIES || []).map(c => `<option value="${c}">${c}</option>`).join('');
    
    const masterIngredientOptions = masterItems
      .map(m => (m.name || '').trim())
      .filter(n => n)
      .sort()
      .map(n => `<option value="${n.replace(/"/g, '&quot;')}">${n}</option>`)
      .join('');

    unregistered.forEach(item => {
      const name = item.name;
      const usages = item.usages;
      
      const usagesHtml = usages.length > 0 
        ? `<div class="text-[11px] text-gray-500 mt-2 flex flex-wrap items-center gap-1.5 w-full">
             <i data-feather="book-open" class="w-3 h-3 text-gray-400"></i> 
             <span class="mr-1">Digunakan di:</span>
             ${usages.map(u => `<span class="bg-gray-200 text-gray-700 px-1.5 py-0.5 rounded leading-none">${u}</span>`).join('')}
           </div>` 
        : '';

      const idSafe = 'ing-' + btoa(name).replace(/[^a-zA-Z0-9]/g, '');
      const row = document.createElement('div');
      row.className = 'flex flex-col sm:flex-row sm:items-start gap-3 bg-gray-50 border border-gray-200 p-3 rounded-xl';
      row.id = idSafe;
      
      row.innerHTML = `
        <div class="flex-1 flex flex-col w-full mb-2 sm:mb-0 min-w-0">
          <input type="text" id="input-name-${idSafe}" value="${name.replace(/"/g, '&quot;')}" class="px-3 py-2 border border-gray-200 rounded-lg bg-white text-sm outline-none focus:ring-2 focus:ring-cookgreen-500 w-full sm:max-w-xs font-medium text-gray-900">
          ${usagesHtml}
        </div>
        <div class="flex flex-col gap-2 w-full sm:w-auto">
          <div class="flex items-center gap-2 justify-between sm:justify-end">
            <select id="sel-${idSafe}" class="px-3 py-2 border border-gray-200 rounded-lg bg-white text-sm outline-none focus:ring-2 focus:ring-cookgreen-500 w-full sm:w-40 flex-1">
              <option value="" disabled selected>Pilih Kategori...</option>
              ${categoryOptions}
            </select>
            <button onclick="registerMissingIngredient('${name.replace(/'/g, "\\'")}', '${idSafe}')" class="px-4 py-2 bg-cookgreen-900 text-white rounded-lg text-sm font-medium hover:bg-cookgreen-800 transition-colors whitespace-nowrap">
              Daftarkan
            </button>
          </div>
          <div class="flex items-center gap-2 justify-between sm:justify-end">
            <select id="map-sel-${idSafe}" class="px-3 py-2 border border-gray-200 rounded-lg bg-white text-sm outline-none focus:ring-2 focus:ring-amber-500 w-full sm:w-40 flex-1">
              <option value="" disabled selected>Koreksi ke Bahan...</option>
              ${masterIngredientOptions}
            </select>
            <button onclick="correctMissingIngredient('${name.replace(/'/g, "\\'")}', '${idSafe}')" class="px-4 py-2 bg-amber-500 text-white rounded-lg text-sm font-medium hover:bg-amber-600 transition-colors whitespace-nowrap">
              Koreksi
            </button>
          </div>
          <div class="flex items-center gap-2 justify-end mt-1">
            <button onclick="deleteUnregisteredIngredient('${name.replace(/'/g, "\\'")}', '${idSafe}')" class="px-4 py-2 text-red-500 bg-red-50 hover:bg-red-100 rounded-lg text-sm font-medium transition-colors w-full sm:w-auto flex items-center justify-center gap-1.5 whitespace-nowrap border border-red-100">
              <i data-feather="trash-2" class="w-3.5 h-3.5"></i> Hapus dari Resep
            </button>
          </div>
        </div>
      `;
      listContainer.appendChild(row);
    });

    listContainer.classList.remove('hidden');

  } catch (err) {
    console.error(err);
    showToast('Gagal memindai data: ' + err.message, 'error');
    loadingState.classList.add('hidden');
  }
};

window.registerMissingIngredient = async (originalName, rowIdSafe) => {
  const select = document.getElementById(`sel-${rowIdSafe}`);
  const inputNameElem = document.getElementById(`input-name-${rowIdSafe}`);
  const category = select.value;
  const correctedName = inputNameElem ? inputNameElem.value.trim() : originalName;

  if (!category) {
    showToast(`Pilih kategori untuk ${originalName} terlebih dahulu!`, 'error');
    return;
  }
  if (!correctedName) {
    showToast(`Nama bahan tidak boleh kosong!`, 'error');
    return;
  }

  try {
    showToast(`Mendaftarkan ${correctedName}...`, 'info');
    
    // 1. Create the new ingredient
    const payload = { name: correctedName, category };
    await pb.collection('ingredients').create(payload);
    
    // 2. If name was corrected, update recipes
    if (correctedName !== originalName) {
       showToast(`Memperbarui resep dari ${originalName} ke ${correctedName}...`, 'info');
       const recipes = await pb.collection('recipes').getFullList({ fields: 'id,ingredients' });
       let updatedCount = 0;
       for (const r of recipes) {
          if (Array.isArray(r.ingredients)) {
             let hasChanged = false;
             const newIngredients = r.ingredients.map(ing => {
                if (ing && ing.name && ing.name.trim() === originalName) {
                   hasChanged = true;
                   return { ...ing, name: correctedName };
                }
                return ing;
             });

             if (hasChanged) {
                await pb.collection('recipes').update(r.id, { ingredients: newIngredients });
                updatedCount++;
             }
          }
       }
       showToast(`${correctedName} berhasil didaftarkan dan ${updatedCount} resep diperbarui!`, 'success');
    } else {
       showToast(`${originalName} berhasil didaftarkan!`, 'success');
    }
    
    // Remove row from UI
    const row = document.getElementById(rowIdSafe);
    if (row) {
      row.remove();
    }
    
    // Check if list is empty now
    const listContainer = document.getElementById('unregistered-list');
    if (listContainer.children.length === 0) {
      listContainer.classList.add('hidden');
      document.getElementById('unregistered-empty').classList.remove('hidden');
    }

  } catch (err) {
    console.error(err);
    showToast(`Gagal mendaftarkan ${originalName}: ${err.message}`, 'error');
  }
};

window.correctMissingIngredient = async (unregisteredName, rowIdSafe) => {
  const select = document.getElementById(`map-sel-${rowIdSafe}`);
  const targetIngredientName = select.value;
  if (!targetIngredientName) {
    showToast(`Pilih bahan pengganti untuk ${unregisteredName} terlebih dahulu!`, 'error');
    return;
  }

  try {
    showToast(`Sedang mengkoreksi ${unregisteredName}...`, 'info');

    // Fetch all recipes to find usages
    const recipes = await pb.collection('recipes').getFullList({ fields: 'id,ingredients' });
    
    let updatedCount = 0;
    for (const r of recipes) {
       if (Array.isArray(r.ingredients)) {
          let hasChanged = false;
          const newIngredients = r.ingredients.map(ing => {
             if (ing && ing.name && ing.name.trim() === unregisteredName) {
                hasChanged = true;
                return { ...ing, name: targetIngredientName };
             }
             return ing;
          });

          if (hasChanged) {
             await pb.collection('recipes').update(r.id, { ingredients: newIngredients });
             updatedCount++;
          }
       }
    }

    showToast(`${unregisteredName} berhasil dikoreksi menjadi ${targetIngredientName} pada ${updatedCount} resep!`, 'success');
    
    // Remove row from UI
    const row = document.getElementById(rowIdSafe);
    if (row) {
      row.remove();
    }
    
    // Check if list is empty now
    const listContainer = document.getElementById('unregistered-list');
    if (listContainer.children.length === 0) {
      listContainer.classList.add('hidden');
      document.getElementById('unregistered-empty').classList.remove('hidden');
    }

  } catch (err) {
    console.error(err);
    showToast(`Gagal mengkoreksi: ${err.message}`, 'error');
  }
};

window.deleteUnregisteredIngredient = async (unregisteredName, rowIdSafe) => {
  if (!confirm(`Yakin ingin menghapus "${unregisteredName}" dari SEMUA resep yang menggunakannya?\nTindakan ini tidak dapat dibatalkan.`)) {
    return;
  }

  try {
    showToast(`Sedang menghapus ${unregisteredName} dari resep...`, 'info');

    // Fetch all recipes to find usages
    const recipes = await pb.collection('recipes').getFullList({ fields: 'id,ingredients' });
    
    let updatedCount = 0;
    for (const r of recipes) {
       if (Array.isArray(r.ingredients)) {
          const originalLength = r.ingredients.length;
          // Filter out the ingredient
          const newIngredients = r.ingredients.filter(ing => !(ing && ing.name && ing.name.trim() === unregisteredName));

          if (newIngredients.length !== originalLength) {
             await pb.collection('recipes').update(r.id, { ingredients: newIngredients });
             updatedCount++;
          }
       }
    }

    showToast(`${unregisteredName} berhasil dihapus dari ${updatedCount} resep!`, 'success');
    
    // Remove row from UI
    const row = document.getElementById(rowIdSafe);
    if (row) {
      row.remove();
    }
    
    // Update count badge
    const countBadge = document.getElementById('unregistered-count');
    if (countBadge) {
       let current = parseInt(countBadge.textContent || '0');
       if (current > 0) {
          countBadge.textContent = (current - 1).toString();
       }
    }

    // Check if list is empty now
    const listContainer = document.getElementById('unregistered-list');
    if (listContainer.children.length === 0) {
      listContainer.classList.add('hidden');
      document.getElementById('unregistered-empty').classList.remove('hidden');
    }

  } catch (err) {
    console.error(err);
    showToast(`Gagal menghapus: ${err.message}`, 'error');
  }
};
