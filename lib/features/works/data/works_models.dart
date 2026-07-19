/// Sprint 10.9 — modelos do Painel Obras (contratos preparados `/v1/works/*`).
library;

Map<String, dynamic> asWorksMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asWorksMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final v = raw['data'] ?? raw['items'] ?? raw['results'] ?? raw['projects'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

int asWorksInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

double asWorksDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

String? asWorksString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class WorksDashboard {
  const WorksDashboard({
    this.worksOpen = 0,
    this.worksInProgress = 0,
    this.worksCompleted = 0,
    this.demandsOpen = 0,
    this.inspectionsPending = 0,
    this.scheduleUpcoming = 0,
    this.checklistOpen = 0,
    this.photosCount = 0,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final int worksOpen;
  final int worksInProgress;
  final int worksCompleted;
  final int demandsOpen;
  final int inspectionsPending;
  final int scheduleUpcoming;
  final int checklistOpen;
  final int photosCount;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory WorksDashboard.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asWorksMap(root['data'] ?? root);
    final counts = asWorksMap(data['counts'] ?? data['summary'] ?? data);
    return WorksDashboard(
      worksOpen: asWorksInt(counts['works_open'] ?? counts['open']),
      worksInProgress: asWorksInt(
        counts['works_in_progress'] ?? counts['in_progress'],
      ),
      worksCompleted: asWorksInt(
        counts['works_completed'] ?? counts['completed'],
      ),
      demandsOpen: asWorksInt(counts['demands_open'] ?? counts['demands']),
      inspectionsPending: asWorksInt(
        counts['inspections_pending'] ?? counts['inspections'],
      ),
      scheduleUpcoming: asWorksInt(
        counts['schedule_upcoming'] ?? counts['schedule'],
      ),
      checklistOpen: asWorksInt(
        counts['checklist_open'] ?? counts['checklist'],
      ),
      photosCount: asWorksInt(counts['photos'] ?? counts['photos_count']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class WorksItem {
  const WorksItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.district,
    this.progressPct,
    this.startedAt,
    this.dueAt,
    this.lat,
    this.lng,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? district;
  final double? progressPct;
  final DateTime? startedAt;
  final DateTime? dueAt;
  final double? lat;
  final double? lng;
  final Map<String, dynamic> raw;

  factory WorksItem.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) {
      final s = asWorksString(v);
      return s == null ? null : DateTime.tryParse(s);
    }

    return WorksItem(
      id: asWorksString(json['id'] ?? json['uuid']) ?? '',
      title:
          asWorksString(json['title'] ?? json['name'] ?? json['label']) ??
          'Obra',
      code: asWorksString(json['code'] ?? json['number']),
      status: asWorksString(json['status']),
      kind: asWorksString(json['kind'] ?? json['type'] ?? json['category']),
      summary: asWorksString(
        json['summary'] ?? json['description'] ?? json['body'],
      ),
      district: asWorksString(json['district'] ?? json['neighborhood']),
      progressPct: json['progress_pct'] == null && json['progress'] == null
          ? null
          : asWorksDouble(json['progress_pct'] ?? json['progress']),
      startedAt: dt(json['started_at'] ?? json['start_at']),
      dueAt: dt(json['due_at'] ?? json['deadline'] ?? json['scheduled_at']),
      lat: json['lat'] == null ? null : asWorksDouble(json['lat']),
      lng: json['lng'] == null ? null : asWorksDouble(json['lng']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
