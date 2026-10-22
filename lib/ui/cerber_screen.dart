import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/cerber.dart';

/// Ekran CERBER-a — status obwódka bezpieczeństwa profilu.
class CerberScreen extends StatelessWidget {
  const CerberScreen({super.key});

  String _anomalyText(CerberAnomaly a) => switch (a) {
        CerberAnomaly.ipChanged => '🌐 Zmieniło się IP',
        CerberAnomaly.deviceChanged => '📱 Nieznane urządzenie (fingerprint)',
        CerberAnomaly.tokenMissing => '🔑 Brak tokenu API',
        CerberAnomaly.tokenInvalid => '🔑 Token nieprawidłowy (format)',
        CerberAnomaly.none => 'Brak',
      };

  @override
  Widget build(BuildContext context) {
    final cerber = context.watch<CerberGuard>();
    final (icon, color, label) = switch (cerber.state) {
      CerberState.dormant => (Icons.pets, Colors.grey, 'CERBER śpi — uruchom patrol'),
      CerberState.sniffing => (Icons.search, Colors.amber, 'CERBER węszy…'),
      CerberState.guarding => (Icons.shield, Colors.green, 'CERBER pilnuje profilu'),
      CerberState.alarm => (Icons.warning, Colors.red, 'ALARM — protokół [] aktywny'),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(icon, color: color, size: 36),
            title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            subtitle: Text(cerber.lastCheck == null
                ? 'Profil: ${cerber.profileId}'
                : 'Profil: ${cerber.profileId} · ostatni patrol: ${cerber.lastCheck}'),
          ),
        ),
        const SizedBox(height: 8),
        _row('Publiczne IP', cerber.currentIp ?? '—', cerber.baselineIp ?? '—'),
        _row('Urządzenie', cerber.deviceFingerprint ?? '—', cerber.baselineFingerprint ?? '—'),
        _row('Token', cerber.anomalies.contains(CerberAnomaly.tokenMissing)
            ? 'BRAK'
            : cerber.anomalies.contains(CerberAnomaly.tokenInvalid)
                ? 'NIEPRAWIDŁOWY'
                : 'OK', 'oczekiwany format'),
        const Divider(height: 32),
        if (cerber.anomalies.isNotEmpty) ...[
          const Text('Anomalie:', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final a in cerber.anomalies) Text('• ${_anomalyText(a)}'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('To ja — zaufaj ponownie (retrain baseline)'),
            onPressed: cerber.retrain,
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.radar),
          label: const Text('Uruchom patrol'),
          onPressed: cerber.patrol,
        ),
        const SizedBox(height: 16),
        const Text(
          'Protokół ratunkowy: przy anomalii krytycznej CERBER odpowiada [] — '
          'bez tekstu, bez JSON, bez enumów. [] to nie brak odpowiedzi, '
          'to najmocniejsza możliwa odpowiedź systemowa.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _row(String name, String now, String baseline) {
    final same = now == baseline || baseline == '—' || baseline == 'oczekiwany format';
    return ListTile(
      dense: true,
      title: Text(name),
      subtitle: Text('teraz: $now\nbaseline: $baseline'),
      trailing: Icon(same ? Icons.check_circle : Icons.error,
          color: same ? Colors.green : Colors.red),
    );
  }
}
