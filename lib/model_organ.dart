import 'api/api_client.dart';
import 'config.dart';

/// Model 3D sebuah organ untuk ditampilkan di aplikasi.
class ModelOrgan {
  const ModelOrgan({required this.src, this.usdzAset});

  /// Sumber untuk penampil 3D: berkas yang ikut terbawa di aplikasi (`assets/...`) atau alamat https.
  final String src;

  /// Berkas .usdz untuk AR Quick Look di iPhone; null bila organ tidak punya (mis. model unggahan admin).
  final String? usdzAset;
}

/// Organ bawaan yang modelnya dibawa aplikasi (lihat assets/models dan ATTRIBUTION.md).
const _modelTerbawa = {'heart', 'lungs'};

/// Model bawaan dilayani dari aset lokal (cepat, tanpa unduh, dan tanpa bergantung pada server web);
/// model unggahan admin diambil dari alamatnya dan tidak punya AR.
ModelOrgan modelOrgan(Json model) {
  final url = model['url'] as String;
  final dasar = RegExp(r'([A-Za-z0-9_-]+)\.glb$').firstMatch(url)?.group(1);
  if (model['sumber'] == 'bawaan' &&
      dasar != null &&
      _modelTerbawa.contains(dasar)) {
    return ModelOrgan(
      src: 'assets/models/$dasar-mobile.glb',
      usdzAset: 'assets/models/$dasar.usdz',
    );
  }
  return ModelOrgan(src: Config.sumberWeb(url));
}
