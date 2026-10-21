import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../state/auth_model.dart';
import 'widgets.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key, required this.pindahTab});
  final void Function(int) pindahTab;

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();
    final nama = context.select<AuthModel, String>(
      (a) => a.pengguna?.nama ?? '',
    );
    final depan = nama.split(' ').first;
    return DataView<Json>(
      muat: api.progres,
      bangun: (context, p) {
        final total = p['tugas_total'] as int? ?? 0;
        final selesai = p['tugas_selesai'] as int? ?? 0;
        final persen = (p['persen_selesai'] as num?)?.toDouble() ?? 0;
        final terbaru = (p['percobaan_terbaru'] as List?) ?? const [];
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Halo, $depan',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text('Lanjutkan belajar anatomi hari ini.'),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progres tugas belajar'),
                    const SizedBox(height: 6),
                    Text(
                      '$selesai dari $total tugas selesai',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (persen / 100).clamp(0, 1),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p['rata_skor_terbaik'] == null
                          ? 'Belum ada skor.'
                          : 'Rata-rata skor terbaik: ${p['rata_skor_terbaik']}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Pintasan(
                      ikon: Icons.view_in_ar,
                      label: 'Jelajahi 3D dan AR',
                      aksi: () => pindahTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Pintasan(
                      ikon: Icons.chat_bubble,
                      label: 'Tanya asisten',
                      aksi: () => pindahTab(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Pintasan(
              ikon: Icons.checklist,
              label: 'Kerjakan tugas',
              aksi: () => pindahTab(3),
            ),
            if (terbaru.isNotEmpty) ...[
              const SizedBox(height: 24),
              Seksi(
                judul: 'Percobaan terbaru',
                anak: Card(
                  child: Column(
                    children: [
                      for (final e in terbaru.take(4).cast<Json>())
                        ListTile(
                          title: Text(e['judul'] as String),
                          subtitle: Text(
                            '${e['benar']} dari ${e['total']} benar',
                          ),
                          trailing: Text(
                            '${e['skor']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Pintasan extends StatelessWidget {
  const _Pintasan({
    required this.ikon,
    required this.label,
    required this.aksi,
  });
  final IconData ikon;
  final String label;
  final VoidCallback aksi;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: aksi,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(ikon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
