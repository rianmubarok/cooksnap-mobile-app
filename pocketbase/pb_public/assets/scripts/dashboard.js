// ─── PocketBase Init ──────────────────────────────────────────────────────────
const pb = new PocketBase(window.location.origin);

// ─── Application State ────────────────────────────────────────────────────────
// All mutable state in one place — easier to reset, trace, and reason about.
const state = {
  collection:    'recipes',
  page:          1,
  perPage:       12,
  search:        '',
  primaryFilter: '',
  secondaryFilter: '',
  isImporting:   false,
  appConfigId:   null,
};

// ─── DOM References ───────────────────────────────────────────────────────────
let loginView, dashboardView, loginForm, logoutBtn, adminEmailDisplay, loadingState;
let emptyState, tableContainer, recipesGridContainer, recipesGrid;
let ingredientsCategoryContainer, ingredientsCategories, settingsContainer, pagination;
let pageInfo, btnPrev, btnNext, headerTitle, searchInput, filterPrimary, filterSecondary;
let perPageSelect, editModal, editCollectionName, editRecordId, editFieldsContainer, btnSaveEdit;
let searchContainer, perPageContainer;
let editFieldMeta = [];

// ─── View Management ──────────────────────────────────────────────────────────
// Single function replaces the five nearly-identical showXxx() functions.
const VIEWS_WITH_PAGINATION = new Set(['recipes']);

let CONTENT_VIEWS;

function setView(activeKey) {
  Object.entries(CONTENT_VIEWS).forEach(([key, el]) => {
    el?.classList.toggle('hidden', key !== activeKey);
  });
  tableContainer.classList.add('hidden');
  pagination.classList.toggle('hidden', !VIEWS_WITH_PAGINATION.has(activeKey));
}

// ─── Domain Constants ─────────────────────────────────────────────────────────
const DIFFICULTY_OPTIONS = ['Mudah', 'Sedang', 'Sulit'];

let INGREDIENT_CATEGORIES = [];
let CATEGORY_EMOJI_MAP = {};
let INGREDIENT_CATEGORIES_RECORDS = [];

async function loadIngredientCategories() {
  try {
    const records = await pb.collection('ingredient_categories').getFullList({ sort: 'order,name' });
    if (records.length === 0) {
      // Seed initial data
      const defaultCategories = [
        { name: 'Sumber Protein', icon: '🥩', order: 1 },
        { name: 'Seafood', icon: '🦞', order: 2 },
        { name: 'Sayuran', icon: '🥬', order: 3 },
        { name: 'Jamur', icon: '🍄', order: 4 },
        { name: 'Bumbu', icon: '🧄', order: 5 },
        { name: 'Bumbu Dasar', icon: '🧂', order: 6 },
        { name: 'Karbohidrat', icon: '🍚', order: 7 },
        { name: 'Kacang & Biji', icon: '🥜', order: 8 },
        { name: 'Susu & Olahan Susu', icon: '🥛', order: 9 },
        { name: 'Buah', icon: '🍎', order: 10 },
        { name: 'Tepung', icon: '🌾', order: 11 },
        { name: 'Lainnya', icon: '📦', order: 12 }
      ];
      for (const cat of defaultCategories) {
        await pb.collection('ingredient_categories').create(cat);
      }
      return await loadIngredientCategories(); // retry after seed
    }

    INGREDIENT_CATEGORIES_RECORDS = records;
    INGREDIENT_CATEGORIES = records.map(r => r.name);
    CATEGORY_EMOJI_MAP = {};
    records.forEach(r => {
      CATEGORY_EMOJI_MAP[r.name] = r.icon || '📦';
    });
  } catch (err) {
    console.error('Error loading ingredient categories:', err);
  }
}

// ─── Example JSON Templates ───────────────────────────────────────────────────
const RECIPE_EXAMPLE_JSON = `[
  {
    "recipe_name": "Nasi Goreng Kampung",
    "description": "Nasi goreng rumahan sederhana.",
    "image_url": "https://example.com/nasi-goreng.jpg",
    "ingredients": [
      { "name": "Nasi", "quantity": 2, "unit": "piring" },
      { "name": "Telur Ayam", "quantity": 2, "unit": "butir" },
      { "name": "Kecap Manis", "quantity": 2, "unit": "sdm" },
      { "name": "Garam", "unit": "secukupnya" }
    ],
    "steps": [
      "Tumis bumbu hingga harum.",
      "Masukkan nasi, aduk rata.",
      "Tambahkan kecap dan garam, angkat."
    ],
    "cooking_time": 20,
    "difficulty": "Mudah",
    "tags": ["Indonesia", "Cepat", "Mudah"],
    "source_url": "https://example.com/resep"
  }
]`;

const INGREDIENT_EXAMPLE_JSON = `[
  {
    "name": "Tomat",
    "category": "Sayuran"
  },
  {
    "name": "Bawang Putih",
    "category": "Bumbu"
  }
]`;

// ─── Bootstrap ────────────────────────────────────────────────────────────────
window.initDashboard = () => {
  // Initialize DOM references
  loginView                    = document.getElementById('login-view');
  dashboardView                = document.getElementById('dashboard-view');
  loginForm                    = document.getElementById('login-form');
  logoutBtn                    = document.getElementById('logout-btn');
  adminEmailDisplay            = document.getElementById('admin-email-display');
  loadingState                 = document.getElementById('loading-state');
  emptyState                   = document.getElementById('empty-state');
  tableContainer               = document.getElementById('table-container');
  recipesGridContainer         = document.getElementById('recipes-grid-container');
  recipesGrid                  = document.getElementById('recipes-grid');
  ingredientsCategoryContainer = document.getElementById('ingredients-category-container');
  ingredientsCategories        = document.getElementById('ingredients-categories');
  settingsContainer            = document.getElementById('settings-container');
  pagination                   = document.getElementById('pagination');
  pageInfo                     = document.getElementById('page-info');
  btnPrev                      = document.getElementById('btn-prev');
  btnNext                      = document.getElementById('btn-next');
  headerTitle                  = document.getElementById('header-title');
  searchInput                  = document.getElementById('search-input');
  filterPrimary                = document.getElementById('filter-primary');
  filterSecondary              = document.getElementById('filter-secondary');
  perPageSelect                = document.getElementById('per-page-select');
  editModal                    = document.getElementById('edit-modal');
  editCollectionName           = document.getElementById('edit-collection-name');
  editRecordId                 = document.getElementById('edit-record-id');
  editFieldsContainer          = document.getElementById('edit-fields-container');
  btnSaveEdit                  = document.getElementById('btn-save-edit');
  searchContainer              = document.getElementById('search-container');
  perPageContainer             = document.getElementById('per-page-container');

  CONTENT_VIEWS = {
    loading:     loadingState,
    empty:       emptyState,
    recipes:     recipesGridContainer,
    ingredients: ingredientsCategoryContainer,
    settings:    settingsContainer,
  };

  // Re-run feather icons now that DOM is fully populated
  feather.replace();

  checkAuth();
  setupFilterOptions();
  bindToolbarEvents();

  if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const email    = document.getElementById('login-email').value;
      const password = document.getElementById('login-password').value;
      const btn      = document.getElementById('login-btn');
      const orig     = btn.innerHTML;

      btn.innerHTML = `<div class="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div> Processing...`;
      btn.disabled  = true;

      try {
        await pb.collection('_superusers').authWithPassword(email, password);
        showToast('Login berhasil', 'success');
        checkAuth();
      } catch (err) {
        showToast('Login gagal: Email atau Password salah', 'error');
        console.error(err);
      } finally {
        btn.innerHTML = orig;
        btn.disabled  = false;
      }
    });
  }

  if (logoutBtn) {
    logoutBtn.addEventListener('click', () => {
      pb.authStore.clear();
      checkAuth();
      showToast('Berhasil logout', 'success');
    });
  }

  // Initial Tab Activation
  const initialTab = document.getElementById('tab-recipes');
  if (initialTab) initialTab.classList.add('bg-cookgreen-100', 'text-cookgreen-900');
};

// ─── Toolbar Event Bindings ───────────────────────────────────────────────────
function bindToolbarEvents() {
  searchInput.addEventListener('input', () => {
    state.search = searchInput.value.trim();
    state.page   = 1;
    loadData();
  });

  filterPrimary.addEventListener('change', () => {
    state.primaryFilter = filterPrimary.value;
    state.page          = 1;
    loadData();
  });

  filterSecondary.addEventListener('change', () => {
    state.secondaryFilter = filterSecondary.value;
    state.page            = 1;
    loadData();
  });

  perPageSelect.addEventListener('change', () => {
    state.perPage = Number(perPageSelect.value) || 12;
    state.page    = 1;
    loadData();
  });
}

// ─── Auth ─────────────────────────────────────────────────────────────────────
async function checkAuth() {
  if (pb.authStore.isValid && pb.authStore.isSuperuser) {
    loginView.classList.add('hidden');
    dashboardView.classList.remove('hidden');
    adminEmailDisplay.textContent = pb.authStore.model.email;
    
    // Load dynamic categories before loading data
    await loadIngredientCategories();
    setupFilterOptions();
    
    loadData();
  } else {
    loginView.classList.remove('hidden');
    dashboardView.classList.add('hidden');
  }
}

// ─── Tab Switching ────────────────────────────────────────────────────────────
window.switchTab = (collection) => {
  // Reset state for the new tab
  Object.assign(state, { collection, page: 1, search: '', primaryFilter: '', secondaryFilter: '' });
  searchInput.value = '';

  // Update sidebar active styles
  ['recipes', 'ingredients', 'settings'].forEach((tab) => {
    document.getElementById(`tab-${tab}`).classList.remove('bg-cookgreen-100', 'text-cookgreen-900');
  });
  document.getElementById(`tab-${collection}`).classList.add('bg-cookgreen-100', 'text-cookgreen-900');

  // Update header and toolbars
  const btnScan = document.getElementById('btn-scan-ingredients');
  if (collection === 'settings') {
    headerTitle.textContent = 'Pengaturan Aplikasi';
    document.getElementById('action-bar').classList.add('hidden');
    if (btnScan) btnScan.classList.add('hidden');
  } else {
    headerTitle.textContent = collection === 'recipes' ? 'Manajemen Resep' : 'Manajemen Bahan';
    document.getElementById('action-bar').classList.remove('hidden');
    
    // Toggle ingredients specific UI
    if (collection === 'ingredients') {
      if (btnScan) btnScan.classList.remove('hidden');
      if (searchContainer) searchContainer.classList.add('hidden');
      if (filterPrimary) filterPrimary.classList.add('hidden');
      if (perPageContainer) perPageContainer.classList.add('hidden');
    } else {
      if (btnScan) btnScan.classList.add('hidden');
      if (searchContainer) searchContainer.classList.remove('hidden');
      if (filterPrimary) filterPrimary.classList.remove('hidden');
      if (perPageContainer) perPageContainer.classList.remove('hidden');
    }
  }

  setupFilterOptions();
  loadData();
};

// ─── Data Loading ─────────────────────────────────────────────────────────────
window.refreshData = () => { loadData(); };

window.loadData = async function loadData() {
  setView('loading');
  try {
    if (state.collection === 'recipes') {
      const filters = [];
      if (state.search) {
        const safe = state.search.replace(/'/g, "\\'");
        filters.push(`(recipe_name ~ '${safe}' || description ~ '${safe}')`);
      }
      if (state.primaryFilter) {
        filters.push(`difficulty = '${state.primaryFilter.replace(/'/g, "\\'")}'`);
      }

      const result = await pb.collection(state.collection).getList(state.page, state.perPage, {
        sort:   '-created',
        filter: filters.join(' && '),
      });
      renderRecipesGrid(result);

    } else if (state.collection === 'settings') {
      await loadSettingsView();

    } else {
      const allItems = await pb.collection(state.collection).getFullList({ sort: 'category,name' });
      const filtered = allItems.filter((item) => {
        const name     = (item.name     || '').toLowerCase();
        const category = (item.category || '').toLowerCase();
        const matchSearch   = !state.search        || name.includes(state.search.toLowerCase()) || category.includes(state.search.toLowerCase());
        const matchCategory = !state.primaryFilter || item.category === state.primaryFilter;
        return matchSearch && matchCategory;
      });
      renderIngredientCategories(filtered);
    }
  } catch (err) {
    console.error(err);
    showToast('Gagal memuat data: ' + err.message, 'error');
    setView('empty');
  }
}



// ─── Render: Recipes Grid ─────────────────────────────────────────────────────
function renderRecipesGrid(resultList) {
  if (resultList.totalItems === 0) {
    setView('empty');
    return;
  }

  recipesGrid.innerHTML = '';

  resultList.items.forEach((item) => {
    const card        = document.createElement('div');
    card.className    = 'bg-white border border-gray-100 rounded-2xl p-4 transition-all';
    const difficulty  = item.difficulty   || '-';
    let cookingTimeLabel = '-';
    if (item.cooking_time) {
      const ct = parseInt(item.cooking_time, 10);
      if (ct < 60) {
        cookingTimeLabel = `${ct} mnt`;
      } else {
        const h = Math.floor(ct / 60);
        const m = ct % 60;
        cookingTimeLabel = m === 0 ? `${h} jam` : `${h} jam ${m} mnt`;
      }
    }
    const tagsHtml    = Array.isArray(item.tags) && item.tags.length
      ? item.tags.slice(0, 4).map((t) => `<span class="inline-block px-2 py-1 bg-blue-50 text-blue-600 rounded text-xs font-medium">${t}</span>`).join('')
      : '<span class="text-xs text-gray-400">Tanpa tag</span>';

    card.innerHTML = `
      <div class="flex items-start justify-between gap-3 mb-3">
        <h4 class="text-base font-medium text-gray-900 break-words">${item.recipe_name || '-'}</h4>
        <div class="flex items-center gap-1">
          <button onclick="openEditModal('${item.id}')" class="p-2 text-cookgreen-900 hover:text-cookgreen-800 hover:bg-cookgreen-50 rounded-lg transition-colors" title="Edit Data">
            <i data-feather="edit-2" class="w-4 h-4"></i>
          </button>
          <button onclick="deleteRecord('${item.id}')" class="p-2 text-red-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="Hapus Data">
            <i data-feather="trash-2" class="w-4 h-4"></i>
          </button>
        </div>
      </div>
      <p class="text-sm text-gray-500 mb-4 break-words">${item.description || 'Tanpa deskripsi'}</p>
      <div class="flex flex-wrap gap-2 mb-3">
        <span class="inline-block px-2 py-1 bg-orange-50 text-orange-600 rounded text-xs font-medium">${cookingTimeLabel}</span>
        <span class="inline-block px-2 py-1 bg-cookgreen-50 text-cookgreen-900 rounded text-xs font-medium">${difficulty}</span>
      </div>
      <div class="flex flex-wrap gap-1.5">${tagsHtml}</div>
    `;
    recipesGrid.appendChild(card);
  });

  pageInfo.textContent  = `Halaman ${resultList.page} dari ${resultList.totalPages} (${resultList.totalItems} total)`;
  btnPrev.disabled      = resultList.page === 1;
  btnNext.disabled      = resultList.page >= resultList.totalPages;

  feather.replace();
  setView('recipes');
}

// ─── Filter Setup ─────────────────────────────────────────────────────────────
function setupFilterOptions() {
  if (state.collection === 'recipes') {
    filterPrimary.innerHTML = `
      <option value="">Semua tingkat kesulitan</option>
      ${DIFFICULTY_OPTIONS.map((d) => `<option value="${d}">${d}</option>`).join('')}
    `;
  } else {
    filterPrimary.innerHTML = `
      <option value="">Semua kategori bahan</option>
      ${INGREDIENT_CATEGORIES.map((c) => `<option value="${c}">${c}</option>`).join('')}
    `;
  }
  filterSecondary.innerHTML = '';
  filterSecondary.classList.add('hidden');
  filterPrimary.value   = state.primaryFilter;
  filterSecondary.value = state.secondaryFilter;
}

// ─── Render: Ingredients ──────────────────────────────────────────────────────
function renderIngredientCategories(items) {
  if (items.length === 0) {
    setView('empty');
    return;
  }

  ingredientsCategories.innerHTML = '';
  const grouped = {};
  items.forEach((item) => {
    const key = item.category || 'Lainnya';
    (grouped[key] = grouped[key] || []).push(item);
  });

  Object.keys(grouped).forEach((category) => {
    const section        = document.createElement('div');
    section.className    = 'border border-gray-100 rounded-2xl bg-white overflow-hidden';

    const catRecord = INGREDIENT_CATEGORIES_RECORDS.find(r => r.name === category);
    const catIdStr = catRecord ? `'${catRecord.id}', 'ingredient_categories'` : `null, null`;
    const editCatBtn = catRecord ? `
      <button onclick="openEditModal(${catIdStr})" class="p-1.5 text-gray-400 hover:text-cookgreen-900 hover:bg-cookgreen-50 rounded-lg transition-colors ml-2" title="Edit Kategori">
        <i data-feather="edit-2" class="w-4 h-4"></i>
      </button>
    ` : '';

    const ingredientChips = grouped[category]
      .map((item) => `
        <span class="inline-flex items-center gap-2 px-3 py-1.5 bg-gray-50 border border-gray-200 rounded-full text-sm text-gray-700">
          ${item.name || '-'}
          <button onclick="openEditModal('${item.id}')" class="text-cookgreen-900 hover:text-cookgreen-800" title="Edit Data">
            <i data-feather="edit-2" class="w-3.5 h-3.5"></i>
          </button>
          <button onclick="deleteRecord('${item.id}')" class="text-red-400 hover:text-red-600" title="Hapus Data">
            <i data-feather="x" class="w-3.5 h-3.5"></i>
          </button>
        </span>
      `)
      .join('');

    section.innerHTML = `
      <details class="group" open>
        <summary class="list-none cursor-pointer px-4 py-3 flex items-center justify-between bg-gray-50 border-b border-gray-100">
          <div class="flex items-center">
            <div class="flex items-center gap-2">
              <span class="text-lg">${CATEGORY_EMOJI_MAP[category] || '📦'}</span>
              <span class="font-medium text-gray-900">${category}</span>
              <span class="text-xs text-gray-500">(${grouped[category].length})</span>
            </div>
            ${editCatBtn}
          </div>
          <i data-feather="chevron-down" class="w-4 h-4 text-gray-400 group-open:rotate-180 transition-transform"></i>
        </summary>
        <div class="p-4">
          <div class="flex flex-wrap gap-2">${ingredientChips}</div>
        </div>
      </details>
    `;
    ingredientsCategories.appendChild(section);
  });

  feather.replace();
  setView('ingredients');
}

// ─── Pagination ────────────────────────────────────────────────────────────────
window.prevPage = () => {
  if (state.page > 1) { state.page--; loadData(); }
};

window.nextPage = () => {
  state.page++;
  loadData();
};

// ─── Delete ───────────────────────────────────────────────────────────────────
window.deleteRecord = async (id) => {
  if (!confirm('Yakin ingin menghapus data ini?')) return;
  try {
    await pb.collection(state.collection).delete(id);
    showToast('Data berhasil dihapus', 'success');
    loadData();
  } catch (err) {
    console.error(err);
    showToast('Gagal menghapus data', 'error');
  }
};

window.exportJSON = async () => {
   try {
     showToast(`Mempersiapkan export data ${state.collection}...`, 'info');
     const items = await pb.collection(state.collection).getFullList();
     
     const cleanedItems = items.map(item => {
        const { collectionId, collectionName, created, updated, expand, ...rest } = item;
        return rest;
     });
     
     const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(cleanedItems, null, 2));
     const downloadAnchorNode = document.createElement('a');
     downloadAnchorNode.setAttribute("href", dataStr);
     downloadAnchorNode.setAttribute("download", `${state.collection}_export.json`);
     document.body.appendChild(downloadAnchorNode);
     downloadAnchorNode.click();
     downloadAnchorNode.remove();
     showToast(`Berhasil export data ${state.collection}`, 'success');
   } catch (err) {
     console.error(err);
     showToast('Gagal export JSON: ' + err.message, 'error');
   }
};
