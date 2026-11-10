import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../tema.dart';
import 'kaca.dart';
import 'komponen.dart';

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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: KepalaHalaman(
            mikro: 'Asisten',
            judul: 'Tanya AI',
            aksi: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'SMP', label: Text('SMP')),
                ButtonSegment(value: 'SMA', label: Text('SMA')),
              ],
              selected: {_jenjang},
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              onSelectionChanged: (s) => setState(() => _jenjang = s.first),
            ),
          ),
        ),
        Expanded(
          child: _pesan.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      'Tanyakan apa saja tentang jantung, paru-paru, peredaran darah, dan pernapasan. Jawaban disusun dari buku dan disertai sumbernya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Warna.netral500,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _gulir,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, ruangBilahTab - 6),
          child: KacaPanel(
            radius: 999,
            sigma: 12,
            padding: const EdgeInsets.fromLTRB(20, 4, 6, 4),
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
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Kirim',
                  style: IconButton.styleFrom(
                    backgroundColor: Warna.biru,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _sibuk ? null : _kirim,
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Gelembung percakapan seperti `bubble` di web: pengguna biru, AI abu.
class _Gelembung extends StatelessWidget {
  const _Gelembung({required this.pesan});
  final _Pesan pesan;
  @override
  Widget build(BuildContext context) {
    final user = pesan.dariUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: user ? Warna.biru : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(user ? 20 : 6),
            bottomRight: Radius.circular(user ? 6 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              pesan.teks,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: user ? Colors.white : Warna.teks,
              ),
            ),
            if (pesan.cadangan)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Lencana('Jawaban lokal'),
              ),
            if (pesan.sumber.isNotEmpty)
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  dense: true,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    'Sumber (${pesan.sumber.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Warna.biru,
                    ),
                  ),
                  children: [
                    for (final s in pesan.sumber)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Warna.abu,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s['buku']}, hlm. ${s['halaman']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${s['cuplikan']}',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Warna.netral500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
