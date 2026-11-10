import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../tema.dart';

/// Label mikro berawalan garis miring biru, mis. "/ ORGAN" (kelas `.mikro` di web).
class Mikro extends StatelessWidget {
  const Mikro(this.teks, {super.key, this.warna});
  final String teks;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    final dasar = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.88,
      color: warna ?? Warna.netral400,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '/ ',
            style: dasar.copyWith(color: Warna.biru),
          ),
          TextSpan(text: teks.toUpperCase(), style: dasar),
        ],
      ),
    );
  }
}

/// Judul bergaya web: Inter Tight dan titik biru di akhir (kelas `.titik-biru`).
class JudulTitik extends StatelessWidget {
  const JudulTitik(this.teks, {super.key, this.ukuran = 34, this.titik = true});
  final String teks;
  final double ukuran;
  final bool titik;

  @override
  Widget build(BuildContext context) {
    final gaya = gayaTampilan(ukuran);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: teks, style: gaya),
          if (titik)
            TextSpan(
              text: ' ●',
              style: gaya.copyWith(
                fontSize: ukuran * 0.42,
                color: Warna.biru,
                letterSpacing: 0,
              ),
            ),
        ],
      ),
    );
  }
}

/// Kepala halaman: label mikro, judul bertitik, dan keterangan singkat.
class KepalaHalaman extends StatelessWidget {
  const KepalaHalaman({
    super.key,
    required this.mikro,
    required this.judul,
    this.keterangan,
    this.aksi,
  });
  final String mikro;
  final String judul;
  final String? keterangan;
  final Widget? aksi;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Mikro(mikro),
              const SizedBox(height: 8),
              JudulTitik(judul),
              if (keterangan != null) ...[
                const SizedBox(height: 8),
                Text(
                  keterangan!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Warna.netral500,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?aksi,
      ],
    );
  }
}

enum TipeLencana { netral, biru, gelap, hijau, amber }

/// Badge pil huruf kapital (fungsi `badge` di variants.ts web).
class Lencana extends StatelessWidget {
  const Lencana(this.teks, {super.key, this.tipe = TipeLencana.netral});
  final String teks;
  final TipeLencana tipe;

  @override
  Widget build(BuildContext context) {
    final (latar, isi) = switch (tipe) {
      TipeLencana.netral => (
        Colors.black.withValues(alpha: 0.05),
        Warna.netral500,
      ),
      TipeLencana.biru => (Warna.biru, Colors.white),
      TipeLencana.gelap => (Warna.netral900, Colors.white),
      TipeLencana.hijau => (const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      TipeLencana.amber => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(color: latar, shape: const StadiumBorder()),
      child: Text(
        teks.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isi,
        ),
      ),
    );
  }
}

/// Bilah progres tipis seperti di web (jalur hitam 5%, isi biru).
class BilahProgres extends StatelessWidget {
  const BilahProgres({super.key, required this.nilai});
  final double nilai; // 0..1
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: nilai.clamp(0, 1),
        minHeight: 8,
        backgroundColor: Colors.black.withValues(alpha: 0.06),
        valueColor: const AlwaysStoppedAnimation(Warna.biru),
      ),
    );
  }
}

/// Kartu putih membulat (`kartu` di web).
class KartuPutih extends StatelessWidget {
  const KartuPutih({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.warna = Colors.white,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color warna;
  @override
  Widget build(BuildContext context) {
    final isi = Padding(padding: padding, child: child);
    return Material(
      color: warna,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? isi : InkWell(onTap: onTap, child: isi),
    );
  }
}

/// Latar halaman: abu web dengan dua cahaya biru lembut agar kaca punya sesuatu untuk dibiaskan.
class LatarAurora extends StatelessWidget {
  const LatarAurora({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Warna.latar),
        Positioned(
          top: -120,
          right: -100,
          child: _Cahaya(
            ukuran: 360,
            warna: Warna.biru.withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          bottom: 140,
          left: -140,
          child: _Cahaya(
            ukuran: 340,
            warna: const Color(0xFF7AA7FF).withValues(alpha: 0.28),
          ),
        ),
        child,
      ],
    );
  }
}

class _Cahaya extends StatelessWidget {
  const _Cahaya({required this.ukuran, required this.warna});
  final double ukuran;
  final Color warna;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: ukuran,
          height: ukuran,
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
