package com.wallpaper.pixamart

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.DisplayMetrics


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.pixamart/screenDimensions";

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if(call.method == "getScreenDimensions") {
                result.success(getScreenDimensions())
            }/* else {
                result.notImplemented()
            }*/
        }
    }

    private fun getScreenDimensions(): Map<String, Int> {
        val displayMetrics = DisplayMetrics()
        //windowManager.currentWindowMetrics(displayMetrics)
        windowManager.defaultDisplay.getMetrics(displayMetrics);
        return mapOf("height" to displayMetrics.widthPixels, "width" to displayMetrics.heightPixels);
    }
}
