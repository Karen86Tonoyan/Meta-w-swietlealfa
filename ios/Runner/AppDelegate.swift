import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "alfa/meta_wearables"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    // Stub Meta Wearables SDK (iOS). Po zatwierdzeniu konta Meta Developer:
    // 1. Dodaj Meta Wearables SDK przez SPM/CocoaPods.
    // 2. Zamień stub-y na realne wywołania (session, audio, camera).
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isConnected": result(false)
      case "startAudioStream", "capturePhoto": result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
