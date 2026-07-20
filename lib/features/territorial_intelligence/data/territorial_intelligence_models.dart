/// Fase 12 — modelos da Inteligência Territorial (`/v1/intelligence/*`).
library;

Map<String, dynamic> asTiMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asTiMapList(dynamic raw) {
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
        raw['indicators'] ??
        raw['kpis'] ??
        raw['charts'] ??
        raw['series'] ??
        raw['neighborhoods'] ??
        raw['regions'] ??
        raw['trends'] ??
        raw['projections'] ??
        raw['rows'] ??
        raw['entries'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

int asTiInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

double asTiDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

String? asTiString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class TerritorialDashboard {
  const TerritorialDashboard({
    this.kpisTotal = 0,
    this.demandsOpen = 0,
    this.worksActive = 0,
    this.protocolsOpen = 0,
    this.attendancesPeriod = 0,
    this.neighborhoods = 0,
    this.regions = 0,
    this.leaderships = 0,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final int kpisTotal;
  final int demandsOpen;
  final int worksActive;
  final int protocolsOpen;
  final int attendancesPeriod;
  final int neighborhoods;
  final int regions;
  final int leaderships;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory TerritorialDashboard.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asTiMap(root['data'] ?? root);
    final counts = asTiMap(data['counts'] ?? data['kpis'] ?? data['summary'] ?? data);
    return TerritorialDashboard(
      kpisTotal: asTiInt(counts['kpis_total'] ?? counts['kpis'] ?? counts['total']),
      demandsOpen: asTiInt(counts['demands_open'] ?? counts['demands']),
      worksActive: asTiInt(counts['works_active'] ?? counts['works']),
      protocolsOpen: asTiInt(counts['protocols_open'] ?? counts['protocols']),
      attendancesPeriod: asTiInt(
        counts['attendances'] ?? counts['attendances_period'],
      ),
      neighborhoods: asTiInt(counts['neighborhoods']),
      regions: asTiInt(counts['regions']),
      leaderships: asTiInt(counts['leaderships'] ?? counts['leaders']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class TerritorialItem {
  const TerritorialItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.value,
    this.region,
    this.neighborhood,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final double? value;
  final String? region;
  final String? neighborhood;
  final Map<String, dynamic> raw;

  factory TerritorialItem.fromJson(Map<String, dynamic> json) {
    return TerritorialItem(
      id: asTiString(json['id'] ?? json['uuid'] ?? json['code']) ?? '',
      title:
          asTiString(
            json['title'] ??
                json['name'] ??
                json['label'] ??
                json['indicator'] ??
                json['kpi'],
          ) ??
          'Item',
      code: asTiString(json['code'] ?? json['number']),
      status: asTiString(json['status']),
      kind: asTiString(json['kind'] ?? json['type'] ?? json['category']),
      summary: asTiString(
        json['summary'] ?? json['description'] ?? json['body'],
      ),
      value: json['value'] == null && json['amount'] == null
          ? null
          : asTiDouble(json['value'] ?? json['amount']),
      region: asTiString(json['region'] ?? json['region_name']),
      neighborhood: asTiString(
        json['neighborhood'] ?? json['bairro'] ?? json['neighborhood_name'],
      ),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
