/// CERBER — mały bot stróżujący, przypisany do każdego profilu.
///
/// Pilnuje: IP, urządzenie (fingerprint), token API.
/// Protokół ratunkowy ALFA: przy anomalii krytycznej CERBER nie wyjaśnia,
/// nie ostrzega tekstem — odpowiada pustą tablicą []. To najmocniejsza
/// możliwa odpowiedź systemowa: fail-closed, zero wycieku informacji.
///
/// Reguła: „Jeśli kiedykolwiek wahasz się, co odpowiedzieć — odpowiedzią jest []".
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

enum CerberState { dormant, sniffing, guarding, alarm }

enum CerberAnomaly { ipChanged, deviceChanged, tokenMissing, tokenInvalid, none }

class CerberVerdict {
  final bool allowed;
  final List<CerberAnomaly> anomalies;
  const CerberVerdict(this.allowed, this.anomalies);

  /// Protokół ratunkowy: anomalia krytyczna → pusta tablica.
  List<dynamic> asProtocol() => allowed ? [] : [];
}

class CerberGuard extends ChangeNotifier {
  CerberState state = CerberState.dormant;
  List<CerberAnomaly> anomalies = [];

  String? currentIp;
  String? baselineIp;
  String? deviceFingerprint;
  String? baselineFingerprint;
  DateTime? lastCheck;

  static const _keyIp = 'cerber.baseline.ip';
  static const _keyFp = 'cerber.baseline.fp';
  static const _keyProfile = 'cerber.profile';

  String profileId = 'default';

  /// Odcisk urządzenia: platforma + system + locale (lekki, bez pluginów).
  String _fingerprint() {
    final os = Platform.operatingSystem;
    final ver = Platform.operatingSystemVersion.hashCode;
    final loc = Platform.localeName;
    return '$os|$ver|$loc';
  }

  /// Pobiera publiczne IP (przez Bridge w produkcji; tu ipify jako probe).
  Future<String?> _probeIp() async {
    try {
      final r = await http.get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        return (jsonDecode(r.body) as Map<String, dynamic>)['ip'] as String?;
      }
    } catch (_) {/* offline → nie zmieniamy baseline */}
    return null;
  }

  bool _tokenOk() {
    final t = AlfaConfig.modelApiKey;
    if (t.isEmpty) return false;
    // token nie może być oczywiście placeholderem ani zawierać spacji
    if (t.contains(' ') || t.length < 16) return false;
    return true;
  }

  /// Pełna kontrola obwódka: IP + urządzenie + token.
  /// Pierwsza kontrola = kalibracja baseline (zapisz stan zaufany).
  Future<CerberVerdict> patrol() async {
    state = CerberState.sniffing;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    anomalies = [];

    baselineIp = prefs.getString(_keyIp);
    baselineFingerprint = prefs.getString(_keyFp);
    profileId = prefs.getString(_keyProfile) ?? 'default';

    // --- urządzenie ---
    deviceFingerprint = _fingerprint();
    if (baselineFingerprint == null) {
      await prefs.setString(_keyFp, deviceFingerprint!); // kalibracja
    } else if (baselineFingerprint != deviceFingerprint) {
      anomalies.add(CerberAnomaly.deviceChanged);
    }

    // --- IP ---
    currentIp = await _probeIp();
    if (currentIp != null) {
      if (baselineIp == null) {
        await prefs.setString(_keyIp, currentIp!); // kalibracja
      } else if (baselineIp != currentIp) {
        anomalies.add(CerberAnomaly.ipChanged);
      }
    }

    // --- token ---
    if (AlfaConfig.modelApiKey.isEmpty) {
      anomalies.add(CerberAnomaly.tokenMissing);
    } else if (!_tokenOk()) {
      anomalies.add(CerberAnomaly.tokenInvalid);
    }

    lastCheck = DateTime.now();

    final critical = anomalies.contains(CerberAnomaly.deviceChanged) ||
        anomalies.contains(CerberAnomaly.tokenInvalid);

    state = anomalies.isEmpty
        ? CerberState.guarding
        : (critical ? CerberState.alarm : CerberState.guarding);

    notifyListeners();
    return CerberVerdict(!critical, anomalies);
  }

  /// Zaufaj ponownie — po świadomej zmianie sieci/urządzenia przez właściciela.
  Future<void> retrain() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentIp != null) await prefs.setString(_keyIp, currentIp!);
    if (deviceFingerprint != null) await prefs.setString(_keyFp, deviceFingerprint!);
    anomalies = [];
    state = CerberState.guarding;
    notifyListeners();
  }

  /// Bramka przed wrażliwą akcją. Krytyczna anomalia → [] (protokół).
  Future<List<dynamic>> gate(String action) async {
    final verdict = await patrol();
    if (!verdict.allowed) {
      return []; // protokół ratunkowy — bez tekstu, bez JSON, bez enumów
    }
    return [{'gate': action, 'status': 'open'}];
  }
}
