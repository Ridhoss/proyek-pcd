# Smart Patrol Vision App (Flutter + OpenCV)

- **Nama** : Ridho Sulistyo S
- **NIM**  : 241511059
- **Kelas**: 2B-D3

Aplikasi ini dibuat untuk memenuhi tugas Pemrograman Citra Digital yang merupakan bagian dari modul **Proyek PY4AI Modul 6 – Dasar Vision & Interface**, yang berfokus pada implementasi **Computer Vision di Flutter** menggunakan kamera sebagai input dan **OpenCV** untuk pemrosesan citra.


## Deskripsi Proyek

Aplikasi ini merupakan evolusi dari Logbook App menjadi **Smart-Patrol System**, yang mampu:

* Mengakses kamera secara real-time
* Menampilkan **live camera preview**
* Menambahkan **overlay visual (CustomPainter)**
* Melakukan **image processing menggunakan OpenCV**

---

## Konfigurasi Kamera

### Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>

<uses-feature android:name="android.hardware.camera"/>
<uses-feature android:name="android.hardware.camera.autofocus"/>
```

## Cara Menjalankan Project

```bash
# Clone project
git clone https://github.com/Ridhoss/proyek-pcd.git

# Masuk folder
cd proyek-pcd

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

---

## Fitur Utama (Modul 6)

### Vision Setup

* Kamera berhasil diakses
* Live preview tampil
* Kamera auto dispose saat background

---

## Image Processing

Fitur yang tersedia:

* Grayscale
* Edge Detection
* Brightness & Contrast
* Gaussian Blur
* Sharpening
* Inverse
* High Pass Filter
* Histogram Equalization
---

## Troubleshooting

### Kamera tidak muncul

* Pastikan permission di-allow
* Gunakan real device

### Build error

```bash
flutter clean
flutter pub get
```

### Emulator tidak detect kamera

* Aktifkan camera di AVD Manager

---

## Repository

https://github.com/SalmaArifahZahra/-PY4AI_2B_D3_2024-_Modul6_062.git