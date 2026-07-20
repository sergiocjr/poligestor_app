/// Fase 17 — modelos da Gestão Eleitoral (`/v1/elections/*`).
library;

Map<String, dynamic> asElectionsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asElectionsMapList(dynamic raw) {
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
        raw['candidates'] ??
        raw['campaigns'] ??
        raw['volunteers'] ??
        raw['leaders'] ??
        raw['supporters'] ??
        raw['regions'] ??
        raw['events'] ??
        raw['polls'] ??
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

String? asElectionsString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class ElectionsItem {
  const ElectionsItem({
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

  factory ElectionsItem.fromJson(Map<String, dynamic> json) {
    final m = asElectionsMap(json);
    final id =
        asElectionsString(m['id'] ?? m['uuid'] ?? m['code'] ?? m['slug']) ??
        '${m.hashCode}';
    final title =
        asElectionsString(
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
    return ElectionsItem(
      id: id,
      title: title,
      code: asElectionsString(m['code'] ?? m['document'] ?? m['cpf']),
      status: asElectionsString(m['status'] ?? m['state']),
      kind: asElectionsString(m['type'] ?? m['kind'] ?? m['category']),
      summary: asElectionsString(
        m['summary'] ?? m['description'] ?? m['notes'] ?? m['body'],
      ),
      region: asElectionsString(
        m['region'] ?? m['neighborhood'] ?? m['district'] ?? m['zone'],
      ),
      supportLevel: asElectionsString(
        m['support_level'] ?? m['support'] ?? m['grau_apoio'],
      ),
      date: date,
      raw: m,
    );
  }
}
