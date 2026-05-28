/**
 * CookSnap — PocketBase Seed Script
 *
 * Script ini melakukan seed data awal ke PocketBase:
 * - Recipes (10 resep dari dummy_recipe_source.dart)
 * - Ingredients (master bahan dari dummy_ingredients.dart)
 *
 * CARA PAKAI:
 * 1. Pastikan PocketBase sudah berjalan (./pocketbase serve)
 * 2. Isi BASE_URL dan ADMIN_EMAIL / ADMIN_PASSWORD di bawah
 * 3. Jalankan: node seed_via_api.js
 *
 * Requirements: Node.js >= 18 (gunakan global fetch)
 */

// =============================================
// KONFIGURASI — EDIT BAGIAN INI
// =============================================
const BASE_URL = 'https://cooksnap-mobile-app-production.up.railway.app';
const ADMIN_EMAIL = 'admin@cooksnap.com';   // email admin PocketBase
const ADMIN_PASSWORD = 'Cooksnap123456';       // password admin PocketBase
// =============================================

const recipes = require('./recipes.json');
const ingredients = require('./ingredients.json');

// ── Helpers ──────────────────────────────────────────────

async function getAdminToken() {
  const res = await fetch(`${BASE_URL}/api/collections/_superusers/auth-with-password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ identity: ADMIN_EMAIL, password: ADMIN_PASSWORD }),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Login admin gagal: ${err}`);
  }

  const data = await res.json();
  return data.token;
}

async function createRecord(token, collection, body) {
  const res = await fetch(`${BASE_URL}/api/collections/${collection}/records`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Gagal buat record di ${collection}: ${err}`);
  }

  return res.json();
}

async function collectionIsEmpty(token, collection) {
  const res = await fetch(
    `${BASE_URL}/api/collections/${collection}/records?perPage=1`,
    { headers: { Authorization: `Bearer ${token}` } }
  );

  if (!res.ok) return false;
  const data = await res.json();
  return data.totalItems === 0;
}

// ── Seed Functions ────────────────────────────────────────

async function seedRecipes(token) {
  console.log('\n📖 Seeding recipes...');

  const isEmpty = await collectionIsEmpty(token, 'recipes');
  if (!isEmpty) {
    console.log('  ⚠️  Collection recipes sudah ada data, skip.');
    return;
  }

  let ok = 0;
  let fail = 0;

  for (const recipe of recipes) {
    try {
      const payload = {
        ...recipe,
        // PocketBase menyimpan JSON field sebagai string JSON atau array tergantung versi
        ingredients: JSON.stringify(recipe.ingredients),
        steps: JSON.stringify(recipe.steps),
        tags: JSON.stringify(recipe.tags),
      };
      await createRecord(token, 'recipes', payload);
      console.log(`  ✅ ${recipe.recipe_name}`);
      ok++;
    } catch (e) {
      console.error(`  ❌ ${recipe.recipe_name}: ${e.message}`);
      fail++;
    }
  }

  console.log(`  Total: ${ok} berhasil, ${fail} gagal.`);
}

async function seedIngredients(token) {
  console.log('\n🥕 Seeding ingredients...');

  const isEmpty = await collectionIsEmpty(token, 'ingredients');
  if (!isEmpty) {
    console.log('  ⚠️  Collection ingredients sudah ada data, skip.');
    return;
  }

  let ok = 0;
  let fail = 0;

  for (const item of ingredients) {
    try {
      await createRecord(token, 'ingredients', item);
      ok++;
    } catch (e) {
      console.error(`  ❌ Gagal bahan: ${e.message}`);
      fail++;
    }
  }

  console.log(`  Total: ${ok} berhasil, ${fail} gagal (mungkin duplikat).`);
}

// ── Main ──────────────────────────────────────────────────

async function main() {
  console.log('🚀 CookSnap PocketBase Seed Script');
  console.log(`   Server: ${BASE_URL}`);

  let token;
  try {
    token = await getAdminToken();
    console.log('   ✅ Login admin berhasil');
  } catch (e) {
    console.error(`\n❌ ${e.message}`);
    console.error(
      '   Pastikan PocketBase sudah berjalan dan kredensial admin benar.'
    );
    process.exit(1);
  }

  await seedRecipes(token);
  await seedIngredients(token);

  console.log('\n🎉 Seed selesai!');
  console.log(
    `   Cek data di: ${BASE_URL}/_/`
  );
}

main().catch((e) => {
  console.error('\n❌ Fatal error:', e.message);
  process.exit(1);
});
