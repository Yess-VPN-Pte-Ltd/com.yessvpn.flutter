package com.yessvpn.flutter.yess_vpn

import android.annotation.SuppressLint
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    companion object

    fun Connect() {
        val intent: Intent = YessVPNService.prepare(this@MainActivity)
        if (intent != null) {
            startActivityForResult(intent, 0)
        } else {
            onActivityResult(0, RESULT_OK, null)
        }
    }

    //用户同意后,开启vpn服务
    @SuppressLint("ResourceAsColor")
    override fun onActivityResult(request: Int, result: Int, data: Intent?) {
        super.onActivityResult(request, result, data)
        if (result == RESULT_OK) {
            val intent = Intent(this, YessVPNService::class.java)
            startService(intent)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val methodChannel: MethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "toAndroid")
        methodChannel.setMethodCallHandler { call, result ->
            run {
                if (call.method != null) {
                    if ("Connect" == call.method) {
                        result.success(Connect())
                    }
                } else {
                    result.notImplemented()
                }
            }
        }

    }


}
