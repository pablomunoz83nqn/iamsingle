import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAUVi8sJISqV0Vxs1Ew6YWTUVD4_9Q2mr8")
    GeneratedPluginRegistrant.register(with: self)
      
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

