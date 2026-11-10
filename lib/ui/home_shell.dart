import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'asisten_screen.dart';
import 'beranda_screen.dart';
import 'eksplorasi_screen.dart';
import 'kaca.dart';
import 'komponen.dart';
import 'profil_screen.dart';
import 'tugas_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;

  void pindah(int i) => setState(() => _i = i);

  static const _tujuan = [
    ItemTab(
      ikon: Icons.home_outlined,
      ikonAktif: Icons.home_rounded,
      label: 'Beranda',
    ),
    ItemTab(
      ikon: Icons.view_in_ar_outlined,
      ikonAktif: Icons.view_in_ar_rounded,
      label: 'Eksplorasi',
    ),
    ItemTab(
      ikon: Icons.chat_bubble_outline_rounded,
      ikonAktif: Icons.chat_bubble_rounded,
      label: 'Asisten',
    ),
    ItemTab(
      ikon: Icons.checklist_rounded,
      ikonAktif: Icons.checklist_rounded,
      label: 'Tugas',
    ),
    ItemTab(
      ikon: Icons.person_outline_rounded,
      ikonAktif: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bawah = math.max(MediaQuery.paddingOf(context).bottom, 10.0);
    return LatarAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _i,
                children: [
                  BerandaScreen(pindahTab: pindah),
                  const EksplorasiScreen(),
                  const AsistenScreen(),
                  const TugasScreen(),
                  const ProfilScreen(),
                ],
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: bawah,
              child: KacaTabBar(item: _tujuan, indeks: _i, onPilih: pindah),
            ),
          ],
        ),
      ),
    );
  }
}
