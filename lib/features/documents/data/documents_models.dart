/// Fase 13 — modelos da Gestão Documental (`/v1/documents/*`).
library;

Map<String, dynamic> asDocsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asDocsMapList(dynamic raw) {
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
        raw['documents'] ??
        raw['files'] ??
        raw['attachments'] ??
        raw['templates'] ??
        raw['categories'] ??
        raw['favorites'] ??
        raw['history'] ??
        raw['timeline'] ??
        raw['signatures'] ??
        raw['approvals'] ??
        raw['rows'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

int asDocsInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

String? asDocsString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.category,
    this.mimeType,
    this.url,
    this.summary,
    this.updatedAt,
    this.favorite = false,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? category;
  final String? mimeType;
  final String? url;
  final String? summary;
  final DateTime? updatedAt;
  final bool favorite;
  final Map<String, dynamic> raw;

  bool get isPdf {
    final m = (mimeType ?? '').toLowerCase();
    final n = (title).toLowerCase();
    final u = (url ?? '').toLowerCase();
    return m == 'application/pdf' || n.endsWith('.pdf') || u.contains('.pdf');
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    final updatedRaw =
        json['updated_at'] ?? json['updatedAt'] ?? json['created_at'];
    return DocumentItem(
      id: asDocsString(json['id'] ?? json['uuid'] ?? json['code']) ?? '',
      title:
          asDocsString(
            json['title'] ??
                json['name'] ??
                json['filename'] ??
                json['label'] ??
                json['document'],
          ) ??
          'Documento',
      code: asDocsString(json['code'] ?? json['number']),
      status: asDocsString(json['status']),
      category: asDocsString(
        json['category'] ?? json['category_name'] ?? json['tipo'],
      ),
      mimeType: asDocsString(json['mime_type'] ?? json['mimeType'] ?? json['type']),
      url: asDocsString(json['url'] ?? json['file_url'] ?? json['download_url']),
      summary: asDocsString(
        json['summary'] ?? json['description'] ?? json['body'],
      ),
      updatedAt: updatedRaw == null
          ? null
          : DateTime.tryParse(updatedRaw.toString()),
      favorite: json['favorite'] == true ||
          json['is_favorite'] == true ||
          json['starred'] == true,
      raw: Map<String, dynamic>.from(json),
    );
  }
}
