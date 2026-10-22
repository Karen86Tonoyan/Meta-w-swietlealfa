/// BotEngine — rejestr botów ALFA (nazwa rytualna, rola, zakres).
/// Routing: lokalny wybór bota → zapytanie przez Bridge do hubu ALFA,
/// gdzie docelowy silnik (lub ensemble) generuje odpowiedź.
library;

import 'package:flutter/foundation.dart';

class AlfaBot {
  final String id;
  final String ritualName;
  final String role;
  final String scope;
  const AlfaBot(this.id, this.ritualName, this.role, this.scope);
}

class BotEngine extends ChangeNotifier {
  final bots = const [
    AlfaBot('ALFA_CODER_01', 'Rytuał Kodu', 'Kodowanie', 'Generowanie i poprawa kodu, review, refaktoryzacja'),
    AlfaBot('ALFA_ARCHITECT', 'Rytuał Struktury', 'Architektura', 'Projekt systemów, diagramy, decyzje architektoniczne'),
    AlfaBot('ALFA_DEBUGGER', 'Rytuał Tropu', 'Debugowanie', 'Analiza błędów, logi, hipotezy przyczyn'),
    AlfaBot('ALFA_TESTER', 'Rytuał Próby', 'Testy', 'Testy jednostkowe, scenariusze, edge cases'),
    AlfaBot('ALFA_DOC_GENERATOR', 'Rytuał Zapisu', 'Dokumentacja', 'README, specyfikacje, komentarze'),
    AlfaBot('ALFA_PROMPT_MASTER', 'Rytuał Słowa', 'Prompty', 'Optymalizacja promptów i instrukcji'),
  ];

  String activeBotId = 'ALFA_CODER_01';
  final List<({String bot, String text, bool fromUser})> history = [];

  AlfaBot get active => bots.firstWhere((b) => b.id == activeBotId);

  void select(String id) {
    activeBotId = id;
    notifyListeners();
  }

  void addUserMessage(String text) {
    history.add((bot: activeBotId, text: text, fromUser: true));
    notifyListeners();
  }

  void addBotReply(String botId, String text) {
    history.add((bot: botId, text: text, fromUser: false));
    notifyListeners();
  }
}
