import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../config.dart';
import '../state/auth_model.dart';
import '../tema.dart';
import 'komponen.dart';
import 'widgets.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuthModel>().pengguna;
    if (p == null) return const SizedBox.shrink();
    final inisial = p.nama.trim().isEmpty
        ? '?'
        : p.nama.trim()[0].toUpperCase();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, ruangBilahTab + 16),
      children: [
        const KepalaHalaman(mikro: 'Profil', judul: 'Akunmu'),
        const SizedBox(height: 24),
        KartuPutih(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Warna.biru,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  inisial,
                  style: gayaTampilan(
                    26,
                    berat: FontWeight.w700,
                    warna: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(p.nama, style: gayaTampilan(24)),
              const SizedBox(height: 4),
              Text(
                p.email,
                style: const TextStyle(fontSize: 14, color: Warna.netral500),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Lencana(p.role, tipe: TipeLencana.biru),
                  if (p.sekolah != null && p.sekolah!.isNotEmpty)
                    Lencana(p.sekolah!),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        KartuPutih(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const RiwayatScreen()),
          ),
          child: const Row(
            children: [
              Icon(Icons.history_rounded, color: Warna.biru),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Riwayat belajar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Warna.netral400),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: Warna.merah),
          onPressed: () => context.read<AuthModel>().keluar(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Keluar'),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Server: ${Config.apiBase}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: Warna.netral400),
          ),
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
                  padding: EdgeInsets.all(36),
                  child: Text(
                    'Belum ada riwayat. Buka bagian tubuh di menu Eksplorasi untuk mulai belajar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.5, color: Warna.netral500),
                  ),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              for (final r in rekap)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: KartuPutih(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama[r['id_bagian'] as int] ??
                              'Bagian ${r['id_bagian']}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${r['jumlah']}× dibuka · total ${r['total_durasi']} detik'
                          '${r['dimmed_dibuka'] == true ? ' · materi lanjutan dibuka' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Warna.netral500,
                          ),
                        ),
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
