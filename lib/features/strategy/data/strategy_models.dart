/// Sprint 10.7 — modelos do Painel Estratégico (contratos LIVE `/v1/strategy/*`).
library;

Map<String, dynamic> asStrategyMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asStrategyMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final v = raw['data'] ?? raw['items'] ?? raw['results'] ?? raw['points'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

int asInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

double asDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

String? asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

class StrategyKpiSummary {
  const StrategyKpiSummary({
    required this.protocolsOpen,
    required this.protocolsCreated,
    required this.protocolsResolved,
    required this.protocolsOverdue,
    required this.avgResolutionHours,
    required this.avgRating,
    required this.nps,
    required this.growthPercent,
    required this.slaAtRisk,
    required this.slaBreached,
    required this.campaigns,
    required this.satisfaction,
    this.byCategory = const {},
    this.byStatus = const {},
    this.byPriority = const {},
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final int protocolsOpen;
  final int protocolsCreated;
  final int protocolsResolved;
  final int protocolsOverdue;
  final double avgResolutionHours;
  final double avgRating;
  final int nps;
  final int growthPercent;
  final int slaAtRisk;
  final int slaBreached;
  final int campaigns;
  final double satisfaction;
  final Map<String, int> byCategory;
  final Map<String, int> byStatus;
  final Map<String, int> byPriority;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory StrategyKpiSummary.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asStrategyMap(root['data'] ?? root);
    final summary = asStrategyMap(data['summary'] ?? data);
    Map<String, int> counts(dynamic raw) {
      final m = asStrategyMap(raw);
      return {for (final e in m.entries) e.key: asInt(e.value)};
    }

    return StrategyKpiSummary(
      protocolsOpen: asInt(summary['protocols_open']),
      protocolsCreated: asInt(summary['protocols_created']),
      protocolsResolved: asInt(summary['protocols_resolved']),
      protocolsOverdue: asInt(summary['protocols_overdue']),
      avgResolutionHours: asDouble(summary['avg_resolution_hours']),
      avgRating: asDouble(summary['avg_rating']),
      nps: asInt(summary['nps']),
      growthPercent: asInt(summary['growth_percent']),
      slaAtRisk: asInt(summary['sla_at_risk']),
      slaBreached: asInt(summary['sla_breached']),
      campaigns: asInt(summary['campaigns']),
      satisfaction: asDouble(summary['satisfaction']),
      byCategory: counts(data['by_category']),
      byStatus: counts(data['by_status']),
      byPriority: counts(data['by_priority']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class StrategyHeatPoint {
  const StrategyHeatPoint({
    required this.label,
    required this.total,
    required this.open,
    required this.resolved,
    this.city,
    this.district,
    this.state,
    this.lat,
    this.lng,
    this.weight,
  });

  final String label;
  final int total;
  final int open;
  final int resolved;
  final String? city;
  final String? district;
  final String? state;
  final double? lat;
  final double? lng;
  final double? weight;

  factory StrategyHeatPoint.fromJson(Map<String, dynamic> json) {
    final district = asString(json['district']);
    final city = asString(json['city']);
    final label =
        asString(json['label']) ??
        [
          district,
          city,
        ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    return StrategyHeatPoint(
      label: label.isEmpty ? 'Área' : label,
      total: asInt(json['total'] ?? json['weight']),
      open: asInt(json['open']),
      resolved: asInt(json['resolved']),
      city: city,
      district: district,
      state: asString(json['state']),
      lat: json['lat'] == null ? null : asDouble(json['lat']),
      lng: json['lng'] == null ? null : asDouble(json['lng']),
      weight: json['weight'] == null ? null : asDouble(json['weight']),
    );
  }
}

class StrategyHeatmapData {
  const StrategyHeatmapData({
    required this.points,
    this.clusters = const [],
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final List<StrategyHeatPoint> points;
  final List<StrategyHeatPoint> clusters;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory StrategyHeatmapData.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asStrategyMap(root['data'] ?? root);
    return StrategyHeatmapData(
      points: asStrategyMapList(
        data['points'] ?? data['heatmap'],
      ).map(StrategyHeatPoint.fromJson).toList(),
      clusters: asStrategyMapList(
        data['clusters'],
      ).map(StrategyHeatPoint.fromJson).toList(),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class StrategyFinding {
  const StrategyFinding({
    required this.title,
    required this.summary,
    this.type,
    this.severity,
    this.score,
  });

  final String title;
  final String summary;
  final String? type;
  final String? severity;
  final double? score;

  factory StrategyFinding.fromJson(Map<String, dynamic> json) {
    return StrategyFinding(
      title: asString(json['title']) ?? 'Achado',
      summary: asString(json['summary'] ?? json['body']) ?? '',
      type: asString(json['type']),
      severity: asString(json['severity']),
      score: json['score'] == null ? null : asDouble(json['score']),
    );
  }
}

class StrategyRegionsData {
  const StrategyRegionsData({
    required this.heatmap,
    this.findings = const [],
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final List<StrategyHeatPoint> heatmap;
  final List<StrategyFinding> findings;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory StrategyRegionsData.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asStrategyMap(root['data'] ?? root);
    return StrategyRegionsData(
      heatmap: asStrategyMapList(
        data['heatmap'],
      ).map(StrategyHeatPoint.fromJson).toList(),
      findings: asStrategyMapList(
        data['findings'],
      ).map(StrategyFinding.fromJson).toList(),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class StrategyAlert {
  const StrategyAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.status,
    this.type,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String severity;
  final String status;
  final String? type;
  final DateTime? createdAt;

  factory StrategyAlert.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at'] ?? json['notified_at']);
    return StrategyAlert(
      id: asString(json['id']) ?? '',
      title: asString(json['title']) ?? 'Alerta',
      body: asString(json['body'] ?? json['summary']) ?? '',
      severity: asString(json['severity']) ?? 'medium',
      status: asString(json['status']) ?? 'open',
      type: asString(json['type']),
      createdAt: created == null ? null : DateTime.tryParse(created),
    );
  }
}

class StrategyTrendDetection {
  const StrategyTrendDetection({required this.label, this.type, this.value});

  final String label;
  final String? type;
  final String? value;

  factory StrategyTrendDetection.fromJson(Map<String, dynamic> json) {
    return StrategyTrendDetection(
      label: asString(json['label'] ?? json['topic']) ?? 'Tendência',
      type: asString(json['type']),
      value: asString(json['value'] ?? json['count']),
    );
  }
}

class StrategyTrendsData {
  const StrategyTrendsData({
    required this.detections,
    this.emergingTopics = const [],
    this.seasonalityHint,
    this.seriesTotalsCreated = 0,
    this.seriesTotalsResolved = 0,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final List<StrategyTrendDetection> detections;
  final List<StrategyTrendDetection> emergingTopics;
  final String? seasonalityHint;
  final int seriesTotalsCreated;
  final int seriesTotalsResolved;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory StrategyTrendsData.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asStrategyMap(root['data'] ?? root);
    final series = asStrategyMap(data['series']);
    final totals = asStrategyMap(series['totals']);
    return StrategyTrendsData(
      detections: asStrategyMapList(
        data['detections'],
      ).map(StrategyTrendDetection.fromJson).toList(),
      emergingTopics: asStrategyMapList(
        data['emerging_topics'],
      ).map(StrategyTrendDetection.fromJson).toList(),
      seasonalityHint: asString(data['seasonality_hint']),
      seriesTotalsCreated: asInt(totals['created']),
      seriesTotalsResolved: asInt(totals['resolved']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class StrategyForecastPoint {
  const StrategyForecastPoint({
    required this.date,
    required this.predictedCreated,
    required this.predictedResolved,
    required this.netBacklogDelta,
  });

  final String date;
  final double predictedCreated;
  final double predictedResolved;
  final double netBacklogDelta;

  factory StrategyForecastPoint.fromJson(Map<String, dynamic> json) {
    return StrategyForecastPoint(
      date: asString(json['date']) ?? '',
      predictedCreated: asDouble(json['predicted_created']),
      predictedResolved: asDouble(json['predicted_resolved']),
      netBacklogDelta: asDouble(json['net_backlog_delta']),
    );
  }
}

class StrategyForecastsData {
  const StrategyForecastsData({
    required this.model,
    required this.horizonDays,
    required this.protocols,
    required this.currentOpen,
    required this.predictedOpen,
    required this.slaOutlook,
    this.findings = const [],
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final String model;
  final int horizonDays;
  final List<StrategyForecastPoint> protocols;
  final int currentOpen;
  final double predictedOpen;
  final String slaOutlook;
  final List<StrategyFinding> findings;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory StrategyForecastsData.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asStrategyMap(root['data'] ?? root);
    final load = asStrategyMap(data['load']);
    final sla = asStrategyMap(data['sla']);
    return StrategyForecastsData(
      model: asString(data['model']) ?? '—',
      horizonDays: asInt(data['horizon_days']),
      protocols: asStrategyMapList(
        data['protocols'],
      ).map(StrategyForecastPoint.fromJson).toList(),
      currentOpen: asInt(load['current_open']),
      predictedOpen: asDouble(load['predicted_open']),
      slaOutlook: asString(sla['outlook']) ?? '—',
      findings: asStrategyMapList(
        data['findings'],
      ).map(StrategyFinding.fromJson).toList(),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class StrategyNeighborhood {
  const StrategyNeighborhood({
    required this.name,
    required this.quantity,
    required this.criticality,
    this.district,
    this.city,
    this.zone,
    this.region,
    this.priority,
    this.trend,
    this.growthPercent,
  });

  final String name;
  final int quantity;
  final int criticality;
  final String? district;
  final String? city;
  final String? zone;
  final String? region;
  final String? priority;
  final String? trend;
  final double? growthPercent;

  factory StrategyNeighborhood.fromJson(Map<String, dynamic> json) {
    return StrategyNeighborhood(
      name:
          asString(json['neighborhood'] ?? json['name'] ?? json['district']) ??
          'Bairro',
      quantity: asInt(json['quantity'] ?? json['total']),
      criticality: asInt(json['criticality']),
      district: asString(json['district']),
      city: asString(json['city']),
      zone: asString(json['zone']),
      region: asString(json['region']),
      priority: asString(json['priority']),
      trend: asString(json['trend']),
      growthPercent: json['growth_percent'] == null
          ? null
          : asDouble(json['growth_percent']),
    );
  }
}

class StrategyReportItem {
  const StrategyReportItem({
    required this.id,
    required this.title,
    this.status,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? status;
  final DateTime? createdAt;

  factory StrategyReportItem.fromJson(Map<String, dynamic> json) {
    final created = asString(json['created_at']);
    return StrategyReportItem(
      id: asString(json['id']) ?? '',
      title:
          asString(json['title'] ?? json['name'] ?? json['label']) ??
          'Relatório',
      status: asString(json['status']),
      createdAt: created == null ? null : DateTime.tryParse(created),
    );
  }
}

/// Modelo preparado para `/v1/strategy/goals` (quando estável).
class StrategyGoal {
  const StrategyGoal({
    required this.id,
    required this.title,
    this.target,
    this.current,
    this.unit,
    this.status,
  });

  final String id;
  final String title;
  final double? target;
  final double? current;
  final String? unit;
  final String? status;

  factory StrategyGoal.fromJson(Map<String, dynamic> json) {
    return StrategyGoal(
      id: asString(json['id']) ?? '',
      title: asString(json['title'] ?? json['name']) ?? 'Meta',
      target: json['target'] == null ? null : asDouble(json['target']),
      current: json['current'] == null ? null : asDouble(json['current']),
      unit: asString(json['unit']),
      status: asString(json['status']),
    );
  }
}
