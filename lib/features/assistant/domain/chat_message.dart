enum ChatSender { user, assistant }

enum ChatAttachmentKind {
  none,
  image,
  document,
  location,
  audio,
}

/// Mensagem de conversa — preparada para anexos futuros.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sender,
    required this.createdAt,
    this.text,
    this.attachmentKind = ChatAttachmentKind.none,
    this.attachmentLabel,
    this.attachmentMeta,
  });

  final String id;
  final ChatSender sender;
  final DateTime createdAt;
  final String? text;
  final ChatAttachmentKind attachmentKind;
  final String? attachmentLabel;
  final Map<String, dynamic>? attachmentMeta;

  bool get isUser => sender == ChatSender.user;
  bool get isAssistant => sender == ChatSender.assistant;
  bool get hasAttachment => attachmentKind != ChatAttachmentKind.none;
}

/// Saudação inicial estática da UI (não é histórico nem mock de IA).
List<ChatMessage> assistantWelcomeMessages() {
  return [
    ChatMessage(
      id: 'welcome',
      sender: ChatSender.assistant,
      createdAt: DateTime.now(),
      text:
          'Olá! Sou o assistente do PoliGestor. Como posso ajudar você hoje?',
    ),
  ];
}
