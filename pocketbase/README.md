# CookSnap — PocketBase Setup Guide

Folder ini berisi semua file yang dibutuhkan untuk setup PocketBase backend CookSnap.

## Struktur Folder

```
pocketbase/
├── README.md                   ← Panduan ini
├── schema/
│   └── collections.json        ← Schema semua collection (import via Admin UI)
├── seed/
│   ├── recipes.json            ← Data 10 resep awal
│   ├── ingredients.json        ← Data master bahan makanan
│   └── seed_via_api.js         ← Script seed otomatis via PocketBase API
└── hooks/
    └── pb_hooks.js             ← Custom hooks (opsional)
```

---

## Langkah Setup

### 1. Download & Jalankan PocketBase

```bash
# Download PocketBase dari https://pocketbase.io/docs/
# Letakkan executable di folder ini, lalu jalankan:
./pocketbase serve
```

> Default URL: http://127.0.0.1:8090
> Admin UI: http://127.0.0.1:8090/_/

### 2. Buat Admin Account

- Buka Admin UI di browser
- Buat akun admin pertama

### 3. Import Schema Collection

- Buka Admin UI → Settings → Import Collections
- Upload file `schema/collections.json`
- Klik **Import**

### 4. Seed Data

```bash
# Pastikan Node.js sudah terinstall
# Edit BASE_URL dan ADMIN_TOKEN di seed_via_api.js terlebih dahulu
node seed/seed_via_api.js
```

### 5. Update .env Flutter

Tambahkan ke file `.env` di root project:

```env
GEMINI_API_KEY=your_gemini_api_key_here
POCKETBASE_URL=http://127.0.0.1:8090
```

---

## Collections

| Collection    | Tipe       | Deskripsi                              |
|---------------|------------|----------------------------------------|
| `users`       | Auth       | Autentikasi pengguna (built-in)        |
| `recipes`     | Base       | Data resep masakan                     |
| `ingredients` | Base       | Master daftar bahan makanan            |
| `favorites`   | Base       | Relasi user ↔ resep favorit           |

---

## API Endpoints yang Digunakan Flutter

| Aksi                  | Method | Endpoint                                    |
|-----------------------|--------|---------------------------------------------|
| Register              | POST   | `/api/collections/users/records`            |
| Login                 | POST   | `/api/collections/users/auth-with-password` |
| Get semua resep       | GET    | `/api/collections/recipes/records`          |
| Get resep by ID       | GET    | `/api/collections/recipes/records/:id`      |
| Search resep          | GET    | `/api/collections/recipes/records?filter=`  |
| Get ingredients       | GET    | `/api/collections/ingredients/records`      |
| Get favorites user    | GET    | `/api/collections/favorites/records?filter=`|
| Tambah favorite       | POST   | `/api/collections/favorites/records`        |
| Hapus favorite        | DELETE | `/api/collections/favorites/records/:id`    |
| Update profil         | PATCH  | `/api/collections/users/records/:id`        |

---

## Notes

- `password_hash` tidak perlu dibuat manual — PocketBase Auth menangani hash otomatis.
- Field `profile_image` menggunakan **File field** PocketBase (bukan URL string).
- Untuk production, ganti URL ke domain server PocketBase yang di-deploy.
