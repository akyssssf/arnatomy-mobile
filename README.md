# ARnatomy Mobile

Aplikasi mobile (Flutter) untuk ARnatomy: belajar anatomi jantung dan paru-paru dengan model 3D, AR, asisten AI, dan tugas belajar.
Aplikasi ini hanyalah **klien** dari backend ARnatomy (repo `arnatomy-backend`, API `/v1`); semua data, skor, dan akun ada di server.

## Fitur

| Layar | Isi | Endpoint backend |
| --- | --- | --- |
| Masuk / Daftar | Login email + kata sandi (siswa/guru), token JWT di penyimpanan aman perangkat, refresh otomatis | `/v1/auth/login`, `/register`, `/refresh`, `/me`, `/logout` |
| Beranda | Progres tugas belajar, percobaan terbaru | `/v1/tugas/progres` |
| Eksplorasi | Daftar organ, model 3D (putar/zoom), **AR di iPhone** lewat Quick Look (berkas `.usdz` terbawa di aplikasi); fakta, label bagian tubuh (dasar dan lanjutan) | `/v1/organ`, `/organ/:id`, `/bagian/:id/konten` |
| Asisten | Tanya jawab berbasis buku (RAG) dengan sumber; pilihan jenjang SMP/SMA | `/v1/asisten/tanya` |
| Tugas | Kuis dan simulasi urutan alur (dinilai server) | `/v1/tugas`, `/tugas/:id`, `/tugas/:id/percobaan` |
| Profil | Data akun, riwayat belajar, keluar | `/v1/riwayat`, `/v1/auth/logout` |

Membuka bagian tubuh dicatat sebagai riwayat belajar (durasi dihitung server).

## Batasan yang diketahui

- **Target utama: iPhone.** Android ikut dibangun dari kode yang sama (APK rilis berhasil dibuat), tetapi belum dicoba di perangkat dan belum punya AR.
- **AR di iPhone** memakai AR Quick Look milik iOS: tombol "Lihat di ruanganmu" memanggil kode Swift (`ios/Runner/AppDelegate.swift`) yang membuka berkas `.usdz`
  dari dalam aplikasi. Model berukuran nyata (jantung ±12 cm, paru-paru ±26 cm); cubit untuk memperbesar. Label belum menempel pada model seperti di versi web.
  Berkas `.usdz` dibuat dari model web lewat Blender (poligon dikurangi ke 40% agar ±7 MB) dan lolos `usdchecker`; kode Swift dan AR belum dicoba di perangkat.
- **Model dibawa aplikasi** (`assets/models/`, ±16 MB) sehingga tidak bergantung pada server web. Model unggahan admin tampil di 3D lewat alamatnya, tanpa AR.
- **Rakit organ 3D** (FR-18) hanya ada di versi web; di aplikasi hanya menampilkan keterangan.
- **Login Google** belum ada di aplikasi (butuh Client ID iOS). Akun dibuat lewat Daftar, atau akun yang sudah ada.
- Simulator iOS tidak mendukung AR maupun kamera; uji AR harus di iPhone sungguhan.

## Menjalankan di iPhone

Prasyarat: macOS, Xcode, Flutter 3.47+, CocoaPods (`brew install cocoapods`), iPhone dengan kabel.

1. Di iPhone: **Pengaturan → Privasi & Keamanan → Mode Pengembang** aktif, sambungkan kabel, ketuk "Percayai".
2. Di Xcode: **Settings → Accounts** tambahkan Apple ID.
3. `open ios/Runner.xcworkspace`, pilih target **Runner → Signing & Capabilities**: centang *Automatically manage signing*, pilih **Team** (Personal Team),
   dan ganti **Bundle Identifier** menjadi yang unik (mis. `id.ac.uns.<namamu>.arnatomy`).
4. `flutter devices` harus menampilkan iPhone-mu. Jalankan backend (lihat bawah), lalu:
   ```bash
   flutter run --release --dart-define=API_BASE=http://<IP-Mac>:4000
   ```
5. Pertama kali: iPhone **Pengaturan → Umum → VPN & Manajemen Perangkat** → percayai profil pengembangmu.

Catatan: Apple ID gratis menandatangani aplikasi selama **7 hari**; setelah itu pasang ulang dengan langkah 4.

**Backend untuk iPhone.** Server produksi percobaan (Railway) sudah dimatikan, jadi jalankan backend di Mac yang sama Wi-Fi-nya dengan iPhone:
```bash
cd ../arnatomy-backend && npm ci && npm run dev      # http://localhost:4000, data dan akun demo siap (hanya mode dev)
ipconfig getifaddr en0                               # IP Mac, mis. 10.111.10.9 -> API_BASE=http://10.111.10.9:4000
```
Akun demo: `siswa@arnatomy.id` / `siswa123`. Saat pertama dibuka, iOS meminta izin "Jaringan Lokal": pilih Izinkan.
Gambar organ memakai `WEB_BASE` (situs web) dan bisa kosong tanpa server itu; model 3D dan AR tidak terpengaruh karena dibawa aplikasi.

Alamat server dapat diganti saat build: `--dart-define=API_BASE=...` dan `--dart-define=WEB_BASE=...` (`WEB_BASE` = situs web yang menyajikan gambar organ).
Android: `flutter build apk --release`.

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
  config.dart            alamat server
  model_organ.dart       memilih model lokal (.glb dan .usdz) atau alamat untuk tiap organ
  api/api_client.dart    klien HTTP, token, refresh otomatis, galat berpesan Indonesia
  state/auth_model.dart  status sesi (Provider)
  ui/                    layar: login, beranda, eksplorasi + detail organ, asisten, tugas (kuis, simulasi), profil + riwayat
test/                    uji klien, layar login, dan integrasi backend
```

## Keamanan

- Token JWT disimpan di Keystore Android / Keychain iOS (`flutter_secure_storage`), bukan di preferensi biasa.
- Lalu lintas http polos hanya diizinkan ke `localhost` (server lokal penampil 3D); sisanya wajib HTTPS (`NSAllowsLocalNetworking` di iOS, `network_security_config.xml` di Android).
- Opsi `DEV_ACCESS`/`DEV_REFRESH` hanya bekerja di mode debug dan diabaikan pada build rilis.

Model 3D: HuBMAP Human Reference Atlas, CC BY 4.0 (lihat `ATTRIBUTION.md`).
