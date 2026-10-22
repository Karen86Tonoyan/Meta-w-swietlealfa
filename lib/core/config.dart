/// Centralna konfiguracja ALFA × Meta.
/// KLUCZE: w produkcji NIE w aplikacji — przez ALFA Bridge (serwer).
/// Klucz w kliencie tylko do developmentu; Guardian zablokuje commit klucza.
library;

class AlfaConfig {
  /// Meta Model API
  static const metaApiBase = 'https://api.meta.ai/v1';
  static const asrRealtimeUrl = 'wss://api.meta.ai/v1/asr/realtime';
  static const asrFileUrl = '$metaApiBase/asr/transcribe';
  static const chatUrl = '$metaApiBase/chat/completions';

  /// Modele
  static const sttModel = 'muse-voice-transcribe-1.0';
  static const botModel = 'muse-spark-1.3';
  static const heavyModel = 'muse-wonder-1.0';

  /// Klucz API — dev only. Produkcyjnie: Bridge wstrzykuje z serwera.
  static String modelApiKey = const String.fromEnvironment('MODEL_API_KEY', defaultValue: '');

  /// Endpoint ALFA Bridge (telefon w LAN / localhost)
  static String bridgeEndpoint = 'ws://127.0.0.1:8080/bridge';

  /// Lokalny fallback (self-hosted Muse Glimmer przez vLLM/llama.cpp, OpenAI-compatible)
  static String localFallbackBase = 'http://127.0.0.1:8000/v1';
  static bool preferLocal = false;

  /// Keyword biasing dla STT — rytuał ALFA
  static const sttKeywords = [
    'ALFA', 'Guardian', 'CERBER', 'Brain', 'Bridge',
    'ALFA_CODER_01', 'ALFA_ARCHITECT', 'ALFA_DEBUGGER',
    'ALFA_TESTER', 'ALFA_DOC_GENERATOR', 'ALFA_PROMPT_MASTER',
  ];
}
