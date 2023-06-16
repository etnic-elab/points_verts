import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let value = getPlist(withName: "GoogleMaps")?["API_KEY"] {
        GMSServices.provideAPIKey(value as! String)
    }
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override init() {
   super.init()
   FirebaseApp.configure()
   // not really needed unless you really need it FIRDatabase.database().persistenceEnabled = true
  }

  func getPlist(withName name: String) -> NSDictionary?
  {
    if let path = Bundle.main.path(forResource: name, ofType: "plist") {
     return NSDictionary(contentsOfFile: path)
    }
    return [:]
  }
}
