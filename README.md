# ARnatomy Mobile

Aplikasi mobile (Flutter) untuk ARnatomy: belajar anatomi jantung dan paru-paru dengan model 3D, AR, asisten AI, dan tugas belajar.
Aplikasi ini hanyalah **klien** dari backend ARnatomy (repo `arnatomy-backend`, API `/v1`); semua data, skor, dan akun ada di server.

## Fitur

| Layar | Isi | Endpoint backend |
| --- | --- | --- |
| Masuk / Daftar | Login email + kata sandi (siswa/guru), token JWT di penyimpanan aman perangkat, refresh otomatis | `/v1/auth/login`, `/register`, `/refresh`, `/me`, `/logout` |
| Beranda | Progres tugas belajar, percobaan terbaru | `/v1/tugas/progres` |
| Eksplorasi | Daftar organ, model 3D (putar/zoom) dan **AR** lewat Google Scene Viewer, fakta, label bagian tubuh (dasar dan lanjutan) | `/v1/organ`, `/organ/:id`, `/bagian/:id/konten` |
| Asisten | Tanya jawab berbasis buku (RAG) dengan sumber; pilihan jenjang SMP/SMA | `/v1/asisten/tanya` |
| Tugas | Kuis dan simulasi urutan alur (dinilai server) | `/v1/tugas`, `/tugas/:id`, `/tugas/:id/percobaan` |
| Profil | Data akun, riwayat belajar, keluar | `/v1/riwayat`, `/v1/auth/logout` |

Membuka bagian tubuh dicatat sebagai riwayat belajar (durasi dihitung server).

## Batasan yang diketahui

- **Rakit organ 3D** (FR-18) hanya ada di versi web; di aplikasi hanya menampilkan keterangan.
- **AR** memakai Google Scene Viewer (Android, butuh ARCore). Model ditaruh di ruangan, tetapi label belum menempel pada model seperti di versi web.
  Di iOS, Quick Look membutuhkan berkas `.usdz` yang belum dibuat, jadi iOS baru menampilkan 3D.
- **Login Google** belum ada di aplikasi (butuh Client ID Android). Akun dibuat lewat Daftar, atau akun yang sudah ada.
- Model unggahan admin dipakai apa adanya; model bawaan memakai salinan Draco (`*-mobile.glb`), lihat `lib/config.dart`.
- Belum diuji pada perangkat Android sungguhan dan iOS.

## Menjalankan

Prasyarat: Flutter 3.47+, JDK 17, Android SDK 36 (`flutter doctor` harus hijau untuk Android).

```bash
flutter pub get
flutter run                                   # memakai server produksi (lihat lib/config.dart)
flutter run --dart-define=API_BASE=http://10.0.2.2:4000 --dart-define=WEB_BASE=http://10.0.2.2:3000   # backend lokal dari emulator Android
flutter build apk --release                   # build/app/outputs/flutter-apk/app-release.apk
```

Alamat server dapat diganti saat build lewat `--dart-define=API_BASE=...` dan `WEB_BASE=...`.
`WEB_BASE` adalah situs web ARnatomy yang menyajikan model 3D bawaan (`/models/*.glb`) dan gambar organ.

## Pengujian

```bash
flutter analyze
flutter test                                   # uji klien API (dengan tiruan) dan layar login
# uji integrasi ke backend sungguhan (jalankan `npm run dev` di arnatomy-backend dulu; akun demo hanya ada di mode dev):
flutter test test/backend_lokal_test.dart --dart-define=BACKEND_LOKAL=http://localhost:4000
```

## Struktur

```
lib/
  config.dart            alamat server, pemetaan model mobile
  api/api_client.dart    klien HTTP, token, refresh otomatis, galat berpesan Indonesia
  state/auth_model.dart  status sesi (Provider)
  ui/                    layar: login, beranda, eksplorasi + detail organ, asisten, tugas (kuis, simulasi), profil + riwayat
test/                    uji klien, layar login, dan integrasi backend
```

## Keamanan

- Token JWT disimpan di Keystore Android / Keychain iOS (`flutter_secure_storage`), bukan di preferensi biasa.
- Lalu lintas http polos hanya diizinkan ke `localhost` (server lokal penampil 3D); sisanya wajib HTTPS (`network_security_config.xml`).
- Opsi `DEV_ACCESS`/`DEV_REFRESH` hanya bekerja di mode debug dan diabaikan pada build rilis.

Model 3D: HuBMAP Human Reference Atlas, CC BY 4.0 (lihat `ATTRIBUTION.md` di repo frontend).
