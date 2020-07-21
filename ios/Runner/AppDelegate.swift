import UIKit
import Flutter
import NeuraSDK
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let locationManager = CLLocationManager()
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        //// Init Neura SDK
        NeuraSDK.shared.setAppUID("[APP UID]", appSecret: "[APP SECRET]]")
        UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
        
        
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        //        FlutterMethodChannel tied to the channel name com.neura.flutterApp/authenticate:
        let authenticateChannel = FlutterMethodChannel(name: "com.neura.flutterApp/authenticate",
                                                       binaryMessenger: controller.binaryMessenger)
       
        authenticateChannel.setMethodCallHandler{ (call, result) in
           //// Note: this method is invoked on the UI thread.
            self.authenticate(flutterResult: result)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if NeuraSDKPushNotification.handleNeuraPush(withInfo: userInfo, fetchCompletionHandler: completionHandler) {
            // A Neura notification was consumed and handled.
            // The SDK will call the completion handler.
            return
        }
        completionHandler(.noData)
    }
    
   override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NeuraSDK.shared.collectDataForBGFetch { result in
            completionHandler(result)
        }
    }
    
    private func authenticate(flutterResult: @escaping FlutterResult) {
        guard !NeuraSDK.shared.isAuthenticated() else {
            flutterResult(NeuraSDK.shared.neuraUserId() ?? "isAuthenticated")
            return
        }
        //// Authentication request
        let request = NeuraAnonymousAuthenticationRequest()
        NeuraSDK.shared.authenticate(with: request){ result in
            flutterResult(result.neuraUserId ?? "fail")
        }
    }
}
