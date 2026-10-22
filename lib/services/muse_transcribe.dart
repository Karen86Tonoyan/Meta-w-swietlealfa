/// Muse Voice Transcribe — klient realtime STT.
///
/// Strumień: mikrofon okularów (Meta Wearables SDK) → ten klient
/// (wss://api.meta.ai/v1/asr/realtime) → transkrypcje → router ALFA.
///
/// Fallback: lokalny Whisper/Glimmer przez Bridge, gdy preferLocal = true.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/config.dart';

enum SttState { idle, connecting, streaming, error }

class MuseTranscribe extends ChangeNotifier {
  WebSocketChannel? _ws;
  SttState state = SttState.idle;

  final _partialCtrl = StreamController<String>.broadcast(); // częściowe
  final _finalCtrl = StreamController<String>.broadcast();   // sfinalizowane (po endpointingu)
  final _speakerCtrl = StreamController<({int speaker, String text})>.broadcast(); // diaryzacja

  Stream<String> get partials => _partialCtrl.stream;
  Stream<String> get finals => _finalCtrl.stream;
  Stream<({int speaker, String text})> get speakerTurns => _speakerCtrl.stream;

  Future<bool> start({String language = 'pl'}) async {
    state = SttState.connecting;
    notifyListeners();
    try {
      final uri = Uri.parse(AlfaConfig.asrRealtimeUrl).replace(queryParameters: {
        'model': AlfaConfig.sttModel,
        'language': language,
      });
      _ws = WebSocketChannel.connect(
        uri,
        protocols: ['bearer-token', AlfaConfig.modelApiKey],
      );
      await _ws!.ready;

      // Konfiguracja sesji: keyword biasing (rytuał ALFA) + VAD
      _ws!.sink.add(jsonEncode({
        'type': 'session.update',
        'session': {
          'model': AlfaConfig.sttModel,
          'language': language,
          'keywords': AlfaConfig.sttKeywords,
          'diarization': true,
          'vad': {'enabled': true, 'silence_ms': 700},
        },
      }));

      _ws!.stream.listen(_onEvent, onDone: _stop, onError: (_) => _stop());
      state = SttState.streaming;
      notifyListeners();
      return true;
    } catch (_) {
      state = SttState.error;
      notifyListeners();
      return false;
    }
  }

  /// Surowe ramki audio z okularów (PCM16 16kHz mono).
  void sendAudio(Uint8List pcm16) {
    if (state != SttState.streaming) return;
    _ws!.sink.add(jsonEncode({
      'type': 'audio.append',
      'audio': base64Encode(pcm16),
    }));
  }

  void commitTurn() {
    _ws?.sink.add(jsonEncode({'type': 'audio.commit'}));
  }

  void _onEvent(dynamic raw) {
    try {
      final e = jsonDecode(raw as String) as Map<String, dynamic>;
      switch (e['type']) {
        case 'transcript.partial':
          _partialCtrl.add(e['text'] as String);
        case 'transcript.final':
          _finalCtrl.add(e['text'] as String);
          if (e['speaker'] != null) {
            _speakerCtrl.add((speaker: e['speaker'] as int, text: e['text'] as String));
          }
        case 'error':
          state = SttState.error;
          notifyListeners();
      }
    } catch (_) {/* Guardian: drop malformed */}
  }

  void _stop() {
    state = SttState.idle;
    notifyListeners();
  }

  Future<void> stop() async {
    await _ws?.sink.close();
    _stop();
  }

  @override
  void dispose() {
    _ws?.sink.close();
    super.dispose();
  }
}
