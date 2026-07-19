import '../../mandate/data/mandate_models.dart';

export '../../mandate/data/mandate_models.dart'
    show
        asMap,
        asMapList,
        asInt,
        asDouble,
        asString,
        MandatePeriod,
        MandateBriefing;

/// Filtros enviados às rotas `/v1/mandate/{analytics,trends,insights,briefing,briefings}`.
class IntelligenceFilter {
  const IntelligenceFilter({
    this.period,
    this.from,
    this.to,
    this.district,
    this.category,
    this.assigneeId,
    this.scope,
    this.generate,
  });

  /// today | 7d | 30d (quando a API aceitar)
  final String? period;
  final String? from;
  final String? to;
  final String? district;
  final String? category;
  final String? assigneeId;

  /// daily | weekly | monthly (briefings)
  final String? scope;
  final bool? generate;

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      if (v is bool) {
        if (v) q[k] = 1;
        return;
      }
      q[k] = v;
    }

    put('period', period);
    put('from', from);
    put('to', to);
    put('district', district);
    put('category', category);
    put('assignee_id', assigneeId);
    put('scope', scope);
    put('generate', generate == true ? true : null);
    return q;
  }
}

class IntelligenceInsight {
  const IntelligenceInsight({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.body,
    this.data = const {},
    this.periodFrom,
    this.periodTo,
    this.detectedAt,
  });

  final String id;
  final String type;
  final String priority;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? periodFrom;
  final String? periodTo;
  final DateTime? detectedAt;

  String get categoryLabel {
    return switch (type) {
      'overdue_pressure' => 'Atrasos',
      'subject_rising' => 'Assunto em alta',
      'subject_concentration' => 'Concentração',
      'neighborhood_hotspot' => 'Bairro',
      'team_overload' => 'Equipe',
      'low_ratings' => 'Avaliações',
      _ => type.replaceAll('_', ' '),
    };
  }

  /// CTA amigável derivado do `type` (não vem campo action no payload).
  String get recommendedAction {
    return switch (type) {
      'overdue_pressure' => 'Priorize a fila de atendimentos atrasados.',
      'subject_rising' =>
        'Acompanhe o assunto em crescimento e planeje resposta.',
      'subject_concentration' =>
        'Revise a concentração deste assunto no período.',
      'neighborhood_hotspot' => 'Olhe de perto o bairro em destaque.',
      'team_overload' => 'Redistribua a carga da equipe sobrecarregada.',
      'low_ratings' => 'Analise os casos com avaliações baixas.',
      _ => 'Revise este ponto com a equipe do gabinete.',
    };
  }

  String? get routeHint {
    return switch (type) {
      'overdue_pressure' => '/home/protocols',
      'subject_rising' || 'subject_concentration' => '/home/mandate/subjects',
      'neighborhood_hotspot' => '/home/mandate/neighborhoods',
      'team_overload' => '/home/mandate/team',
      _ => null,
    };
  }

  bool get isOpportunity {
    return priority == 'attention' ||
        type.contains('rising') ||
        type.contains('hotspot') ||
        type.contains('overload') ||
        type.contains('overdue');
  }

  factory IntelligenceInsight.fromJson(Map<String, dynamic> json) {
    final detected = asString(json['detected_at']);
    return IntelligenceInsight(
      id: asString(json['id']) ?? '',
      type: asString(json['type']) ?? 'insight',
      priority: asString(json['priority']) ?? 'info',
      title: asString(json['title']) ?? 'Insight',
      body: asString(json['body'] ?? json['description']) ?? '',
      data: asMap(json['data']),
      periodFrom: asString(json['period_from']),
      periodTo: asString(json['period_to']),
      detectedAt: detected != null ? DateTime.tryParse(detected) : null,
    );
  }
}

class IntelligenceInsightsData {
  const IntelligenceInsightsData({
    required this.items,
    required this.generated,
    this.audience,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final List<IntelligenceInsight> items;
  final int generated;
  final String? audience;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory IntelligenceInsightsData.fromJson(
    Map<String, dynamic> json, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    return IntelligenceInsightsData(
      items: asMapList(
        json['items'],
      ).map(IntelligenceInsight.fromJson).toList(),
      generated: asInt(json['generated'], asMapList(json['items']).length),
      audience: asString(json['audience']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class TrendPoint {
  const TrendPoint({
    required this.label,
    required this.created,
    required this.resolved,
  });

  final String label;
  final int created;
  final int resolved;

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
    label: asString(json['date'] ?? json['week'] ?? json['month']) ?? '',
    created: asInt(json['created']),
    resolved: asInt(json['resolved']),
  );
}

class TrendSignals {
  const TrendSignals({
    required this.createdSlope,
    required this.resolvedSlope,
    required this.createdVsResolved,
    required this.momentum,
  });

  final double createdSlope;
  final double resolvedSlope;
  final int createdVsResolved;
  final String momentum;

  String get momentumLabel {
    return switch (momentum) {
      'up' || 'rising' => 'Em alta',
      'down' || 'falling' => 'Em queda',
      'stable' => 'Estável',
      _ => momentum,
    };
  }

  factory TrendSignals.fromJson(Map<String, dynamic> json) => TrendSignals(
    createdSlope: asDouble(json['created_slope']),
    resolvedSlope: asDouble(json['resolved_slope']),
    createdVsResolved: asInt(json['created_vs_resolved']),
    momentum: asString(json['momentum']) ?? 'stable',
  );
}

class IntelligenceTrendsData {
  const IntelligenceTrendsData({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.signals,
    this.period,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final List<TrendPoint> daily;
  final List<TrendPoint> weekly;
  final List<TrendPoint> monthly;
  final TrendSignals signals;
  final MandatePeriod? period;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory IntelligenceTrendsData.fromJson(
    Map<String, dynamic> json, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    return IntelligenceTrendsData(
      daily: asMapList(json['daily']).map(TrendPoint.fromJson).toList(),
      weekly: asMapList(json['weekly']).map(TrendPoint.fromJson).toList(),
      monthly: asMapList(json['monthly']).map(TrendPoint.fromJson).toList(),
      signals: TrendSignals.fromJson(asMap(json['signals'])),
      period: MandatePeriod.fromJson(asMap(json['period'])),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class AnalyticsNeighborhoodItem {
  const AnalyticsNeighborhoodItem({
    required this.district,
    required this.total,
    required this.open,
    required this.resolved,
    required this.overdue,
    this.avgResolutionHours,
    this.previousTotal,
    this.growthPct,
    this.topSubjects = const [],
  });

  final String district;
  final int total;
  final int open;
  final int resolved;
  final int overdue;
  final double? avgResolutionHours;
  final int? previousTotal;
  final double? growthPct;
  final List<({String name, int count})> topSubjects;

  factory AnalyticsNeighborhoodItem.fromJson(Map<String, dynamic> json) {
    final tops = asMapList(json['top_subjects'])
        .map((e) => (name: asString(e['name']) ?? '', count: asInt(e['count'])))
        .where((e) => e.name.isNotEmpty)
        .toList();
    return AnalyticsNeighborhoodItem(
      district: asString(json['district']) ?? '—',
      total: asInt(json['total']),
      open: asInt(json['open']),
      resolved: asInt(json['resolved']),
      overdue: asInt(json['overdue']),
      avgResolutionHours: json['avg_resolution_hours'] != null
          ? asDouble(json['avg_resolution_hours'])
          : null,
      previousTotal: json.containsKey('previous_total')
          ? asInt(json['previous_total'])
          : null,
      growthPct: json['growth_pct'] != null
          ? asDouble(json['growth_pct'])
          : null,
      topSubjects: tops,
    );
  }
}

class AnalyticsSubjectItem {
  const AnalyticsSubjectItem({
    required this.theme,
    required this.label,
    required this.total,
    required this.trend,
    this.previousTotal,
    this.growthPct,
    this.weekly = const [],
  });

  final String theme;
  final String label;
  final int total;
  final String trend;
  final int? previousTotal;
  final double? growthPct;
  final List<({String date, int total})> weekly;

  String get trendLabel {
    return switch (trend) {
      'up' => 'Crescimento',
      'down' => 'Queda',
      'stable' => 'Estável',
      _ => trend,
    };
  }

  factory AnalyticsSubjectItem.fromJson(Map<String, dynamic> json) {
    final weekly = asMapList(json['weekly'])
        .map((e) => (date: asString(e['date']) ?? '', total: asInt(e['total'])))
        .toList();
    return AnalyticsSubjectItem(
      theme: asString(json['theme']) ?? '',
      label: asString(json['label']) ?? asString(json['theme']) ?? '',
      total: asInt(json['total']),
      trend: asString(json['trend']) ?? 'stable',
      previousTotal: json.containsKey('previous_total')
          ? asInt(json['previous_total'])
          : null,
      growthPct: json['growth_pct'] != null
          ? asDouble(json['growth_pct'])
          : null,
      weekly: weekly,
    );
  }
}

class AnalyticsTeamMember {
  const AnalyticsTeamMember({
    required this.rank,
    required this.name,
    required this.attended,
    required this.inProgress,
    required this.completed,
    required this.overdue,
    required this.avgHours,
    required this.avgRating,
    required this.score,
    this.assigneeId,
  });

  final int rank;
  final String name;
  final int attended;
  final int inProgress;
  final int completed;
  final int overdue;
  final double avgHours;
  final double avgRating;
  final double score;
  final dynamic assigneeId;

  factory AnalyticsTeamMember.fromJson(Map<String, dynamic> json) =>
      AnalyticsTeamMember(
        rank: asInt(json['rank']),
        name: asString(json['assignee_name']) ?? 'Colaborador',
        attended: asInt(json['attended']),
        inProgress: asInt(json['in_progress']),
        completed: asInt(json['completed']),
        overdue: asInt(json['overdue']),
        avgHours: asDouble(json['avg_hours']),
        avgRating: asDouble(json['avg_rating']),
        score: asDouble(json['score']),
        assigneeId: json['assignee_id'],
      );
}

class DaySnapshot {
  const DaySnapshot({
    required this.open,
    required this.resolvedToday,
    required this.waitingCitizen,
    required this.overdue,
    required this.newToday,
    this.avgResolutionHours,
  });

  final int open;
  final int resolvedToday;
  final int waitingCitizen;
  final int overdue;
  final int newToday;
  final double? avgResolutionHours;

  factory DaySnapshot.fromJson(Map<String, dynamic> json) => DaySnapshot(
    open: asInt(json['protocols_open']),
    resolvedToday: asInt(json['protocols_resolved_today']),
    waitingCitizen: asInt(json['waiting_citizen']),
    overdue: asInt(json['overdue']),
    newToday: asInt(json['new_today']),
    avgResolutionHours: json['avg_resolution_hours'] != null
        ? asDouble(json['avg_resolution_hours'])
        : null,
  );
}

class IntelligenceAnalyticsData {
  IntelligenceAnalyticsData({
    required this.snapshot,
    required this.neighborhoods,
    required this.neighborhoodSummary,
    required this.subjects,
    required this.subjectSummary,
    required this.team,
    required this.teamSummary,
    this.embeddedTrends,
    this.period,
    this.generatedAt,
    this.audience,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final DaySnapshot snapshot;
  final List<AnalyticsNeighborhoodItem> neighborhoods;
  final Map<String, dynamic> neighborhoodSummary;
  final List<AnalyticsSubjectItem> subjects;
  final Map<String, dynamic> subjectSummary;
  final List<AnalyticsTeamMember> team;
  final Map<String, dynamic> teamSummary;
  final IntelligenceTrendsData? embeddedTrends;
  final MandatePeriod? period;
  final DateTime? generatedAt;
  final String? audience;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory IntelligenceAnalyticsData.fromJson(
    Map<String, dynamic> json, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final neighborhoods = asMap(json['neighborhoods']);
    final subjects = asMap(json['subjects']);
    final team = asMap(json['team']);
    final trendsRaw = json['trends'];
    final gen = asString(json['generated_at']);
    return IntelligenceAnalyticsData(
      snapshot: DaySnapshot.fromJson(asMap(json['executive_snapshot'])),
      neighborhoods: asMapList(
        neighborhoods['items'],
      ).map(AnalyticsNeighborhoodItem.fromJson).toList(),
      neighborhoodSummary: asMap(neighborhoods['summary']),
      subjects: asMapList(
        subjects['items'],
      ).map(AnalyticsSubjectItem.fromJson).toList(),
      subjectSummary: asMap(subjects['summary']),
      team: asMapList(
        team['members'],
      ).map(AnalyticsTeamMember.fromJson).toList(),
      teamSummary: asMap(team['summary']),
      embeddedTrends: trendsRaw is Map
          ? IntelligenceTrendsData.fromJson(
              Map<String, dynamic>.from(trendsRaw),
            )
          : null,
      period: MandatePeriod.fromJson(asMap(json['period'])),
      generatedAt: gen != null ? DateTime.tryParse(gen) : null,
      audience: asString(json['audience']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class IntelligenceBriefingsHistory {
  const IntelligenceBriefingsHistory({
    required this.scope,
    required this.bullets,
    this.audience,
    this.source,
    this.message,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final String scope;
  final List<String> bullets;
  final String? audience;
  final String? source;
  final String? message;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory IntelligenceBriefingsHistory.fromJson(
    Map<String, dynamic> json, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final bulletsRaw = json['bullets'];
    final bullets = bulletsRaw is List
        ? bulletsRaw
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    return IntelligenceBriefingsHistory(
      scope: asString(json['scope']) ?? 'daily',
      bullets: bullets,
      audience: asString(json['audience']),
      source: asString(json['source']),
      message: asString(json['message']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class IntelligenceBriefingView {
  const IntelligenceBriefingView({
    required this.briefing,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final MandateBriefing briefing;
  final bool fromCache;
  final String? cacheAgeLabel;
}
