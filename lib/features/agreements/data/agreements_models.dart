/// Sprint 11.0 — modelos do Painel de Convênios (contratos preparados `/v1/agreements/*`).
library;

Map<String, dynamic> asAgreementsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asAgreementsMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final v =
        raw['data'] ??
        raw['items'] ??
        raw['results'] ??
        raw['agreements'] ??
        raw['projects'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

int asAgreementsInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

double asAgreementsDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

String? asAgreementsString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class AgreementsDashboard {
  const AgreementsDashboard({
    this.agreementsOpen = 0,
    this.agreementsInProgress = 0,
    this.agreementsCompleted = 0,
    this.resourcesActive = 0,
    this.projectsOpen = 0,
    this.executionPending = 0,
    this.accountabilityOpen = 0,
    this.scheduleUpcoming = 0,
    this.documentsCount = 0,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final int agreementsOpen;
  final int agreementsInProgress;
  final int agreementsCompleted;
  final int resourcesActive;
  final int projectsOpen;
  final int executionPending;
  final int accountabilityOpen;
  final int scheduleUpcoming;
  final int documentsCount;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory AgreementsDashboard.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asAgreementsMap(root['data'] ?? root);
    final counts = asAgreementsMap(data['counts'] ?? data['summary'] ?? data);
    return AgreementsDashboard(
      agreementsOpen: asAgreementsInt(
        counts['agreements_open'] ?? counts['open'],
      ),
      agreementsInProgress: asAgreementsInt(
        counts['agreements_in_progress'] ?? counts['in_progress'],
      ),
      agreementsCompleted: asAgreementsInt(
        counts['agreements_completed'] ?? counts['completed'],
      ),
      resourcesActive: asAgreementsInt(
        counts['resources_active'] ?? counts['resources'],
      ),
      projectsOpen: asAgreementsInt(
        counts['projects_open'] ?? counts['projects'],
      ),
      executionPending: asAgreementsInt(
        counts['execution_pending'] ?? counts['execution'],
      ),
      accountabilityOpen: asAgreementsInt(
        counts['accountability_open'] ?? counts['accountability'],
      ),
      scheduleUpcoming: asAgreementsInt(
        counts['schedule_upcoming'] ?? counts['schedule'],
      ),
      documentsCount: asAgreementsInt(
        counts['documents'] ?? counts['documents_count'],
      ),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class AgreementsItem {
  const AgreementsItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.partner,
    this.amount,
    this.progressPct,
    this.startedAt,
    this.dueAt,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? partner;
  final double? amount;
  final double? progressPct;
  final DateTime? startedAt;
  final DateTime? dueAt;
  final Map<String, dynamic> raw;

  factory AgreementsItem.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) {
      final s = asAgreementsString(v);
      return s == null ? null : DateTime.tryParse(s);
    }

    return AgreementsItem(
      id: asAgreementsString(json['id'] ?? json['uuid']) ?? '',
      title:
          asAgreementsString(json['title'] ?? json['name'] ?? json['label']) ??
          'Convênio',
      code: asAgreementsString(json['code'] ?? json['number']),
      status: asAgreementsString(json['status']),
      kind: asAgreementsString(
        json['kind'] ?? json['type'] ?? json['category'],
      ),
      summary: asAgreementsString(
        json['summary'] ?? json['description'] ?? json['body'],
      ),
      partner: asAgreementsString(
        json['partner'] ?? json['grantor'] ?? json['agency'],
      ),
      amount: json['amount'] == null && json['value'] == null
          ? null
          : asAgreementsDouble(json['amount'] ?? json['value']),
      progressPct: json['progress_pct'] == null && json['progress'] == null
          ? null
          : asAgreementsDouble(json['progress_pct'] ?? json['progress']),
      startedAt: dt(
        json['started_at'] ?? json['start_at'] ?? json['signed_at'],
      ),
      dueAt: dt(json['due_at'] ?? json['deadline'] ?? json['ends_at']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
