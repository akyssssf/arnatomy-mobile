import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_client.dart';
import '../config.dart';
import 'widgets.dart';

class OrganDetailScreen extends StatelessWidget {
  const OrganDetailScreen({super.key, required this.id, required this.nama});
  final int id;
  final String nama;

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();
    return Scaffold(
      appBar: AppBar(title: Text(nama)),
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
    final url = model == null
        ? null
        : Config.modelMobile(
            model['url'] as String,
            bawaan: model['sumber'] == 'bawaan',
          );
    final usdz = model == null
        ? null
        : Config.modelAr(
            model['url'] as String,
            bawaan: model['sumber'] == 'bawaan',
          );
    final ios = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final fakta = ((organ['fakta'] as List?) ?? const []).cast<Json>();
    final bagian = ((organ['bagian'] as List?) ?? const []).cast<Json>();
    return ListView(
      children: [
        if (url != null)
          SizedBox(
            height: 340,
            child: ModelViewer(
              key: ValueKey(url),
              src: url,
              alt: 'Model 3D ${organ['nama_organ']}',
              // iPhone: AR lewat tombol "Lihat di ruanganmu" (Quick Look membuka berkas .usdz di Safari);
              // Android: tombol AR bawaan viewer (Google Scene Viewer, butuh ARCore).
              ar: !ios,
              arModes: const ['scene-viewer', 'webxr'],
              autoRotate: true,
              cameraControls: true,
              backgroundColor: const Color(0xFFEDEAE0),
            ),
          )
        else
          const SizedBox(
            height: 200,
            child: Center(child: Text('Model 3D belum tersedia.')),
          ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ios ? 'Geser untuk memutar, cubit untuk memperbesar.' : 'Geser untuk memutar, cubit untuk memperbesar. Ketuk ikon AR di pojok model untuk menaruhnya di ruanganmu (perlu perangkat yang mendukung ARCore).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (ios && usdz != null) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _bukaAr(context, usdz),
                  icon: const Icon(Icons.view_in_ar),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Lihat di ruanganmu (AR)'),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Safari akan menampilkan modelnya. Ketuk gambar model, lalu pilih AR dan arahkan kamera ke lantai atau meja. Ukuran model sama seperti organ aslinya; cubit untuk memperbesar.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 20),
              if (organ['deskripsi'] != null) ...[
                Text(organ['deskripsi'] as String),
                const SizedBox(height: 20),
              ],
              if (fakta.isNotEmpty)
                Seksi(
                  judul: 'Fakta singkat',
                  anak: Card(
                    child: Column(
                      children: [
                        for (final f in fakta)
                          ListTile(
                            dense: true,
                            title: Text(f['label'] as String),
                            trailing: Text(f['nilai'] as String),
                          ),
                      ],
                    ),
                  ),
                ),
              if (bagian.isNotEmpty) ...[
                const SizedBox(height: 20),
                Seksi(
                  judul: 'Bagian tubuh (ketuk untuk belajar)',
                  anak: Card(
                    child: Column(
                      children: [
                        for (final b in bagian)
                          ListTile(
                            title: Text(_namaBagian(b)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              builder: (_) => BagianSheet(
                                idBagian: b['id_bagian'] as int,
                                nama: _namaBagian(b),
                              ),
                            ),
                          ),
                      ],
                    ),
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

/// iPhone: berkas .usdz dibuka di Safari, yang menawarkan AR Quick Look (kamera dan ARKit dikelola iOS, tanpa izin tambahan di aplikasi).
Future<void> _bukaAr(BuildContext context, String usdz) async {
  final ok = await launchUrl(
    Uri.parse(usdz),
    mode: LaunchMode.inAppBrowserView,
  );
  if (!ok && context.mounted) {
    tampilkanSnack(context, 'AR tidak dapat dibuka di perangkat ini.');
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
      initialChildSize: 0.6,
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            children: [
              Text(
                widget.nama,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (daftar.isEmpty)
                const Text('Materi untuk bagian ini belum diterbitkan.'),
              for (final k in dasar) ...[
                Text(
                  k['judul_tampil'] as String,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(k['deskripsi'] as String),
                const SizedBox(height: 16),
              ],
              if (dimmed.isNotEmpty)
                ExpansionTile(
                  title: const Text('Pelajari lebih lanjut'),
                  onExpansionChanged: (buka) {
                    if (buka && !_dimmedDicatat) {
                      _dimmedDicatat = true;
                      _catat('dimmed');
                    }
                  },
                  children: [
                    for (final k in dimmed)
                      ListTile(
                        title: Text(k['judul_tampil'] as String),
                        subtitle: Text(k['deskripsi'] as String),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
