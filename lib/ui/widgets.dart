import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../tema.dart';
import 'komponen.dart';

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
          color: Warna.biru,
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 26,
                color: Warna.netral500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            if (ulang != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: ulang, child: const Text('Coba lagi')),
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

/// Bagian berjudul: label mikro di atas isi.
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
          padding: const EdgeInsets.only(bottom: 10, left: 2),
          child: Mikro(judul),
        ),
        anak,
      ],
    );
  }
}
