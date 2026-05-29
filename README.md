<div align="center">
  <img src="pocketbase/pb_public/Home.jpg" alt="CookSnap Home" width="300"/>

  # 🍳 CookSnap

  **Aplikasi Mobile Berbasis AI untuk Mendeteksi Bahan Makanan & Rekomendasi Resep**

  *“Masak dari apa yang kamu punya sekarang.”*

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![PocketBase](https://img.shields.io/badge/PocketBase-B8DBE4?style=for-the-badge&logo=pocketbase&logoColor=black)](https://pocketbase.io/)
  [![Gemini API](https://img.shields.io/badge/Gemini_API-8E75B2?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)

  ### 📥 [Download APK CookSnap v1.0.0](https://github.com/rianmubarok/cooksnap-mobile-app/releases/download/v1.0.0/cooksnap-v1.0.0.apk)
</div>

---

## ✨ Fitur Utama (MVP)

- 📸 **Camera Scanner**: Deteksi bahan makanan secara instan menggunakan AI (Gemini Vision).
- 🥘 **Recipe Recommendation**: Dapatkan rekomendasi resep cerdas berdasarkan bahan yang berhasil dipindai.
- 🔐 **Authentication**: Login, Register, dan manajemen sesi pengguna yang aman.
- 💖 **Favorite Recipes**: Simpan resep favorit Anda untuk dimasak nanti.
- 👤 **User Profile**: Kelola profil pengguna dengan mudah.
- 📱 **Sleek UI/UX**: Antarmuka modern dan responsif dengan navigasi yang mulus.

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend/BaaS**: PocketBase
- **AI Engine**: Gemini Vision API
- **State Management**: Provider
- **Storage/Image Hosting**: Cloudinary
- **Design**: Figma

---

## 🚀 Instalasi & Setup

### 1. Clone Repository

```bash
git clone https://github.com/rianmubarok/cooksnap-mobile-app.git
cd cooksnap-mobile-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Konfigurasi Environment (Jika ada)
Pastikan Anda sudah menyiapkan file `.env` yang berisi URL PocketBase dan API Key yang dibutuhkan.

### 4. Jalankan Proyek

```bash
flutter run
```

---

## 📂 Struktur Folder

```text
lib/
├── core/         # Konfigurasi, routing, tema, dan konstanta
├── data/         # Repositori dan pemrosesan data (API/Database)
├── models/       # Struktur data (Model)
├── providers/    # State management
├── screens/      # Halaman antarmuka pengguna (UI)
├── services/     # Layanan eksternal (API calls)
├── widgets/      # Komponen UI yang dapat digunakan kembali
└── main.dart     # Entry point aplikasi
```

---

## 👥 Git Workflow

Kami menggunakan branching model sederhana untuk menjaga stabilitas kode.

| Branch      | Fungsi            |
| ----------- | ----------------- |
| `main`        | Versi stabil / Demo siap rilis |
| `development` | Development utama |

### Alur Kerja

1. **Tarik perubahan terbaru** sebelum mulai menulis kode:
   ```bash
   git pull origin development
   ```
2. **Commit perubahan** menggunakan standar format:
   ```bash
   git add .
   git commit -m "feat: implement scanner UI"
   git push origin development
   ```

### 📝 Aturan Commit
Gunakan pesan commit yang jelas dan deskriptif.
✅ **Disarankan:** `git commit -m "setup flutter structure"` atau `"feat: implement login ui"`
❌ **Hindari:** `git commit -m "fix"` atau `"update"`

---

## 📜 Peraturan Proyek
- **Fokus ke MVP**: Jangan menambah fitur besar di tengah development yang belum direncanakan.
- **Gunakan Dummy Data**: Jika backend belum siap, gunakan dummy data terlebih dahulu.
- **Diskusi Database**: Semua perubahan struktur database (PocketBase) harus didiskusikan.
- **Stabilitas Utama**: Prioritaskan aplikasi tetap stabil untuk keperluan demo.

---
*Dokumentasi lebih lanjut dapat dilihat pada folder `docs/`.*
