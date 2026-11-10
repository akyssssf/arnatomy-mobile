import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../state/auth_model.dart';
import '../tema.dart';
import 'komponen.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, ruangBilahTab + 16),
          children: [
            KepalaHalaman(
              mikro: 'Beranda',
              judul: depan.isEmpty ? 'Halo' : 'Halo, $depan',
              keterangan: 'Lanjutkan belajar anatomi hari ini.',
            ),
            const SizedBox(height: 24),
            KartuPutih(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Mikro('Tugas belajar'),
                  const SizedBox(height: 8),
                  JudulTitik('$selesai dari $total selesai', ukuran: 26),
                  const SizedBox(height: 16),
                  BilahProgres(nilai: persen / 100),
                  const SizedBox(height: 12),
                  Text(
                    p['rata_skor_terbaik'] == null
                        ? 'Belum ada tugas yang dikerjakan. Mulai dari simulasi lalu kuis.'
                        : 'Rata-rata skor terbaikmu ${p['rata_skor_terbaik']}.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Warna.netral500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Warna.abu,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => pindahTab(3),
                    child: const Text('Semua tugas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Pintasan(
                      ikon: Icons.view_in_ar_rounded,
                      label: 'Jelajahi 3D dan AR',
                      biru: true,
                      aksi: () => pindahTab(1),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _Pintasan(
                      ikon: Icons.chat_bubble_rounded,
                      label: 'Tanya asisten AI',
                      aksi: () => pindahTab(2),
                    ),
                  ),
                ],
              ),
            ),
            if (terbaru.isNotEmpty) ...[
              const SizedBox(height: 28),
              Seksi(
                judul: 'Percobaan terbaru',
                anak: Column(
                  children: [
                    for (final e in terbaru.take(4).cast<Json>())
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: KartuPutih(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['judul'] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${e['benar']} dari ${e['total']} benar',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Warna.netral500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Lencana(
                                'Skor ${e['skor']}',
                                tipe: (e['skor'] as int? ?? 0) >= 70
                                    ? TipeLencana.hijau
                                    : TipeLencana.netral,
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
    this.biru = false,
  });
  final IconData ikon;
  final String label;
  final VoidCallback aksi;
  final bool biru;
  @override
  Widget build(BuildContext context) {
    final isi = biru ? Colors.white : Warna.teks;
    return KartuPutih(
      warna: biru ? Warna.biru : Colors.white,
      onTap: aksi,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: biru ? Colors.white.withValues(alpha: 0.18) : Warna.abu,
              shape: BoxShape.circle,
            ),
            child: Icon(
              ikon,
              size: 22,
              color: biru ? Colors.white : Warna.biru,
            ),
          ),
          const SizedBox(height: 28),
          Text(label, style: gayaTampilan(17, warna: isi, tinggi: 1.15)),
        ],
      ),
    );
  }
}
