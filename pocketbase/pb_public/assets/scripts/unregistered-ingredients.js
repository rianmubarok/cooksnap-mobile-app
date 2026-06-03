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

  listContainer.classList.add('hidden');
  emptyState.classList.add('hidden');
  loadingState.classList.remove('hidden');

  try {
    // 1. Fetch all master ingredients (just their names)
    const masterItems = await pb.collection('ingredients').getFullList({ fields: 'name' });
    const masterNames = new Set(masterItems.map(m => (m.name || '').trim().toLowerCase()));

    // 2. Fetch all recipes
    const recipes = await pb.collection('recipes').getFullList({ fields: 'ingredients' });
    
    // 3. Extract unique ingredient names from all recipes
    const recipeIngredientNames = new Set();
    recipes.forEach(r => {
      if (Array.isArray(r.ingredients)) {
        r.ingredients.forEach(ing => {
          if (ing && ing.name) {
            recipeIngredientNames.add(ing.name.trim());
          }
        });
      }
    });

    // 4. Find the difference
    const unregistered = [];
    recipeIngredientNames.forEach(name => {
      if (!masterNames.has(name.toLowerCase())) {
        unregistered.push(name);
      }
    });

    unregistered.sort();

    loadingState.classList.add('hidden');

    if (unregistered.length === 0) {
      emptyState.classList.remove('hidden');
      return;
    }

    // 5. Render list
    listContainer.innerHTML = '';
    const categoryOptions = INGREDIENT_CATEGORIES.map(c => `<option value="${c}">${c}</option>`).join('');
    
    const masterIngredientOptions = masterItems
      .map(m => (m.name || '').trim())
      .filter(n => n)
      .sort()
      .map(n => `<option value="${n.replace(/"/g, '&quot;')}">${n}</option>`)
      .join('');

    unregistered.forEach(name => {
      const idSafe = 'ing-' + btoa(name).replace(/[^a-zA-Z0-9]/g, '');
      const row = document.createElement('div');
      row.className = 'flex flex-col sm:flex-row sm:items-center gap-3 bg-gray-50 border border-gray-200 p-3 rounded-xl';
      row.id = idSafe;
      
      row.innerHTML = `
        <div class="flex-1 font-medium text-gray-900 break-words mb-2 sm:mb-0">${name}</div>
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

window.registerMissingIngredient = async (name, rowIdSafe) => {
  const select = document.getElementById(`sel-${rowIdSafe}`);
  const category = select.value;
  if (!category) {
    showToast(`Pilih kategori untuk ${name} terlebih dahulu!`, 'error');
    return;
  }

  try {
    const payload = { name, category };
    await pb.collection('ingredients').create(payload);
    showToast(`${name} berhasil didaftarkan!`, 'success');
    
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
    showToast(`Gagal mendaftarkan ${name}: ${err.message}`, 'error');
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
