import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'config.dart';
import 'state/auth_model.dart';
import 'tema.dart';
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
