/// PlanGuard — CERBER waliduje plan człowieka i kroki agenta.
///
/// Zasada: żaden krok agenta nie wykonuje się, zanim CERBER go nie
/// zwaliduje. Plan człowieka jest sprawdzany jako całość na starcie
/// (spójność, dozwolone akcje), kroki agenta — pojedynczo, tuż przed
/// wykonaniem. Krytyczne naruszenie → protokół [] (fail-closed).
library;

import 'cerber.dart';

/// Typy akcji, które agent w ogóle może planować.
enum StepKind {
  readFile,      // odczyt — bezpieczny
  writeFile,     // zapis — wymaga zgodny planu
  runCommand,    // komenda — wysokie ryzyko
  sendMessage,   // wysyłka — zawsze zatwierdzenie
  networkCall,   // sieć — sprawdzany host
  deleteFile,    // kasowanie — zawsze zatwierdzenie
}

class PlanStep {
  final StepKind kind;
  final String target;     // ścieżka / host / polecenie
  final String? detail;
  const PlanStep(this.kind, this.target, {this.detail});
}

class StepVerdict {
  final bool allowed;
  final bool needsHumanApproval;
  final String? reason;
  const StepVerdict.allow() : allowed = true, needsHumanApproval = false, reason = null;
  const StepVerdict.ask(this.reason) : allowed = false, needsHumanApproval = true;
  const StepVerdict.deny(this.reason) : allowed = false, needsHumanApproval = false;
}

class PlanGuard {
  final CerberGuard cerber;
  PlanGuard(this.cerber);

  /// Hosty dozwolone dla networkCall (allow-lista, nie deny-lista).
  static const allowedHosts = [
    'api.meta.ai', 'api.github.com', 'api.ipify.org',
  ];

  /// Ścieżki, których agent nigdy nie rusza (deny-lista bezwzględna).
  static const forbiddenPaths = [
    '.env', 'secrets', '.git/', 'id_rsa', '.ssh',
  ];

  static const _dangerousCmds = [
    'rm -rf', 'mkfs', 'dd if=', ':(){', 'chmod 777', 'curl | sh', 'wget | sh',
  ];

  /// 1) Walidacja PLANU CZŁOWIEKA — całość, przed startem agenta.
  ///    Sprawdza spójność i wstępną dopuszczalność każdego kroku.
  Future<List<dynamic>> validateHumanPlan(List<PlanStep> plan) async {
    // Najpierw patrol środowiska — jeśli obwódka padła, plan nie rusza.
    final env = await cerber.patrol();
    if (!env.allowed) return []; // protokół []

    if (plan.isEmpty) return [];
    if (plan.length > 50) {
      return [
        {'verdict': 'revise', 'reason': 'plan zbyt długi — rozbij na fazy (max 50 kroków)'}
      ];
    }

    final issues = <Map<String, dynamic>>[];
    for (var i = 0; i < plan.length; i++) {
      final v = validateAgentStep(plan[i], stepIndex: i);
      if (!v.allowed && !v.needsHumanApproval) {
        issues.add({'step': i, 'target': plan[i].target, 'reason': v.reason});
      }
    }
    if (issues.isNotEmpty) {
      return [{'verdict': 'revise', 'issues': issues}];
    }
    return [{'verdict': 'approved', 'steps': plan.length}];
  }

  /// 2) Walidacja KROKU AGENTA — pojedynczo, tuż przed wykonaniem.
  ///    Agent może odbiegać od planu — dlatego każdy krok przechodzi
  ///    przez CERBER-a niezależnie od zatwierdzonego planu.
  StepVerdict validateAgentStep(PlanStep step, {int? stepIndex}) {
    // Ścieżki zakazane — bezwzględna odmowa.
    for (final f in forbiddenPaths) {
      if (step.target.contains(f)) {
        return StepVerdict.deny('CERBER: ścieżka zakazana ($f)');
      }
    }

    switch (step.kind) {
      case StepKind.readFile:
        return const StepVerdict.allow();

      case StepKind.writeFile:
        return const StepVerdict.allow(); // diff + Accept/Reject po stronie IDE

      case StepKind.networkCall:
        final ok = allowedHosts.any((h) => step.target.contains(h));
        return ok
            ? const StepVerdict.allow()
            : StepVerdict.ask('CERBER: host poza allow-listą (${step.target}) — zatwierdź');

      case StepKind.runCommand:
        for (final d in _dangerousCmds) {
          if (step.target.contains(d)) {
            return StepVerdict.deny('CERBER: komenda niebezpieczna ($d)');
          }
        }
        return StepVerdict.ask('CERBER: komenda wymaga zatwierdzenia: ${step.target}');

      case StepKind.sendMessage:
      case StepKind.deleteFile:
        return StepVerdict.ask('CERBER: ${step.kind.name} zawsze wymaga zatwierdzenia');
    }
  }

  /// Bramka wykonawcza: allowed → wykonaj; ask → kanał zatwierdzania;
  /// deny → krok umiera. Błąd patrolu → [].
  Future<List<dynamic>> gateStep(PlanStep step, {int? stepIndex}) async {
    final v = validateAgentStep(step, stepIndex: stepIndex);
    if (!v.allowed && !v.needsHumanApproval) {
      return []; // deny krytyczne → protokół []
    }
    return [
      {
        'gate': 'step',
        'kind': step.kind.name,
        'target': step.target,
        'status': v.allowed ? 'open' : 'awaiting_approval',
        if (v.reason != null) 'reason': v.reason,
      }
    ];
  }
}
