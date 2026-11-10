import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../config.dart';
import '../tema.dart';
import 'komponen.dart';
import 'organ_detail_screen.dart';
import 'widgets.dart';

class EksplorasiScreen extends StatelessWidget {
  const EksplorasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();
    return DataView<List<dynamic>>(
      muat: api.organ,
      bangun: (context, daftar) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, ruangBilahTab + 16),
        children: [
          const KepalaHalaman(
            mikro: 'Eksplorasi',
            judul: 'Pilih organ',
            keterangan: 'Lihat model 3D, putar, perbesar, dan taruh di ruanganmu dengan AR.',
          ),
          const SizedBox(height: 24),
          for (final o in daftar.cast<Json>()) ...[
            _KartuOrgan(organ: o),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _KartuOrgan extends StatelessWidget {
  const _KartuOrgan({required this.organ});
  final Json organ;
  @override
  Widget build(BuildContext context) {
    final gambar = organ['gambar'] as String?;
    return KartuPutih(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrganDetailScreen(
            id: organ['id_organ'] as int,
            nama: organ['nama_organ'] as String,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 104,
            height: 104,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Warna.abu,
              borderRadius: BorderRadius.circular(18),
            ),
            child: gambar == null
                ? const Icon(
                    Icons.view_in_ar_rounded,
                    size: 36,
                    color: Warna.netral400,
                  )
                : Image.network(
                    Config.sumberWeb(gambar),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.view_in_ar_rounded,
                      size: 36,
                      color: Warna.netral400,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Lencana(organ['sistem_organ'] as String),
                const SizedBox(height: 10),
                JudulTitik(organ['nama_organ'] as String, ukuran: 24),
                if (organ['julukan'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"${organ['julukan']}"',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Warna.netral500,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Warna.netral400),
        ],
      ),
    );
  }
}
