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
    return switch ((status ?? '').toLowerCase().trim()) {
      'open' || 'aberto' || 'recebido' || 'em_analise' || 'em análise' =>
        'Aberta',
      'in_progress' ||
      'andamento' ||
      'em_andamento' ||
      'encaminhado' ||
      'aguardando_cidadao' ||
      'aguardando cidadão' =>
        'Em andamento',
      'waiting' || 'aguardando' => 'Aguardando',
      'resolved' || 'resolvido' || 'encerrado' => 'Resolvida',
      'closed' || 'fechado' || 'concluido' || 'concluído' => 'Concluída',
      '' => '—',
      _ => status!,
    };
  }
}

/// Filtros de status usados na Home → Solicitações.
enum RequestStatusFilter {
  open,
  inProgress,
  resolved;

  String get queryValue => switch (this) {
        RequestStatusFilter.open => 'open',
        RequestStatusFilter.inProgress => 'in_progress',
        RequestStatusFilter.resolved => 'resolved',
      };

  String get label => switch (this) {
        RequestStatusFilter.open => 'Abertas',
        RequestStatusFilter.inProgress => 'Andamento',
        RequestStatusFilter.resolved => 'Resolvidas',
      };

  static RequestStatusFilter? tryParse(String? raw) {
    return switch ((raw ?? '').toLowerCase().trim()) {
      'open' || 'aberto' || 'abertas' => RequestStatusFilter.open,
      'in_progress' || 'andamento' || 'em_andamento' =>
        RequestStatusFilter.inProgress,
      'resolved' || 'resolvidas' || 'resolvido' => RequestStatusFilter.resolved,
      _ => null,
    };
  }

  bool matches(ProtocolSummary protocol) {
    final s = (protocol.status ?? '').toLowerCase().trim();
    return switch (this) {
      RequestStatusFilter.open =>
        s == 'open' ||
            s == 'aberto' ||
            s == 'recebido' ||
            s == 'em_analise' ||
            s == 'em análise' ||
            s == 'waiting' ||
            s == 'aguardando',
      RequestStatusFilter.inProgress =>
        s == 'in_progress' ||
            s == 'andamento' ||
            s == 'em_andamento' ||
            s == 'encaminhado' ||
            s == 'aguardando_cidadao' ||
            s == 'aguardando cidadão',
      RequestStatusFilter.resolved =>
        s == 'resolved' ||
            s == 'resolvido' ||
            s == 'encerrado' ||
            s == 'closed' ||
            s == 'fechado' ||
            s == 'concluido' ||
            s == 'concluído',
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
  static const visit = RequestCategory(
    id: 'visita',
    label: 'Solicitar visita',
    iconName: 'home',
    description: 'Peça visita no local',
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

  /// Catálogo estável para formulários (sem acompanhar).
  static const formOptions = [
    help,
    report,
    suggestion,
    appointment,
    visit,
    document,
  ];

  static const all = [
    help,
    report,
    suggestion,
    appointment,
    visit,
    track,
    document,
  ];

  /// Normaliza slugs vindos da API (ex.: agenda → atendimento).
  static String normalizeId(String? raw) {
    final key = (raw ?? '').trim().toLowerCase();
    return switch (key) {
      'agenda' || 'agendamento' || 'appointment' => 'atendimento',
      'visit' || 'visita_local' || 'solicitar_visita' => 'visita',
      'denúncia' || 'denuncia' || 'report' => 'denuncia',
      'sugestão' || 'sugestao' || 'idea' => 'sugestao',
      'help' || 'ajuda' => 'ajuda',
      'documento' || 'document' || 'arquivo' => 'documento',
      'protocolo' || 'acompanhar' || 'track' => 'acompanhar',
      'assistente' || 'chat' => 'assistente',
      _ => key,
    };
  }

  /// Remove duplicados por id, preservando a primeira ocorrência.
  static List<RequestCategory> uniqueById(Iterable<RequestCategory> source) {
    final seen = <String>{};
    final out = <RequestCategory>[];
    for (final item in source) {
      final id = normalizeId(item.id);
      if (id.isEmpty || !seen.add(id)) continue;
      out.add(
        RequestCategory(
          id: id,
          label: item.label,
          iconName: item.iconName,
          description: item.description,
        ),
      );
    }
    return out;
  }

  /// Itens seguros para DropdownButton (ids únicos).
  static List<RequestCategory> dropdownCategories({
    Iterable<RequestCategory>? source,
  }) {
    final list = uniqueById(source ?? formOptions)
        .where((c) => c.id != 'acompanhar' && c.id != 'assistente')
        .toList();
    return list;
  }

  /// Retorna o value do dropdown somente se existir exatamente uma vez.
  static String? sanitizeDropdownValue(
    String? value, {
    Iterable<RequestCategory>? source,
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final id = normalizeId(value);
    final items = dropdownCategories(source: source);
    final matches = items.where((c) => c.id == id).length;
    if (matches == 1) return id;
    return null;
  }
}
