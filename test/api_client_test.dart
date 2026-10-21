import 'dart:convert';

import 'package:arnatomy_mobile/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object o, [int status = 200]) => http.Response(
  jsonEncode(o),
  status,
  headers: {'content-type': 'application/json'},
);

const _user = {
  'id_user': 1,
  'nama': 'Budi Santoso',
  'email': 'budi@contoh.id',
  'role': 'siswa',
  'asal_sekolah': 'SMAN 1',
};

void main() {
  test('login menyimpan token dan mengembalikan pengguna', () async {
    final simpan = PenyimpanTokenMemori();
    final api = ApiClient(
      dasar: 'https://api.test/',
      penyimpan: simpan,
      klien: MockClient((r) async {
        expect(r.url.toString(), 'https://api.test/v1/auth/login');
        expect(jsonDecode(r.body), {
          'email': 'budi@contoh.id',
          'password': 'rahasia123',
        });
        return _json({
          'access_token': 'A1',
          'refresh_token': 'R1',
          'user': _user,
        }, 200);
      }),
    );
    final u = await api.login(' budi@contoh.id ', 'rahasia123');
    expect(u['nama'], 'Budi Santoso');
    expect((await simpan.baca())!.access, 'A1');
  });

  test('galat server menjadi ApiException berpesan Indonesia', () async {
    final api = ApiClient(
      penyimpan: PenyimpanTokenMemori(),
      klien: MockClient(
        (_) async => _json({
          'pesan': 'Email atau kata sandi salah.',
          'kode': 'KREDENSIAL_SALAH',
        }, 401),
      ),
    );
    expect(
      () => api.login('a@b.c', 'x'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.pesan, 'pesan', 'Email atau kata sandi salah.')
            .having((e) => e.status, 'status', 401),
      ),
    );
  });

  test('401 pada permintaan terlindungi: token ditukar lalu permintaan diulang sekali', () async {
    final simpan = PenyimpanTokenMemori();
    await simpan.simpan('LAMA', 'REFRESH');
    final panggilan = <String>[];
    final api = ApiClient(
      penyimpan: simpan,
      klien: MockClient((r) async {
        panggilan.add(
          '${r.method} ${r.url.path} ${r.headers['Authorization'] ?? ''}',
        );
        if (r.url.path == '/v1/auth/refresh') {
          expect(jsonDecode(r.body), {'refresh_token': 'REFRESH'});
          return _json({'access_token': 'BARU', 'refresh_token': 'REFRESH2'});
        }
        return r.headers['Authorization'] == 'Bearer BARU'
            ? _json(_bungkusUser())
            : _json({'pesan': 'kedaluwarsa'}, 401);
      }),
    );
    final u = await api.saya();
    expect(u['email'], 'budi@contoh.id');
    expect(panggilan, [
      'GET /v1/auth/me Bearer LAMA',
      'POST /v1/auth/refresh ',
      'GET /v1/auth/me Bearer BARU',
    ]);
    expect((await simpan.baca())!.refresh, 'REFRESH2');
  });

  test('refresh gagal: token dibuang dan sesi dinyatakan berakhir', () async {
    final simpan = PenyimpanTokenMemori();
    await simpan.simpan('LAMA', 'BASI');
    var berakhir = false;
    final api = ApiClient(
      penyimpan: simpan,
      klien: MockClient((_) async => _json({'pesan': 'tidak sah'}, 401)),
    )..onSesiBerakhir = () => berakhir = true;
    await expectLater(
      api.saya(),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)),
    );
    expect(berakhir, isTrue);
    expect(await simpan.baca(), isNull);
  });

  test('jaringan putus menghasilkan pesan yang ramah', () async {
    final api = ApiClient(
      penyimpan: PenyimpanTokenMemori(),
      klien: MockClient((_) async => throw http.ClientException('putus')),
    );
    expect(
      () => api.organ(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.pesan,
          'pesan',
          contains('Tidak dapat terhubung'),
        ),
      ),
    );
  });
}

Map<String, Object> _bungkusUser() => {'user': _user};
