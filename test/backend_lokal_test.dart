// Uji integrasi terhadap backend ARnatomy sungguhan (tanpa tiruan). Dilewati bila BACKEND_LOKAL tidak diberikan.
//   (di arnatomy-backend)  npm run dev   # akun demo hanya ada di mode pengembangan
//   flutter test test/backend_lokal_test.dart --dart-define=BACKEND_LOKAL=http://localhost:4000
import 'package:arnatomy_mobile/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

const _alamat = String.fromEnvironment('BACKEND_LOKAL');

void main() {
  final lewati = _alamat.isEmpty
      ? 'isi --dart-define=BACKEND_LOKAL=http://localhost:4000'
      : null;

  test('alur klien: login, katalog, konten, asisten, tugas, riwayat', () async {
    final api = ApiClient(dasar: _alamat, penyimpan: PenyimpanTokenMemori());

    final user = await api.login('siswa@arnatomy.id', 'siswa123');
    expect(user['role'], 'siswa');
    expect((await api.saya())['email'], 'siswa@arnatomy.id');

    final organ = (await api.organ()).cast<Json>();
    expect(organ.length, greaterThanOrEqualTo(2));
    expect(organ.first['model'], isA<Map>());
    final detail = await api.organDetail(organ.first['id_organ'] as int);
    final bagian = (detail['bagian'] as List).cast<Json>();
    expect(bagian, isNotEmpty);

    final konten = (await api.kontenBagian(bagian.first['id_bagian'] as int))
        .cast<Json>();
    expect(konten.any((k) => k['jenis_konten'] == 'dasar'), isTrue);

    final idRiwayat = await api.catatRiwayat(
      bagian.first['id_bagian'] as int,
      'dasar',
    );
    expect(idRiwayat, isNotNull);
    await api.tutupRiwayat(idRiwayat!);
    final riwayat = await api.riwayat();
    expect((riwayat['rekap'] as List), isNotEmpty);

    final daftarTugas = (await api.tugas()).cast<Json>();
    final kuis = daftarTugas.firstWhere((t) => t['jenis'] == 'kuis');
    final isiKuis = await api.isiTugas(kuis['id_tugas'] as int);
    final soal = (isiKuis['soal'] as List).cast<Json>();
    final hasilKuis = await api.kirimPercobaan(
      kuis['id_tugas'] as int,
      List.filled(soal.length, 0),
    );
    expect(hasilKuis['total'], soal.length);
    expect(hasilKuis['rincian'], hasLength(soal.length));

    final simulasi = daftarTugas.firstWhere((t) => t['jenis'] == 'simulasi');
    final langkah =
        ((await api.isiTugas(simulasi['id_tugas'] as int))['langkah'] as List)
            .cast<Json>();
    final hasilSim = await api.kirimPercobaan(simulasi['id_tugas'] as int, [
      for (final l in langkah) l['id_langkah'] as int,
    ]);
    expect(hasilSim['skor'], 100);
    expect(hasilSim['selesai'], isTrue);

    final tanya = await api.tanya('Apa fungsi jantung?');
    expect(tanya['jawaban'], isA<String>());
    expect(tanya['sumber'], isA<List>());

    final progres = await api.progres();
    expect(progres['tugas_total'], greaterThan(0));

    await api.keluar();
    expect(await api.punyaToken(), isFalse);
  }, skip: lewati);

  test('login salah menghasilkan pesan dari server', () async {
    final api = ApiClient(dasar: _alamat, penyimpan: PenyimpanTokenMemori());
    await expectLater(
      api.login('siswa@arnatomy.id', 'salah-total'),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)),
    );
  }, skip: lewati);
}
