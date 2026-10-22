package com.alfa.meta_glasses

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Stub kanału Meta Wearables (Android).
 * Po zatwierdzeniu Meta Wearables Developer:
 * 1. Dodaj Meta Wearables SDK do build.gradle.
 * 2. Zamień stub-y na realne wywołania SDK (pairing, audio stream, camera).
 */
class MainActivity : FlutterActivity() {
    private val CHANNEL = "alfa/meta_wearables"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isConnected" -> result.success(false) // TODO: Meta SDK
                    "startAudioStream" -> result.success(null) // TODO: Meta SDK
                    "capturePhoto" -> result.success(null) // TODO: Meta SDK
                    else -> result.notImplemented()
                }
            }
    }
}
