/// Muse API — klient chat completions (muse-spark-1.3 / muse-wonder-1.0)
/// z lokalnym fallbackiem (self-hosted Glimmer, OpenAI-compatible).
///
/// Routing:
///   preferLocal=true  → najpierw lokalny Glimmer, błąd → Meta API
///   preferLocal=false → Meta API, brak klucza → lokalny
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class MuseApi {
  /// Zwraca odpowiedź tekstową modelu.
  Future<String> chat({
    required List<Map<String, String>> messages,
    bool heavy = false,
    double temperature = 0.5,
  }) async {
    final model = heavy ? AlfaConfig.heavyModel : AlfaConfig.botModel;

    if (AlfaConfig.preferLocal) {
      try {
        return await _call(AlfaConfig.localFallbackBase, model: 'local', messages: messages, temperature: temperature);
      } catch (_) {/* spadamy do Meta API */}
    }

    if (AlfaConfig.modelApiKey.isEmpty) {
      return await _call(AlfaConfig.localFallbackBase, model: 'local', messages: messages, temperature: temperature);
    }

    return await _call(
      AlfaConfig.metaApiBase,
      model: model,
      messages: messages,
      temperature: temperature,
      apiKey: AlfaConfig.modelApiKey,
    );
  }

  Future<String> _call(
    String base, {
    required String model,
    required List<Map<String, String>> messages,
    required double temperature,
    String? apiKey,
  }) async {
    final r = await http.post(
      Uri.parse('$base/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey != null) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': temperature,
      }),
    );
    if (r.statusCode == 429 || r.statusCode >= 500) {
      // Retry-After honored by caller's Bridge; tutaj prosty rzut błędu
      throw StateError('Muse API ${r.statusCode}: ${r.body}');
    }
    if (r.statusCode != 200) throw StateError('Muse API ${r.statusCode}');
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return j['choices'][0]['message']['content'] as String;
  }
}
