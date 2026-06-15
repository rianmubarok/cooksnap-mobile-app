/**
 * CookSnap — Seed ingredient_corrections
 *
 * Memasukkan data pemetaan koreksi bahan ke koleksi ingredient_corrections.
 * Jika original_name sudah ada (duplikat), entri tersebut di-skip.
 *
 * CARA PAKAI:
 * 1. Pastikan PocketBase sudah berjalan
 * 2. Jalankan: node seed/seed_corrections.js
 *
 * Requirements: Node.js >= 18
 */

const BASE_URL      = 'https://cooksnap-mobile-app-production.up.railway.app';
const ADMIN_EMAIL   = 'admin@cooksnap.com';
const ADMIN_PASSWORD = 'Cooksnap123456';

// ── Data Koreksi ──────────────────────────────────────────
const corrections = [
  // Lada / Merica
  { original_name: "lada bubuk",              corrected_name: "merica" },
  { original_name: "lada halus",              corrected_name: "merica" },
  { original_name: "lada",                    corrected_name: "merica" },
  { original_name: "merica bubuk",            corrected_name: "merica" },
  { original_name: "black pepper",            corrected_name: "merica" },
  { original_name: "black papper",            corrected_name: "merica" },

  // Ayam
  { original_name: "dada ayam",                              corrected_name: "daging ayam" },
  { original_name: "dada ayam matang",                       corrected_name: "daging ayam" },
  { original_name: "ayam dada potong2",                      corrected_name: "daging ayam" },
  { original_name: "ayam kampung",                           corrected_name: "daging ayam" },
  { original_name: "ayam paha atas atau paha bawah",         corrected_name: "daging ayam" },
  { original_name: "ayam potong",                            corrected_name: "daging ayam" },
  { original_name: "ayam potong2",                           corrected_name: "daging ayam" },
  { original_name: "ayam diungkep dulu",                     corrected_name: "daging ayam" },
  { original_name: "ayam yg sudah direbus sebelumnya",       corrected_name: "daging ayam" },

  // Daging lainnya
  { original_name: "daging kalkun matang",           corrected_name: "daging kalkun" },
  { original_name: "daging kambing campur tulang",   corrected_name: "daging kambing" },
  { original_name: "ham matang",                     corrected_name: "ham" },
  { original_name: "ceker ayam bersihkan",           corrected_name: "ceker ayam" },
  { original_name: "tulang ayam bersihkan lalu potong", corrected_name: "tulang ayam" },

  // Air & Kaldu
  { original_name: "air es",                    corrected_name: "air" },
  { original_name: "es batu",                   corrected_name: "air" },
  { original_name: "air lemon",                 corrected_name: "lemon" },
  { original_name: "jus lemon",                 corrected_name: "lemon" },
  { original_name: "air jeruk nipis",           corrected_name: "jeruk nipis" },
  { original_name: "air perasan jeruk nipis",   corrected_name: "jeruk nipis" },
  { original_name: "air jeruk nipis / lemon",   corrected_name: "jeruk nipis" },
  { original_name: "air kaldu ayam kampung",    corrected_name: "kaldu ayam" },
  { original_name: "kaldu ayam",                corrected_name: "kaldu ayam" },
  { original_name: "kaldu sapi",                corrected_name: "kaldu sapi" },
  { original_name: "kaldu jamur",               corrected_name: "kaldu jamur" },

  // Gula & Cabai
  { original_name: "gula jawa",             corrected_name: "gula merah" },
  { original_name: "cabai merah keriting",  corrected_name: "cabai merah" },
  { original_name: "cabe hijau",            corrected_name: "cabai hijau" },
  { original_name: "cabe ijo besar",        corrected_name: "cabai hijau" },
  { original_name: "cabai hijau besar",     corrected_name: "cabai hijau" },

  // Rempah & Bumbu
  { original_name: "dill",              corrected_name: "daun dill" },
  { original_name: "sereh",             corrected_name: "serai" },
  { original_name: "btng sere geprek",  corrected_name: "serai" },
  { original_name: "jintan biji",       corrected_name: "biji jintan" },
  { original_name: "jinten bubuk",      corrected_name: "jintan bubuk" },
  { original_name: "ketumbar bubuk",    corrected_name: "ketumbar" },
  { original_name: "kayu manis bubuk",  corrected_name: "kayu manis" },
  { original_name: "sedikit biji pala", corrected_name: "biji pala" },

  // Sayuran & Buah
  { original_name: "paprika merah panggang",  corrected_name: "paprika merah" },
  { original_name: "bit rebus",               corrected_name: "bit" },
  { original_name: "buncis dan wortel di kukus", corrected_name: "buncis" },
  { original_name: "timun",                   corrected_name: "mentimun" },
  { original_name: "bayam baby",              corrected_name: "bayam" },
  { original_name: "buah beri campuran",      corrected_name: "buah beri campur" },
  { original_name: "salad hijau",             corrected_name: "selada" },

  // Karbohidrat & Sereal
  { original_name: "oat gulung",                    corrected_name: "oat" },
  { original_name: "oat tradisional",               corrected_name: "oat" },
  { original_name: "campuran bulgur dan quinoa",    corrected_name: "bulgur" },
  { original_name: "quinoa siap santap",            corrected_name: "quinoa" },
  { original_name: "makaroni rebus",                corrected_name: "makaroni" },
  { original_name: "pasta matang",                  corrected_name: "pasta" },
  { original_name: "mie gandum utuh",               corrected_name: "mie gandum" },
  { original_name: "mini bagel",                    corrected_name: "bagel" },
  { original_name: "roti pita panggang",            corrected_name: "roti pita" },
  { original_name: "tortilla wrap",                 corrected_name: "tortilla" },

  // Tepung
  { original_name: "tepung bumbu ayam instan uk besar campur sedikit tepung terigu", corrected_name: "tepung bumbu ayam" },
  { original_name: "tepung bumbu serbaguna larutkan dgn 75 ml air",                  corrected_name: "tepung bumbu serbaguna" },
  { original_name: "tepung roti/ tepung panir",                                      corrected_name: "tepung panir" },

  // Kacang & Biji
  { original_name: "pine nut panggang",        corrected_name: "pine nut" },
  { original_name: "kacang butter kalengan",   corrected_name: "kacang butter" },
  { original_name: "kacang hitam kalengan",    corrected_name: "kacang hitam" },
  { original_name: "kelapa serut panggang",    corrected_name: "kelapa serut" },

  // Susu & Olahan
  { original_name: "sour cream",       corrected_name: "krim asam" },
  { original_name: "butter",           corrected_name: "mentega" },
  { original_name: "butter / margarin",corrected_name: "margarin" },
  { original_name: "susu cair",        corrected_name: "susu" },
  { original_name: "yogurt",           corrected_name: "yogurt plain" },

  // Saus & Kondimen
  { original_name: "saos cabe",            corrected_name: "saus sambal" },
  { original_name: "saus cabai",           corrected_name: "saus sambal" },
  { original_name: "saos hoisin",          corrected_name: "saus hoisin" },
  { original_name: "saos teriyaki",        corrected_name: "saus teriyaki" },
  { original_name: "saos teriyaki 2 sdm",  corrected_name: "saus teriyaki" },
  { original_name: "passata (puree tomat)",corrected_name: "passata" },
  { original_name: "tomat cincang kalengan", corrected_name: "tomat" },

  // Non-bahan (blacklist) — corrected_name: null = bukan makanan
  { original_name: "arang untuk memanggang ayam", corrected_name: null },
];

// ── Helpers ───────────────────────────────────────────────

async function getAdminToken() {
  const res = await fetch(`${BASE_URL}/api/collections/_superusers/auth-with-password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ identity: ADMIN_EMAIL, password: ADMIN_PASSWORD }),
  });
  if (!res.ok) throw new Error(`Login gagal: ${await res.text()}`);
  return (await res.json()).token;
}

async function upsertCorrection(token, item) {
  const payload = {
    original_name:   item.original_name,
    corrected_name:  item.corrected_name ?? '',   // PocketBase tidak terima null untuk text
    correction_count: item.correction_count ?? 1,
  };

  const res = await fetch(`${BASE_URL}/api/collections/ingredient_corrections/records`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    const err = await res.text();
    // Jika duplikat unique index, anggap OK (sudah ada)
    if (err.includes('unique') || err.includes('duplicate') || err.includes('already exists')) {
      return 'skip';
    }
    throw new Error(err);
  }
  return 'ok';
}

// ── Main ──────────────────────────────────────────────────

async function main() {
  console.log('🔧 Seed ingredient_corrections');
  console.log(`   Server : ${BASE_URL}`);
  console.log(`   Total  : ${corrections.length} entri\n`);

  let token;
  try {
    token = await getAdminToken();
    console.log('✅ Login admin berhasil\n');
  } catch (e) {
    console.error('❌', e.message);
    process.exit(1);
  }

  let ok = 0, skipped = 0, failed = 0;

  for (const item of corrections) {
    try {
      const result = await upsertCorrection(token, item);
      if (result === 'skip') {
        console.log(`  ⚠️  SKIP (duplikat): ${item.original_name}`);
        skipped++;
      } else {
        console.log(`  ✅ ${item.original_name} → ${item.corrected_name ?? '(blacklist)'}`);
        ok++;
      }
    } catch (e) {
      console.error(`  ❌ GAGAL: ${item.original_name} — ${e.message}`);
      failed++;
    }
  }

  console.log(`\n🎉 Selesai! Berhasil: ${ok} | Skip: ${skipped} | Gagal: ${failed}`);
}

main().catch(e => {
  console.error('\n❌ Fatal:', e.message);
  process.exit(1);
});
