import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema.dart';

/// Matriks saturasi (setara `saturate()` CSS) untuk dipasang bersama blur di belakang kaca.
ColorFilter _saturasi(double s) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final a = (1 - s) * lr, b = (1 - s) * lg, c = (1 - s) * lb;
  return ColorFilter.matrix(<double>[
    a + s, b, c, 0, 0, //
    a, b + s, c, 0, 0,
    a, b, c + s, 0, 0,
    0, 0, 0, 1, 0,
  ]);
}

/// Panel Liquid Glass: blur latar + saturasi, tint tipis, tepi bersorot, bayangan lembut.
/// Nilai dasar mengikuti kelas `.kaca` / `.kaca-gelap` di web dan komponen Figma "Liquid Glass".
class KacaPanel extends StatelessWidget {
  const KacaPanel({
    super.key,
    required this.child,
    this.radius = 28,
    this.gelap = false,
    this.padding = EdgeInsets.zero,
    this.sigma = 12,
    this.bayangan = true,
  });
  final Widget child;
  final double radius;
  final bool gelap;
  final EdgeInsetsGeometry padding;
  final double sigma;
  final bool bayangan;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: bayangan
            ? const [
                BoxShadow(
                  color: Color(0x1F111827),
                  blurRadius: 36,
                  offset: Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.compose(
            outer: _saturasi(gelap ? 1.3 : 1.6),
            inner: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          ),
          child: CustomPaint(
            foregroundPainter: _TepiKaca(radius: radius, gelap: gelap),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: gelap
                    ? const Color(0x9E111827)
                    : const Color(0x80FFFFFF),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gelap
                      ? const [Color(0x14FFFFFF), Color(0x00FFFFFF)]
                      : const [Color(0x66FFFFFF), Color(0x0DFFFFFF)],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tepi kaca: garis putih bergradasi (terang di sudut atas-kiri dan bawah-kanan),
/// pendar tipis di dalam, dan bayangan gelap halus di tepi seperti lapisan "multiply" pada desain Figma.
class _TepiKaca extends CustomPainter {
  _TepiKaca({required this.radius, required this.gelap});
  final double radius;
  final bool gelap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // pendar dalam (garis putih kabur)
    final pendar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: gelap ? 0.12 : 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRRect(rr.deflate(1.5), pendar);
    canvas.restore();

    // tepi tajam bergradasi
    final tepi = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: gelap ? 0.45 : 0.95),
          Colors.white.withValues(alpha: gelap ? 0.08 : 0.25),
          Colors.white.withValues(alpha: gelap ? 0.30 : 0.7),
        ],
        stops: const [0, 0.55, 1],
      ).createShader(rect);
    canvas.drawRRect(rr, tepi);

    // bayangan tepi tipis di sisi bawah, memberi kesan ketebalan kaca
    final tebal = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawRRect(rr.shift(const Offset(0, 0.6)), tebal);
  }

  @override
  bool shouldRepaint(_TepiKaca lama) =>
      lama.radius != radius || lama.gelap != gelap;
}

/// Satu tujuan pada bilah tab.
class ItemTab {
  const ItemTab({
    required this.ikon,
    required this.ikonAktif,
    required this.label,
  });
  final IconData ikon;
  final IconData ikonAktif;
  final String label;
}

/// Bilah tab pil mengambang bergaya iOS 26: kaca, dengan pil penanda yang bergeser ke tab aktif.
class KacaTabBar extends StatelessWidget {
  const KacaTabBar({
    super.key,
    required this.item,
    required this.indeks,
    required this.onPilih,
  });
  final List<ItemTab> item;
  final int indeks;
  final ValueChanged<int> onPilih;

  static const double tinggi = 72;
  static const double _sisi = 6;

  @override
  Widget build(BuildContext context) {
    return KacaPanel(
      radius: 999,
      sigma: 14,
      child: SizedBox(
        height: tinggi,
        child: LayoutBuilder(
          builder: (context, c) {
            final lebarItem = (c.maxWidth - _sisi * 2) / item.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: const Cubic(0.2, 0.7, 0.2, 1),
                  left: _sisi + lebarItem * indeks,
                  top: _sisi,
                  width: lebarItem,
                  height: tinggi - _sisi * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withValues(alpha: 0.72),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14111827),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _sisi),
                  child: Row(
                    children: [
                      for (var i = 0; i < item.length; i++)
                        Expanded(
                          child: _Tujuan(
                            data: item[i],
                            aktif: i == indeks,
                            onTap: () {
                              if (i != indeks) HapticFeedback.selectionClick();
                              onPilih(i);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Tujuan extends StatelessWidget {
  const _Tujuan({required this.data, required this.aktif, required this.onTap});
  final ItemTab data;
  final bool aktif;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final warna = aktif ? Warna.biru : Warna.netral500;
    return Semantics(
      button: true,
      selected: aktif,
      label: data.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(aktif ? data.ikonAktif : data.ikon, size: 26, color: warna),
              const SizedBox(height: 3),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: aktif ? FontWeight.w600 : FontWeight.w500,
                  color: warna,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol bulat kaca (mis. tombol kembali atau aksi di atas model 3D).
class KacaTombolBulat extends StatelessWidget {
  const KacaTombolBulat({
    super.key,
    required this.ikon,
    required this.onTap,
    required this.label,
    this.ukuran = 44,
  });
  final IconData ikon;
  final VoidCallback onTap;
  final String label;
  final double ukuran;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: KacaPanel(
          radius: 999,
          sigma: 10,
          child: SizedBox(
            width: ukuran,
            height: ukuran,
            child: Icon(ikon, size: ukuran * 0.46, color: Warna.teks),
          ),
        ),
      ),
    );
  }
}
