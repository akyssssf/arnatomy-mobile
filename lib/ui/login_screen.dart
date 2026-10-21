import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../state/auth_model.dart';
import 'widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _sandi = TextEditingController();
  final _sekolah = TextEditingController();
  bool _daftar = false;
  bool _sibuk = false;
  bool _lihat = false;
  String _peran = 'siswa';

  @override
  void dispose() {
    for (final c in [_nama, _email, _sandi, _sekolah]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _kirim() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _sibuk = true);
    final auth = context.read<AuthModel>();
    try {
      if (_daftar) {
        await auth.daftar(
          nama: _nama.text,
          email: _email.text,
          password: _sandi.text,
          role: _peran,
          asalSekolah: _sekolah.text,
        );
      } else {
        await auth.masuk(_email.text, _sandi.text);
      }
    } on ApiException catch (e) {
      if (mounted) tampilkanSnack(context, e.pesan);
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  String? _wajib(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi.' : null;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'ARnatomy',
                      style: t.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Belajar anatomi jantung dan paru-paru dengan model 3D dan AR.',
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _daftar ? 'Buat akun' : 'Masuk',
                      style: t.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (_daftar) ...[
                      TextFormField(
                        controller: _nama,
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                        ),
                        validator: (v) => (v ?? '').trim().length < 3
                            ? 'Nama minimal 3 karakter.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => _wajib(v, 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sandi,
                      obscureText: !_lihat,
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        helperText: _daftar
                            ? 'Minimal 8 karakter, memuat huruf dan angka.'
                            : null,
                        suffixIcon: IconButton(
                          tooltip: _lihat
                              ? 'Sembunyikan kata sandi'
                              : 'Tampilkan kata sandi',
                          icon: Icon(
                            _lihat
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(() => _lihat = !_lihat),
                        ),
                      ),
                      validator: (v) {
                        if (_wajib(v, 'Kata sandi') case final g?) return g;
                        if (_daftar &&
                            !RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')
                                .hasMatch(v!)) {
                          return 'Minimal 8 karakter, memuat huruf dan angka.';
                        }
                        return null;
                      },
                    ),
                    if (_daftar) ...[
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'siswa', label: Text('Siswa')),
                          ButtonSegment(value: 'guru', label: Text('Guru')),
                        ],
                        selected: {_peran},
                        onSelectionChanged: (s) =>
                            setState(() => _peran = s.first),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _sekolah,
                        decoration: const InputDecoration(
                          labelText: 'Asal sekolah',
                        ),
                        validator: (v) => (v ?? '').trim().length < 3
                            ? 'Nama sekolah minimal 3 karakter.'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _sibuk ? null : _kirim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _sibuk
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_daftar ? 'Daftar' : 'Masuk'),
                      ),
                    ),
                    TextButton(
                      onPressed: _sibuk
                          ? null
                          : () => setState(() => _daftar = !_daftar),
                      child: Text(
                        _daftar
                            ? 'Sudah punya akun? Masuk'
                            : 'Belum punya akun? Daftar',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
