import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

/// Galat dari server ({pesan, kode}) atau jaringan; `pesan` aman ditampilkan ke pengguna.
class ApiException implements Exception {
  ApiException(this.pesan, {this.status, this.kode});
  final String pesan;
  final int? status;
  final String? kode;
  @override
  String toString() => pesan;
}

typedef PasanganToken = ({String access, String refresh});

abstract class PenyimpanToken {
  Future<PasanganToken?> baca();
  Future<void> simpan(String access, String refresh);
  Future<void> hapus();
}

/// Token di penyimpanan aman perangkat (Keystore Android / Keychain iOS).
class PenyimpanTokenAman implements PenyimpanToken {
  PenyimpanTokenAman([FlutterSecureStorage? s])
    : _s = s ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;
  @override
  Future<PasanganToken?> baca() async {
    final a = await _s.read(key: 'access');
    final r = await _s.read(key: 'refresh');
    return a == null || r == null ? null : (access: a, refresh: r);
  }

  @override
  Future<void> simpan(String access, String refresh) async {
    await _s.write(key: 'access', value: access);
    await _s.write(key: 'refresh', value: refresh);
  }

  @override
  Future<void> hapus() async {
    await _s.delete(key: 'access');
    await _s.delete(key: 'refresh');
  }
}

/// Untuk uji: token hanya di memori.
class PenyimpanTokenMemori implements PenyimpanToken {
  PasanganToken? _t;
  @override
  Future<PasanganToken?> baca() async => _t;
  @override
  Future<void> simpan(String access, String refresh) async =>
      _t = (access: access, refresh: refresh);
  @override
  Future<void> hapus() async => _t = null;
}

typedef Json = Map<String, dynamic>;

/// Klien backend ARnatomy. Access token (15 menit) ditukar otomatis lewat refresh token (7 hari).
class ApiClient {
  ApiClient({http.Client? klien, PenyimpanToken? penyimpan, String? dasar})
    : _klien = klien ?? http.Client(),
      penyimpan = penyimpan ?? PenyimpanTokenAman(),
      dasar = (dasar ?? Config.apiBase).replaceAll(RegExp(r'/+$'), '');

  final http.Client _klien;
  final PenyimpanToken penyimpan;
  final String dasar;

  /// Dipanggil saat refresh gagal: pengguna harus masuk kembali.
  void Function()? onSesiBerakhir;

  Future<bool>? _segarkan;

  Future<bool> punyaToken() async => await penyimpan.baca() != null;

  Future<Object?> _panggil(
    String metode,
    String path, {
    Object? json,
    Map<String, String>? query,
    bool auth = true,
    bool ulang = true,
  }) async {
    final uri = Uri.parse('$dasar$path').replace(queryParameters: query);
    final token = auth ? await penyimpan.baca() : null;
    final req = http.Request(metode, uri)
      ..headers['Accept'] = 'application/json'
      ..headers.addAll({if (json != null) 'Content-Type': 'application/json'})
      ..headers.addAll({
        if (token != null) 'Authorization': 'Bearer ${token.access}',
      });
    if (json != null) req.body = jsonEncode(json);
    final http.Response r;
    try {
      r = await http.Response.fromStream(
        await _klien.send(req).timeout(const Duration(seconds: 45)),
      );
    } on TimeoutException {
      throw ApiException('Server terlalu lama menjawab. Coba lagi.');
    } catch (_) {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    }
    if (r.statusCode == 401 && auth && ulang && token != null) {
      if (await (_segarkan ??= _tukarToken(token.refresh)
          .whenComplete(() => _segarkan = null))) {
        return _panggil(
          metode,
          path,
          json: json,
          query: query,
          auth: auth,
          ulang: false,
        );
      }
      await penyimpan.hapus();
      onSesiBerakhir?.call();
      throw ApiException('Sesi berakhir, silakan masuk kembali.', status: 401);
    }
    final badan = r.body.isEmpty ? null : _urai(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return badan;
    final m = badan is Map ? badan : const {};
    throw ApiException(
      (m['pesan'] as String?) ?? 'Permintaan gagal (${r.statusCode}).',
      status: r.statusCode,
      kode: m['kode'] as String?,
    );
  }

  Object? _urai(String s) {
    try {
      return jsonDecode(s);
    } on FormatException {
      return null;
    }
  }

  Future<bool> _tukarToken(String refresh) async {
    try {
      final d = await _panggil(
        'POST',
        '/v1/auth/refresh',
        json: {'refresh_token': refresh},
        auth: false,
      ) as Json;
      await penyimpan.simpan(
        d['access_token'] as String,
        d['refresh_token'] as String,
      );
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<Json> _obj(
    String m,
    String p, {
    Object? json,
    Map<String, String>? query,
    bool auth = true,
  }) async =>
      (await _panggil(m, p, json: json, query: query, auth: auth) ??
              <String, dynamic>{})
          as Json;

  Future<List<dynamic>> _daftar(String p, {Map<String, String>? query}) async =>
      (await _panggil('GET', p, query: query) ?? <dynamic>[]) as List<dynamic>;

  // ---- Autentikasi -------------------------------------------------------
  Future<Json> _masuk(String path, Json isi) async {
    final d = await _obj('POST', path, json: isi, auth: false);
    await penyimpan.simpan(
      d['access_token'] as String,
      d['refresh_token'] as String,
    );
    return d['user'] as Json;
  }

  Future<Json> login(String email, String password) =>
      _masuk('/v1/auth/login', {'email': email.trim(), 'password': password});

  Future<Json> daftar({
    required String nama,
    required String email,
    required String password,
    required String role,
    required String asalSekolah,
  }) => _masuk('/v1/auth/register', {
    'nama': nama.trim(),
    'email': email.trim(),
    'password': password,
    'role': role,
    'asal_sekolah': asalSekolah.trim(),
  });

  Future<Json> saya() async =>
      (await _obj('GET', '/v1/auth/me'))['user'] as Json;

  Future<void> keluar() async {
    try {
      await _panggil('POST', '/v1/auth/logout');
    } on ApiException {
      /* token dibuang di klien walau server tidak terjangkau */
    }
    await penyimpan.hapus();
  }

  // ---- Katalog dan konten ------------------------------------------------
  Future<List<dynamic>> organ() => _daftar('/v1/organ');
  Future<Json> organDetail(int id) => _obj('GET', '/v1/organ/$id');
  Future<List<dynamic>> kontenBagian(int idBagian) =>
      _daftar('/v1/bagian/$idBagian/konten');
  Future<List<dynamic>> semuaKonten() => _daftar('/v1/konten');

  // ---- Asisten AI --------------------------------------------------------
  Future<Json> tanya(
    String pertanyaan, {
    String jenjang = 'SMP',
    int? idBagian,
  }) => _obj(
    'POST',
    '/v1/asisten/tanya',
    json: {'pertanyaan': pertanyaan, 'jenjang': jenjang, 'id_bagian': idBagian},
  );

  // ---- Tugas belajar -----------------------------------------------------
  Future<List<dynamic>> tugas() => _daftar('/v1/tugas');
  Future<Json> progres() => _obj('GET', '/v1/tugas/progres');
  Future<Json> isiTugas(int id) => _obj('GET', '/v1/tugas/$id');
  Future<Json> kirimPercobaan(int id, List<int> jawaban) =>
      _obj('POST', '/v1/tugas/$id/percobaan', json: {'jawaban': jawaban});

  // ---- Riwayat belajar ---------------------------------------------------
  Future<Json> riwayat() => _obj('GET', '/v1/riwayat');
  Future<int?> catatRiwayat(int idBagian, String jenis) async {
    final d = await _obj(
      'POST',
      '/v1/riwayat',
      json: {'id_bagian': idBagian, 'jenis_konten': jenis},
    );
    return d['id_riwayat'] as int?;
  }

  Future<void> tutupRiwayat(int idRiwayat) =>
      _obj('PATCH', '/v1/riwayat/$idRiwayat/tutup');
}
