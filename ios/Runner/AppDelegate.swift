import UIKit
import Flutter
import NeuraSDK
import CoreLocation
import NotificationCenter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let kLatestToken = "kLatestToken"
    let kLastUpdate = "kLastUpdate"
    let locationManager = CLLocationManager()
    lazy var flutterEngine = FlutterEngine(name: "my flutter engine")
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        flutterSetup()
        neuraSetup()
        
        UIApplication.shared.delegate = self
        if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self
        }
        UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
        
        registerForRemoteNotification()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func neuraSetup(){
        NeuraSDK.shared.setAppUID("[APP_UID]]", appSecret: "[APP_SECRET]")
        NeuraSDK.shared.authenticationDelegate = self
    }
    
    func flutterSetup(){
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
               let authenticateChannel = FlutterMethodChannel(name: "com.neura.flutterApp/authenticate",
               binaryMessenger: controller.binaryMessenger)
               locationManager.requestAlwaysAuthorization()
               authenticateChannel.setMethodCallHandler{ (call, result) in
                   self.authenticate(flutterResult: result)
               }
               
               let refreshDataChannel = FlutterMethodChannel(name: "com.neura.flutterApp/refreshData",
               binaryMessenger: controller.binaryMessenger)
               
               refreshDataChannel.setMethodCallHandler{ (call, result) in
                   self.refreshData(flutterResult: result)
               }
    }
    
  
    
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in
                       if granted {
                           DispatchQueue.main.async {
                               UIApplication.shared.registerForRemoteNotifications()
                            let notify : UIUserNotificationSettings = UIUserNotificationSettings(types: .alert, categories: nil)
                              UIApplication.shared.registerUserNotificationSettings(notify)
                            
                           }
                       }
                   }
        } else {
            // Fallback on earlier versions
        }
       

    }
}

// App Delegate LiftSycel
extension AppDelegate {
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          NeuraSDKPushNotification.registerDeviceToken(deviceToken)
      }
      
      override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
          NeuraSDK.shared.collectDataForBGFetch { result in
              completionHandler(result)
          }
      }
      
      override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
      ) {
       if NeuraSDKPushNotification.handleNeuraPush(withInfo: userInfo, fetchCompletionHandler: completionHandler) {
            // A Neura notification was consumed and handled.
            // The SDK will call the completion handler.
            return
        }
          super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
      }
      
     
      
      override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
          print(error.localizedDescription)
      }
      
    
}

extension AppDelegate: NeuraAuthenticationDelegate {
   
    func neuraAccessTokenChanged(_ newAccessToken: String?) {
        userDefaults.set(newAccessToken, forKey: kLatestToken)
        userDefaults.set(Date(), forKey: kLastUpdate)
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
    
    func refreshData(flutterResult: @escaping FlutterResult) {
        let token = userDefaults.string(forKey: kLatestToken) ?? "no token"
        let date = userDefaults.object(forKey: kLastUpdate) as? Date
        let dateStr = dateToString(date: date)
        let result = "last upddate: \(dateStr), token: \(token)"
         flutterResult(result)
    }
    
    func dateToString(date: Date?) -> String {
        guard let date = date else {
            return "none"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    private var userDefaults: UserDefaults {
        return UserDefaults.standard
    }
    func set(_ value: String, for key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func set(_ value: Date, for key: String) {
        userDefaults.set(value, forKey: key)
    }
}



