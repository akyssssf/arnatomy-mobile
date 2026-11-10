import 'dart:convert';

import 'package:arnatomy_mobile/api/api_client.dart';
import 'package:arnatomy_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object o, [int s = 200]) => http.Response(
  jsonEncode(o),
  s,
  headers: {'content-type': 'application/json'},
);

void main() {
  testWidgets('tanpa token: tampil layar masuk; login benar membuka beranda', (
    tester,
  ) async {
    final api = ApiClient(
      penyimpan: PenyimpanTokenMemori(),
      klien: MockClient((r) async {
        if (r.url.path == '/v1/auth/login') {
          return _json({
            'access_token': 'A',
            'refresh_token': 'R',
            'user': {
              'id_user': 1,
              'nama': 'Budi Santoso',
              'email': 'budi@contoh.id',
              'role': 'siswa',
              'asal_sekolah': 'SMAN 1',
            },
          });
        }
        if (r.url.path == '/v1/tugas/progres') {
          return _json({
            'tugas_total': 4,
            'tugas_selesai': 1,
            'persen_selesai': 25,
            'rata_skor_terbaik': 80,
            'percobaan_terbaru': [],
          });
        }
        return _json({'pesan': 'tidak ada'}, 404);
      }),
    );
    await tester.pumpWidget(ArnatomyApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Belum punya akun? Daftar'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();
    expect(find.text('Email wajib diisi.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'budi@contoh.id',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kata sandi'),
      'rahasia123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Halo, Budi', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('1 dari 4 selesai', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('mode daftar menampilkan kolom nama, peran, dan sekolah', (
    tester,
  ) async {
    final api = ApiClient(
      penyimpan: PenyimpanTokenMemori(),
      klien: MockClient((_) async => _json({}, 404)),
    );
    await tester.pumpWidget(ArnatomyApp(api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Belum punya akun? Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Nama lengkap'), findsOneWidget);
    expect(find.text('Asal sekolah'), findsOneWidget);
    expect(find.text('Siswa'), findsOneWidget);
    expect(find.text('Guru'), findsOneWidget);
  });
}
