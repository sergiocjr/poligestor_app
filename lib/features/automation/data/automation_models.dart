/// Sprint 10.6 — modelos da Central de Automação (PoliGestor).
library;

/// Níveis de autonomia (UI). Fonte LIVE atual: `autonomy_level` em `/v1/ai/team`.
enum AutonomyLevel {
  disabled(0, 'Desativado'),
  observe(1, 'Observar'),
  suggest(2, 'Sugerir'),
  draft(3, 'Criar rascunho'),
  approve(4, 'Executar com aprovação'),
  auto(5, 'Executar automaticamente');

  const AutonomyLevel(this.value, this.label);
  final int value;
  final String label;

  static AutonomyLevel fromRaw(String? raw) {
    final s = (raw ?? '').toLowerCase().trim();
    return switch (s) {
      '0' || 'disabled' || 'off' || 'desativado' => AutonomyLevel.disabled,
      '1' || 'observe' || 'observar' => AutonomyLevel.observe,
      '2' || 'suggest' || 'sugerir' => AutonomyLevel.suggest,
      '3' || 'draft' || 'rascunho' => AutonomyLevel.draft,
      '4' ||
      'approve' ||
      'approval' ||
      'com_aprovacao' => AutonomyLevel.approve,
      '5' || 'auto' || 'automatic' || 'autonomous' => AutonomyLevel.auto,
      _ => AutonomyLevel.suggest,
    };
  }
}

class AutoAgentAutonomy {
  const AutoAgentAutonomy({
    required this.agentSlug,
    required this.level,
    this.enabled = true,
  });

  final String agentSlug;
  final AutonomyLevel level;
  final bool enabled;

  factory AutoAgentAutonomy.fromJson(Map<String, dynamic> json) {
    return AutoAgentAutonomy(
      agentSlug: (json['agent_slug'] ?? json['slug'] ?? '').toString(),
      level: AutonomyLevel.fromRaw(
        (json['autonomy_level'] ?? json['autonomy'] ?? json['level'])
            ?.toString(),
      ),
      enabled: json['is_enabled'] != false,
    );
  }
}

class AutoDashboardSnapshot {
  const AutoDashboardSnapshot({
    required this.agentsActive,
    required this.agentsTotal,
    required this.executionsToday,
    required this.successToday,
    required this.failuresToday,
    required this.queueDepth,
    required this.alertsCritical,
    required this.efficiencyPct,
    this.pendingApprovals = 0,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final int agentsActive;
  final int agentsTotal;
  final int executionsToday;
  final int successToday;
  final int failuresToday;
  final int queueDepth;
  final int alertsCritical;
  final double efficiencyPct;
  final int pendingApprovals;
  final bool fromCache;
  final String? cacheAgeLabel;
}

/// Modelo preparado para `/v1/automations` (quando publicado).
class AutoAutomation {
  const AutoAutomation({
    required this.id,
    required this.name,
    this.description,
    this.agentSlug,
    this.status,
    this.trigger,
    this.nextRunAt,
    this.lastRunAt,
    this.autonomy,
    this.successCount = 0,
    this.failureCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final String? agentSlug;
  final String? status;
  final String? trigger;
  final DateTime? nextRunAt;
  final DateTime? lastRunAt;
  final AutonomyLevel? autonomy;
  final int successCount;
  final int failureCount;

  factory AutoAutomation.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return AutoAutomation(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? 'Automação').toString(),
      description: json['description']?.toString(),
      agentSlug: (json['agent_slug'] ?? json['agent'])?.toString(),
      status: json['status']?.toString(),
      trigger: (json['trigger'] ?? json['trigger_type'])?.toString(),
      nextRunAt: dt(json['next_run_at'] ?? json['scheduled_at']),
      lastRunAt: dt(json['last_run_at']),
      autonomy: AutonomyLevel.fromRaw(json['autonomy_level']?.toString()),
      successCount: int.tryParse('${json['success_count'] ?? 0}') ?? 0,
      failureCount: int.tryParse('${json['failure_count'] ?? 0}') ?? 0,
    );
  }

  String get statusLabel => switch ((status ?? '').toLowerCase()) {
    'active' || 'enabled' || 'ativa' => 'Ativa',
    'paused' || 'pausada' => 'Pausada',
    'draft' || 'rascunho' => 'Rascunho',
    'disabled' || 'inactive' => 'Desativada',
    '' => '—',
    _ => status!,
  };
}

List<Map<String, dynamic>> asAutoMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final v = raw['data'] ?? raw['items'] ?? raw['results'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

Map<String, dynamic> asAutoMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}
