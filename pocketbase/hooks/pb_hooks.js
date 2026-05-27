/// onRecordBeforeCreate(e) — Validasi duplikat favorites
///
/// Hook ini mencegah user menambahkan resep yang sama ke favorites dua kali.
/// PocketBase sudah ada unique index, tapi ini memberikan pesan error yang lebih baik.

onRecordBeforeCreateRequest((e) => {
  // Hanya berlaku untuk collection favorites
  if (e.collection?.name !== "favorites") {
    return;
  }

  const userId = e.record?.get("user_id");
  const recipeId = e.record?.get("recipe_id");

  if (!userId || !recipeId) return;

  const existing = $app.dao().findFirstRecordByFilter(
    "favorites",
    `user_id = "${userId}" && recipe_id = "${recipeId}"`
  );

  if (existing) {
    throw new BadRequestError("Resep sudah ada di favorit");
  }
}, "favorites");
