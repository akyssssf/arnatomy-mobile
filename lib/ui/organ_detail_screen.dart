import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../model_organ.dart';
import '../tema.dart';
import 'kaca.dart';
import 'komponen.dart';
import 'widgets.dart';

class OrganDetailScreen extends StatelessWidget {
  const OrganDetailScreen({super.key, required this.id, required this.nama});
  final int id;
  final String nama;

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();
    return Scaffold(
      body: DataView<Json>(
        muat: () => api.organDetail(id),
        bangun: (context, o) => _Isi(organ: o),
      ),
    );
  }
}

class _Isi extends StatelessWidget {
  const _Isi({required this.organ});
  final Json organ;

  @override
  Widget build(BuildContext context) {
    final model = organ['model'] as Json?;
    final pilihan = model == null ? null : modelOrgan(model);
    final url = pilihan?.src;
    final usdz = pilihan?.usdzAset;
    final ios = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final fakta = ((organ['fakta'] as List?) ?? const []).cast<Json>();
    final bagian = ((organ['bagian'] as List?) ?? const []).cast<Json>();
    final atas = MediaQuery.paddingOf(context).top;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            Container(
              height: 400 + atas,
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              padding: EdgeInsets.only(top: atas),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Warna.abu,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: url != null
                  ? ModelViewer(
                      key: ValueKey(url),
                      src: url,
                      alt: 'Model 3D ${organ['nama_organ']}',
                      ar: false,
                      autoRotate: true,
                      cameraControls: true,
                      backgroundColor: Warna.abu,
                    )
                  : const Center(child: Text('Model 3D belum tersedia.')),
            ),
            Positioned(
              top: atas + 10,
              left: 22,
              child: KacaTombolBulat(
                ikon: Icons.arrow_back_ios_new_rounded,
                label: 'Kembali',
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            if (ios && usdz != null)
              Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: _TombolAr(onTap: () => _bukaAr(context, usdz)),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, ruangBilahTab),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Lencana(organ['sistem_organ'] as String),
              const SizedBox(height: 12),
              JudulTitik(organ['nama_organ'] as String, ukuran: 38),
              const SizedBox(height: 8),
              const Text(
                'Geser untuk memutar, cubit untuk memperbesar.',
                style: TextStyle(fontSize: 13, color: Warna.netral400),
              ),
              if (organ['deskripsi'] != null) ...[
                const SizedBox(height: 18),
                Text(
                  organ['deskripsi'] as String,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
              if (fakta.isNotEmpty) ...[
                const SizedBox(height: 28),
                Seksi(
                  judul: 'Fakta singkat',
                  anak: KartuPutih(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        for (final (i, f) in fakta.indexed) ...[
                          if (i > 0) const Divider(indent: 18, endIndent: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    f['label'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Warna.netral500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    f['nilai'] as String,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              if (bagian.isNotEmpty) ...[
                const SizedBox(height: 28),
                Seksi(
                  judul: 'Bagian tubuh, ketuk untuk belajar',
                  anak: Column(
                    children: [
                      for (final b in bagian)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: KartuPutih(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            onTap: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              backgroundColor: Warna.latar,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(32),
                                ),
                              ),
                              builder: (_) => BagianSheet(
                                idBagian: b['id_bagian'] as int,
                                nama: _namaBagian(b),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _namaBagian(b),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Warna.netral400,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Tombol kaca mengambang di atas model: membuka AR Quick Look (iPhone).
class _TombolAr extends StatelessWidget {
  const _TombolAr({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Lihat di ruanganmu dengan AR',
      child: GestureDetector(
        onTap: onTap,
        child: KacaPanel(
          radius: 999,
          sigma: 12,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.view_in_ar_rounded, size: 20, color: Warna.biru),
              SizedBox(width: 10),
              Text(
                'Lihat di ruanganmu (AR)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kanalAr = MethodChannel('id.ac.uns.arnatomy/ar');

/// iPhone: meminta AR Quick Look (kode Swift di ios/Runner/AppDelegate.swift) membuka berkas .usdz yang terbawa di aplikasi.
Future<void> _bukaAr(BuildContext context, String usdzAset) async {
  try {
    await _kanalAr.invokeMethod<void>('quickLook', {'aset': usdzAset});
  } on PlatformException catch (e) {
    if (context.mounted) {
      tampilkanSnack(
        context,
        e.message ?? 'AR tidak dapat dibuka di perangkat ini.',
      );
    }
  } on MissingPluginException {
    if (context.mounted) {
      tampilkanSnack(context, 'AR hanya tersedia di iPhone.');
    }
  }
}

String _namaBagian(Json b) =>
    (b['nama_bagian_internal'] ??
            b['nama_bagian'] ??
            'Bagian ${b['id_bagian']}')
        .toString();

/// Label dasar dan dimmed sebuah bagian. Membuka lembar ini dicatat sebagai riwayat belajar (durasi dihitung server).
class BagianSheet extends StatefulWidget {
  const BagianSheet({super.key, required this.idBagian, required this.nama});
  final int idBagian;
  final String nama;
  @override
  State<BagianSheet> createState() => _BagianSheetState();
}

class _BagianSheetState extends State<BagianSheet> {
  late final ApiClient _api = context.read<ApiClient>();
  late final Future<List<dynamic>> _konten = _api.kontenBagian(widget.idBagian);
  int? _idRiwayat;
  bool _dimmedDicatat = false;

  @override
  void initState() {
    super.initState();
    _catat('dasar').then((id) => _idRiwayat = id);
  }

  Future<int?> _catat(String jenis) async {
    try {
      return await _api.catatRiwayat(widget.idBagian, jenis);
    } on ApiException {
      return null; /* riwayat gagal dicatat tidak boleh menghalangi belajar */
    }
  }

  @override
  void dispose() {
    final id = _idRiwayat;
    if (id != null) _api.tutupRiwayat(id).catchError((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      maxChildSize: 0.92,
      builder: (context, scroll) => FutureBuilder<List<dynamic>>(
        future: _konten,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return GalatView(pesan: pesanGalat(snap.error));
          final daftar = (snap.data ?? const []).cast<Json>();
          final dasar = daftar.where((k) => k['jenis_konten'] == 'dasar');
          final dimmed = daftar.where((k) => k['jenis_konten'] == 'dimmed');
          return ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              const Mikro('Bagian tubuh'),
              const SizedBox(height: 8),
              JudulTitik(widget.nama, ukuran: 28),
              const SizedBox(height: 16),
              if (daftar.isEmpty)
                const Text(
                  'Materi untuk bagian ini belum diterbitkan.',
                  style: TextStyle(color: Warna.netral500),
                ),
              for (final k in dasar) ...[
                KartuPutih(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        k['judul_tampil'] as String,
                        style: gayaTampilan(19),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        k['deskripsi'] as String,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (dimmed.isNotEmpty)
                Material(
                  color: Warna.netral900,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white70,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: const Text(
                        'Pelajari lebih lanjut',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onExpansionChanged: (buka) {
                        if (buka && !_dimmedDicatat) {
                          _dimmedDicatat = true;
                          _catat('dimmed');
                        }
                      },
                      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final k in dimmed) ...[
                          Text(
                            k['judul_tampil'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            k['deskripsi'] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
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
