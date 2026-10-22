/// ALFA Bridge — połączenie WebSocket do lokalnego huba ALFA.
///
/// Na Androidzie/iOS: Bridge działa na telefonie lub w LAN.
/// Na Windowsie: aplikacja łączy się z Bridge przez WebSocket
/// i dostaje pełną funkcjonalność danych (transkrypcja, obrazy,
/// pamięć Brain, odpowiedzi botów) — bez bezpośredniego parowania
/// z okularami (Meta Wearables SDK nie wspiera Windows).
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum BridgeState { disconnected, connecting, connected, error }

class AlfaBridge extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  BridgeState state = BridgeState.disconnected;
  String endpoint = 'ws://127.0.0.1:8080/bridge';
  final List<Map<String, dynamic>> eventLog = [];

  final _transcriptionCtrl = StreamController<String>.broadcast();
  final _frameCtrl = StreamController<Uint8List>.broadcast();

  Stream<String> get transcriptions => _transcriptionCtrl.stream;
  Stream<Uint8List> get frames => _frameCtrl.stream;

  Future<void> connect() async {
    state = BridgeState.connecting;
    notifyListeners();
    try {
      _channel = WebSocketChannel.connect(Uri.parse(endpoint));
      await _channel!.ready;
      state = BridgeState.connected;
      _sub = _channel!.stream.listen(_onMessage, onDone: _onDone, onError: (_) => _onDone());
    } catch (e) {
      state = BridgeState.error;
    }
    notifyListeners();
  }

  void _onMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      eventLog.add(msg);
      switch (msg['type']) {
        case 'transcription':
          _transcriptionCtrl.add(msg['text'] as String);
        case 'frame':
          _frameCtrl.add(base64Decode(msg['jpeg_b64'] as String));
      }
      notifyListeners();
    } catch (_) {/* Guardian: drop malformed frames */}
  }

  void _onDone() {
    state = BridgeState.disconnected;
    notifyListeners();
  }

  void send(Map<String, dynamic> msg) {
    if (state == BridgeState.connected) {
      _channel!.sink.add(jsonEncode(msg));
    }
  }

  void askBot(String botId, String prompt) {
    send({'type': 'bot_request', 'bot': botId, 'prompt': prompt, 'ts': DateTime.now().toIso8601String()});
  }

  @override
  void dispose() {
    _sub?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
