enum ChatSender { user, assistant }

enum ChatAttachmentKind { none, image, document, location, audio }

class ChatProtocolInfo {
  const ChatProtocolInfo({required this.id, required this.number, this.status});

  final String id;
  final String number;
  final String? status;

  String get dedupeKey {
    final n = number.trim().toLowerCase();
    if (n.isNotEmpty) return 'n:$n';
    final i = id.trim().toLowerCase();
    return i.isNotEmpty ? 'i:$i' : '';
  }

  bool get isValid => number.trim().isNotEmpty || id.trim().isNotEmpty;

  factory ChatProtocolInfo.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['protocol_id'] ?? json['uuid'] ?? '')
        .toString()
        .trim();
    final number =
        (json['number'] ??
                json['protocolo'] ??
                json['protocol_number'] ??
                json['codigo'] ??
                '')
            .toString()
            .trim();
    final status = (json['status'] ?? json['state'])?.toString().trim();
    return ChatProtocolInfo(
      id: id,
      number: number,
      status: (status == null || status.isEmpty) ? null : status,
    );
  }
}

/// Mensagem de conversa — texto, card de protocolo ou atalhos.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sender,
    required this.createdAt,
    this.text,
    this.attachmentKind = ChatAttachmentKind.none,
    this.attachmentLabel,
    this.attachmentMeta,
    this.protocol,
    this.showConfirmShortcuts = false,
  });

  final String id;
  final ChatSender sender;
  final DateTime createdAt;
  final String? text;
  final ChatAttachmentKind attachmentKind;
  final String? attachmentLabel;
  final Map<String, dynamic>? attachmentMeta;
  final ChatProtocolInfo? protocol;
  final bool showConfirmShortcuts;

  bool get isUser => sender == ChatSender.user;
  bool get isAssistant => sender == ChatSender.assistant;
  bool get hasAttachment => attachmentKind != ChatAttachmentKind.none;
  bool get isProtocolCard => protocol != null;
}

/// Saudação inicial estática da UI (não é histórico nem mock de IA).
List<ChatMessage> assistantWelcomeMessages() {
  return [
    ChatMessage(
      id: 'welcome',
      sender: ChatSender.assistant,
      createdAt: DateTime.now(),
      text: 'Olá! Sou o assistente do PoliGestor. Como posso ajudar você hoje?',
    ),
  ];
}
