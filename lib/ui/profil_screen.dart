import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../config.dart';
import '../state/auth_model.dart';
import 'widgets.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuthModel>().pengguna;
    if (p == null) return const SizedBox.shrink();
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Profil',
          style: t.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nama,
                  style: t.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(p.email),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(p.role)),
                    if (p.sekolah != null && p.sekolah!.isNotEmpty)
                      Chip(label: Text(p.sekolah!)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat belajar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RiwayatScreen()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.read<AuthModel>().keluar(),
          icon: const Icon(Icons.logout),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Keluar'),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Server: ${Config.apiBase}',
          style: t.textTheme.bodySmall?.copyWith(color: Colors.black45),
        ),
      ],
    );
  }
}

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat belajar')),
      body: DataView<(Json, List<dynamic>)>(
        muat: () async {
          final hasil = await Future.wait([api.riwayat(), api.semuaKonten()]);
          return (hasil[0] as Json, hasil[1] as List<dynamic>);
        },
        bangun: (context, d) {
          final nama = <int, String>{
            for (final k in d.$2.cast<Json>().where(
              (k) => k['jenis_konten'] == 'dasar',
            ))
              k['id_bagian'] as int: k['judul_tampil'] as String,
          };
          final rekap = ((d.$1['rekap'] as List?) ?? const []).cast<Json>();
          if (rekap.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Belum ada riwayat. Buka bagian tubuh di menu Eksplorasi untuk mulai belajar.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final r in rekap)
                Card(
                  child: ListTile(
                    title: Text(
                      nama[r['id_bagian'] as int] ?? 'Bagian ${r['id_bagian']}',
                    ),
                    subtitle: Text(
                      '${r['jumlah']}x dibuka · total ${r['total_durasi']} detik'
                      '${r['dimmed_dibuka'] == true ? ' · materi lanjutan dibuka' : ''}',
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
