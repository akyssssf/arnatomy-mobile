import 'package:arnatomy_mobile/model_organ.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('model bawaan jantung dan paru memakai aset lokal beserta .usdz', () {
    final jantung = modelOrgan({
      'sumber': 'bawaan',
      'url': '/models/heart.glb',
    });
    expect(jantung.src, 'assets/models/heart-mobile.glb');
    expect(jantung.usdzAset, 'assets/models/heart.usdz');
    final paru = modelOrgan({'sumber': 'bawaan', 'url': '/models/lungs.glb'});
    expect(paru.src, 'assets/models/lungs-mobile.glb');
    expect(paru.usdzAset, 'assets/models/lungs.usdz');
  });

  test('model unggahan admin diambil dari alamatnya dan tanpa AR', () {
    final m = modelOrgan({
      'sumber': 'unggahan',
      'url': 'https://cdn.contoh.id/organ/ginjal.glb',
    });
    expect(m.src, 'https://cdn.contoh.id/organ/ginjal.glb');
    expect(m.usdzAset, isNull);
  });

  test('organ bawaan baru yang belum dibundel jatuh ke alamat situs', () {
    final m = modelOrgan({'sumber': 'bawaan', 'url': '/models/kidney.glb'});
    expect(m.src, endsWith('/models/kidney.glb'));
    expect(m.src, startsWith('http'));
    expect(m.usdzAset, isNull);
  });
}
