/// Parsing defensivo — payloads `/v1/virtual-team/*` e `/v1/ai/handoffs`.
Map<String, dynamic> asMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asMapList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

int asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double? asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

String? asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class VtPageMeta {
  const VtPageMeta({
    required this.page,
    required this.perPage,
    required this.total,
  });

  final int page;
  final int perPage;
  final int total;

  factory VtPageMeta.fromJson(Map<String, dynamic> json) => VtPageMeta(
        page: asInt(json['page'], 1),
        perPage: asInt(json['per_page'], 20),
        total: asInt(json['total']),
      );
}

class VtAgentStats {
  const VtAgentStats({
    required this.tasksCompleted,
    required this.tasksFailed,
    required this.delegations,
    this.avgDurationMs,
  });

  final int tasksCompleted;
  final int tasksFailed;
  final int delegations;
  final int? avgDurationMs;

  factory VtAgentStats.fromJson(Map<String, dynamic> json) => VtAgentStats(
        tasksCompleted: asInt(json['tasks_completed']),
        tasksFailed: asInt(json['tasks_failed']),
        delegations: asInt(json['delegations']),
        avgDurationMs: json['avg_duration_ms'] == null
            ? null
            : asInt(json['avg_duration_ms']),
      );
}

class VtAgent {
  const VtAgent({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.specialty,
    required this.objective,
    required this.responsibilities,
    required this.priority,
    required this.state,
    required this.isAvailable,
    required this.isOnline,
    required this.stats,
    required this.queue,
    this.lastRunAt,
    this.model,
    this.maxConcurrent,
  });

  final String id;
  final String slug;
  final String name;
  final String description;
  final String specialty;
  final String objective;
  final List<String> responsibilities;
  final int priority;
  final String state;
  final bool isAvailable;
  final bool isOnline;
  final DateTime? lastRunAt;
  final VtAgentStats stats;
  final String queue;
  final String? model;
  final int? maxConcurrent;

  String get stateLabel {
    return switch (state) {
      'idle' => 'Aguardando',
      'busy' || 'running' => 'Em execução',
      'error' => 'Com falha',
      'offline' => 'Offline',
      _ => state,
    };
  }

  factory VtAgent.fromJson(Map<String, dynamic> json) {
    final last = asString(json['last_run_at']);
    final limits = asMap(json['limits']);
    final responsibilities = json['responsibilities'];
    return VtAgent(
      id: asString(json['id']) ?? '',
      slug: asString(json['slug']) ?? '',
      name: asString(json['name']) ?? 'Agente',
      description: asString(json['description']) ?? '',
      specialty: asString(json['specialty']) ?? '',
      objective: asString(json['objective']) ?? '',
      responsibilities: responsibilities is List
          ? responsibilities.map((e) => e.toString()).toList()
          : const [],
      priority: asInt(json['priority']),
      state: asString(json['state']) ?? 'idle',
      isAvailable: json['is_available'] == true,
      isOnline: json['is_online'] == true,
      lastRunAt: last != null ? DateTime.tryParse(last) : null,
      stats: VtAgentStats.fromJson(asMap(json['stats'])),
      queue: asString(json['queue']) ?? '',
      model: asString(json['model']),
      maxConcurrent: limits['max_concurrent'] == null
          ? null
          : asInt(limits['max_concurrent']),
    );
  }
}

class VtDashboard {
  const VtDashboard({
    required this.tasksOpen,
    required this.tasksCompleted24h,
    required this.tasksFailed24h,
    required this.efficiencyPct,
    required this.executions24h,
    required this.delegations24h,
    required this.handoffs24h,
    required this.learningsCurrent,
    required this.agentsActive,
    required this.agentsTotal,
    required this.audits24h,
    required this.queueDepth,
    this.avgDurationMs,
    this.generatedAt,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final int tasksOpen;
  final int tasksCompleted24h;
  final int tasksFailed24h;
  final int? avgDurationMs;
  final double efficiencyPct;
  final int executions24h;
  final int delegations24h;
  final int handoffs24h;
  final int learningsCurrent;
  final int agentsActive;
  final int agentsTotal;
  final int audits24h;
  final int queueDepth;
  final DateTime? generatedAt;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory VtDashboard.fromJson(
    Map<String, dynamic> json, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final gen = asString(json['generated_at']);
    return VtDashboard(
      tasksOpen: asInt(json['tasks_open']),
      tasksCompleted24h: asInt(json['tasks_completed_24h']),
      tasksFailed24h: asInt(json['tasks_failed_24h']),
      avgDurationMs: json['avg_duration_ms'] == null
          ? null
          : asInt(json['avg_duration_ms']),
      efficiencyPct: asDoubleOrNull(json['efficiency_pct']) ?? 0,
      executions24h: asInt(json['executions_24h']),
      delegations24h: asInt(json['delegations_24h']),
      handoffs24h: asInt(json['handoffs_24h']),
      learningsCurrent: asInt(json['learnings_current']),
      agentsActive: asInt(json['agents_active']),
      agentsTotal: asInt(json['agents_total']),
      audits24h: asInt(json['audits_24h']),
      queueDepth: asInt(json['queue_depth']),
      generatedAt: gen != null ? DateTime.tryParse(gen) : null,
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

/// Tarefa — parsing tolerante a campos futuros do backend.
class VtTask {
  const VtTask({
    required this.id,
    required this.title,
    required this.status,
    this.code,
    this.description,
    this.type,
    this.priority,
    this.agentSlug,
    this.agentName,
    this.origin,
    this.destination,
    this.createdAt,
    this.updatedAt,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String status;
  final String? code;
  final String? description;
  final String? type;
  final String? priority;
  final String? agentSlug;
  final String? agentName;
  final String? origin;
  final String? destination;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  factory VtTask.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    final updated = asString(json['updated_at']);
    return VtTask(
      id: asString(json['id']) ?? '',
      code: asString(json['code']),
      title: asString(json['title'] ?? json['name'] ?? json['subject']) ??
          'Tarefa',
      description: asString(json['description']),
      type: asString(json['type']),
      status: asString(json['status']) ?? 'unknown',
      priority: asString(
        json['priority_label'] ?? json['priority'] ?? json['priority_score'],
      ),
      agentSlug: asString(
        json['assigned_agent'] ?? json['agent_slug'] ?? json['assignee_slug'],
      ),
      agentName: asString(json['agent_name'] ?? json['assignee_name']),
      origin: asString(
        json['origin'] ?? json['from_agent'] ?? json['created_by_agent'],
      ),
      destination: asString(json['destination'] ?? json['to_agent']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
      updatedAt: updated != null ? DateTime.tryParse(updated) : null,
      raw: json,
    );
  }
}

class VtExecution {
  const VtExecution({
    required this.id,
    required this.status,
    this.taskId,
    this.agentSlug,
    this.agentName,
    this.startedAt,
    this.endedAt,
    this.durationMs,
    this.result,
    this.error,
    this.origin,
    this.destination,
    this.raw = const {},
  });

  final String id;
  final String status;
  final String? taskId;
  final String? agentSlug;
  final String? agentName;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationMs;
  final String? result;
  final String? error;
  final String? origin;
  final String? destination;
  final Map<String, dynamic> raw;

  factory VtExecution.fromJson(Map<String, dynamic> json) {
    final start = asString(json['started_at'] ?? json['created_at']);
    final end = asString(json['ended_at'] ?? json['finished_at']);
    return VtExecution(
      id: asString(json['id']) ?? '',
      status: asString(json['status']) ?? 'unknown',
      taskId: asString(json['task_id']),
      agentSlug: asString(json['agent_slug']),
      agentName: asString(json['agent_name']),
      startedAt: start != null ? DateTime.tryParse(start) : null,
      endedAt: end != null ? DateTime.tryParse(end) : null,
      durationMs:
          json['duration_ms'] == null ? null : asInt(json['duration_ms']),
      result: asString(json['result'] ?? json['outcome']),
      error: asString(json['error']),
      origin: asString(json['origin']),
      destination: asString(json['destination']),
      raw: json,
    );
  }
}

class VtEvent {
  const VtEvent({
    required this.id,
    required this.type,
    required this.title,
    this.agentSlug,
    this.createdAt,
    this.raw = const {},
  });

  final String id;
  final String type;
  final String title;
  final String? agentSlug;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  factory VtEvent.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at'] ?? json['occurred_at']);
    final type =
        asString(json['event_type'] ?? json['type'] ?? json['event']) ??
            'event';
    return VtEvent(
      id: asString(json['id']) ?? '',
      type: type,
      title: asString(json['title'] ?? json['message'] ?? type) ?? 'Evento',
      agentSlug: asString(json['agent_slug'] ?? json['actor_agent']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
      raw: json,
    );
  }
}

class VtHandoff {
  const VtHandoff({
    required this.id,
    required this.fromAgent,
    required this.toAgent,
    required this.reason,
    required this.status,
    this.taskId,
    this.kind,
    this.createdAt,
    this.payload = const {},
  });

  final String id;
  final String fromAgent;
  final String toAgent;
  final String reason;
  final String status;
  final String? taskId;
  final String? kind;
  final DateTime? createdAt;
  final Map<String, dynamic> payload;

  factory VtHandoff.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    return VtHandoff(
      id: asString(json['id']) ?? '',
      fromAgent: asString(json['from_agent']) ?? '—',
      toAgent: asString(json['to_agent']) ?? '—',
      reason: asString(json['reason']) ?? '',
      status: asString(json['status']) ?? '',
      taskId: asString(json['task_id']),
      kind: asString(json['handoff_kind']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
      payload: asMap(json['payload']),
    );
  }
}

class VtMemoryItem {
  const VtMemoryItem({
    required this.id,
    required this.label,
    this.detail,
    this.kind,
    this.agentSlug,
    this.createdAt,
    this.raw = const {},
  });

  final String id;
  final String label;
  final String? detail;
  final String? kind;
  final String? agentSlug;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  factory VtMemoryItem.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    return VtMemoryItem(
      id: asString(json['id']) ?? '',
      label: asString(json['title'] ?? json['label'] ?? json['key']) ??
          'Memória',
      detail: asString(json['body'] ?? json['detail'] ?? json['content']),
      kind: asString(json['kind']),
      agentSlug: asString(json['agent_slug']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
      raw: json,
    );
  }
}

class VtLearningItem {
  const VtLearningItem({
    required this.id,
    required this.title,
    this.body,
    this.outcome,
    this.agentSlug,
    this.createdAt,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? body;
  final String? outcome;
  final String? agentSlug;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  factory VtLearningItem.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    return VtLearningItem(
      id: asString(json['id']) ?? '',
      title: asString(json['topic'] ?? json['title'] ?? json['summary']) ??
          'Aprendizado',
      body: asString(
        json['summary'] ?? json['body'] ?? json['content'] ?? json['description'],
      ),
      outcome: asString(json['outcome']),
      agentSlug: asString(json['agent_slug']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
      raw: json,
    );
  }
}

class VtQueueItem {
  const VtQueueItem({
    required this.id,
    required this.label,
    this.agentSlug,
    this.priority,
    this.raw = const {},
  });

  final String id;
  final String label;
  final String? agentSlug;
  final String? priority;
  final Map<String, dynamic> raw;

  factory VtQueueItem.fromJson(Map<String, dynamic> json) => VtQueueItem(
        id: asString(json['id']) ?? '',
        label: asString(json['label'] ?? json['title'] ?? json['name']) ??
            'Item na fila',
        agentSlug: asString(json['agent_slug']),
        priority: asString(json['priority']),
        raw: json,
      );
}

class VtPagedList<T> {
  const VtPagedList({
    required this.items,
    this.meta,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final List<T> items;
  final VtPageMeta? meta;
  final bool fromCache;
  final String? cacheAgeLabel;
}

class VtLogEntry {
  const VtLogEntry({
    required this.id,
    required this.source,
    required this.level,
    required this.type,
    required this.message,
    this.agentSlug,
    this.taskId,
    this.createdAt,
  });

  final String id;
  final String source;
  final String level;
  final String type;
  final String message;
  final String? agentSlug;
  final String? taskId;
  final DateTime? createdAt;

  factory VtLogEntry.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    return VtLogEntry(
      id: asString(json['id']) ?? '',
      source: asString(json['source']) ?? '',
      level: asString(json['level']) ?? 'info',
      type: asString(json['type']) ?? '',
      message: asString(json['message']) ?? '',
      agentSlug: asString(json['agent_slug']),
      taskId: asString(json['task_id']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }
}

class VtAuditEntry {
  const VtAuditEntry({
    required this.id,
    required this.decisionType,
    required this.decidedBy,
    required this.rationale,
    required this.status,
    this.agentSlug,
    this.taskId,
    this.durationMs,
    this.createdAt,
  });

  final String id;
  final String decisionType;
  final String decidedBy;
  final String rationale;
  final String status;
  final String? agentSlug;
  final String? taskId;
  final int? durationMs;
  final DateTime? createdAt;

  factory VtAuditEntry.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    return VtAuditEntry(
      id: asString(json['id']) ?? '',
      decisionType: asString(json['decision_type']) ?? '',
      decidedBy: asString(json['decided_by']) ?? '',
      rationale: asString(json['rationale']) ?? '',
      status: asString(json['status']) ?? '',
      agentSlug: asString(json['agent_slug']),
      taskId: asString(json['task_id']),
      durationMs:
          json['duration_ms'] == null ? null : asInt(json['duration_ms']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }
}

class VtTimelineItem {
  const VtTimelineItem({
    required this.id,
    required this.kind,
    required this.title,
    this.body,
    this.agentSlug,
    this.taskId,
    this.createdAt,
  });

  final String id;
  final String kind;
  final String title;
  final String? body;
  final String? agentSlug;
  final String? taskId;
  final DateTime? createdAt;

  factory VtTimelineItem.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    return VtTimelineItem(
      id: asString(json['id']) ?? '',
      kind: asString(json['kind']) ?? 'event',
      title: asString(json['title']) ?? 'Evento',
      body: asString(json['body']),
      agentSlug: asString(json['agent_slug']),
      taskId: asString(json['task_id']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }
}

class VtAlert {
  const VtAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.status,
    this.source,
    this.agentSlug,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String severity;
  final String status;
  final String? source;
  final String? agentSlug;
  final DateTime? createdAt;

  factory VtAlert.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    return VtAlert(
      id: asString(json['id']) ?? '',
      title: asString(json['title']) ?? 'Alerta',
      body: asString(json['body'] ?? json['summary']) ?? '',
      severity: asString(json['severity']) ?? 'medium',
      status: asString(json['status']) ?? 'open',
      source: asString(json['source']),
      agentSlug: asString(json['agent_slug']),
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }
}

class VtSearchResults {
  const VtSearchResults({
    required this.query,
    required this.total,
    required this.tasks,
    required this.agents,
    required this.handoffs,
    required this.memory,
    required this.executions,
  });

  final String query;
  final int total;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> agents;
  final List<Map<String, dynamic>> handoffs;
  final List<Map<String, dynamic>> memory;
  final List<Map<String, dynamic>> executions;

  bool get isEmpty => total == 0;

  factory VtSearchResults.fromJson(
    Map<String, dynamic> data, {
    Map<String, dynamic>? meta,
    required String query,
  }) {
    return VtSearchResults(
      query: asString(meta?['q']) ?? query,
      total: asInt(meta?['total']),
      tasks: asMapList(data['tasks']),
      agents: asMapList(data['agents']),
      handoffs: asMapList(data['handoffs']),
      memory: asMapList(data['memory']),
      executions: asMapList(data['executions']),
    );
  }
}

class VtTeamRoot {
  const VtTeamRoot({
    required this.dashboard,
    required this.agentsState,
    required this.recentHandoffs,
    required this.stats,
    this.sprint,
    this.generatedAt,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final VtDashboard dashboard;
  final List<VtAgent> agentsState;
  final List<VtHandoff> recentHandoffs;
  final Map<String, dynamic> stats;
  final String? sprint;
  final DateTime? generatedAt;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory VtTeamRoot.fromJson(
    Map<String, dynamic> json, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final gen = asString(json['generated_at']);
    final dash = asMap(json['dashboard']);
    return VtTeamRoot(
      sprint: asString(json['sprint']),
      generatedAt: gen != null ? DateTime.tryParse(gen) : null,
      dashboard: VtDashboard.fromJson(dash.isEmpty ? json : dash),
      agentsState: asMapList(json['agents_state']).map(VtAgent.fromJson).toList(),
      recentHandoffs:
          asMapList(json['recent_handoffs']).map(VtHandoff.fromJson).toList(),
      stats: asMap(json['stats']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}
