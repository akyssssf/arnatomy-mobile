import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';

class _Pesan {
  _Pesan.user(this.teks) : dariUser = true, sumber = const [], cadangan = false;
  _Pesan.asisten(this.teks, this.sumber, {this.cadangan = false})
    : dariUser = false;
  final bool dariUser;
  final String teks;
  final List<Json> sumber;
  final bool cadangan;
}

class AsistenScreen extends StatefulWidget {
  const AsistenScreen({super.key});
  @override
  State<AsistenScreen> createState() => _AsistenScreenState();
}

class _AsistenScreenState extends State<AsistenScreen> {
  final _kolom = TextEditingController();
  final _gulir = ScrollController();
  final _pesan = <_Pesan>[];
  String _jenjang = 'SMP';
  bool _sibuk = false;

  @override
  void dispose() {
    _kolom.dispose();
    _gulir.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    final q = _kolom.text.trim();
    if (q.isEmpty || _sibuk) return;
    final api = context.read<ApiClient>();
    setState(() {
      _pesan.add(_Pesan.user(q));
      _sibuk = true;
      _kolom.clear();
    });
    _turun();
    try {
      final r = await api.tanya(q, jenjang: _jenjang);
      final sumber = ((r['sumber'] as List?) ?? const []).cast<Json>();
      if (mounted) {
        setState(
          () => _pesan.add(
            _Pesan.asisten(
              r['jawaban'] as String,
              sumber,
              cadangan: r['asal'] == 'lokal',
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _pesan.add(_Pesan.asisten(e.pesan, const [])));
      }
    } finally {
      if (mounted) setState(() => _sibuk = false);
      _turun();
    }
  }

  void _turun() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_gulir.hasClients) {
      _gulir.animateTo(
        _gulir.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Asisten AI',
                  style: t.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'SMP', label: Text('SMP')),
                  ButtonSegment(value: 'SMA', label: Text('SMA')),
                ],
                selected: {_jenjang},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _jenjang = s.first),
              ),
            ],
          ),
        ),
        Expanded(
          child: _pesan.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Tanyakan apa saja tentang jantung, paru-paru, peredaran darah, dan pernapasan. Jawaban disusun dari buku dan disertai sumbernya.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _gulir,
                  padding: const EdgeInsets.all(16),
                  itemCount: _pesan.length + (_sibuk ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _pesan.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return _Gelembung(pesan: _pesan[i]);
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kolom,
                    maxLength: 500,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _kirim(),
                    decoration: const InputDecoration(
                      hintText: 'Tulis pertanyaan…',
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Kirim',
                  onPressed: _sibuk ? null : _kirim,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Gelembung extends StatelessWidget {
  const _Gelembung({required this.pesan});
  final _Pesan pesan;
  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final user = pesan.dariUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: user ? skema.primary : Colors.white,
          border: user ? null : Border.all(color: const Color(0xFFD9D5CA)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              pesan.teks,
              style: TextStyle(color: user ? Colors.white : null),
            ),
            if (pesan.cadangan)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Jawaban dari basis pengetahuan lokal (penjelasan AI sedang tidak tersedia).',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            if (pesan.sumber.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  'Sumber (${pesan.sumber.length})',
                  style: const TextStyle(fontSize: 13),
                ),
                children: [
                  for (final s in pesan.sumber)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${s['buku']}, hlm. ${s['halaman']}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        '${s['cuplikan']}',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
