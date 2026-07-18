enum ChatSender { user, assistant }

enum ChatAttachmentKind {
  none,
  image,
  document,
  location,
  audio,
}

/// Mensagem de conversa — preparada para anexos futuros (sem IA ainda).
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

class MockAssistantConversation {
  MockAssistantConversation._();

  static List<ChatMessage> seed() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'm1',
        sender: ChatSender.assistant,
        createdAt: now.subtract(const Duration(minutes: 12)),
        text:
            'Olá! Sou o assistente do PoliGestor. Posso ajudar com solicitações, agenda e informações do seu bairro.',
      ),
      ChatMessage(
        id: 'm2',
        sender: ChatSender.user,
        createdAt: now.subtract(const Duration(minutes: 11)),
        text: 'Quero saber como abrir uma solicitação de iluminação.',
      ),
      ChatMessage(
        id: 'm3',
        sender: ChatSender.assistant,
        createdAt: now.subtract(const Duration(minutes: 10)),
        text:
            'Claro. Em Solicitações → Nova solicitação, escolha o tipo e descreva o local. Você também pode anexar uma foto.',
      ),
      ChatMessage(
        id: 'm4',
        sender: ChatSender.user,
        createdAt: now.subtract(const Duration(minutes: 9)),
        text: 'Posso enviar a localização depois?',
        attachmentKind: ChatAttachmentKind.location,
        attachmentLabel: 'Localização (em breve)',
        attachmentMeta: {'lat': -22.89, 'lng': -47.06},
      ),
      ChatMessage(
        id: 'm5',
        sender: ChatSender.assistant,
        createdAt: now.subtract(const Duration(minutes: 8)),
        text:
            'Sim. Em breve você poderá enviar imagem, documento, áudio e localização por aqui. Por enquanto, use o texto normalmente.',
      ),
    ];
  }

  /// Resposta mock local — sem rede, sem Gemini.
  static String mockReply(String userText) {
    final t = userText.toLowerCase();
    if (t.contains('protocolo') || t.contains('solicit')) {
      return 'Para acompanhar um protocolo, abra a aba Solicitações. Se quiser, me diga o número e eu oriento o próximo passo.';
    }
    if (t.contains('agenda') || t.contains('compromisso')) {
      return 'Seus próximos compromissos aparecem na Home, na seção Agenda. Posso ajudar a preparar uma nova solicitação de atendimento.';
    }
    if (t.contains('obrigado') || t.contains('valeu')) {
      return 'Por nada! Estou por aqui quando precisar.';
    }
    return 'Entendi. Em breve responderei com inteligência artificial. Por enquanto, esta é uma resposta de demonstração da interface.';
  }
}
