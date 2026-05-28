# CookSnap

CookSnap adalah aplikasi mobile berbasis AI untuk mendeteksi bahan makanan melalui kamera dan memberikan rekomendasi resep berdasarkan bahan yang tersedia.

> “Masak dari apa yang kamu punya sekarang.”

---

### 📥 [Download APK CookSnap v1.0.0](https://github.com/rianmubarok/cooksnap-mobile-app/releases/download/v1.0.0/cooksnap-v1.0.0.apk)

---

# Tech Stack

- Flutter
- PocketBase
- Gemini Vision API
- Provider
- Cloudinary
- Figma

---

# MVP Features

- Splash Screen
- Onboarding
- Login & Register
- Home
- Camera Scanner
- Scan Result
- Recipe Recommendation
- Recipe Detail
- Favorite
- Profile

---

# Project Setup

## 1. Clone Repository

```bash
git clone https://github.com/rianmubarok/cooksnap-mobile-app.git
```

Masuk ke folder project:

```bash
cd cooksnap-mobile-app
```

---

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Run Project

```bash
flutter run
```

---

# Main Development Flow

1. Setup project
2. Static UI
3. Navigation
4. Dummy data
5. Database integration
6. AI integration
7. Testing

---

# Git Workflow

## Main Branch

| Branch      | Fungsi            |
| ----------- | ----------------- |
| main        | versi stabil/demo |
| development | development utama |

---

## Pull Latest Changes

Sebelum mulai kerja:

```bash
git pull origin development
```

---

## Push Changes

```bash
git add .
git commit -m "your commit message"
git push origin development
```

---

# Commit Rules

Gunakan commit yang jelas.

Contoh:

```bash
git commit -m "setup flutter structure"
```

```bash
git commit -m "implement login ui"
```

Hindari:

```bash
git commit -m "fix"
```

atau:

```bash
git commit -m "update"
```

---

# Folder Structure

```text
lib/
│
├── core/
├── models/
├── providers/
├── screens/
├── services/
├── widgets/
└── main.dart
```

---

# Documentation

Dokumentasi lengkap tersedia pada folder:

```text
docs/
```

---

# Project Rules

- Fokus ke MVP
- Jangan menambah fitur besar di tengah development
- Gunakan dummy data jika backend belum siap
- Semua perubahan database harus diskusi terlebih dahulu
- Prioritaskan aplikasi stabil untuk demo
