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
        NeuraSDK.shared.setAppUID("us-lab-9y4lqts_luLhi2p5XJbyFcytMChUUu64VSeLxA0", appSecret: "POlc-b4XrJn7agpimlFfPA5TuE9YLxjBwoM64p1RUNk")
        UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let authenticateChannel = FlutterMethodChannel(name: "com.neura.flutterApp/authenticate",
        binaryMessenger: controller.binaryMessenger)
        locationManager.requestAlwaysAuthorization()
        authenticateChannel.setMethodCallHandler{ (call, result) in
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
        let request = NeuraAnonymousAuthenticationRequest()
        NeuraSDK.shared.authenticate(with: request){ result in
            flutterResult(result.neuraUserId ?? "fail")
        }
    }
}
