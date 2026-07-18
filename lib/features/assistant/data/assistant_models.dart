import '../domain/chat_message.dart';

typedef AssistantProtocolInfo = ChatProtocolInfo;

class AssistantReply {
  const AssistantReply({
    required this.reply,
    this.intent,
    this.nextAction,
    this.finished,
    this.conversationId,
    this.protocol,
  });

  final String reply;
  final String? intent;
  final String? nextAction;
  final bool? finished;
  final String? conversationId;
  final ChatProtocolInfo? protocol;

  bool get isProtocolCreated {
    final action = (nextAction ?? '').trim().toUpperCase();
    return action == 'PROTOCOL_CREATED';
  }

  /// Só exibe card se a API marcou criação **e** enviou o objeto protocol.
  bool get shouldShowProtocolCard =>
      isProtocolCreated && protocol != null && protocol!.isValid;

  bool get asksConfirmation {
    if (isProtocolCreated) return false;
    final action = (nextAction ?? '').trim().toUpperCase();
    if (action.isEmpty) return false;
    return action == 'CONFIRM' ||
        action == 'CONFIRMATION' ||
        action == 'ASK_CONFIRMATION' ||
        action == 'AWAITING_CONFIRMATION' ||
        action == 'NEED_CONFIRMATION' ||
        action == 'CONFIRM_DETAILS';
  }

  factory AssistantReply.fromJson(Map<String, dynamic> json) {
    final reply = (json['reply'] ?? json['message'] ?? json['content'] ?? '')
        .toString()
        .trim();
    if (reply.isEmpty) {
      throw const FormatException('Resposta do assistente sem campo reply');
    }

    ChatProtocolInfo? protocol;
    final rawProtocol = json['protocol'];
    if (rawProtocol is Map<String, dynamic>) {
      protocol = ChatProtocolInfo.fromJson(rawProtocol);
    } else if (rawProtocol is Map) {
      protocol = ChatProtocolInfo.fromJson(
        Map<String, dynamic>.from(rawProtocol),
      );
    }
    if (protocol != null && !protocol.isValid) {
      protocol = null;
    }

    return AssistantReply(
      reply: reply,
      intent: stringOrNull(json['intent']),
      nextAction: stringOrNull(json['next_action'] ?? json['nextAction']),
      finished: json['finished'] is bool ? json['finished'] as bool : null,
      conversationId: stringOrNull(
        json['conversation_id'] ?? json['conversationId'],
      ),
      protocol: protocol,
    );
  }

  static String? stringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }
}

/// Monta mensagens de UI a partir da reply HTTP, sem duplicar cards.
class AssistantReplyPresenter {
  AssistantReplyPresenter({Set<String>? shownProtocolKeys})
      : _shownProtocolKeys = shownProtocolKeys ?? <String>{};

  final Set<String> _shownProtocolKeys;

  Set<String> get shownProtocolKeys => Set.unmodifiable(_shownProtocolKeys);

  List<ChatMessage> present(
    AssistantReply reply, {
    required String Function() nextId,
    DateTime? now,
  }) {
    final createdAt = now ?? DateTime.now();
    final messages = <ChatMessage>[
      ChatMessage(
        id: nextId(),
        sender: ChatSender.assistant,
        createdAt: createdAt,
        text: reply.reply,
        showConfirmShortcuts: reply.asksConfirmation,
      ),
    ];

    if (reply.shouldShowProtocolCard) {
      final protocol = reply.protocol!;
      final key = protocol.dedupeKey;
      if (key.isNotEmpty && !_shownProtocolKeys.contains(key)) {
        _shownProtocolKeys.add(key);
        messages.add(
          ChatMessage(
            id: nextId(),
            sender: ChatSender.assistant,
            createdAt: createdAt,
            text: null,
            protocol: protocol,
          ),
        );
      }
    }

    return messages;
  }

  void rememberProtocol(ChatProtocolInfo protocol) {
    final key = protocol.dedupeKey;
    if (key.isNotEmpty) _shownProtocolKeys.add(key);
  }

  void reset() => _shownProtocolKeys.clear();
}

/// Snapshot da conversa ativa do portal (GET /assistant/conversation).
class AssistantConversation {
  const AssistantConversation({
    this.id,
    this.messages = const [],
  });

  final String? id;
  final List<AssistantHistoryMessage> messages;

  bool get hasMessages => messages.isNotEmpty;

  factory AssistantConversation.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ??
            json['conversation_id'] ??
            json['uuid'] ??
            json['conversationId'])
        ?.toString();

    final rawMessages = json['messages'] ??
        json['history'] ??
        json['items'] ??
        json['data'];

    final messages = <AssistantHistoryMessage>[];
    if (rawMessages is List) {
      for (var i = 0; i < rawMessages.length; i++) {
        final item = rawMessages[i];
        if (item is Map<String, dynamic>) {
          final parsed = AssistantHistoryMessage.tryParse(item, index: i);
          if (parsed != null) messages.add(parsed);
        } else if (item is Map) {
          final parsed = AssistantHistoryMessage.tryParse(
            Map<String, dynamic>.from(item),
            index: i,
          );
          if (parsed != null) messages.add(parsed);
        }
      }
    }

    return AssistantConversation(id: id, messages: messages);
  }

  List<ChatMessage> toChatMessages({AssistantReplyPresenter? presenter}) {
    final out = <ChatMessage>[];
    for (final m in messages) {
      out.add(m.toChatMessage());
      final protocol = m.protocol;
      if (protocol != null && protocol.isValid) {
        final key = protocol.dedupeKey;
        if (presenter != null) {
          if (key.isEmpty || presenter.shownProtocolKeys.contains(key)) {
            continue;
          }
          presenter.rememberProtocol(protocol);
        }
        out.add(
          ChatMessage(
            id: '${m.id}-protocol',
            sender: ChatSender.assistant,
            createdAt: m.createdAt,
            protocol: protocol,
          ),
        );
      }
    }
    return out;
  }
}

class AssistantHistoryMessage {
  const AssistantHistoryMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.protocol,
    this.nextAction,
  });

  final String id;
  final ChatSender sender;
  final String text;
  final DateTime createdAt;
  final ChatProtocolInfo? protocol;
  final String? nextAction;

  static AssistantHistoryMessage? tryParse(
    Map<String, dynamic> json, {
    required int index,
  }) {
    final text = (json['content'] ??
            json['text'] ??
            json['message'] ??
            json['body'] ??
            json['reply'] ??
            '')
        .toString()
        .trim();
    if (text.isEmpty) return null;

    final role = (json['role'] ??
            json['sender'] ??
            json['from'] ??
            json['author'] ??
            json['type'] ??
            '')
        .toString()
        .toLowerCase()
        .trim();

    final sender = _parseSender(role);
    final id =
        (json['id'] ?? json['message_id'] ?? json['uuid'] ?? 'hist-$index')
            .toString();
    final createdAt = _parseDate(
          json['created_at'] ??
              json['createdAt'] ??
              json['timestamp'] ??
              json['sent_at'],
        ) ??
        DateTime.now();

    ChatProtocolInfo? protocol;
    final rawProtocol = json['protocol'];
    if (rawProtocol is Map<String, dynamic>) {
      protocol = ChatProtocolInfo.fromJson(rawProtocol);
    } else if (rawProtocol is Map) {
      protocol = ChatProtocolInfo.fromJson(
        Map<String, dynamic>.from(rawProtocol),
      );
    }
    if (protocol != null && !protocol.isValid) protocol = null;

    return AssistantHistoryMessage(
      id: id,
      sender: sender,
      text: text,
      createdAt: createdAt,
      protocol: protocol,
      nextAction: AssistantReply.stringOrNull(
        json['next_action'] ?? json['nextAction'],
      ),
    );
  }

  ChatMessage toChatMessage() => ChatMessage(
        id: id,
        sender: sender,
        createdAt: createdAt,
        text: text,
      );

  static ChatSender _parseSender(String role) {
    if (role.contains('user') ||
        role.contains('citizen') ||
        role.contains('human') ||
        role == 'me' ||
        role == 'portal') {
      return ChatSender.user;
    }
    return ChatSender.assistant;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is int) {
      final ms = raw > 9999999999 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.tryParse(raw.toString());
  }
}
