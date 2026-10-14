import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let value = getPlist(withName: "GoogleMaps")?["API_KEY"] {
        GMSServices.provideAPIKey(value as! String)
    }
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  func getPlist(withName name: String) -> NSDictionary?
  {
    if let path = Bundle.main.path(forResource: name, ofType: "plist") {
     return NSDictionary(contentsOfFile: path)
    }
    return [:]
  }
}
