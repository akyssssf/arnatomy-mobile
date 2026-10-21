import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
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
          title: const Text('Rakit organ 3D'),
          content: const Text(
            'Permainan merakit organ memakai pemasangan bagian dalam 3D dan tersedia di versi web ARnatomy. Versi mobile menyusul.',
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
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Tugas belajar',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Skor dihitung server. Tugas selesai bila skor mencapai ambang.',
          ),
          const SizedBox(height: 16),
          for (final t in daftar.cast<Json>()) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Icon(switch (t['jenis']) {
                  'kuis' => Icons.quiz_outlined,
                  'simulasi' => Icons.timeline,
                  _ => Icons.extension_outlined,
                }),
                title: Text(
                  t['judul'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${t['deskripsi']}\nAmbang ${t['ambang']} · ${t['percobaan']}x dicoba'
                    '${t['skor_terbaik'] == null ? '' : ' · skor terbaik ${t['skor_terbaik']}'}',
                  ),
                ),
                isThreeLine: true,
                trailing: (t['selesai'] as bool? ?? false)
                    ? const Icon(Icons.check_circle, color: Color(0xFF1F7A3D))
                    : const Icon(Icons.chevron_right),
                onTap: () => _buka(t),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '${hasil['skor']}',
                  style: Theme.of(context).textTheme.displayMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text('${hasil['benar']} dari ${hasil['total']} benar'),
                const SizedBox(height: 8),
                Text(
                  selesai
                      ? 'Tugas selesai 🎉'
                      : 'Belum mencapai ambang ${hasil['ambang']}. Coba lagi.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selesai
                        ? const Color(0xFF1F7A3D)
                        : const Color(0xFFA85A00),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...rincian,
        const SizedBox(height: 16),
        FilledButton(onPressed: ulang, child: const Text('Coba lagi')),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kembali ke daftar tugas'),
        ),
      ],
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

  Future<void> _kirim(List<Json> soal) async {
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
                  Card(
                    child: ListTile(
                      leading: Icon(
                        rincian[i]['benar'] == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: rincian[i]['benar'] == true
                            ? const Color(0xFF1F7A3D)
                            : const Color(0xFFB3261E),
                      ),
                      title: Text('${i + 1}. ${soal[i]['pertanyaan']}'),
                      subtitle: Text(
                        'Jawaban benar: ${(soal[i]['pilihan'] as List)[rincian[i]['jawaban_benar'] as int]}\n${rincian[i]['penjelasan']}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
              ],
            );
          }
          final lengkap = !_jawab!.contains(-1);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                snap.data!['judul'] as String,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < soal.length; i++) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ${soal[i]['pertanyaan']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        RadioGroup<int>(
                          groupValue: _jawab![i],
                          onChanged: (v) =>
                              setState(() => _jawab![i] = v ?? -1),
                          child: Column(
                            children: [
                              for (final (j, p)
                                  in (soal[i]['pilihan'] as List)
                                      .cast<String>()
                                      .indexed)
                                RadioListTile<int>(
                                  value: j,
                                  title: Text(p),
                                  contentPadding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton(
                onPressed: (_sibuk || !lengkap) ? null : () => _kirim(soal),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    lengkap
                        ? 'Kirim jawaban'
                        : 'Jawab semua soal (${_jawab!.where((x) => x != -1).length}/${soal.length})',
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
                  Card(
                    child: ListTile(
                      leading: Icon(
                        r['benar'] == true ? Icons.check_circle : Icons.cancel,
                        color: r['benar'] == true
                            ? const Color(0xFF1F7A3D)
                            : const Color(0xFFB3261E),
                      ),
                      title: Text('Posisi ${r['posisi']}: ${r['judul_benar']}'),
                    ),
                  ),
              ],
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snap.data!['judul'] as String,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tahan dan geser untuk mengurutkan langkah dari awal sampai akhir.',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  onReorderItem: (a, b) =>
                      setState(() => _urut!.insert(b, _urut!.removeAt(a))),
                  children: [
                    for (final (i, l) in _urut!.indexed)
                      Card(
                        key: ValueKey(l['id_langkah']),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          title: Text(
                            l['judul'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            l['deskripsi'] as String,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.drag_handle),
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _sibuk ? null : _kirim,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Periksa urutan'),
                      ),
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
