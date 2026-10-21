import 'package:flutter/material.dart';

import '../api/api_client.dart';

/// Memuat data async dengan keadaan memuat, galat (dengan tombol coba lagi), dan tarik-untuk-segarkan.
class DataView<T> extends StatefulWidget {
  const DataView({super.key, required this.muat, required this.bangun});
  final Future<T> Function() muat;
  final Widget Function(BuildContext context, T data) bangun;

  @override
  State<DataView<T>> createState() => _DataViewState<T>();
}

class _DataViewState<T> extends State<DataView<T>> {
  late Future<T> _f = widget.muat();

  Future<void> _ulang() async {
    setState(() => _f = widget.muat());
    try {
      await _f;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _f,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return GalatView(pesan: pesanGalat(snap.error), ulang: _ulang);
        }
        return RefreshIndicator(
          onRefresh: _ulang,
          child: widget.bangun(context, snap.data as T),
        );
      },
    );
  }
}

String pesanGalat(Object? e) =>
    e is ApiException ? e.pesan : 'Terjadi kesalahan. Coba lagi.';

class GalatView extends StatelessWidget {
  const GalatView({super.key, required this.pesan, this.ulang});
  final String pesan;
  final VoidCallback? ulang;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            Text(pesan, textAlign: TextAlign.center),
            if (ulang != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: ulang,
                child: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void tampilkanSnack(BuildContext context, String pesan) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(pesan)));
}

/// Kotak berjudul kecil di atas isi.
class Seksi extends StatelessWidget {
  const Seksi({super.key, required this.judul, required this.anak});
  final String judul;
  final Widget anak;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            judul,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        anak,
      ],
    );
  }
}
