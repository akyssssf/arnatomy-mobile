/// Alamat server. Dapat diganti saat build:
///   flutter run --dart-define=API_BASE=http://10.0.2.2:4000 --dart-define=WEB_BASE=http://10.0.2.2:3000
class Config {
  /// Backend ARnatomy (API /v1).
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://api-production-8e84.up.railway.app',
  );

  /// Situs web ARnatomy: menyajikan gambar organ dan model unggahan admin. Model bawaan ikut terbawa di aplikasi.
  static const webBase = String.fromEnvironment(
    'WEB_BASE',
    defaultValue: 'https://web-production-0198b5.up.railway.app',
  );

  /// Hanya untuk pengembangan: token awal agar tidak mengetik login saat uji tampilan. Diabaikan di build rilis.
  static const devAccess = String.fromEnvironment('DEV_ACCESS');
  static const devRefresh = String.fromEnvironment('DEV_REFRESH');

  /// Jadikan alamat relatif dari backend/situs menjadi alamat penuh.
  static String sumberWeb(String jalur) => jalur.startsWith('http')
      ? jalur
      : '$webBase${jalur.startsWith('/') ? '' : '/'}$jalur';
}
