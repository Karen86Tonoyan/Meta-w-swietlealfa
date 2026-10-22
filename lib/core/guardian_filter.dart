/// Guardian — klient-side pre-filter przed wysłaniem czegokolwiek do Bridge.
/// Pełny Guardian (CERBER) żyje po stronie serwera ALFA; tu tylko
/// deterministyczne reguły pierwszej linii.
library;

class GuardianFilter {
  static const _blockedPatterns = [
    'api_key', 'password', 'token:', 'BEGIN PRIVATE KEY',
  ];

  /// Zwraca null jeśli czyste; inaczej powód blokady.
  static String? check(String input) {
    final lower = input.toLowerCase();
    for (final p in _blockedPatterns) {
      if (lower.contains(p.toLowerCase())) {
        return 'Guardian: wykryto wrażliwy wzorzec ($p) — zablokowano lokalnie';
      }
    }
    if (input.length > 8000) return 'Guardian: przekroczono limit długości wejścia';
    return null;
  }
}
