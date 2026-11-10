import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../tema.dart';
import 'komponen.dart';
import 'widgets.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});
  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  int _kunci = 0;

  Future<void> _buka(Json t) async {
    final jenis = t['jenis'] as String;
    final id = t['id_tugas'] as int;
    if (jenis == 'rakit') {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text('Rakit organ 3D', style: gayaTampilan(22)),
          content: const Text(
            'Permainan merakit organ memakai pemasangan bagian dalam 3D dan tersedia di versi web ARnatomy. Versi mobile menyusul.',
            style: TextStyle(height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            jenis == 'kuis' ? KuisScreen(id: id) : SimulasiScreen(id: id),
      ),
    );
    if (mounted) {
      setState(() => _kunci++); /* segarkan skor setelah mengerjakan */
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();
    return DataView<List<dynamic>>(
      key: ValueKey(_kunci),
      muat: api.tugas,
      bangun: (context, daftar) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, ruangBilahTab + 16),
        children: [
          const KepalaHalaman(
            mikro: 'Tugas',
            judul: 'Tugas belajar',
            keterangan: 'Skor dihitung server. Tugas selesai bila skor mencapai ambang.',
          ),
          const SizedBox(height: 24),
          for (final t in daftar.cast<Json>()) ...[
            _KartuTugas(tugas: t, onTap: () => _buka(t)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _KartuTugas extends StatelessWidget {
  const _KartuTugas({required this.tugas, required this.onTap});
  final Json tugas;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final jenis = tugas['jenis'] as String;
    final selesai = tugas['selesai'] as bool? ?? false;
    final ikon = switch (jenis) {
      'kuis' => Icons.quiz_rounded,
      'simulasi' => Icons.timeline_rounded,
      _ => Icons.extension_rounded,
    };
    final nama = switch (jenis) {
      'kuis' => 'Kuis',
      'simulasi' => 'Simulasi',
      _ => 'Rakit organ',
    };
    final dicoba = tugas['percobaan'] as int? ?? 0;
    return KartuPutih(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Warna.abu,
                  shape: BoxShape.circle,
                ),
                child: Icon(ikon, size: 20, color: Warna.biru),
              ),
              const SizedBox(width: 12),
              Lencana(
                nama,
                tipe: jenis == 'kuis' ? TipeLencana.netral : TipeLencana.gelap,
              ),
              const Spacer(),
              if (selesai) const Lencana('Selesai', tipe: TipeLencana.hijau),
            ],
          ),
          const SizedBox(height: 14),
          Text(tugas['judul'] as String, style: gayaTampilan(20, tinggi: 1.2)),
          const SizedBox(height: 6),
          Text(
            tugas['deskripsi'] as String,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Warna.netral500,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            dicoba == 0
                ? 'Belum dicoba · lulus ≥ ${tugas['ambang']}'
                : 'Skor terbaik ${tugas['skor_terbaik']} · lulus ≥ ${tugas['ambang']} · $dicoba× dicoba',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Warna.netral400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ringkasan hasil percobaan (dipakai kuis dan simulasi).
class HasilView extends StatelessWidget {
  const HasilView({
    super.key,
    required this.hasil,
    required this.rincian,
    required this.ulang,
  });
  final Json hasil;
  final List<Widget> rincian;
  final VoidCallback ulang;
  @override
  Widget build(BuildContext context) {
    final selesai = hasil['selesai'] as bool? ?? false;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        KartuPutih(
          warna: selesai ? Warna.biru : Colors.white,
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Mikro('Hasil', warna: selesai ? Colors.white70 : null),
              const SizedBox(height: 6),
              Text(
                '${hasil['skor']}',
                style: gayaTampilan(
                  72,
                  berat: FontWeight.w700,
                  warna: selesai ? Colors.white : Warna.teks,
                ),
              ),
              Text(
                '${hasil['benar']} dari ${hasil['total']} benar',
                style: TextStyle(
                  fontSize: 15,
                  color: selesai ? Colors.white70 : Warna.netral500,
                ),
              ),
              const SizedBox(height: 14),
              Lencana(
                selesai
                    ? 'Tugas selesai'
                    : 'Belum mencapai ambang ${hasil['ambang']}',
                tipe: selesai ? TipeLencana.gelap : TipeLencana.amber,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...rincian,
        const SizedBox(height: 8),
        FilledButton(onPressed: ulang, child: const Text('Coba lagi')),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kembali ke daftar tugas'),
        ),
      ],
    );
  }
}

/// Satu baris rincian hasil, ikon benar atau salah.
class _BarisHasil extends StatelessWidget {
  const _BarisHasil({
    required this.benar,
    required this.judul,
    this.keterangan,
  });
  final bool benar;
  final String judul;
  final String? keterangan;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: KartuPutih(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              benar ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: benar ? Warna.hijau : Warna.merah,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  if (keterangan != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      keterangan!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Warna.netral500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KuisScreen extends StatefulWidget {
  const KuisScreen({super.key, required this.id});
  final int id;
  @override
  State<KuisScreen> createState() => _KuisScreenState();
}

class _KuisScreenState extends State<KuisScreen> {
  late final ApiClient _api = context.read<ApiClient>();
  late Future<Json> _f = _api.isiTugas(widget.id);
  List<int>? _jawab;
  Json? _hasil;
  bool _sibuk = false;

  Future<void> _kirim() async {
    setState(() => _sibuk = true);
    try {
      final h = await _api.kirimPercobaan(widget.id, _jawab!);
      if (mounted) setState(() => _hasil = h);
    } on ApiException catch (e) {
      if (mounted) tampilkanSnack(context, e.pesan);
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kuis')),
      body: FutureBuilder<Json>(
        future: _f,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return GalatView(
              pesan: pesanGalat(snap.error),
              ulang: () => setState(() => _f = _api.isiTugas(widget.id)),
            );
          }
          final soal = ((snap.data!['soal'] as List?) ?? const []).cast<Json>();
          _jawab ??= List.filled(soal.length, -1);
          if (_hasil != null) {
            final rincian = ((_hasil!['rincian'] as List?) ?? const [])
                .cast<Json>();
            return HasilView(
              hasil: _hasil!,
              ulang: () => setState(() {
                _hasil = null;
                _jawab = List.filled(soal.length, -1);
              }),
              rincian: [
                for (var i = 0; i < rincian.length; i++)
                  _BarisHasil(
                    benar: rincian[i]['benar'] == true,
                    judul: '${i + 1}. ${soal[i]['pertanyaan']}',
                    keterangan:
                        'Jawaban benar: ${(soal[i]['pilihan'] as List)[rincian[i]['jawaban_benar'] as int]}\n${rincian[i]['penjelasan']}',
                  ),
              ],
            );
          }
          final terjawab = _jawab!.where((x) => x != -1).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const Mikro('Kuis'),
              const SizedBox(height: 8),
              JudulTitik(snap.data!['judul'] as String, ukuran: 28),
              const SizedBox(height: 16),
              BilahProgres(nilai: soal.isEmpty ? 0 : terjawab / soal.length),
              const SizedBox(height: 6),
              Text(
                '$terjawab dari ${soal.length} terjawab',
                style: const TextStyle(fontSize: 12.5, color: Warna.netral400),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < soal.length; i++) ...[
                KartuPutih(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}. ${soal[i]['pertanyaan']}',
                        style: gayaTampilan(17, tinggi: 1.3),
                      ),
                      const SizedBox(height: 12),
                      for (final (j, p)
                          in (soal[i]['pilihan'] as List)
                              .cast<String>()
                              .indexed)
                        _Pilihan(
                          teks: p,
                          terpilih: _jawab![i] == j,
                          onTap: () => setState(() => _jawab![i] = j),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: (_sibuk || terjawab < soal.length) ? null : _kirim,
                child: Text(
                  terjawab == soal.length
                      ? 'Kirim jawaban'
                      : 'Jawab semua soal ($terjawab/${soal.length})',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Pilihan extends StatelessWidget {
  const _Pilihan({
    required this.teks,
    required this.terpilih,
    required this.onTap,
  });
  final String teks;
  final bool terpilih;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: terpilih ? Warna.biru.withValues(alpha: 0.08) : Warna.abu,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: terpilih ? Warna.biru : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  terpilih
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: terpilih ? Warna.biru : Warna.netral400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    teks,
                    style: const TextStyle(fontSize: 14.5, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simulasi alur: susun langkah-langkah dengan urutan yang benar. Server mengirim urutan benar, jadi diacak di klien.
class SimulasiScreen extends StatefulWidget {
  const SimulasiScreen({super.key, required this.id});
  final int id;
  @override
  State<SimulasiScreen> createState() => _SimulasiScreenState();
}

class _SimulasiScreenState extends State<SimulasiScreen> {
  late final ApiClient _api = context.read<ApiClient>();
  late Future<Json> _f = _api.isiTugas(widget.id);
  List<Json>? _urut;
  Json? _hasil;
  bool _sibuk = false;

  void _acak(List<Json> langkah) {
    final l = [...langkah];
    do {
      l.shuffle(Random());
    } while (l.length > 1 && _samaDenganAsli(l, langkah));
    _urut = l;
  }

  bool _samaDenganAsli(List<Json> a, List<Json> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i]['id_langkah'] != b[i]['id_langkah']) return false;
    }
    return true;
  }

  Future<void> _kirim() async {
    setState(() => _sibuk = true);
    try {
      final h = await _api.kirimPercobaan(widget.id, [
        for (final l in _urut!) l['id_langkah'] as int,
      ]);
      if (mounted) setState(() => _hasil = h);
    } on ApiException catch (e) {
      if (mounted) tampilkanSnack(context, e.pesan);
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulasi alur')),
      body: FutureBuilder<Json>(
        future: _f,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return GalatView(
              pesan: pesanGalat(snap.error),
              ulang: () => setState(() => _f = _api.isiTugas(widget.id)),
            );
          }
          final langkah = ((snap.data!['langkah'] as List?) ?? const [])
              .cast<Json>();
          if (_urut == null) _acak(langkah);
          if (_hasil != null) {
            final rincian = ((_hasil!['rincian'] as List?) ?? const [])
                .cast<Json>();
            return HasilView(
              hasil: _hasil!,
              ulang: () => setState(() {
                _hasil = null;
                _acak(langkah);
              }),
              rincian: [
                for (final r in rincian)
                  _BarisHasil(
                    benar: r['benar'] == true,
                    judul: 'Posisi ${r['posisi']}: ${r['judul_benar']}',
                  ),
              ],
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Mikro('Simulasi'),
                      const SizedBox(height: 8),
                      JudulTitik(snap.data!['judul'] as String, ukuran: 28),
                      const SizedBox(height: 8),
                      const Text(
                        'Tahan dan geser untuk mengurutkan langkah dari awal sampai akhir.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Warna.netral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  onReorderItem: (a, b) =>
                      setState(() => _urut!.insert(b, _urut!.removeAt(a))),
                  proxyDecorator: (child, i, anim) =>
                      Material(color: Colors.transparent, child: child),
                  children: [
                    for (final (i, l) in _urut!.indexed)
                      Padding(
                        key: ValueKey(l['id_langkah']),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: KartuPutih(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Warna.biru,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l['judul'] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l['deskripsi'] as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        height: 1.35,
                                        color: Warna.netral500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.drag_indicator_rounded,
                                color: Warna.netral400,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _sibuk ? null : _kirim,
                      child: const Text('Periksa urutan'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
