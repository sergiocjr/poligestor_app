/// Helpers de parsing defensivo para payloads `/v1/mandate/*`.
Map<String, dynamic> asMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asMapList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

int asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double asDouble(dynamic v, [double fallback = 0]) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

String? asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class MandatePeriod {
  const MandatePeriod({this.from, this.to, this.assigneeId, this.category});

  final String? from;
  final String? to;
  final String? assigneeId;
  final String? category;

  factory MandatePeriod.fromJson(Map<String, dynamic> json) => MandatePeriod(
    from: asString(json['from']),
    to: asString(json['to']),
    assigneeId: asString(json['assignee_id']),
    category: asString(json['category']),
  );
}

class MandateDaySummary {
  const MandateDaySummary({
    required this.open,
    required this.resolvedToday,
    required this.waitingCitizen,
    required this.overdue,
    required this.newToday,
    required this.avgResolutionHours,
  });

  final int open;
  final int resolvedToday;
  final int waitingCitizen;
  final int overdue;
  final int newToday;
  final double avgResolutionHours;

  factory MandateDaySummary.fromJson(Map<String, dynamic> json) =>
      MandateDaySummary(
        open: asInt(json['protocols_open']),
        resolvedToday: asInt(json['protocols_resolved_today']),
        waitingCitizen: asInt(json['waiting_citizen']),
        overdue: asInt(json['overdue']),
        newToday: asInt(json['new_today']),
        avgResolutionHours: asDouble(json['avg_resolution_hours']),
      );
}

class MandateSeriesPoint {
  const MandateSeriesPoint({
    required this.label,
    required this.created,
    required this.resolved,
  });

  final String label;
  final int created;
  final int resolved;

  factory MandateSeriesPoint.fromJson(Map<String, dynamic> json) =>
      MandateSeriesPoint(
        label: asString(json['date'] ?? json['month']) ?? '',
        created: asInt(json['created']),
        resolved: asInt(json['resolved']),
      );
}

class MandateThemeCount {
  const MandateThemeCount({
    required this.theme,
    required this.label,
    required this.open,
  });

  final String theme;
  final String label;
  final int open;

  factory MandateThemeCount.fromJson(Map<String, dynamic> json) =>
      MandateThemeCount(
        theme: asString(json['theme']) ?? '',
        label: asString(json['label']) ?? asString(json['theme']) ?? '',
        open: asInt(json['open'] ?? json['quantity']),
      );
}

class MandateBriefing {
  const MandateBriefing({
    required this.bullets,
    this.source,
    this.generatedAt,
    this.audience,
  });

  final List<String> bullets;
  final String? source;
  final DateTime? generatedAt;
  final String? audience;

  factory MandateBriefing.fromJson(Map<String, dynamic> json) {
    final bulletsRaw = json['bullets'];
    final bullets = bulletsRaw is List
        ? bulletsRaw
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    final gen = asString(json['generated_at']);
    return MandateBriefing(
      bullets: bullets,
      source: asString(json['source']),
      audience: asString(json['audience']),
      generatedAt: gen != null ? DateTime.tryParse(gen) : null,
    );
  }
}

class MandateAttentionItem {
  const MandateAttentionItem({
    required this.title,
    required this.explanation,
    required this.priority,
    this.actionLabel,
    this.routeHint,
  });

  final String title;
  final String explanation;
  final int priority; // 1 alta
  final String? actionLabel;
  final String? routeHint;
}

class MandateExecutive {
  MandateExecutive({
    required this.daySummary,
    required this.monthTotals,
    required this.weeklySeries,
    required this.monthlySeries,
    required this.situationByTheme,
    required this.attention,
    this.period,
    this.generatedAt,
    this.briefing,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final MandateDaySummary daySummary;
  final Map<String, dynamic> monthTotals;
  final List<MandateSeriesPoint> weeklySeries;
  final List<MandateSeriesPoint> monthlySeries;
  final List<MandateThemeCount> situationByTheme;
  final List<MandateAttentionItem> attention;
  final MandatePeriod? period;
  final DateTime? generatedAt;
  final MandateBriefing? briefing;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory MandateExecutive.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final exec = asMap(root['executive'] ?? root);
    final day = MandateDaySummary.fromJson(asMap(exec['day_summary']));
    final themes = asMapList(
      exec['situation_by_theme'],
    ).map(MandateThemeCount.fromJson).toList();
    final briefingRaw = root['briefing'] ?? exec['briefing'];
    final briefing = briefingRaw is Map
        ? MandateBriefing.fromJson(Map<String, dynamic>.from(briefingRaw))
        : null;

    final attention = <MandateAttentionItem>[];
    if (day.overdue > 0) {
      attention.add(
        MandateAttentionItem(
          title: 'Protocolos em atraso',
          explanation: '${day.overdue} solicitação(ões) passaram do prazo.',
          priority: 1,
          actionLabel: 'Ver protocolos',
          routeHint: '/home/protocols',
        ),
      );
    }
    if (day.waitingCitizen > 0) {
      attention.add(
        MandateAttentionItem(
          title: 'Aguardando cidadão',
          explanation:
              '${day.waitingCitizen} caso(s) esperando retorno do cidadão.',
          priority: 2,
          actionLabel: 'Ver protocolos',
          routeHint: '/home/protocols',
        ),
      );
    }
    final hotThemes = [...themes]..sort((a, b) => b.open.compareTo(a.open));
    if (hotThemes.isNotEmpty && hotThemes.first.open > 0) {
      attention.add(
        MandateAttentionItem(
          title: 'Assunto em evidência',
          explanation:
              '${hotThemes.first.label}: ${hotThemes.first.open} abertas.',
          priority: 3,
          actionLabel: 'Ver assuntos',
          routeHint: '/home/mandate/subjects',
        ),
      );
    }

    final gen = asString(exec['generated_at']);
    return MandateExecutive(
      daySummary: day,
      monthTotals: asMap(exec['month_totals']),
      weeklySeries: asMapList(
        exec['weekly_series'],
      ).map(MandateSeriesPoint.fromJson).toList(),
      monthlySeries: asMapList(
        exec['monthly_series'],
      ).map(MandateSeriesPoint.fromJson).toList(),
      situationByTheme: themes,
      attention: attention,
      period: MandatePeriod.fromJson(asMap(exec['period'])),
      generatedAt: gen != null ? DateTime.tryParse(gen) : null,
      briefing: briefing,
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class MandateDistrictStat {
  const MandateDistrictStat({
    required this.district,
    required this.total,
    required this.open,
    required this.resolved,
    this.previousTotal,
    this.topCategories = const [],
  });

  final String district;
  final int total;
  final int open;
  final int resolved;
  final int? previousTotal;
  final List<({String name, int count})> topCategories;

  factory MandateDistrictStat.fromJson(Map<String, dynamic> json) {
    final cats = asMapList(json['top_categories'])
        .map((c) => (name: asString(c['name']) ?? '', count: asInt(c['count'])))
        .where((c) => c.name.isNotEmpty)
        .toList();
    return MandateDistrictStat(
      district: asString(json['district']) ?? '—',
      total: asInt(json['total']),
      open: asInt(json['open']),
      resolved: asInt(json['resolved']),
      previousTotal: json.containsKey('previous_total')
          ? asInt(json['previous_total'])
          : null,
      topCategories: cats,
    );
  }
}

class MandateNeighborhoodsData {
  const MandateNeighborhoodsData({
    required this.districts,
    this.topProblems = const [],
    this.avgHoursByDistrict = const [],
    this.period,
  });

  final List<MandateDistrictStat> districts;
  final List<Map<String, dynamic>> topProblems;
  final List<Map<String, dynamic>> avgHoursByDistrict;
  final MandatePeriod? period;

  factory MandateNeighborhoodsData.fromJson(Map<String, dynamic> json) {
    final list = asMapList(
      json['most_active_districts'] ?? json['neighborhoods'],
    );
    return MandateNeighborhoodsData(
      districts: list.map(MandateDistrictStat.fromJson).toList(),
      topProblems: asMapList(json['top_problems']),
      avgHoursByDistrict: asMapList(json['avg_resolution_hours_by_district']),
      period: MandatePeriod.fromJson(asMap(json['period'])),
    );
  }
}

class MandateSubjectStat {
  const MandateSubjectStat({
    required this.theme,
    required this.label,
    required this.quantity,
    this.previousQuantity,
    this.trendPercent,
  });

  final String theme;
  final String label;
  final int quantity;
  final int? previousQuantity;
  final double? trendPercent;

  factory MandateSubjectStat.fromJson(Map<String, dynamic> json) =>
      MandateSubjectStat(
        theme: asString(json['theme']) ?? '',
        label: asString(json['label']) ?? asString(json['theme']) ?? '',
        quantity: asInt(json['quantity'] ?? json['total']),
        previousQuantity: json.containsKey('previous_quantity')
            ? asInt(json['previous_quantity'])
            : null,
        trendPercent: json['trend_percent'] != null
            ? asDouble(json['trend_percent'])
            : null,
      );
}

class MandateSubjectsData {
  const MandateSubjectsData({
    required this.byTheme,
    this.byCategory = const [],
    this.weeklyEvolution = const [],
    this.period,
  });

  final List<MandateSubjectStat> byTheme;
  final List<Map<String, dynamic>> byCategory;
  final List<Map<String, dynamic>> weeklyEvolution;
  final MandatePeriod? period;

  factory MandateSubjectsData.fromJson(Map<String, dynamic> json) =>
      MandateSubjectsData(
        byTheme: asMapList(
          json['by_theme'],
        ).map(MandateSubjectStat.fromJson).toList(),
        byCategory: asMapList(json['by_category']),
        weeklyEvolution: asMapList(json['weekly_evolution']),
        period: MandatePeriod.fromJson(asMap(json['period'])),
      );
}

class MandateTeamMember {
  const MandateTeamMember({
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

  factory MandateTeamMember.fromJson(Map<String, dynamic> json) =>
      MandateTeamMember(
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

class MandateTeamData {
  const MandateTeamData({
    required this.ranking,
    this.summary = const {},
    this.labels = const {},
    this.period,
  });

  final List<MandateTeamMember> ranking;
  final Map<String, dynamic> summary;
  final Map<String, String> labels;
  final MandatePeriod? period;

  factory MandateTeamData.fromJson(Map<String, dynamic> json) {
    final meta = asMap(json['meta']);
    final labelsRaw = asMap(meta['labels']);
    final labels = <String, String>{
      for (final e in labelsRaw.entries) e.key: e.value.toString(),
    };
    return MandateTeamData(
      ranking: asMapList(
        json['ranking'],
      ).map(MandateTeamMember.fromJson).toList(),
      summary: asMap(json['summary']),
      labels: labels,
      period: MandatePeriod.fromJson(asMap(json['period'])),
    );
  }
}

class MandateAgendaEvent {
  const MandateAgendaEvent({
    required this.id,
    required this.title,
    this.type,
    this.typeLabel,
    this.startsAt,
    this.endsAt,
    this.location,
    this.priority,
    this.assigneeName,
    this.notes,
    this.status,
  });

  final dynamic id;
  final String title;
  final String? type;
  final String? typeLabel;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? location;
  final String? priority;
  final String? assigneeName;
  final String? notes;
  final String? status;

  factory MandateAgendaEvent.fromJson(Map<String, dynamic> json) {
    final start = asString(
      json['starts_at'] ?? json['start_at'] ?? json['startsAt'],
    );
    final end = asString(json['ends_at'] ?? json['end_at'] ?? json['endsAt']);
    return MandateAgendaEvent(
      id: json['id'],
      title: asString(json['title'] ?? json['titulo']) ?? 'Compromisso',
      type: asString(json['type'] ?? json['event_type']),
      typeLabel: asString(json['type_label'] ?? json['event_type_label']),
      startsAt: start != null ? DateTime.tryParse(start) : null,
      endsAt: end != null ? DateTime.tryParse(end) : null,
      location: asString(json['location'] ?? json['local']),
      priority: asString(json['priority']),
      assigneeName: asString(json['assignee_name']),
      notes: asString(json['notes'] ?? json['description']),
      status: asString(json['status']),
    );
  }
}

class MandateAgendaData {
  const MandateAgendaData({
    required this.events,
    required this.total,
    this.eventTypes = const {},
    this.filters = const {},
  });

  final List<MandateAgendaEvent> events;
  final int total;
  final Map<String, String> eventTypes;
  final Map<String, dynamic> filters;

  factory MandateAgendaData.fromJson(Map<String, dynamic> json) {
    final typesRaw = asMap(json['event_types']);
    return MandateAgendaData(
      events: asMapList(
        json['events'],
      ).map(MandateAgendaEvent.fromJson).toList(),
      total: asInt(json['total'], asMapList(json['events']).length),
      eventTypes: {for (final e in typesRaw.entries) e.key: e.value.toString()},
      filters: asMap(json['filters']),
    );
  }
}

class MandateSearchHit {
  const MandateSearchHit({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.url,
  });

  final String type;
  final String id;
  final String title;
  final String? subtitle;
  final String? url;

  factory MandateSearchHit.fromJson(Map<String, dynamic> json) =>
      MandateSearchHit(
        type: asString(json['type']) ?? 'item',
        id: asString(json['id']) ?? '',
        title: asString(json['title']) ?? 'Resultado',
        subtitle: asString(json['subtitle']),
        url: asString(json['url']),
      );
}

class MandateSearchData {
  const MandateSearchData({
    required this.query,
    required this.groups,
    required this.total,
  });

  final String query;
  final Map<String, List<MandateSearchHit>> groups;
  final int total;

  factory MandateSearchData.fromJson(Map<String, dynamic> json) {
    final groupsRaw = asMap(json['groups']);
    final groups = <String, List<MandateSearchHit>>{};
    for (final e in groupsRaw.entries) {
      groups[e.key] = asMapList(
        e.value,
      ).map(MandateSearchHit.fromJson).toList();
    }
    return MandateSearchData(
      query: asString(json['query']) ?? '',
      groups: groups,
      total: asInt(json['total']),
    );
  }
}

class MandateReportRow {
  const MandateReportRow({
    required this.id,
    required this.number,
    required this.subject,
    required this.statusLabel,
    this.district,
    this.themeLabel,
    this.assigneeName,
    this.personName,
    this.createdAt,
    this.rating,
  });

  final String id;
  final String number;
  final String subject;
  final String statusLabel;
  final String? district;
  final String? themeLabel;
  final String? assigneeName;
  final String? personName;
  final String? createdAt;
  final double? rating;

  factory MandateReportRow.fromJson(Map<String, dynamic> json) =>
      MandateReportRow(
        id: asString(json['id']) ?? '',
        number: asString(json['number']) ?? '',
        subject: asString(json['subject']) ?? '',
        statusLabel: asString(json['status_label'] ?? json['status']) ?? '',
        district: asString(json['district']),
        themeLabel: asString(json['theme_label'] ?? json['theme']),
        assigneeName: asString(json['assignee_name']),
        personName: asString(json['person_name']),
        createdAt: asString(json['created_at']),
        rating: json['rating'] != null ? asDouble(json['rating']) : null,
      );
}

class MandateReportsData {
  const MandateReportsData({required this.rows, required this.total});

  final List<MandateReportRow> rows;
  final int total;

  factory MandateReportsData.fromJson(Map<String, dynamic> json) =>
      MandateReportsData(
        rows: asMapList(json['rows']).map(MandateReportRow.fromJson).toList(),
        total: asInt(json['total'], asMapList(json['rows']).length),
      );
}

class MandateTvData {
  const MandateTvData({
    required this.kpis,
    this.monthTotals = const {},
    this.queueTop = const [],
    this.agendaToday = const [],
    this.teamTop = const [],
    this.mapHotspots = const [],
    this.briefing,
    this.refreshSeconds = 30,
    this.generatedAt,
  });

  final MandateDaySummary kpis;
  final Map<String, dynamic> monthTotals;
  final List<Map<String, dynamic>> queueTop;
  final List<Map<String, dynamic>> agendaToday;
  final List<Map<String, dynamic>> teamTop;
  final List<Map<String, dynamic>> mapHotspots;
  final MandateBriefing? briefing;
  final int refreshSeconds;
  final DateTime? generatedAt;

  factory MandateTvData.fromJson(Map<String, dynamic> json) {
    final gen = asString(json['generated_at']);
    final briefingRaw = json['briefing'];
    return MandateTvData(
      kpis: MandateDaySummary.fromJson(
        asMap(json['kpis'] ?? json['day_summary']),
      ),
      monthTotals: asMap(json['month_totals']),
      queueTop: asMapList(json['queue_top']),
      agendaToday: asMapList(json['agenda_today']),
      teamTop: asMapList(json['team_top3'] ?? json['team_top']),
      mapHotspots: asMapList(json['map_hotspots']),
      briefing: briefingRaw is Map
          ? MandateBriefing.fromJson(Map<String, dynamic>.from(briefingRaw))
          : null,
      refreshSeconds: asInt(json['refresh_seconds'], 30),
      generatedAt: gen != null ? DateTime.tryParse(gen) : null,
    );
  }
}

class MandateMapData {
  const MandateMapData({required this.neighborhoods, this.period});

  final List<MandateDistrictStat> neighborhoods;
  final MandatePeriod? period;

  factory MandateMapData.fromJson(Map<String, dynamic> json) {
    final nested = asMap(json['neighborhoods']);
    final list = asMapList(
      nested['neighborhoods'] ?? json['neighborhoods'] ?? json['points'],
    );
    return MandateMapData(
      neighborhoods: list.map(MandateDistrictStat.fromJson).toList(),
      period: MandatePeriod.fromJson(asMap(nested['period'] ?? json['period'])),
    );
  }
}
