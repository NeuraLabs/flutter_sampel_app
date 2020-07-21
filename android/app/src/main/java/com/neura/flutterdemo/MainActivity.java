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
        //GeneratedPluginRegistrant.registerWith(this);
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
