import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Palet dan gaya yang sama dengan web ARnatomy (lihat arnatomy-next/src/app/globals.css).
class Warna {
  static const biru = Color(0xFF1566F4);
  static const biruGelap = Color(0xFF0D55D9);
  static const latar = Color(0xFFE6E8EB);
  static const abu = Color(0xFFF1F2F4);
  static const teks = Color(0xFF171717);
  static const netral400 = Color(0xFF646870);
  static const netral500 = Color(0xFF5B5F66);
  static const netral900 = Color(0xFF171717);
  static const hijau = Color(0xFF1F7A3D);
  static const amber = Color(0xFFA85A00);
  static const merah = Color(0xFFB3261E);
}

/// Jarak bawah yang disisakan untuk bilah tab kaca yang mengambang.
const double ruangBilahTab = 112;

const _inter = 'Inter';
const _tampilan = 'InterTight';

/// Gaya judul web: Inter Tight, tebal, kerapatan huruf -0,035em.
TextStyle gayaTampilan(
  double ukuran, {
  FontWeight berat = FontWeight.w600,
  Color? warna,
  double tinggi = 1.1,
}) => TextStyle(
  fontFamily: _tampilan,
  fontSize: ukuran,
  fontWeight: berat,
  letterSpacing: ukuran * -0.035,
  height: tinggi,
  color: warna ?? Warna.teks,
);

ThemeData tema() {
  final skema =
      ColorScheme.fromSeed(
        seedColor: Warna.biru,
        brightness: Brightness.light,
      ).copyWith(
        primary: Warna.biru,
        onPrimary: Colors.white,
        surface: Warna.latar,
        onSurface: Warna.teks,
        error: Warna.merah,
      );
  const pil = StadiumBorder();
  return ThemeData(
    useMaterial3: true,
    colorScheme: skema,
    fontFamily: _inter,
    scaffoldBackgroundColor: Warna.latar,
    textTheme: ThemeData.light().textTheme.apply(
      fontFamily: _inter,
      bodyColor: Warna.teks,
      displayColor: Warna.teks,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: gayaTampilan(18),
      foregroundColor: Warna.teks,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Warna.biru,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Warna.biru.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white70,
        shape: pil,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _inter,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Warna.netral900,
        side: BorderSide.none,
        shape: pil,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _inter,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Warna.biru,
        shape: pil,
        textStyle: const TextStyle(
          fontFamily: _inter,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Warna.biru, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Warna.merah, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Warna.merah, width: 2),
      ),
      labelStyle: const TextStyle(color: Warna.netral500),
      hintStyle: const TextStyle(color: Warna.netral400),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Warna.netral500,
        selectedBackgroundColor: Warna.netral900,
        selectedForegroundColor: Colors.white,
        side: BorderSide.none,
        shape: pil,
        textStyle: const TextStyle(
          fontFamily: _inter,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.black.withValues(alpha: 0.05),
      side: BorderSide.none,
      shape: pil,
      labelStyle: const TextStyle(
        fontFamily: _inter,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Warna.netral500,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Warna.biru),
    dividerTheme: DividerThemeData(
      color: Colors.black.withValues(alpha: 0.06),
      space: 1,
      thickness: 1,
    ),
    listTileTheme: const ListTileThemeData(iconColor: Warna.netral500),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Warna.netral900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentTextStyle: const TextStyle(
        fontFamily: _inter,
        color: Colors.white,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
