import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../config.dart';
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
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Eksplorasi',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih organ untuk melihat model 3D dan mencobanya dalam AR.',
          ),
          const SizedBox(height: 16),
          for (final o in daftar.cast<Json>()) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OrganDetailScreen(
                      id: o['id_organ'] as int,
                      nama: o['nama_organ'] as String,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: o['gambar'] == null
                          ? const Icon(Icons.view_in_ar, size: 40)
                          : Image.network(
                              Config.sumberWeb(o['gambar'] as String),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.view_in_ar, size: 40),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o['nama_organ'] as String,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              o['sistem_organ'] as String,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            if (o['julukan'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('"${o['julukan']}"'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
