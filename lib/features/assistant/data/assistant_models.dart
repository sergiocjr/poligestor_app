class AssistantReply {
  const AssistantReply({required this.reply});

  final String reply;

  factory AssistantReply.fromJson(Map<String, dynamic> json) {
    final reply = (json['reply'] ?? json['message'] ?? json['content'] ?? '')
        .toString()
        .trim();
    if (reply.isEmpty) {
      throw const FormatException('Resposta do assistente sem campo reply');
    }
    return AssistantReply(reply: reply);
  }
}
