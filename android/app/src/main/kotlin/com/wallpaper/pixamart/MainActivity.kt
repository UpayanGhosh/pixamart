package com.wallpaper.pixamart

import android.app.WallpaperManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.wallpaper.pixamart/wallpaper")
            .setMethodCallHandler { call, result ->
                if (call.method != "setWallpaper") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                val location = call.argument<Int>("location") ?: 3
                val file = path?.let { File(it) }
                if (file == null || !file.isFile) {
                    result.error("NO_FILE", "Wallpaper file not found", null)
                    return@setMethodCallHandler
                }
                val flags = when (location) {
                    1 -> WallpaperManager.FLAG_SYSTEM
                    2 -> WallpaperManager.FLAG_LOCK
                    else -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                }
                thread {
                    try {
                        FileInputStream(file).use {
                            WallpaperManager.getInstance(applicationContext).setStream(it, null, true, flags)
                        }
                        runOnUiThread { result.success(true) }
                    } catch (e: Exception) {
                        runOnUiThread { result.error("SET_FAILED", e.message, null) }
                    }
                }
            }
    }
}
