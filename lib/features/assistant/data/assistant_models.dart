import 'package:flutter/foundation.dart';

import '../domain/chat_message.dart';

typedef AssistantProtocolInfo = ChatProtocolInfo;

class AssistantReply {
  const AssistantReply({
    required this.reply,
    this.intent,
    this.nextAction,
    this.finished = false,
    this.conversationId,
    this.protocol,
  });

  final String reply;
  final String? intent;
  final String? nextAction;
  final bool finished;
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
    if (rawProtocol is Map) {
      protocol = ChatProtocolInfo.fromJson(asStringKeyMap(rawProtocol));
    }
    if (protocol != null && !protocol.isValid) {
      protocol = null;
    }

    return AssistantReply(
      reply: reply,
      intent: stringOrNull(json['intent']),
      nextAction: stringOrNull(json['next_action'] ?? json['nextAction']),
      finished: boolOrNull(json['finished']) ?? false,
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

  static bool? boolOrNull(Object? raw) {
    if (raw is bool) return raw;
    if (raw == null) return null;
    final value = raw.toString().trim().toLowerCase();
    if (value == 'true' || value == '1') return true;
    if (value == 'false' || value == '0') return false;
    return null;
  }

  static int? intOrNull(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString().trim());
  }

  static Map<String, dynamic> asStringKeyMap(Map raw) {
    return Map<String, dynamic>.from(raw);
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
    this.state = const {},
    this.slotsFilled = const {},
    this.slotsPending = const [],
    this.pendingRequests = const [],
    this.finished = false,
    this.lastInteractionAt,
  });

  final String? id;
  final List<AssistantHistoryMessage> messages;
  final Map<String, dynamic> state;
  final Map<String, dynamic> slotsFilled;
  final List<dynamic> slotsPending;
  final List<dynamic> pendingRequests;
  final bool finished;
  final DateTime? lastInteractionAt;

  bool get hasMessages => messages.isNotEmpty;

  int? get firstSeq {
    for (final m in messages) {
      if (m.seq != null) return m.seq;
    }
    return null;
  }

  int? get lastSeq {
    for (var i = messages.length - 1; i >= 0; i--) {
      final seq = messages[i].seq;
      if (seq != null) return seq;
    }
    return null;
  }

  factory AssistantConversation.empty({String? id}) =>
      AssistantConversation(id: id);

  factory AssistantConversation.fromJson(Map<String, dynamic> json) {
    final id = AssistantReply.stringOrNull(
      json['conversation_id'] ??
          json['id'] ??
          json['uuid'] ??
          json['conversationId'],
    );

    // Maps vazios ({}) são válidos — nunca tratar como erro.
    final state = _asMap(json['state']) ?? const <String, dynamic>{};
    final slotsFilled =
        _asMap(json['slots_filled'] ?? json['slotsFilled']) ??
            const <String, dynamic>{};
    final slotsPending = _asList(
      json['slots_pending'] ?? json['slotsPending'],
    );
    final pendingRequests = _asList(
      json['pending_requests'] ?? json['pendingRequests'],
    );

    final finished = AssistantReply.boolOrNull(json['finished']) ??
        AssistantReply.boolOrNull(state['finished']) ??
        false;

    final lastInteractionAt = AssistantHistoryMessage.parseDate(
      json['last_interaction_at'] ?? json['lastInteractionAt'],
    );

    // Fonte canônica: messages (List). Sempre lista (vazia ou não).
    final rawMessages = json['messages'];
    final messages = <AssistantHistoryMessage>[];
    if (rawMessages is List) {
      for (var i = 0; i < rawMessages.length; i++) {
        final item = rawMessages[i];
        if (item is Map) {
          final parsed = AssistantHistoryMessage.tryParse(
            AssistantReply.asStringKeyMap(item),
            index: i,
          );
          if (parsed != null) messages.add(parsed);
        }
      }
    }

    // Se houver seq, ordenar crescente (não usar created_at).
    if (messages.any((m) => m.seq != null)) {
      messages.sort((a, b) {
        final as = a.seq;
        final bs = b.seq;
        if (as == null && bs == null) return 0;
        if (as == null) return 1;
        if (bs == null) return -1;
        return as.compareTo(bs);
      });
    }

    return AssistantConversation(
      id: id,
      messages: messages,
      state: state,
      slotsFilled: slotsFilled,
      slotsPending: slotsPending,
      pendingRequests: pendingRequests,
      finished: finished,
      lastInteractionAt: lastInteractionAt,
    );
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

  static Map<String, dynamic>? _asMap(Object? raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static List<dynamic> _asList(Object? raw) {
    if (raw is List) return List<dynamic>.from(raw);
    return const [];
  }

  /// Log técnico apenas em debug — sem conteúdo das mensagens.
  void debugLogMeta({int? httpStatus}) {
    if (!kDebugMode) return;
    debugPrint(
      '[assistant.conversation] status=${httpStatus ?? '-'} '
      'conversation_id=$id '
      'messages_count=${messages.length} '
      'first_seq=$firstSeq '
      'last_seq=$lastSeq '
      'finished=$finished '
      'pending_requests_count=${pendingRequests.length} '
      'state_runtime=${state.runtimeType} '
      'slots_filled_runtime=${slotsFilled.runtimeType}',
    );
  }
}

class AssistantHistoryMessage {
  const AssistantHistoryMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.seq,
    this.protocol,
    this.nextAction,
  });

  final String id;
  final ChatSender sender;
  final String text;
  final DateTime createdAt;
  final int? seq;
  final ChatProtocolInfo? protocol;
  final String? nextAction;

  static AssistantHistoryMessage? tryParse(
    Map<String, dynamic> json, {
    required int index,
  }) {
    final text = (json['text'] ??
            json['content'] ??
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
    final seq = AssistantReply.intOrNull(json['seq']);
    final id = (json['id'] ??
            json['message_id'] ??
            json['uuid'] ??
            (seq != null ? 'seq-$seq' : 'hist-$index'))
        .toString();
    final createdAt = parseDate(
          json['created_at'] ??
              json['createdAt'] ??
              json['timestamp'] ??
              json['sent_at'],
        ) ??
        DateTime.now();

    ChatProtocolInfo? protocol;
    final rawProtocol = json['protocol'];
    if (rawProtocol is Map) {
      protocol = ChatProtocolInfo.fromJson(
        AssistantReply.asStringKeyMap(rawProtocol),
      );
    }
    if (protocol != null && !protocol.isValid) protocol = null;

    return AssistantHistoryMessage(
      id: id,
      sender: sender,
      text: text,
      createdAt: createdAt,
      seq: seq,
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
    // API usa "model" para o assistente (Gemini).
    return ChatSender.assistant;
  }

  static DateTime? parseDate(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is int) {
      final ms = raw > 9999999999 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.tryParse(raw.toString());
  }
}
