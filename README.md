# flutterdemo

This app demonstrates how to intgrate neura SDK in Flutter Project 

## create the Flutter platform client

1. First, construct the channel.
Use a MethodChannel with a single platform method that returns neura user id when the user is connected.
The client and host sides of a channel are connected through a channel name.

```
class _MyHomePageState extends State<MyHomePage> {
 static const authenticateChannel = const MethodChannel('com.neura.flutterApp/authenticate');
 }
```

 2. invoke a method on the method channel, specifying the concrete method to call using the String identifier authenticate. The call might fail—for example if the platform does not support the platform API (such as when running in a simulator)—so wrap the invokeMethod call in a try-catch statement.

Use the returned result to update the user interface state in userStatus inside setState.

 
```
// Get neura user id when connected.
String userStatus = "Not Connected";

Future authenticateToNeura() async {
    String authenticationIdResponse = "";

    try {
       await authenticateChannel
          .invokeMethod('authenticate')
          .then((result) {
        authenticationIdResponse = result;
      });
    } on PlatformException catch (e) {
      authenticationIdResponse = e.code;

    } finally {
      setState(() {
        userStatus = authenticationIdResponse;
      });
    }
 ```
    
   
   
    
3. Request Location Permissions:

In order to our sdk work well we need to request location permission in both platforms, lucky for us we can do threw flutter:

setup: 
To use this plugin, add location_permissions as a dependency in your pubspec.yaml file. For example:

``` 
dependencies:
  location_permissions: ^2.0.5
 ```
Add a method code that request the Permissions:

```
 void requestPermission() async {
   await LocationPermissions().requestPermissions();
  }
  ```
3. Finally, replace the build method from the template to contain a small user interface that displays the neuraId state in a string, and a buttons for authenticate and request permissions. 

 
```
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$userStatus',
              style: Theme.of(context).textTheme.headline5,
            ),
            FlatButton(child: Text('Authenticate'), onPressed: authenticateToNeura),
            FlatButton(child: Text('Request Location Permission'), onPressed: requestPermission),
          ],
        ),
      ),
//
    );
  }
}
```

## iOS platform-specific implementation
Created by Rivi Elfenbein
Last updated yesterday at 8:05 PMAnalyticsAnalytics

Instructions
Follow our installation iOS guide in our dev site:
https://dev.theneura.com/tutorials/ios

Start by opening the iOS host portion of your Flutter app in Xcode:

Start Xcode.

Select the menu item File > Open….

Navigate to the directory holding your Flutter app, and select the ios folder inside it. Click OK.

Add support for Swift in the standard template setup that uses Objective-C:

Expand Runner > Runner in the Project navigator.

Open the file AppDelegate.swift located under Runner > Runner in the Project navigator.

Add to  the application:didFinishLaunchingWithOptions: function  a FlutterMethodChannel tied to the channel name samples.flutter.dev/battery:

```
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        //// Init Neura SDK
        NeuraSDK.shared.setAppUID("[APPUID]", appSecret: "[APP SECRET]]")
        UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
               
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        //        FlutterMethodChannel tied to the channel name com.neura.flutterApp/authenticate:
        let authenticateChannel = FlutterMethodChannel(name: "com.neura.flutterApp/authenticate",
                                                       binaryMessenger: controller.binaryMessenger)
       
        authenticateChannel.setMethodCallHandler{ (call, result) in
        
            self.authenticate(flutterResult: result)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
  ```      
    
 3. Add authentication method 
 
 ```
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
   ``` 
   
   
   
   
 ## Add an Android platform-specific implementation
 

1.first,follow our guide: https://dev.theneura.com/tutorials/android

2. Start by opening the Android host portion of your Flutter app in Android Studio:

Start Android Studio

Select the menu item File > Open…

Navigate to the directory holding your Flutter app, and select the android folder inside it. Click OK.

Open the MainActivity.java file located in the java folder in the Project view.

Next, create a MethodChannel and set a MethodCallHandler inside the configureFlutterEngine() method. Make sure to use the same channel name as was used on the Flutter client side.

 ```
package com.neura.flutterdemo;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {
    private static final String authenticateChannel = "com.neura.flutterApp/authenticate";
    private static final String TAG = "";
    private NeuraHelper mNeuraHelper;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mNeuraHelper =  new NeuraHelper(this);
        new MethodChannel(getFlutterView(), authenticateChannel).setMethodCallHandler(

        new MethodChannel.MethodCallHandler(){
            @Override
            public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                mNeuraHelper.authenticateAnonymously(result);

            }
        });
    }
}

 ```
 

3. authentication method from the stage 1 face is added For your convenience:
 ```

public void authenticateAnonymously( MethodChannel.Result result) {

    if (!isMinVersion()) {
        result.success("verison to min");
        return;
    }

    if (mNeuraApiClient.isLoggedIn()) {
        result.success("is logged in");
        return;
    }

    //Get the FireBase Instance ID, we will use it to instantiate AnonymousAuthenticationRequest
    FirebaseInstanceId.getInstance().getInstanceId()
            .addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                @Override
                public void onComplete(@NonNull Task<InstanceIdResult> task) {

                    if (!task.isSuccessful()) {
                        Log.w(TAG, "getInstanceId failed", task.getException());
                        return;
                    }

                    // Get new Instance ID token
                    if (task.getResult() != null) {
                        String pushToken = task.getResult().getToken();

                        //Instantiate AnonymousAuthenticationRequest instance.
                        AnonymousAuthenticationRequest request = new AnonymousAuthenticationRequest(pushToken);

                        //Pass the AnonymousAuthenticationRequest instance and register a call back for success and failure events.
                        mNeuraApiClient.authenticate(request, new AnonymousAuthenticateCallBack() {
                            @Override
                            public void onSuccess(AnonymousAuthenticateData data) {
                                //mNeuraApiClient.registerAuthStateListener(silentStateListener);
                                result.success("Successfully requested authentication");
                                Log.i(TAG, "Successfully requested authentication with neura. ");
                            }

                            @Override
                            public void onFailure(int errorCode) {
                               // mNeuraApiClient.unregisterAuthStateListener();
                                result.success("Failed to authenticate with neura. ");
                                Log.e(TAG, "Failed to authenticate with neura. " + "Reason : " + SDKUtils.errorCodeToString(errorCode));
                            }
                        });
                    } else {
                        Log.e(TAG, "Firebase task returned without result, cannot proceed with Authentication flow.");
                    }
                }
            });
             ```

   
   
   


