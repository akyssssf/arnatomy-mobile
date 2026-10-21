import Flutter
import QuickLook
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Jembatan AR: Dart meminta Quick Look membuka berkas .usdz yang ikut terbawa di aplikasi.
    let kanal = FlutterMethodChannel(
      name: "id.ac.uns.arnatomy/ar",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    kanal.setMethodCallHandler { call, result in
      guard call.method == "quickLook",
        let aset = (call.arguments as? [String: Any])?["aset"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      ArQuickLook.shared.tampilkan(aset: aset, result: result)
    }
  }
}

/// AR Quick Look milik iOS (ARKit dan kamera dikelola sistem). Pengguna dapat menaruh model di lantai/meja dan mencubit untuk memperbesar.
final class ArQuickLook: NSObject, QLPreviewControllerDataSource {
  static let shared = ArQuickLook()
  private var url: URL?

  func tampilkan(aset: String, result: @escaping FlutterResult) {
    let kunci = FlutterDartProject.lookupKey(forAsset: aset)
    guard let jalur = Bundle.main.path(forResource: kunci, ofType: nil) else {
      result(FlutterError(code: "TIDAK_ADA", message: "Berkas model tidak ditemukan di aplikasi.", details: nil))
      return
    }
    url = URL(fileURLWithPath: jalur)
    let jendela = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    guard var atas = jendela?.rootViewController else {
      result(FlutterError(code: "TANPA_LAYAR", message: "Tidak ada layar untuk menampilkan AR.", details: nil))
      return
    }
    while let tampil = atas.presentedViewController { atas = tampil }
    let pengendali = QLPreviewController()
    pengendali.dataSource = self
    atas.present(pengendali, animated: true) { result(nil) }
  }

  func numberOfPreviewItems(in controller: QLPreviewController) -> Int { url == nil ? 0 : 1 }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    let item = ARQuickLookPreviewItem(fileAt: url!)
    item.allowsContentScaling = true
    return item
  }
}
