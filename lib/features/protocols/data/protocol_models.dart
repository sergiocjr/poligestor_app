class ProtocolSummary {
  ProtocolSummary({
    required this.id,
    required this.title,
    this.number,
    this.status,
    this.priority,
    this.category,
    this.createdAt,
    this.description,
  });

  final dynamic id;
  final String title;
  final String? number;
  final String? status;
  final String? priority;
  final String? category;
  final DateTime? createdAt;
  final String? description;

  factory ProtocolSummary.fromJson(Map<String, dynamic> json) {
    final title = (json['subject'] ??
            json['title'] ??
            json['assunto'] ??
            json['descricao'] ??
            'Protocolo')
        .toString();
    final createdRaw = json['created_at'] ?? json['createdAt'] ?? json['data'];
    return ProtocolSummary(
      id: json['id'],
      title: title,
      number: (json['number'] ?? json['numero'] ?? json['code'])?.toString(),
      status: (json['status'] ?? json['situacao'])?.toString(),
      priority: json['priority']?.toString(),
      category: json['category']?.toString(),
      description: (json['description'] ?? json['descricao'])?.toString(),
      createdAt:
          createdRaw != null ? DateTime.tryParse(createdRaw.toString()) : null,
    );
  }

  bool get isOpen =>
      status == 'open' || status == 'aberto' || status == 'waiting';
  bool get isInProgress =>
      status == 'in_progress' || status == 'andamento' || status == 'em_andamento';
  bool get isResolved =>
      status == 'resolved' ||
      status == 'closed' ||
      status == 'resolvido' ||
      status == 'concluido';
}

class ProtocolComment {
  ProtocolComment({
    required this.id,
    required this.body,
    this.createdAt,
    this.authorName,
  });

  final dynamic id;
  final String body;
  final DateTime? createdAt;
  final String? authorName;

  factory ProtocolComment.fromJson(Map<String, dynamic> json) {
    final author = json['user'] ?? json['author'] ?? json['creator'];
    String? name;
    if (author is Map) {
      name = (author['name'] ?? author['nome'])?.toString();
    }
    final createdRaw = json['created_at'] ?? json['createdAt'];
    return ProtocolComment(
      id: json['id'],
      body: (json['body'] ?? json['content'] ?? json['message'] ?? '').toString(),
      authorName: name,
      createdAt:
          createdRaw != null ? DateTime.tryParse(createdRaw.toString()) : null,
    );
  }
}

class ProtocolAttachment {
  ProtocolAttachment({
    required this.id,
    this.name,
    this.url,
    this.mimeType,
  });

  final dynamic id;
  final String? name;
  final String? url;
  final String? mimeType;

  factory ProtocolAttachment.fromJson(Map<String, dynamic> json) {
    return ProtocolAttachment(
      id: json['id'],
      name: (json['name'] ?? json['filename'] ?? json['original_name'])
          ?.toString(),
      url: (json['url'] ?? json['path'] ?? json['download_url'])?.toString(),
      mimeType: (json['mime_type'] ?? json['content_type'])?.toString(),
    );
  }
}

class ProtocolDetail extends ProtocolSummary {
  ProtocolDetail({
    required super.id,
    required super.title,
    super.number,
    super.status,
    super.priority,
    super.category,
    super.createdAt,
    super.description,
    this.comments = const [],
    this.attachments = const [],
    this.raw,
  });

  final List<ProtocolComment> comments;
  final List<ProtocolAttachment> attachments;
  final Map<String, dynamic>? raw;

  factory ProtocolDetail.fromJson(Map<String, dynamic> json) {
    final base = ProtocolSummary.fromJson(json);
    final commentsRaw = json['comments'] ?? json['timeline'] ?? const [];
    final attachmentsRaw = json['attachments'] ?? const [];

    return ProtocolDetail(
      id: base.id,
      title: base.title,
      number: base.number,
      status: base.status,
      priority: base.priority,
      category: base.category,
      createdAt: base.createdAt,
      description: base.description,
      comments: (commentsRaw is List)
          ? commentsRaw
              .whereType<Map>()
              .map((e) => ProtocolComment.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      attachments: (attachmentsRaw is List)
          ? attachmentsRaw
              .whereType<Map>()
              .map((e) =>
                  ProtocolAttachment.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      raw: json,
    );
  }
}

class ProtocolStatusLabel {
  static String pt(String? status) {
    return switch (status) {
      'open' || 'aberto' || 'recebido' => 'Aberta',
      'in_progress' || 'andamento' || 'em_andamento' => 'Em andamento',
      'waiting' || 'aguardando' => 'Aguardando',
      'resolved' || 'resolvido' => 'Resolvida',
      'closed' || 'fechado' || 'concluido' => 'Concluída',
      null => '—',
      _ => status,
    };
  }
}

class RequestCategory {
  const RequestCategory({
    required this.id,
    required this.label,
    required this.iconName,
    required this.description,
  });

  final String id;
  final String label;
  final String iconName;
  final String description;

  static const help = RequestCategory(
    id: 'ajuda',
    label: 'Solicitar ajuda',
    iconName: 'help',
    description: 'Peça apoio ao gabinete',
  );
  static const report = RequestCategory(
    id: 'denuncia',
    label: 'Fazer denúncia',
    iconName: 'report',
    description: 'Relate um problema',
  );
  static const suggestion = RequestCategory(
    id: 'sugestao',
    label: 'Enviar sugestão',
    iconName: 'lightbulb',
    description: 'Ideias para o bairro',
  );
  static const appointment = RequestCategory(
    id: 'atendimento',
    label: 'Agendar atendimento',
    iconName: 'event',
    description: 'Marque um horário',
  );
  static const track = RequestCategory(
    id: 'acompanhar',
    label: 'Acompanhar protocolo',
    iconName: 'search',
    description: 'Veja o andamento',
  );
  static const document = RequestCategory(
    id: 'documento',
    label: 'Enviar documento',
    iconName: 'attach',
    description: 'Anexe arquivos',
  );

  static const all = [help, report, suggestion, appointment, track, document];
}
