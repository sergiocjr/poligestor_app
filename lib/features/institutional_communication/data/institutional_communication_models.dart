/// Fase 15 — modelos da Comunicação Institucional (`/v1/communication/*`).
library;

Map<String, dynamic> asIcMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asIcMapList(dynamic raw) {
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
        raw['feed'] ??
        raw['news'] ??
        raw['announcements'] ??
        raw['campaigns'] ??
        raw['media'] ??
        raw['publications'] ??
        raw['schedule'] ??
        raw['history'] ??
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

int asIcInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

String? asIcString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class InstitutionalCommunicationItem {
  const InstitutionalCommunicationItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.channel,
    this.date,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? channel;
  final DateTime? date;
  final Map<String, dynamic> raw;

  factory InstitutionalCommunicationItem.fromJson(Map<String, dynamic> json) {
    final m = asIcMap(json);
    final id =
        asIcString(m['id'] ?? m['uuid'] ?? m['code'] ?? m['slug']) ??
        '${m.hashCode}';
    final title =
        asIcString(
          m['title'] ??
              m['name'] ??
              m['subject'] ??
              m['headline'] ??
              m['label'],
        ) ??
        'Item $id';
    DateTime? date;
    for (final k in [
      'published_at',
      'scheduled_at',
      'created_at',
      'updated_at',
      'date',
      'sent_at',
    ]) {
      final raw = m[k];
      if (raw != null) {
        date = DateTime.tryParse('$raw');
        if (date != null) break;
      }
    }
    return InstitutionalCommunicationItem(
      id: id,
      title: title,
      code: asIcString(m['code'] ?? m['reference']),
      status: asIcString(m['status'] ?? m['state']),
      kind: asIcString(m['type'] ?? m['kind'] ?? m['category']),
      summary: asIcString(
        m['summary'] ?? m['description'] ?? m['body'] ?? m['excerpt'],
      ),
      channel: asIcString(m['channel'] ?? m['medium'] ?? m['platform']),
      date: date,
      raw: m,
    );
  }
}
