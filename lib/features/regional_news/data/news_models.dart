/// Fase 24 — modelos de Notícias Regionais (`/v1/news/*`).
/// Metadados apenas — sem corpo completo da matéria.
library;

Map<String, dynamic> asNewsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asNewsMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final nested =
        map['data'] ??
        map['items'] ??
        map['results'] ??
        map['news'] ??
        map['articles'] ??
        map['mentions'] ??
        map['favorites'] ??
        map['alerts'] ??
        map['filters'];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

String? asNewsString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// Metadados de uma notícia regional (sem texto integral).
class RegionalNewsItem {
  const RegionalNewsItem({
    required this.id,
    required this.title,
    this.summary,
    this.source,
    this.city,
    this.topic,
    this.imageUrl,
    this.originalUrl,
    this.publishedAt,
    this.mentionsPolitician = false,
    this.favorite = false,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? summary;
  final String? source;
  final String? city;
  final String? topic;
  final String? imageUrl;
  final String? originalUrl;
  final DateTime? publishedAt;
  final bool mentionsPolitician;
  final bool favorite;
  final Map<String, dynamic> raw;

  factory RegionalNewsItem.fromJson(Map<String, dynamic> json) {
    final m = asNewsMap(json);
    final articleId = asNewsString(m['article_id']);
    final id =
        asNewsString(m['id'] ?? m['uuid'] ?? m['slug'] ?? m['code']) ??
        articleId ??
        '${m.hashCode}';
    if (articleId != null &&
        (m['title'] == null && m['headline'] == null && m['name'] == null)) {
      return RegionalNewsItem(
        id: articleId,
        title: 'Notícia',
        summary: asNewsString(m['body'] ?? m['summary']),
        mentionsPolitician: true,
        publishedAt: DateTime.tryParse(
          (m['created_at'] ?? m['published_at'] ?? '').toString(),
        ),
        raw: m,
      );
    }
    final title =
        asNewsString(m['title'] ?? m['headline'] ?? m['name']) ?? 'Notícia';
    final summary = asNewsString(
      m['summary'] ?? m['excerpt'] ?? m['description'] ?? m['lead'],
    );
    // Nunca persistir/exibir corpo completo.
    final source = asNewsString(
      m['source'] ?? m['source_name'] ?? m['publisher'] ?? m['outlet'],
    );
    final city = asNewsString(
      m['city'] ?? m['municipality'] ?? m['location'],
    );
    final topic = asNewsString(
      m['topic'] ?? m['subject'] ?? m['category'] ?? m['theme'],
    );
    final imageUrl = asNewsString(
      m['image_url'] ?? m['image'] ?? m['thumbnail'] ?? m['cover'],
    );
    final originalUrl = asNewsString(
      m['url'] ??
          m['original_url'] ??
          m['canonical_url'] ??
          m['link'] ??
          m['source_url'],
    );
    DateTime? publishedAt;
    for (final key in [
      'published_at',
      'published_on',
      'date',
      'created_at',
      'timestamp',
    ]) {
      final raw = m[key];
      if (raw != null) {
        publishedAt = DateTime.tryParse(raw.toString());
        if (publishedAt != null) break;
      }
    }
    final mentions =
        m['mentions_politician'] == true ||
        m['mentions_politician'] == 1 ||
        m['is_mention'] == true ||
        m['highlight'] == true ||
        asNewsString(m['match_type']) != null ||
        asNewsString(m['matched_term']) != null ||
        asNewsString(m['mention_type']) != null;
    final favorite =
        m['favorite'] == true ||
        m['is_favorite'] == true ||
        m['favourited'] == true;
    return RegionalNewsItem(
      id: id,
      title: title,
      summary: summary,
      source: source,
      city: city,
      topic: topic,
      imageUrl: imageUrl,
      originalUrl: originalUrl,
      publishedAt: publishedAt,
      mentionsPolitician: mentions,
      favorite: favorite,
      raw: m,
    );
  }

  RegionalNewsItem copyWith({bool? favorite}) => RegionalNewsItem(
    id: id,
    title: title,
    summary: summary,
    source: source,
    city: city,
    topic: topic,
    imageUrl: imageUrl,
    originalUrl: originalUrl,
    publishedAt: publishedAt,
    mentionsPolitician: mentionsPolitician,
    favorite: favorite ?? this.favorite,
    raw: raw,
  );
}

class NewsFilterOption {
  const NewsFilterOption({required this.id, required this.label, this.group});

  final String id;
  final String label;
  final String? group;

  factory NewsFilterOption.fromJson(Map<String, dynamic> json) {
    final m = asNewsMap(json);
    return NewsFilterOption(
      id: asNewsString(m['id'] ?? m['value'] ?? m['slug'] ?? m['code']) ??
          '${m.hashCode}',
      label:
          asNewsString(m['label'] ?? m['name'] ?? m['title']) ?? 'Filtro',
      group: asNewsString(m['group'] ?? m['type'] ?? m['kind']),
    );
  }
}
