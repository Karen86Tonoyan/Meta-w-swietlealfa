package com.alfa.meta_glasses

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Kanał Meta Wearables (Android).
 *
 * Stan: STUB do czasu zatwierdzenia konta Meta Wearables Developer.
 *
 * Zasada izolacji (obowiązuje też po podmianie na realne SDK):
 * audio z okularów NIGDY nie opuszcza urządzenia „na żywca" — ramki PCM
 * lecą wyłącznie przez EventChannel do Darta, gdzie decyzja o dalszej
 * drodze (Muse realtime API albo lokalny Bridge z CERBER) należy do
 * AlfaConfig.preferLocal i polityki Guardian.
 *
 * Po zatwierdzeniu Meta Wearables Developer:
 * 1. Dodaj Meta Wearables SDK do build.gradle.
 * 2. Zamień stub-y na realne wywołania SDK (pairing, audio stream, camera).
 * 3. Ramki audio pushuj do `audioSink` w formacie PCM16 16kHz mono.
 */
class MainActivity : FlutterActivity() {
    private val CHANNEL = "alfa/meta_wearables"
    private val EVENTS = "alfa/meta_wearables/events"
    private var audioSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // TODO: Meta SDK → Wearables.session().isConnected
                    "isConnected" -> result.success(false)
                    // TODO: Meta SDK → startAudio { pcm -> audioSink?.success(pcm) }
                    "startAudioStream" -> result.success(null)
                    "stopAudioStream" -> result.success(null)
                    // TODO: Meta SDK → camera.capture()
                    "capturePhoto" -> result.success(null)
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTS)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    audioSink = events
                }
                override fun onCancel(arguments: Any?) {
                    audioSink = null
                }
            })
    }

    override fun onDestroy() {
        audioSink?.endOfStream()
        audioSink = null
        super.onDestroy()
    }
}
