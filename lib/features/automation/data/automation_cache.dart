import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'automation_models.dart';

/// Cache por tenant — Sprint 10.6.
class AutomationCache {
  AutomationCache({SharedPreferences? prefs})
    : _prefsFuture = prefs != null
          ? Future.value(prefs)
          : SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefsFuture;
  static const _prefix = 'pg_auto_';

  String _key(String tenant, String name) => '$_prefix${tenant}_$name';

  Future<void> saveDashboard(String tenant, AutoDashboardSnapshot snap) async {
    final prefs = await _prefsFuture;
    await prefs.setString(
      _key(tenant, 'dashboard'),
      jsonEncode({
        'saved_at': DateTime.now().toIso8601String(),
        'agents_active': snap.agentsActive,
        'agents_total': snap.agentsTotal,
        'executions_today': snap.executionsToday,
        'success_today': snap.successToday,
        'failures_today': snap.failuresToday,
        'queue_depth': snap.queueDepth,
        'alerts_critical': snap.alertsCritical,
        'efficiency_pct': snap.efficiencyPct,
        'pending_approvals': snap.pendingApprovals,
      }),
    );
  }

  Future<AutoDashboardSnapshot?> getDashboard(String tenant) async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_key(tenant, 'dashboard'));
    if (s == null || s.isEmpty) return null;
    try {
      final m = asAutoMap(jsonDecode(s));
      final saved = DateTime.tryParse('${m['saved_at']}');
      return AutoDashboardSnapshot(
        agentsActive: int.tryParse('${m['agents_active']}') ?? 0,
        agentsTotal: int.tryParse('${m['agents_total']}') ?? 0,
        executionsToday: int.tryParse('${m['executions_today']}') ?? 0,
        successToday: int.tryParse('${m['success_today']}') ?? 0,
        failuresToday: int.tryParse('${m['failures_today']}') ?? 0,
        queueDepth: int.tryParse('${m['queue_depth']}') ?? 0,
        alertsCritical: int.tryParse('${m['alerts_critical']}') ?? 0,
        efficiencyPct: double.tryParse('${m['efficiency_pct']}') ?? 0,
        pendingApprovals: int.tryParse('${m['pending_approvals']}') ?? 0,
        fromCache: true,
        cacheAgeLabel: saved == null ? null : _age(saved),
      );
    } catch (_) {
      return null;
    }
  }

  String _age(DateTime savedAt) {
    final s = DateTime.now().difference(savedAt).inSeconds;
    if (s < 60) return 'há ${s}s';
    final m = s ~/ 60;
    if (m < 60) return 'há ${m}min';
    return 'há ${m ~/ 60}h';
  }
}
