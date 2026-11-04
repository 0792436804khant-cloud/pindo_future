import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let antiPiracyChannelName = "pindo_future/anti_piracy"
  private var antiPiracyChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    setupScreenProtectionListeners()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    
    if let controller = window?.rootViewController as? FlutterViewController {
      setupMethodChannel(messenger: controller.binaryMessenger)
    }
  }

  private func setupMethodChannel(messenger: FlutterBinaryMessenger) {
    antiPiracyChannel = FlutterMethodChannel(name: antiPiracyChannelName, binaryMessenger: messenger)
    antiPiracyChannel?.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "enableSecureMode":
        result(true)
      case "disableSecureMode":
        result(true)
      case "isSecureModeActive":
        result(true)
      case "isScreenCaptureDetected":
        if #available(iOS 11.0, *) {
          result(UIScreen.main.isCaptured)
        } else {
          result(false)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setupScreenProtectionListeners() {
    if #available(iOS 11.0, *) {
      NotificationCenter.default.addObserver(
        forName: UIScreen.capturedDidChangeNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        let isCaptured = UIScreen.main.isCaptured
        self?.antiPiracyChannel?.invokeMethod("onScreenCaptureChanged", arguments: isCaptured)
      }
    }
  }
}
