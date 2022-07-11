package com.wallpaper.pixamart

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.DisplayMetrics


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.wallpaper.pixamart/screenSize";

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            // This method is invoked on the main thread.
            // TODO
            if(call.method == "getScreenSize") {
                val screenSize = getScreenSize();
                result.success(screenSize);
            } else {
                result.notImplemented();
            }
        }
    }

    private fun getScreenSize(): Map<String, Int> {
        val displayMetrics = DisplayMetrics();
        if(displayMetrics != null) {
            windowManager.defaultDisplay.getMetrics(displayMetrics);
            val screenSize = mapOf("height" to displayMetrics.widthPixels, "width" to displayMetrics.heightPixels);
            return screenSize;
        } else {
            val screenSize = mapOf("height" to 0, "width" to 0);
            return screenSize;
        }
    }
}
