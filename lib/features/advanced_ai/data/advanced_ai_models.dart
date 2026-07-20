/// Fase 18 — modelos da IA Avançada (`/v1/ai/*`).
library;

Map<String, dynamic> asAdvancedAiMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asAdvancedAiMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final nestedList =
        map['data'] ??
        map['items'] ??
        map['results'] ??
        map['rows'] ??
        map['conversations'] ??
        map['prompts'] ??
        map['briefings'] ??
        map['history'] ??
        map['messages'];
    if (nestedList is List) {
      return nestedList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    final bullets = map['bullets'] ?? map['points'];
    if (bullets is List) {
      return bullets
          .where((b) => b != null)
          .map(
            (b) => {
              'id': b.hashCode.toString(),
              'title': b is Map
                  ? (b['text'] ?? b['body'] ?? b['title'] ?? '').toString()
                  : b.toString(),
              'summary': b is Map
                  ? (b['body'] ?? b['text'] ?? '').toString()
                  : null,
            },
          )
          .toList();
    }
  }
  return const [];
}

String? asAdvancedAiString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class AdvancedAiItem {
  const AdvancedAiItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.role,
    this.date,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? role;
  final DateTime? date;
  final Map<String, dynamic> raw;

  factory AdvancedAiItem.fromJson(Map<String, dynamic> json) {
    final m = asAdvancedAiMap(json);
    final id =
        asAdvancedAiString(m['id'] ?? m['uuid'] ?? m['code'] ?? m['slug']) ??
        '${m.hashCode}';
    final title =
        asAdvancedAiString(
          m['title'] ??
              m['name'] ??
              m['label'] ??
              m['subject'] ??
              m['preview'] ??
              m['prompt'],
        ) ??
        'Item $id';
    DateTime? date;
    for (final k in [
      'created_at',
      'updated_at',
      'generated_at',
      'occurred_at',
      'date',
    ]) {
      final raw = m[k];
      if (raw != null) {
        date = DateTime.tryParse('$raw');
        if (date != null) break;
      }
    }
    return AdvancedAiItem(
      id: id,
      title: title,
      code: asAdvancedAiString(m['code'] ?? m['category']),
      status: asAdvancedAiString(m['status'] ?? m['state']),
      kind: asAdvancedAiString(m['type'] ?? m['kind'] ?? m['category']),
      summary: asAdvancedAiString(
        m['summary'] ?? m['description'] ?? m['body'] ?? m['content'] ?? m['text'],
      ),
      role: asAdvancedAiString(m['role'] ?? m['agent']),
      date: date,
      raw: m,
    );
  }
}

class AaiChatMessage {
  const AaiChatMessage({
    required this.role,
    required this.content,
    this.id,
    this.createdAt,
  });

  final String? id;
  final String role;
  final String content;
  final DateTime? createdAt;

  bool get isUser => role == 'user' || role == 'human';

  factory AaiChatMessage.fromJson(Map<String, dynamic> json) {
    return AaiChatMessage(
      id: (json['id'] ?? json['uuid'])?.toString(),
      role: (json['role'] ?? json['sender'] ?? 'assistant').toString(),
      content: (json['content'] ?? json['message'] ?? json['text'] ?? '')
          .toString(),
      createdAt: _parseDt(json['created_at'] ?? json['sent_at']),
    );
  }
}

class AaiChatReply {
  const AaiChatReply({
    required this.message,
    this.conversationId,
    this.raw = const {},
  });

  final AaiChatMessage message;
  final String? conversationId;
  final Map<String, dynamic> raw;

  factory AaiChatReply.fromJson(Map<String, dynamic> json) {
    final nested = json['message'] ?? json['reply'] ?? json['assistant'];
    final AaiChatMessage msg;
    if (nested is Map) {
      msg = AaiChatMessage.fromJson(Map<String, dynamic>.from(nested));
    } else {
      msg = AaiChatMessage(
        role: 'assistant',
        content: (json['content'] ?? json['message'] ?? json['text'] ?? '')
            .toString(),
      );
    }
    return AaiChatReply(
      message: msg,
      conversationId: (json['conversation_id'] ?? json['id'])?.toString(),
      raw: json,
    );
  }
}

DateTime? _parseDt(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());
