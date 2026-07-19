/// Modelos Sprint 10.5 — Assistente Inteligente (PoliGestor only).
library;

class SaChatMessage {
  const SaChatMessage({
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

  factory SaChatMessage.fromJson(Map<String, dynamic> json) {
    return SaChatMessage(
      id: (json['id'] ?? json['uuid'])?.toString(),
      role: (json['role'] ?? json['sender'] ?? 'assistant').toString(),
      content: (json['content'] ?? json['message'] ?? json['text'] ?? '')
          .toString(),
      createdAt: _parseDt(json['created_at'] ?? json['sent_at']),
    );
  }
}

class SaChatReply {
  const SaChatReply({
    required this.message,
    this.conversationId,
    this.raw = const {},
  });

  final SaChatMessage message;
  final String? conversationId;
  final Map<String, dynamic> raw;

  factory SaChatReply.fromJson(Map<String, dynamic> json) {
    final nested = json['message'] ?? json['reply'] ?? json['assistant'];
    final SaChatMessage msg;
    if (nested is Map) {
      msg = SaChatMessage.fromJson(Map<String, dynamic>.from(nested));
    } else {
      msg = SaChatMessage(
        role: 'assistant',
        content: (json['content'] ?? json['message'] ?? json['text'] ?? '')
            .toString(),
      );
    }
    return SaChatReply(
      message: msg,
      conversationId: (json['conversation_id'] ?? json['id'])?.toString(),
      raw: json,
    );
  }
}

class SaConversationItem {
  const SaConversationItem({
    required this.id,
    required this.title,
    this.updatedAt,
    this.messageCount = 0,
  });

  final String id;
  final String title;
  final DateTime? updatedAt;
  final int messageCount;

  factory SaConversationItem.fromJson(Map<String, dynamic> json) {
    return SaConversationItem(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      title: (json['title'] ?? json['subject'] ?? json['preview'] ?? 'Conversa')
          .toString(),
      updatedAt: _parseDt(json['updated_at'] ?? json['created_at']),
      messageCount: _asInt(json['message_count'] ?? json['messages_count']),
    );
  }
}

class SaBriefingView {
  const SaBriefingView({
    required this.bullets,
    this.title,
    this.generatedAt,
    this.scope,
    this.fromCache = false,
  });

  final String? title;
  final List<String> bullets;
  final DateTime? generatedAt;
  final String? scope;
  final bool fromCache;

  factory SaBriefingView.fromJson(Map<String, dynamic> json) {
    final bulletsRaw = json['bullets'] ?? json['items'] ?? json['points'];
    final bullets = <String>[];
    if (bulletsRaw is List) {
      for (final b in bulletsRaw) {
        if (b == null) continue;
        if (b is String) {
          bullets.add(b);
        } else if (b is Map) {
          final t = (b['text'] ?? b['body'] ?? b['title'])?.toString();
          if (t != null && t.isNotEmpty) bullets.add(t);
        } else {
          bullets.add(b.toString());
        }
      }
    }
    final period = json['period'];
    String? scope = json['scope']?.toString();
    if (scope == null && period is Map) {
      scope = period['label']?.toString();
    }
    return SaBriefingView(
      title: (json['title'] ?? json['headline'])?.toString(),
      bullets: bullets,
      generatedAt: _parseDt(json['generated_at']),
      scope: scope,
    );
  }
}

class SaInsightItem {
  const SaInsightItem({
    required this.id,
    required this.title,
    required this.body,
    this.priority,
    this.type,
  });

  final String id;
  final String title;
  final String body;
  final String? priority;
  final String? type;

  factory SaInsightItem.fromJson(Map<String, dynamic> json) {
    return SaInsightItem(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      title: (json['title'] ?? json['headline'] ?? 'Insight').toString(),
      body: (json['body'] ?? json['summary'] ?? json['text'] ?? '').toString(),
      priority: json['priority']?.toString(),
      type: json['type']?.toString(),
    );
  }
}

List<Map<String, dynamic>> asMapList(dynamic raw) {
  Iterable<dynamic> list;
  if (raw is List) {
    list = raw;
  } else if (raw is Map) {
    final v = raw['data'] ?? raw['items'] ?? raw['results'];
    list = v is List ? v : const [];
  } else {
    list = const [];
  }
  return list
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

Map<String, dynamic> asMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

DateTime? _parseDt(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

int _asInt(dynamic v) {
  if (v is int) return v;
  return int.tryParse(v?.toString() ?? '') ?? 0;
}
