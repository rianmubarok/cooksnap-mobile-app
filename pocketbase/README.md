# CookSnap — PocketBase Setup & Schema Guide

Dokumen ini berisi panduan lengkap untuk melakukan *setup* PocketBase sebagai *backend* aplikasi CookSnap, konfigurasi email (SMTP), beserta struktur skema databasenya.

---

## 1. Langkah Setup PocketBase

### 1.1 Download & Jalankan PocketBase
1. Download PocketBase versi terbaru dari [pocketbase.io/docs/](https://pocketbase.io/docs/).
2. Ekstrak file executable `pocketbase.exe`. Anda bebas menaruhnya di mana saja (misalnya `D:\PEMROGRAMAN\POCKETBASE`). 
3. Buka terminal di folder tempat `pocketbase.exe` tersebut berada, lalu jalankan:
   ```bash
   ./pocketbase serve
   ```
> Default URL API: `http://127.0.0.1:8090`
> Admin UI Dashboard: `http://127.0.0.1:8090/_/`

### 1.2 Buat Akun Admin
1. Buka Admin UI di browser (`http://127.0.0.1:8090/_/`).
2. Masukkan email dan *password* untuk membuat akun admin pertama Anda.

### 1.3 Import Schema Database (Otomatis)
1. Buka menu **Settings** → **Import Collections** di Admin UI.
2. Upload atau salin isi file `schema/collections.json` (jika ada) ke dalam kolom yang tersedia.
3. Klik **Import**. 
*(Atau Anda bisa membuat koleksinya secara manual mengikuti Panduan Skema di bawah)*.

### 1.4 Update Variabel Lingkungan (.env)
Pastikan Anda mengubah file `.env` di root project Flutter Anda:
```env
GEMINI_API_KEY=your_gemini_api_key_here
POCKETBASE_URL=http://127.0.0.1:8090
```

---

## 2. Setup SMTP (Untuk Fitur Lupa Password & Verifikasi Email)

PocketBase memiliki fitur bawaan untuk mengirim email verifikasi dan reset password. Untuk mengaktifkannya:

1. Buka Admin UI → **Settings** → **Mail settings**.
2. Aktifkan opsi **Use SMTP mail server (recommended)**.
3. Isi kredensial SMTP Anda (contoh menggunakan Gmail / Google App Password, SendGrid, atau Mailgun):
   - **SMTP server host:** `smtp.gmail.com` (atau penyedia lain)
   - **SMTP server port:** `587` atau `465`
   - **SMTP username:** `rupacode0@gmail.com`
   - **SMTP password:** `password_app_google_anda` (Harus menggunakan *App Password* dari Google)
   - **Sender address:** `rupacode0@gmail.com`
   - **Sender name:** `CookSnap App`
4. Di bagian bawah, klik **Send test email** untuk memastikan konfigurasi berhasil.
5. Klik **Save changes**.

---

## 3. Skema Koleksi Database (Collection Schema)

Berikut adalah struktur koleksi yang harus ada di PocketBase.

### 3.1 users (System Collection)
Koleksi bawaan untuk manajemen autentikasi. Tambahkan *custom fields* ini:

| Nama Field | Tipe | Keterangan | Aturan Tambahan |
| :--- | :--- | :--- | :--- |
| `is_premium` | `Bool` | Status langganan pengguna. | Default: `False` |
| `daily_scan_count` | `Number` | Jumlah *scan* hari ini. | Default: `0`, Min: `0` |
| `last_scan_date` | `Text` | Tanggal terakhir *scan* format ISO `YYYY-MM-DD`. | - |
| `pantry` | `Relation` | Relasi ke bahan yang dimiliki di kulkas. | Target: `ingredients`, Max select: `Any` |

### 3.2 ingredients (Base Collection)
Koleksi master daftar bahan makanan.

| Nama Field | Tipe | Keterangan | Aturan Tambahan |
| :--- | :--- | :--- | :--- |
| `name` | `Text` | Nama bahan baku (contoh: "Ayam", "Bawang"). | Required: `True`, Unique: `True` |
| `category` | `Text` | Kategori bahan baku (contoh: "Sumber Protein"). | Required: `True` |

### 3.3 recipes (Base Collection)
Koleksi untuk menyimpan data resep masakan.

| Nama Field | Tipe | Keterangan | Aturan Tambahan |
| :--- | :--- | :--- | :--- |
| `recipe_name` | `Text` | Nama resep masakan. | Required: `True` |
| `description` | `Text` | Deskripsi singkat masakan. | - |
| `image_url` | `Text` | URL gambar resep. | - |
| `ingredients` | `JSON` | Array JSON berisi bahan (nama, jumlah, unit). | Required: `True` |
| `steps` | `JSON` | Array JSON berisi langkah memasak. | Required: `True` |
| `cooking_time` | `Number` | Waktu memasak dalam menit. | Min: `1` |
| `difficulty` | `Select` | Tingkat kesulitan resep. | Options: `Mudah, Sedang, Sulit` |
| `category` | `Text` | Kategori resep. | - |
| `tags` | `JSON` | Array JSON berisi tag tambahan. | - |
| `source_url` | `Text` | URL referensi asli. | - |
| `video_url` | `Text` | URL video YouTube. | - |

### 3.4 favorites (Base Collection)
Koleksi untuk menyimpan resep favorit pengguna.

| Nama Field | Tipe | Keterangan | Aturan Tambahan |
| :--- | :--- | :--- | :--- |
| `user_id` | `Relation` | User yang menyukai. | Target: `users`, Max Select: 1 |
| `recipe_id` | `Relation` | Resep yang disukai. | Target: `recipes`, Max Select: 1 |

---

## 4. API Rules (Hak Akses)

Pastikan mengatur *API Rules* agar aplikasi dapat mengakses data dengan benar:

*   **users**:
    *   List/View: `id = @request.auth.id` (Hanya bisa melihat datanya sendiri)
    *   Create: `""` (Siapa saja bisa mendaftar/register)
    *   Update/Delete: `id = @request.auth.id`
*   **ingredients** & **recipes**:
    *   List/View: `""` (Siapa saja bisa membaca)
    *   Create/Update/Delete: *Hanya Admin (Biarkan kosong / ikon gembok terkunci)*
*   **favorites**:
    *   List/View: `@request.auth.id = user_id` (Hanya melihat favorit sendiri)
    *   Create: `@request.auth.id != '' && @request.auth.id = @request.data.user_id` (Harus login & mengisi user_id sendiri)
    *   Update: *Hanya Admin (Biarkan kosong / ikon gembok terkunci)*
    *   Delete: `@request.auth.id = user_id` (Hanya menghapus favorit sendiri)

---

## 5. Migrasi di Flutter (Selanjutnya)

Jika setup di atas sudah siap, tahap selanjutnya di *codebase* Flutter adalah:
1. Memasang *package* `pocketbase` di `pubspec.yaml`.
2. Mengganti implementasi *dummy* (seperti `SharedPreferences` dan `DummyRecipeRepository`) menjadi menggunakan PocketBase SDK di dalam folder `lib/providers/` dan `lib/data/repositories/`.
