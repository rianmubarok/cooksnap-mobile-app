# Flutter Setup Guide

## 1. Install Software

Pastikan sudah install:

- Flutter SDK
- Android Studio
- Android SDK
- VSCode / Android Studio
- Git

---

# 2. Check Flutter Installation

Jalankan:

```bash
flutter doctor
```

Pastikan tidak ada error merah.

---

# 3. Clone Repository

```bash
git clone https://github.com/USERNAME/cooksnap.git
```

Masuk folder project:

```bash
cd cooksnap
```

---

# 4. Install Dependencies

```bash
flutter pub get
```

---

# 5. Run Project

```bash
flutter run
```

---

# 6. Setup Emulator

Bisa menggunakan:

- Android Emulator
- Physical Device USB Debugging

---

# 7. Struktur Folder Flutter

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

# 8. Install Main Dependencies

## Provider

```bash
flutter pub add provider
```

## HTTP

```bash
flutter pub add http
```

## Camera

```bash
flutter pub add camera
```

## Image Picker

```bash
flutter pub add image_picker
```

---

# 9. Initial Frontend Setup

Yang harus dibuat pertama:

- Routing/navigation
- Folder structure
- Reusable widget
- Theme/app color
- Static UI

Jangan langsung integrasi backend atau AI.

---

# 10. Initial Routing Pages

Page awal yang harus dibuat:

- Splash Screen
- Onboarding
- Login
- Register
- Home

Gunakan dummy data terlebih dahulu.

---

# 11. Git Workflow

Gunakan branch:

```text
development
```

Untuk pengerjaan utama.

Branch:

```text
main
```

Digunakan untuk versi stabil/demo.

---

# 12. Commit Rules

Gunakan commit kecil dan jelas.

Contoh:

```bash
git commit -m "setup flutter structure"
```

```bash
git commit -m "implement login ui"
```

Hindari commit:

```bash
git commit -m "fix"
```

atau:

```bash
git commit -m "update"
```

---

# 13. Important Notes

- Jangan hardcode final data
- Gunakan dummy data jika backend belum siap
- Pastikan UI responsive
- Gunakan reusable widget
- Diskusikan perubahan besar terlebih dahulu
