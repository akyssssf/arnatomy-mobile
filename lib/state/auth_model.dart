import 'package:flutter/foundation.dart';

import '../api/api_client.dart';

enum StatusSesi { memuat, keluar, masuk }

class Pengguna {
  Pengguna({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.sekolah,
  });
  factory Pengguna.dari(Json j) => Pengguna(
    id: j['id_user'] as int,
    nama: j['nama'] as String,
    email: j['email'] as String,
    role: j['role'] as String,
    sekolah: j['asal_sekolah'] as String?,
  );
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? sekolah;
}

class AuthModel extends ChangeNotifier {
  AuthModel(this.api) {
    api.onSesiBerakhir = () {
      pengguna = null;
      status = StatusSesi.keluar;
      notifyListeners();
    };
  }

  final ApiClient api;
  StatusSesi status = StatusSesi.memuat;
  Pengguna? pengguna;

  /// Memulihkan sesi dari token tersimpan.
  Future<void> mulai() async {
    try {
      if (await api.punyaToken()) {
        pengguna = Pengguna.dari(await api.saya());
        status = StatusSesi.masuk;
      } else {
        status = StatusSesi.keluar;
      }
    } on ApiException {
      status = StatusSesi.keluar;
    }
    notifyListeners();
  }

  Future<void> masuk(String email, String password) async {
    pengguna = Pengguna.dari(await api.login(email, password));
    status = StatusSesi.masuk;
    notifyListeners();
  }

  Future<void> daftar({
    required String nama,
    required String email,
    required String password,
    required String role,
    required String asalSekolah,
  }) async {
    pengguna = Pengguna.dari(
      await api.daftar(
        nama: nama,
        email: email,
        password: password,
        role: role,
        asalSekolah: asalSekolah,
      ),
    );
    status = StatusSesi.masuk;
    notifyListeners();
  }

  Future<void> keluar() async {
    await api.keluar();
    pengguna = null;
    status = StatusSesi.keluar;
    notifyListeners();
  }
}
