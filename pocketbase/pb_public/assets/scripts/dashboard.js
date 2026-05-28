// Inisialisasi PocketBase SDK
const pb = new PocketBase(window.location.origin);

// Global State
let currentCollection = 'recipes';
let currentPage = 1;
let perPage = 12;
let currentSearch = '';
let currentPrimaryFilter = '';
let currentSecondaryFilter = '';
let isImporting = false;

// DOM Elements
const loginView = document.getElementById('login-view');
const dashboardView = document.getElementById('dashboard-view');
const loginForm = document.getElementById('login-form');
const logoutBtn = document.getElementById('logout-btn');
const adminEmailDisplay = document.getElementById('admin-email-display');
const loadingState = document.getElementById('loading-state');
const emptyState = document.getElementById('empty-state');
const tableContainer = document.getElementById('table-container');
const recipesGridContainer = document.getElementById('recipes-grid-container');
const recipesGrid = document.getElementById('recipes-grid');
const ingredientsCategoryContainer = document.getElementById('ingredients-category-container');
const ingredientsCategories = document.getElementById('ingredients-categories');
const settingsContainer = document.getElementById('settings-container');
const pagination = document.getElementById('pagination');
const pageInfo = document.getElementById('page-info');
const btnPrev = document.getElementById('btn-prev');
const btnNext = document.getElementById('btn-next');
const headerTitle = document.getElementById('header-title');
const searchInput = document.getElementById('search-input');
const filterPrimary = document.getElementById('filter-primary');
const filterSecondary = document.getElementById('filter-secondary');
const perPageSelect = document.getElementById('per-page-select');
const editModal = document.getElementById('edit-modal');
const editCollectionName = document.getElementById('edit-collection-name');
const editRecordId = document.getElementById('edit-record-id');
const editFieldsContainer = document.getElementById('edit-fields-container');
const btnSaveEdit = document.getElementById('btn-save-edit');
let editFieldMeta = [];

// On Load
document.addEventListener('DOMContentLoaded', () => {
    checkAuth();
    setupFilterOptions();
    bindToolbarEvents();

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('login-email').value;
        const password = document.getElementById('login-password').value;
        const btn = document.getElementById('login-btn');
        const originalText = btn.innerHTML;

        btn.innerHTML = `<div class="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div> Processing...`;
        btn.disabled = true;

        try {
            await pb.collection('_superusers').authWithPassword(email, password);
            showToast('Login berhasil', 'success');
            checkAuth();
        } catch (err) {
            showToast('Login gagal: Email atau Password salah', 'error');
            console.error(err);
        } finally {
            btn.innerHTML = originalText;
            btn.disabled = false;
        }
    });

    logoutBtn.addEventListener('click', () => {
        pb.authStore.clear();
        checkAuth();
        showToast('Berhasil logout', 'success');
    });
});

function bindToolbarEvents() {
    searchInput.addEventListener('input', () => {
        currentSearch = searchInput.value.trim();
        currentPage = 1;
        loadData();
    });

    filterPrimary.addEventListener('change', () => {
        currentPrimaryFilter = filterPrimary.value;
        currentPage = 1;
        loadData();
    });

    filterSecondary.addEventListener('change', () => {
        currentSecondaryFilter = filterSecondary.value;
        currentPage = 1;
        loadData();
    });

    perPageSelect.addEventListener('change', () => {
        perPage = Number(perPageSelect.value) || 12;
        currentPage = 1;
        loadData();
    });
}

// Auth Logic
function checkAuth() {
    if (pb.authStore.isValid && pb.authStore.isSuperuser) {
        loginView.classList.add('hidden');
        dashboardView.classList.remove('hidden');
        adminEmailDisplay.textContent = pb.authStore.model.email;
        loadData();
    } else {
        loginView.classList.remove('hidden');
        dashboardView.classList.add('hidden');
    }
}

// Tab Switching
window.switchTab = (collection) => {
    currentCollection = collection;
    currentPage = 1;
    currentSearch = '';
    currentPrimaryFilter = '';
    currentSecondaryFilter = '';
    searchInput.value = '';

    // Update active styles
    document.getElementById('tab-recipes').classList.remove('bg-cookgreen-100', 'text-cookgreen-900');
    document.getElementById('tab-ingredients').classList.remove('bg-cookgreen-100', 'text-cookgreen-900');
    document.getElementById('tab-settings').classList.remove('bg-cookgreen-100', 'text-cookgreen-900');
    document.getElementById(`tab-${collection}`).classList.add('bg-cookgreen-100', 'text-cookgreen-900');

    // Update Header
    if (collection === 'settings') {
        headerTitle.textContent = 'Pengaturan Aplikasi';
        document.getElementById('action-bar').classList.add('hidden');
    } else {
        headerTitle.textContent = collection === 'recipes' ? 'Manajemen Resep' : 'Manajemen Bahan';
        document.getElementById('action-bar').classList.remove('hidden');
    }
    
    setupFilterOptions();

    loadData();
};

// Load Data
window.refreshData = () => {
    loadData();
};

async function loadData() {
    showLoading();
    try {
        if (currentCollection === 'recipes') {
            const filters = [];
            if (currentSearch) {
                const safeSearch = currentSearch.replace(/'/g, "\\'");
                filters.push(`(recipe_name ~ '${safeSearch}' || description ~ '${safeSearch}')`);
            }
            if (currentPrimaryFilter) {
                filters.push(`difficulty = '${currentPrimaryFilter.replace(/'/g, "\\'")}'`);
            }
            if (currentSecondaryFilter) {
                // secondary filter reserved for future use
            }

            const resultList = await pb.collection(currentCollection).getList(currentPage, perPage, {
                sort: '-created',
                filter: filters.join(' && '),
            });
            renderRecipesGrid(resultList);
        } else if (currentCollection === 'settings') {
            await loadSettingsView();
        } else {
            const allItems = await pb.collection(currentCollection).getFullList({
                sort: 'category,name',
            });
            const filtered = allItems.filter((item) => {
                const name = (item.name || '').toLowerCase();
                const category = (item.category || '').toLowerCase();
                const matchSearch = !currentSearch || name.includes(currentSearch.toLowerCase()) || category.includes(currentSearch.toLowerCase());
                const matchCategory = !currentPrimaryFilter || item.category === currentPrimaryFilter;
                return matchSearch && matchCategory;
            });
            renderIngredientCategories(filtered);
        }
    } catch (err) {
        console.error(err);
        showToast('Gagal memuat data: ' + err.message, 'error');
        showEmpty();
    }
}

function showLoading() {
    loadingState.classList.remove('hidden');
    emptyState.classList.add('hidden');
    tableContainer.classList.add('hidden');
    recipesGridContainer.classList.add('hidden');
    ingredientsCategoryContainer.classList.add('hidden');
    settingsContainer.classList.add('hidden');
    pagination.classList.add('hidden');
}

function showEmpty() {
    loadingState.classList.add('hidden');
    emptyState.classList.remove('hidden');
    tableContainer.classList.add('hidden');
    recipesGridContainer.classList.add('hidden');
    ingredientsCategoryContainer.classList.add('hidden');
    settingsContainer.classList.add('hidden');
    pagination.classList.add('hidden');
}

function showRecipesView() {
    loadingState.classList.add('hidden');
    emptyState.classList.add('hidden');
    tableContainer.classList.add('hidden');
    ingredientsCategoryContainer.classList.add('hidden');
    settingsContainer.classList.add('hidden');
    recipesGridContainer.classList.remove('hidden');
    pagination.classList.remove('hidden');
}

function showIngredientsView() {
    loadingState.classList.add('hidden');
    emptyState.classList.add('hidden');
    tableContainer.classList.add('hidden');
    recipesGridContainer.classList.add('hidden');
    settingsContainer.classList.add('hidden');
    ingredientsCategoryContainer.classList.remove('hidden');
    pagination.classList.add('hidden');
}

function showSettingsContainer() {
    loadingState.classList.add('hidden');
    emptyState.classList.add('hidden');
    tableContainer.classList.add('hidden');
    recipesGridContainer.classList.add('hidden');
    ingredientsCategoryContainer.classList.add('hidden');
    settingsContainer.classList.remove('hidden');
    pagination.classList.add('hidden');
}

let appConfigId = null;

async function loadSettingsView() {
    try {
        const records = await pb.collection('app_config').getList(1, 1);
        let config;
        
        if (records.items.length === 0) {
            config = await pb.collection('app_config').create({
                latest_version: "1.0.0",
                minimum_version: "1.0.0",
                force_update: false,
                update_message: "Versi baru CookSnap tersedia untuk pengalaman yang lebih baik.",
                apk_url: "",
                is_maintenance: false,
                maintenance_message: "Server sedang dalam perbaikan. Silakan coba lagi nanti."
            });
        } else {
            config = records.items[0];
        }

        appConfigId = config.id;
        
        document.getElementById('cfg-latest').value = config.latest_version || '';
        document.getElementById('cfg-minimum').value = config.minimum_version || '';
        document.getElementById('cfg-force').checked = config.force_update || false;
        document.getElementById('cfg-updmsg').value = config.update_message || '';
        document.getElementById('cfg-apkurl').value = config.apk_url || '';
        document.getElementById('cfg-maint').checked = config.is_maintenance || false;
        document.getElementById('cfg-maintmsg').value = config.maintenance_message || '';

        showSettingsContainer();
    } catch (err) {
        console.error(err);
        showToast('Gagal memuat pengaturan app', 'error');
        showEmpty();
    }
}

window.saveSettings = async () => {
    if (!appConfigId) return;

    const btn = document.getElementById('btn-save-settings');
    const originalText = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = `<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div> Menyimpan...`;

    const payload = {
        latest_version: document.getElementById('cfg-latest').value,
        minimum_version: document.getElementById('cfg-minimum').value,
        force_update: document.getElementById('cfg-force').checked,
        update_message: document.getElementById('cfg-updmsg').value,
        apk_url: document.getElementById('cfg-apkurl').value,
        is_maintenance: document.getElementById('cfg-maint').checked,
        maintenance_message: document.getElementById('cfg-maintmsg').value,
    };

    try {
        await pb.collection('app_config').update(appConfigId, payload);
        showToast('Pengaturan berhasil disimpan', 'success');
    } catch (err) {
        console.error(err);
        showToast('Gagal menyimpan pengaturan', 'error');
    } finally {
        btn.disabled = false;
        btn.innerHTML = originalText;
        feather.replace();
    }
};

function renderRecipesGrid(resultList) {
    if (resultList.totalItems === 0) {
        showEmpty();
        return;
    }

    recipesGrid.innerHTML = '';

    resultList.items.forEach((item) => {
        const card = document.createElement('div');
        card.className = 'bg-white border border-gray-100 rounded-2xl p-4 transition-all';
        const difficulty = item.difficulty || '-';
        const cookingTime = item.cooking_time || '-';
        const tagsHtml = Array.isArray(item.tags) && item.tags.length
            ? item.tags.slice(0, 4).map(t => `<span class="inline-block px-2 py-1 bg-blue-50 text-blue-600 rounded text-xs font-medium">${t}</span>`).join('')
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
                <span class="inline-block px-2 py-1 bg-orange-50 text-orange-600 rounded text-xs font-medium">${cookingTime} menit</span>
                <span class="inline-block px-2 py-1 bg-cookgreen-50 text-cookgreen-900 rounded text-xs font-medium">${difficulty}</span>
            </div>
            <div class="flex flex-wrap gap-1.5">${tagsHtml}</div>
        `;
        recipesGrid.appendChild(card);
    });

    pageInfo.textContent = `Halaman ${resultList.page} dari ${resultList.totalPages} (${resultList.totalItems} total)`;
    btnPrev.disabled = resultList.page === 1;
    btnNext.disabled = resultList.page >= resultList.totalPages;

    feather.replace();
    showRecipesView();
}

function setupFilterOptions() {
    if (currentCollection === 'recipes') {
        filterPrimary.innerHTML = `
            <option value="">Semua tingkat kesulitan</option>
            <option value="Mudah">Mudah</option>
            <option value="Sedang">Sedang</option>
            <option value="Sulit">Sulit</option>
        `;
        filterSecondary.innerHTML = '';
        filterSecondary.classList.add('hidden');
    } else {
        filterPrimary.innerHTML = `
            <option value="">Semua kategori bahan</option>
            <option value="Sumber Protein">Sumber Protein</option>
            <option value="Sayuran">Sayuran</option>
            <option value="Bumbu">Bumbu</option>
            <option value="Bumbu Dasar">Bumbu Dasar</option>
            <option value="Karbohidrat">Karbohidrat</option>
            <option value="Susu & Olahan Susu">Susu & Olahan Susu</option>
            <option value="Buah">Buah</option>
            <option value="Tepung">Tepung</option>
            <option value="Lainnya">Lainnya</option>
        `;
        filterSecondary.innerHTML = '';
        filterSecondary.classList.add('hidden');
    }
    filterPrimary.value = currentPrimaryFilter;
    filterSecondary.value = currentSecondaryFilter;
}

function renderIngredientCategories(items) {
    if (items.length === 0) {
        showEmpty();
        return;
    }

    ingredientsCategories.innerHTML = '';
    const grouped = {};

    items.forEach((item) => {
        const key = item.category || 'Lainnya';
        if (!grouped[key]) grouped[key] = [];
        grouped[key].push(item);
    });

    Object.keys(grouped).forEach((category) => {
        const section = document.createElement('div');
        section.className = 'border border-gray-100 rounded-2xl bg-white overflow-hidden';

        const ingredientChips = grouped[category]
            .map((item) => {
                const name = item.name || '-';
                return `
                    <span class="inline-flex items-center gap-2 px-3 py-1.5 bg-gray-50 border border-gray-200 rounded-full text-sm text-gray-700">
                        ${name}
                        <button onclick="openEditModal('${item.id}')" class="text-cookgreen-900 hover:text-cookgreen-800" title="Edit Data">
                            <i data-feather="edit-2" class="w-3.5 h-3.5"></i>
                        </button>
                        <button onclick="deleteRecord('${item.id}')" class="text-red-400 hover:text-red-600" title="Hapus Data">
                            <i data-feather="x" class="w-3.5 h-3.5"></i>
                        </button>
                    </span>
                `;
            })
            .join('');

        section.innerHTML = `
            <details class="group" open>
                <summary class="list-none cursor-pointer px-4 py-3 flex items-center justify-between bg-gray-50 border-b border-gray-100">
                    <div class="flex items-center gap-2">
                        <span class="text-lg">${categoryEmojiMap[category] || '📦'}</span>
                        <span class="font-medium text-gray-900">${category}</span>
                        <span class="text-xs text-gray-500">(${grouped[category].length})</span>
                    </div>
                    <i data-feather="chevron-down" class="w-4 h-4 text-gray-400 group-open:rotate-180 transition-transform"></i>
                </summary>
                <div class="p-4">
                    <div class="flex flex-wrap gap-2">
                        ${ingredientChips}
                    </div>
                </div>
            </details>
        `;
        ingredientsCategories.appendChild(section);
    });

    feather.replace();
    showIngredientsView();
}

window.prevPage = () => {
    if (currentPage > 1) {
        currentPage--;
        loadData();
    }
};

window.nextPage = () => {
    currentPage++;
    loadData();
};

window.deleteRecord = async (id) => {
    if (!confirm('Yakin ingin menghapus data ini?')) return;

    try {
        await pb.collection(currentCollection).delete(id);
        showToast('Data berhasil dihapus', 'success');
        loadData();
    } catch (err) {
        console.error(err);
        showToast('Gagal menghapus data', 'error');
    }
};

window.openEditModal = async (id) => {
    try {
        const record = await pb.collection(currentCollection).getOne(id);
        editRecordId.value = record.id;
        editCollectionName.textContent = currentCollection;
        renderDynamicEditFields(record);

        editModal.classList.remove('hidden');
        feather.replace();
    } catch (err) {
        console.error(err);
        showToast('Gagal memuat data untuk edit', 'error');
    }
};

window.closeEditModal = () => {
    editModal.classList.add('hidden');
};

window.saveEditRecord = async () => {
    const id = editRecordId.value;
    if (!id) return;

    const originalText = btnSaveEdit.innerHTML;
    btnSaveEdit.disabled = true;
    btnSaveEdit.innerHTML = `<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div> Menyimpan...`;

    try {
        const payload = collectDynamicEditPayload();

        await pb.collection(currentCollection).update(id, payload);
        showToast('Data berhasil diperbarui', 'success');
        closeEditModal();
        loadData();
    } catch (err) {
        console.error(err);
        showToast('Gagal menyimpan perubahan: ' + err.message, 'error');
    } finally {
        btnSaveEdit.disabled = false;
        btnSaveEdit.innerHTML = originalText;
        feather.replace();
    }
};

function isSystemField(key) {
    return ['id', 'created', 'updated', 'collectionId', 'collectionName', 'expand'].includes(key);
}

function renderDynamicEditFields(record) {
    editFieldsContainer.innerHTML = '';
    editFieldMeta = [];

    const editableKeys = Object.keys(record).filter((key) => !isSystemField(key));

    editableKeys.forEach((key) => {
        const value = record[key];
        const isComplex = typeof value === 'object' && value !== null;
        const wrapper = document.createElement('div');
        wrapper.className = 'mb-4';

        const label = document.createElement('label');
        label.className = 'block text-sm font-medium text-gray-700 mb-2 capitalize';
        label.textContent = key.replace(/_/g, ' ');

        let fieldEl;
        if (isComplex) {
            fieldEl = document.createElement('textarea');
            fieldEl.rows = 4;
            fieldEl.className = 'w-full p-3 border border-gray-200 rounded-xl font-mono text-sm bg-gray-50 focus:bg-white focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none transition-all';
            fieldEl.value = JSON.stringify(value, null, 2);
        } else {
            fieldEl = document.createElement('input');
            fieldEl.type = 'text';
            fieldEl.className = 'w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-cookgreen-500 focus:border-cookgreen-500 outline-none transition-all';
            fieldEl.value = value ?? '';
        }

        fieldEl.id = `edit-field-${key}`;
        wrapper.appendChild(label);
        wrapper.appendChild(fieldEl);
        editFieldsContainer.appendChild(wrapper);

        editFieldMeta.push({
            key,
            isComplex,
        });
    });
}

function collectDynamicEditPayload() {
    const payload = {};

    for (const field of editFieldMeta) {
        const inputEl = document.getElementById(`edit-field-${field.key}`);
        if (!inputEl) continue;
        const rawValue = inputEl.value;

        if (field.isComplex) {
            if (!rawValue.trim()) {
                payload[field.key] = null;
                continue;
            }

            try {
                payload[field.key] = JSON.parse(rawValue);
            } catch (err) {
                throw new Error(`Field "${field.key}" harus berupa JSON valid`);
            }
        } else {
            payload[field.key] = rawValue;
        }
    }

    return payload;
}

// Bulk Import Logic
const bulkModal = document.getElementById('bulk-modal');
const jsonInput = document.getElementById('json-input');
const modalCollectionName = document.getElementById('modal-collection-name');
const importProgressContainer = document.getElementById('import-progress-container');
const importProgressBar = document.getElementById('import-progress-bar');
const importStats = document.getElementById('import-stats');
const importLog = document.getElementById('import-log');
const btnStartImport = document.getElementById('btn-start-import');
const recipeExampleJson = `[
  {
    "recipe_name": "Nasi Goreng Kampung",
    "description": "Nasi goreng rumahan sederhana.",
    "image_url": "https://example.com/nasi-goreng.jpg",
    "ingredients": ["nasi putih", "telur ayam", "bawang putih"],
    "steps": ["Tumis bumbu", "Masukkan nasi", "Aduk hingga matang"],
    "cooking_time": 20,
    "difficulty": "Mudah",
    "tags": ["goreng", "praktis", "indonesia"],
    "source_url": "https://example.com/resep-nasi-goreng",
    "video_url": "https://example.com/video-nasi-goreng"
  }
]`;
const ingredientExampleJson = `[
  {
    "name": "Tomat",
    "category": "Sayuran"
  },
  {
    "name": "Bawang Putih",
    "category": "Bumbu"
  }
]`;
const categoryEmojiMap = {
    'Sumber Protein': '🥩',
    Sayuran: '🥬',
    Bumbu: '🧄',
    'Bumbu Dasar': '🧂',
    Karbohidrat: '🍚',
    'Susu & Olahan Susu': '🥛',
    Buah: '🍎',
    Tepung: '🌾',
    Lainnya: '📦',
};
const allowedRecipeDifficulty = ['Mudah', 'Sedang', 'Sulit'];

function normalizeRecipePayload(rawItem) {
    const payload = { ...rawItem };
    const errors = [];

    const difficultyMap = {
        easy: 'Mudah',
        medium: 'Sedang',
        hard: 'Sulit',
        mudah: 'Mudah',
        sedang: 'Sedang',
        sulit: 'Sulit',
    };

    const difficultyRaw = `${payload.difficulty ?? ''}`.trim();
    const difficultyNormalized = difficultyMap[difficultyRaw.toLowerCase()] || difficultyRaw;
    if (!allowedRecipeDifficulty.includes(difficultyNormalized)) {
        errors.push(`difficulty tidak valid: "${difficultyRaw}"`);
    } else {
        payload.difficulty = difficultyNormalized;
    }

    if (!Array.isArray(payload.ingredients)) {
        errors.push('ingredients harus array');
    } else {
        payload.ingredients = payload.ingredients.map((ing) => {
            if (typeof ing === 'string') {
                return { name: ing.trim(), quantity: 1, unit: 'pcs' };
            }
            if (typeof ing === 'object' && ing !== null) {
                return {
                    name: `${ing.name ?? ''}`.trim(),
                    quantity: Number(ing.quantity ?? 1),
                    unit: `${ing.unit ?? 'pcs'}`.trim() || 'pcs',
                };
            }
            return null;
        }).filter(Boolean);
    }

    if (!Array.isArray(payload.steps)) {
        errors.push('steps harus array');
    } else {
        payload.steps = payload.steps.map((s) => `${s}`.trim()).filter(Boolean);
    }

    if (payload.tags != null) {
        if (!Array.isArray(payload.tags)) {
            errors.push('tags harus array');
        } else {
            payload.tags = payload.tags.map((t) => `${t}`.trim()).filter(Boolean);
        }
    }

    if (payload.cooking_time != null) {
        const time = Number(payload.cooking_time);
        if (!Number.isInteger(time) || time <= 0) {
            errors.push('cooking_time harus angka bulat > 0');
        } else {
            payload.cooking_time = time;
        }
    }

    const requiredFields = ['recipe_name', 'description', 'ingredients', 'steps', 'cooking_time', 'difficulty'];
    for (const key of requiredFields) {
        const v = payload[key];
        const empty = v == null || (typeof v === 'string' && !v.trim()) || (Array.isArray(v) && v.length === 0);
        if (empty) errors.push(`${key} wajib diisi`);
    }

    return { payload, errors };
}

window.openBulkModal = () => {
    modalCollectionName.textContent = currentCollection;
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
    jsonInput.value = currentCollection === 'recipes' ? recipeExampleJson : ingredientExampleJson;
};

window.closeBulkModal = () => {
    if (isImporting) {
        if (!confirm('Import sedang berjalan! Yakin ingin menutup? (Proses di background mungkin tetap berjalan)')) return;
    }
    bulkModal.classList.add('hidden');
};

window.startBulkImport = async () => {
    const rawVal = jsonInput.value.trim();
    if (!rawVal) {
        showToast('JSON tidak boleh kosong', 'error');
        return;
    }

    let dataArr = [];
    try {
        dataArr = JSON.parse(rawVal);
        if (!Array.isArray(dataArr)) {
            throw new Error('Data utama harus berbentuk Array: []');
        }
    } catch (e) {
        showToast('Format JSON tidak valid: ' + e.message, 'error');
        return;
    }

    if (dataArr.length === 0) {
        showToast('Array JSON kosong', 'error');
        return;
    }

    if (!confirm(`Terdapat ${dataArr.length} data. Yakin ingin mengimpor sekarang?`)) return;

    isImporting = true;
    importProgressContainer.classList.remove('hidden');
    btnStartImport.disabled = true;
    btnStartImport.classList.add('opacity-50', 'cursor-not-allowed');
    jsonInput.disabled = true;

    let success = 0;
    let failed = 0;
    importLog.innerHTML = '';

    const appendLog = (msg, isError = false) => {
        const div = document.createElement('div');
        div.textContent = msg;
        if (isError) div.classList.add('text-red-500');
        importLog.appendChild(div);
        importLog.scrollTop = importLog.scrollHeight;
    };

    appendLog(`Memulai import ${dataArr.length} data ke '${currentCollection}'...`);

    for (let i = 0; i < dataArr.length; i++) {
        const item = dataArr[i];
        try {
            let payload = { ...item };

            if (currentCollection === 'recipes') {
                const normalized = normalizeRecipePayload(item);
                if (normalized.errors.length > 0) {
                    throw new Error(normalized.errors.join('; '));
                }
                payload = normalized.payload;
            }

            await pb.collection(currentCollection).create(payload);
            success++;
            appendLog(`[${i + 1}] Sukses: ${item.recipe_name || item.name || 'Data'}`);
        } catch (err) {
            failed++;
            appendLog(`[${i + 1}] Gagal: ${err.message}`, true);
        }

        const percent = Math.round(((i + 1) / dataArr.length) * 100);
        importProgressBar.style.width = `${percent}%`;
        importStats.textContent = `${i + 1}/${dataArr.length}`;
    }

    isImporting = false;
    jsonInput.disabled = false;
    appendLog(`SELESAI. Sukses: ${success}, Gagal: ${failed}`);
    showToast(`Import selesai. ${success} berhasil.`, success > 0 ? 'success' : 'error');

    currentPage = 1;
    loadData();

    btnStartImport.innerHTML = `<i data-feather="check" class="w-4 h-4"></i> Selesai`;
    btnStartImport.classList.remove('bg-cookgreen-900');
    btnStartImport.classList.add('bg-cookgreen-800');
    feather.replace();
};

// Custom Toast Function
function showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');

    let bgColor = 'bg-gray-800';
    let icon = 'info';

    if (type === 'success') {
        bgColor = 'bg-cookgreen-900';
        icon = 'check-circle';
    } else if (type === 'error') {
        bgColor = 'bg-red-500';
        icon = 'alert-circle';
    }

    toast.className = `flex items-center gap-3 px-4 py-3 rounded-xl shadow-lg text-white font-medium ${bgColor} animate-slide-up transition-all duration-300 transform`;
    toast.innerHTML = `<i data-feather="${icon}" class="w-5 h-5"></i> <span>${message}</span>`;

    container.appendChild(toast);
    feather.replace();

    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(-10px)';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Inisialisasi awal tab
document.getElementById('tab-recipes').classList.add('bg-cookgreen-100', 'text-cookgreen-900');
