/// Fase 16 — modelos do CRM Político (`/v1/crm/*`).
library;

Map<String, dynamic> asCrmMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asCrmMapList(dynamic raw) {
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
        raw['rows'] ??
        raw['contacts'] ??
        raw['leaders'] ??
        raw['supporters'] ??
        raw['voters'] ??
        raw['volunteers'] ??
        raw['tags'] ??
        raw['groups'] ??
        raw['regions'] ??
        raw['interactions'] ??
        raw['tasks'] ??
        raw['reports'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

String? asCrmString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class CrmItem {
  const CrmItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.region,
    this.supportLevel,
    this.date,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? region;
  final String? supportLevel;
  final DateTime? date;
  final Map<String, dynamic> raw;

  factory CrmItem.fromJson(Map<String, dynamic> json) {
    final m = asCrmMap(json);
    final id =
        asCrmString(m['id'] ?? m['uuid'] ?? m['code'] ?? m['slug']) ??
        '${m.hashCode}';
    final title =
        asCrmString(
          m['title'] ??
              m['name'] ??
              m['full_name'] ??
              m['label'] ??
              m['subject'],
        ) ??
        'Item $id';
    DateTime? date;
    for (final k in [
      'created_at',
      'updated_at',
      'occurred_at',
      'visited_at',
      'date',
      'scheduled_at',
    ]) {
      final raw = m[k];
      if (raw != null) {
        date = DateTime.tryParse('$raw');
        if (date != null) break;
      }
    }
    return CrmItem(
      id: id,
      title: title,
      code: asCrmString(m['code'] ?? m['document'] ?? m['cpf']),
      status: asCrmString(m['status'] ?? m['state']),
      kind: asCrmString(m['type'] ?? m['kind'] ?? m['category']),
      summary: asCrmString(
        m['summary'] ?? m['description'] ?? m['notes'] ?? m['body'],
      ),
      region: asCrmString(
        m['region'] ?? m['neighborhood'] ?? m['district'] ?? m['zone'],
      ),
      supportLevel: asCrmString(
        m['support_level'] ?? m['support'] ?? m['grau_apoio'],
      ),
      date: date,
      raw: m,
    );
  }
}
