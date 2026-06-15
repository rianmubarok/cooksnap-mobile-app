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

// ─── Auto-Koreksi dari Histori ────────────────────────────────────────────────
// FASE 1: Tampilkan preview daftar koreksi (original → corrected)
// FASE 2: Setelah user konfirmasi, apply ke semua resep

window.applyAllCorrections = async () => {
  const previewEl = document.getElementById('auto-correct-preview');
  const progressEl = document.getElementById('auto-correct-progress');

  // Jika preview sedang ditampilkan, toggle tutup
  if (previewEl && !previewEl.classList.contains('hidden')) {
    previewEl.classList.add('hidden');
    return;
  }

  const btn = document.getElementById('btn-auto-correct');
  btn.disabled = true;
  btn.innerHTML = `<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div> Memuat...`;

  try {
    const allCorrections = await pb.collection('ingredient_corrections').getFullList({ sort: 'original_name' });
    const validCorrections = allCorrections.filter(c => c.corrected_name && c.corrected_name.trim() !== '');
    const blacklist = allCorrections.filter(c => !c.corrected_name || c.corrected_name.trim() === '');

    // Render tabel preview
    const tableRows = validCorrections.map((c, i) => `
      <tr class="${i % 2 === 0 ? 'bg-white' : 'bg-indigo-50/30'}">
        <td class="px-3 py-1.5 text-xs text-gray-500 font-mono w-8">${i + 1}</td>
        <td class="px-3 py-1.5 text-xs text-gray-700 font-medium">${c.original_name}</td>
        <td class="px-2 py-1.5 text-gray-400 text-center">→</td>
        <td class="px-3 py-1.5 text-xs text-indigo-700 font-medium">${c.corrected_name}</td>
        <td class="px-3 py-1.5 text-center">
          <button onclick="deleteCorrection('${c.id}')" class="text-red-400 hover:text-red-600 transition-colors" title="Hapus entri koreksi ini">
            <i data-feather="trash-2" class="w-3 h-3"></i>
          </button>
        </td>
      </tr>
    `).join('');

    const blacklistRows = blacklist.length > 0 ? `
      <div class="mt-2 text-xs text-gray-500 flex items-center gap-1.5">
        <i data-feather="slash" class="w-3 h-3 text-red-400"></i>
        <span>${blacklist.length} item blacklist (bukan bahan makanan): ${blacklist.map(b => `<span class="bg-red-50 text-red-600 px-1.5 py-0.5 rounded">${b.original_name}</span>`).join(' ')}</span>
      </div>
    ` : '';

    previewEl.innerHTML = `
      <div class="bg-indigo-50 border border-indigo-100 rounded-xl p-4">
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <i data-feather="list" class="w-4 h-4 text-indigo-600"></i>
            <span class="text-sm font-medium text-indigo-800">${validCorrections.length} koreksi siap diterapkan</span>
          </div>
          <button onclick="executeAllCorrections()" class="flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-medium rounded-lg transition-all">
            <i data-feather="check" class="w-3.5 h-3.5"></i>
            Terapkan Sekarang
          </button>
        </div>
        <div class="max-h-64 overflow-y-auto border border-indigo-100 rounded-lg bg-white">
          <table class="w-full">
            <thead class="bg-indigo-100 sticky top-0">
              <tr>
                <th class="px-3 py-2 text-left text-xs font-medium text-indigo-600 w-8">#</th>
                <th class="px-3 py-2 text-left text-xs font-medium text-indigo-600">Nama Asli</th>
                <th class="px-2 py-2 w-6"></th>
                <th class="px-3 py-2 text-left text-xs font-medium text-indigo-600">Dikoreksi Menjadi</th>
                <th class="px-3 py-2 w-8"></th>
              </tr>
            </thead>
            <tbody>${tableRows}</tbody>
          </table>
        </div>
        ${blacklistRows}
      </div>
    `;

    previewEl.classList.remove('hidden');
    feather.replace();

  } catch (err) {
    showToast('Gagal memuat daftar koreksi: ' + err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = `<i data-feather="zap" class="w-4 h-4"></i> Auto-Koreksi dari Histori`;
    feather.replace();
  }
};

// Hapus satu entri koreksi dari daftar
window.deleteCorrection = async (id) => {
  if (!confirm('Hapus entri koreksi ini dari histori?')) return;
  try {
    await pb.collection('ingredient_corrections').delete(id);
    showToast('Entri koreksi dihapus', 'success');
    // Refresh preview
    document.getElementById('auto-correct-preview').classList.add('hidden');
    await applyAllCorrections();
  } catch (err) {
    showToast('Gagal hapus: ' + err.message, 'error');
  }
};

// FASE 2: Eksekusi penerapan ke semua resep
window.executeAllCorrections = async () => {
  const btn        = document.getElementById('btn-auto-correct');
  const progressEl = document.getElementById('auto-correct-progress');
  const statusEl   = document.getElementById('auto-correct-status');
  const statsEl    = document.getElementById('auto-correct-stats');
  const barEl      = document.getElementById('auto-correct-bar');
  const logEl      = document.getElementById('auto-correct-log');

  // Tutup panel preview, tampilkan progress
  document.getElementById('auto-correct-preview').classList.add('hidden');

  // Disable tombol & tampilkan progress
  btn.disabled = true;
  btn.classList.add('opacity-60', 'cursor-not-allowed');
  progressEl.classList.remove('hidden');
  logEl.innerHTML = '';
  barEl.style.width = '0%';
  barEl.classList.remove('bg-green-500');
  barEl.classList.add('bg-indigo-600');

  const appendLog = (msg, color = 'text-indigo-700') => {
    const div = document.createElement('div');
    div.className = color;
    div.textContent = msg;
    logEl.appendChild(div);
    logEl.scrollTop = logEl.scrollHeight;
  };

  try {
    // 1. Ambil semua histori koreksi (skip blacklist: corrected_name kosong/null)
    statusEl.textContent = 'Memuat histori koreksi...';
    const allCorrections = await pb.collection('ingredient_corrections').getFullList();
    const validCorrections = allCorrections.filter(c => c.corrected_name && c.corrected_name.trim() !== '');

    if (validCorrections.length === 0) {
      appendLog('⚠️  Tidak ada histori koreksi yang valid.', 'text-amber-600');
      statusEl.textContent = 'Selesai — tidak ada koreksi.';
      return;
    }

    appendLog(`📋 ${validCorrections.length} koreksi ditemukan. Memuat resep...`);

    // 2. Ambil semua resep
    statusEl.textContent = 'Memuat semua resep...';
    const recipes = await pb.collection('recipes').getFullList({ fields: 'id,ingredients' });
    appendLog(`📖 ${recipes.length} resep dimuat.`);

    // 3. Buat lookup map: original_name (lowercase) → corrected_name
    const correctionMap = new Map();
    validCorrections.forEach(c => {
      correctionMap.set(c.original_name.trim().toLowerCase(), c.corrected_name.trim());
    });

    // 4. Proses setiap resep
    let totalRecipesUpdated = 0;
    let totalCorrectionsApplied = 0;

    for (let i = 0; i < recipes.length; i++) {
      const r = recipes[i];
      const percent = Math.round(((i + 1) / recipes.length) * 100);
      barEl.style.width = `${percent}%`;
      statsEl.textContent = `${i + 1}/${recipes.length} resep`;
      statusEl.textContent = 'Memproses resep...';

      if (!Array.isArray(r.ingredients)) continue;

      let hasChanged = false;
      let correctionsThisRecipe = 0;

      const newIngredients = r.ingredients.map(ing => {
        if (!ing || !ing.name) return ing;
        const key = ing.name.trim().toLowerCase();
        if (correctionMap.has(key)) {
          const corrected = correctionMap.get(key);
          if (corrected !== ing.name.trim()) {
            hasChanged = true;
            correctionsThisRecipe++;
            return { ...ing, name: corrected };
          }
        }
        return ing;
      });

      if (hasChanged) {
        await pb.collection('recipes').update(r.id, { ingredients: newIngredients });
        totalRecipesUpdated++;
        totalCorrectionsApplied += correctionsThisRecipe;
        appendLog(`✅ Resep #${i + 1}: ${correctionsThisRecipe} koreksi diterapkan`);
      }
    }

    // 5. Ringkasan
    const summaryMsg = `🎉 Selesai! ${totalCorrectionsApplied} koreksi diterapkan ke ${totalRecipesUpdated} resep.`;
    appendLog(summaryMsg, 'text-green-700 font-medium');
    statusEl.textContent = 'Selesai!';
    barEl.style.width = '100%';
    barEl.classList.remove('bg-indigo-600');
    barEl.classList.add('bg-green-500');

    showToast(summaryMsg, 'success');

    // Refresh list bahan tidak terdaftar setelah koreksi
    await scanUnregisteredIngredients();

  } catch (err) {
    console.error(err);
    appendLog(`❌ Error: ${err.message}`, 'text-red-600');
    statusEl.textContent = 'Gagal!';
    showToast('Gagal menerapkan koreksi: ' + err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.classList.remove('opacity-60', 'cursor-not-allowed');
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
    
    // 2.5 Fetch corrections history
    let correctionsHistory = [];
    try {
      correctionsHistory = await pb.collection('ingredient_corrections').getFullList();
    } catch (e) {
      console.warn("Failed to fetch ingredient_corrections", e);
    }
    
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
    
    const sortedMasterNames = masterItems
      .map(m => (m.name || '').trim())
      .filter(n => n)
      .sort();

    unregistered.forEach(item => {
      const name = item.name;
      const usages = item.usages;
      
      // Find recommendation
      let recommendedName = "";
      const nameLower = name.toLowerCase();
      
      const historyMatch = correctionsHistory.find(c => (c.original_name || '').toLowerCase() === nameLower);
      if (historyMatch && historyMatch.corrected_name) {
         recommendedName = historyMatch.corrected_name;
      } else {
         let bestDist = Infinity;
         let bestMatch = "";
         sortedMasterNames.forEach(mName => {
            const dist = typeof calculateLevenshteinDistance === 'function' ? calculateLevenshteinDistance(nameLower, mName.toLowerCase()) : Infinity;
            if (dist < bestDist) {
               bestDist = dist;
               bestMatch = mName;
            }
         });
         
         if (bestMatch && bestDist <= Math.max(2, Math.floor(name.length * 0.4))) {
            recommendedName = bestMatch;
         }
      }

      const masterIngredientOptions = sortedMasterNames
        .map(n => `<option value="${n.replace(/"/g, '&quot;')}" ${n === recommendedName ? 'selected' : ''}>${n}</option>`)
        .join('');
      
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
    
    // Save to ingredient_corrections history
    try {
       // Check if already exists
       const existingHistory = await pb.collection('ingredient_corrections').getFirstListItem(`original_name="${unregisteredName.replace(/"/g, '\\"')}"`);
       await pb.collection('ingredient_corrections').update(existingHistory.id, {
          corrected_name: targetIngredientName,
          correction_count: (existingHistory.correction_count || 1) + 1
       });
    } catch (e) {
       // Not exists, create new
       try {
          await pb.collection('ingredient_corrections').create({
             original_name: unregisteredName,
             corrected_name: targetIngredientName,
             correction_count: 1
          });
       } catch (createErr) {
          console.warn("Failed to create ingredient_corrections record", createErr);
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
