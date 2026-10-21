import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'config.dart';
import 'state/auth_model.dart';
import 'ui/home_shell.dart';
import 'ui/login_screen.dart';

void main() {
  PenyimpanToken? penyimpan;
  if (kDebugMode && Config.devAccess.isNotEmpty) {
    penyimpan = PenyimpanTokenMemori()
      ..simpan(Config.devAccess, Config.devRefresh);
  }
  runApp(ArnatomyApp(api: ApiClient(penyimpan: penyimpan)));
}

class ArnatomyApp extends StatelessWidget {
  const ArnatomyApp({super.key, required this.api});
  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthModel(api)..mulai()),
      ],
      child: MaterialApp(
        title: 'ARnatomy',
        debugShowCheckedModeBanner: false,
        theme: tema(),
        home: const _Gerbang(),
      ),
    );
  }
}

const warnaAksen = Color(0xFF0F6E6E);

ThemeData tema() {
  final skema = ColorScheme.fromSeed(
    seedColor: warnaAksen,
    surface: const Color(0xFFF6F4EF),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: skema,
    scaffoldBackgroundColor: const Color(0xFFF6F4EF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF6F4EF),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFD9D5CA)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

class _Gerbang extends StatelessWidget {
  const _Gerbang();
  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthModel, StatusSesi>((a) => a.status);
    return switch (status) {
      StatusSesi.memuat => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      StatusSesi.keluar => const LoginScreen(),
      StatusSesi.masuk => const HomeShell(),
    };
  }
}
