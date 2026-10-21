# Atribusi model 3D

Model organ di `assets/models/` adalah turunan dari **HuBMAP Human Reference Atlas (HRA)**, 3D Reference Organ Set (adult male),
lisensi **CC BY 4.0**: https://creativecommons.org/licenses/by/4.0/

Sumber: https://humanatlas.io/3d-reference-library · Data: https://lod.humanatlas.io/ref-organ
Sitasi: Börner K. et al. (2025) *Human BioMolecular Atlas Program (HuBMAP): 3D Human Reference Atlas construction and usage*, Nature Methods. https://doi.org/10.1038/s41592-024-02563-5

| Berkas | Asal | Adaptasi |
| --- | --- | --- |
| `heart-mobile.glb`, `heart.usdz` | `ref-organ/heart-male/v1.3` + potongan `ref-organ/blood-vasculature-male/v1.3` (aorta asendens, arkus aorta, trunkus pulmonalis, vena cava superior/inferior, vena pulmonalis, arteri koroner) | digabung jadi satu berkas, warna pembuluh dilembutkan (merah = kaya O₂, biru = miskin O₂); `.glb` dikompres Draco; `.usdz` dibuat dengan Blender dan poligonnya dikurangi ke 40% agar ±7 MB |
| `lungs-mobile.glb`, `lungs.usdz` | `ref-organ/lung-male/v1.4` + `ref-organ/trachea-male/v1.1` + `ref-organ/main-bronchus-male/v1.1` | digabung jadi satu berkas; `.glb` dikompres Draco; `.usdz` seperti jantung |

Cara pembuatan (singkat): kompresi Meshopt dan kuantisasi pada model web dilepas dengan `gltf-transform copy` dan `dequantize`,
lalu `draco` menghasilkan `.glb`. Untuk `.usdz`, model diimpor ke Blender, di-decimate 0,4, dan diekspor ke USDZ
(Y-up, tanpa UV dan warna titik); hasilnya lolos `usdchecker` Apple. Ukuran model nyata (jantung ±12 cm, paru-paru ±26 cm).
