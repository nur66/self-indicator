# Self Indicator App

Aplikasi Flutter untuk melakukan penilaian diri (self assessment) dengan form input dan dashboard chart untuk visualisasi data.

## Fitur

- **Form Input**: Tambah indicator baru dengan kategori, skor, dan deskripsi
- **Dashboard**: Visualisasi data dengan chart (line chart untuk trend skor, pie chart untuk distribusi kategori)
- **Daftar Indicator**: Melihat semua indicator yang telah ditambahkan
- **Local Storage**: Data tersimpan secara lokal menggunakan SharedPreferences

## Cara Menjalankan

1. Pastikan Flutter sudah terinstall
2. Clone atau download project ini
3. Jalankan `flutter pub get` untuk menginstall dependencies
4. Jalankan `flutter run` untuk menjalankan aplikasi

## Dependencies

- `fl_chart`: Untuk membuat chart dan grafik
- `shared_preferences`: Untuk menyimpan data secara lokal
- `provider`: Untuk state management
- `intl`: Untuk formatting tanggal

## Struktur Project

```
lib/
├── models/
│   └── indicator_model.dart
├── providers/
│   └── indicator_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── form_screen.dart
│   ├── dashboard_screen.dart
│   └── indicator_list_screen.dart
├── services/
│   └── storage_service.dart
└── main.dart
```

## Kategori Indicator

- Personal
- Professional
- Health
- Education
- Social
- Financial

Setiap indicator memiliki skor 1-10 dan dapat dikategorikan sesuai kebutuhan.