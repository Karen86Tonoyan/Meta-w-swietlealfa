/// Warstwa natywna Meta Wearables SDK przez MethodChannel.
///
/// UWAGA: wymaga zatwierdzonego konta Meta Wearables Developer.
/// Do czasu zatwierdzenia kanał zwraca stub-data, więc cała reszta
/// aplikacji (Bridge, boty, UI, Windows) działa niezależnie.
library;

import 'package:flutter/services.dart';

class MetaWearablesChannel {
  static const _ch = MethodChannel('alfa/meta_wearables');

  Future<bool> isConnected() async {
    try {
      return await _ch.invokeMethod<bool>('isConnected') ?? false;
    } on MissingPluginException {
      return false; // stub / Windows
    }
  }

  Future<void> startAudioStream() async {
    try {
      await _ch.invokeMethod('startAudioStream');
    } on MissingPluginException {/* stub */}
  }

  Future<void> capturePhoto() async {
    try {
      await _ch.invokeMethod('capturePhoto');
    } on MissingPluginException {/* stub */}
  }

  /// Strumień zdarzeń z okularów (przyciski, audio, klatki).
  Stream<dynamic> events() {
    const ev = EventChannel('alfa/meta_wearables/events');
    return ev.receiveBroadcastStream();
  }
}
