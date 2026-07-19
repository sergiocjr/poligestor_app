/// Models do protocolo / solicitação (portal e staff).
/// Parsing defensivo: aceita aliases PT/EN sem inventar campos obrigatórios.
library;

class ProtocolSummary {
  ProtocolSummary({
    required this.id,
    required this.title,
    this.number,
    this.status,
    this.statusLabel,
    this.priority,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.unreadCount = 0,
    this.hasUnread = false,
    this.lastMessagePreview,
    this.awaitingCitizen = false,
  });

  final dynamic id;
  final String title;
  final String? number;
  final String? status;

  /// Rótulo humano vindo da API (`status_label`) — preferir na UI.
  final String? statusLabel;
  final String? priority;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? description;
  final int unreadCount;
  final bool hasUnread;
  final String? lastMessagePreview;
  final bool awaitingCitizen;

  String get displayStatus =>
      ProtocolStatusLabel.display(status: status, statusLabel: statusLabel);

  factory ProtocolSummary.fromJson(Map<String, dynamic> json) {
    final title =
        (json['subject'] ??
                json['title'] ??
                json['titulo'] ??
                json['assunto'] ??
                json['descricao'] ??
                'Solicitação')
            .toString();
    final unread = _asInt(
      json['unread_count'] ??
          json['mensagens_nao_lidas'] ??
          json['unread_messages'] ??
          json['new_messages'],
    );
    final awaiting =
        _asBool(
          json['awaiting_citizen'] ??
              json['aguardando_cidadao'] ??
              json['needs_citizen_reply'] ??
              json['aguardando_informacao'],
        ) ||
        _statusIsAwaitingCitizen(json['status']?.toString());
    final preview =
        (json['last_message_preview'] ??
                json['ultima_resposta'] ??
                json['last_public_message'] ??
                json['preview'])
            ?.toString();
    final updatedRaw =
        json['updated_at'] ??
        json['updatedAt'] ??
        json['last_updated_at'] ??
        json['ultima_atualizacao'] ??
        json['last_update'];
    final createdRaw = json['created_at'] ?? json['createdAt'] ?? json['data'];

    return ProtocolSummary(
      id: json['id'] ?? json['uuid'] ?? json['protocol_id'] ?? '',
      title: title,
      number:
          (json['number'] ??
                  json['numero'] ??
                  json['code'] ??
                  json['protocolo'])
              ?.toString(),
      status: (json['status'] ?? json['situacao'])?.toString(),
      statusLabel: () {
        final raw =
            (json['status_label'] ??
                    json['situacao_label'] ??
                    json['statusLabel'])
                ?.toString()
                .trim();
        return (raw == null || raw.isEmpty || raw == 'null') ? null : raw;
      }(),
      priority: (json['priority'] ?? json['prioridade'])?.toString(),
      category: _categoryLabel(json['category'] ?? json['categoria']),
      description: (json['description'] ?? json['descricao'])?.toString(),
      createdAt: createdRaw != null
          ? DateTime.tryParse(createdRaw.toString())
          : null,
      updatedAt: updatedRaw != null
          ? DateTime.tryParse(updatedRaw.toString())
          : null,
      unreadCount: unread,
      hasUnread:
          unread > 0 ||
          _asBool(
            json['has_unread'] ??
                json['tem_nao_lidas'] ??
                json['has_new_message'],
          ),
      lastMessagePreview: preview != null && preview.trim().isNotEmpty
          ? preview.trim()
          : null,
      awaitingCitizen: awaiting,
    );
  }

  bool get isOpen =>
      status == 'open' ||
      status == 'aberto' ||
      status == 'novo' ||
      status == 'new' ||
      status == 'waiting' ||
      status == 'recebido' ||
      status == 'received' ||
      status == 'em_analise';
  bool get isInProgress =>
      status == 'in_progress' ||
      status == 'andamento' ||
      status == 'em_andamento' ||
      status == 'em_execucao' ||
      status == 'em_execução' ||
      status == 'encaminhado' ||
      status == 'respondida';
  bool get isResolved =>
      status == 'resolved' ||
      status == 'closed' ||
      status == 'resolvido' ||
      status == 'concluido' ||
      status == 'concluído' ||
      status == 'arquivado' ||
      status == 'archived';
  bool get isAwaitingCitizen =>
      awaitingCitizen || _statusIsAwaitingCitizen(status);

  bool get showUnreadBadge => hasUnread || unreadCount > 0;
}

class ProtocolMessage {
  ProtocolMessage({
    required this.id,
    required this.body,
    this.createdAt,
    this.authorName,
    this.isFromCabinet = false,
    this.isUnread = false,
    this.isInternal = false,
    this.attachments = const [],
  });

  final dynamic id;
  final String body;
  final DateTime? createdAt;
  final String? authorName;
  final bool isFromCabinet;
  final bool isUnread;
  final bool isInternal;
  final List<ProtocolAttachment> attachments;

  /// Compatível com usos antigos de [ProtocolComment].
  String get content => body;

  factory ProtocolMessage.fromJson(Map<String, dynamic> json) {
    final author = json['user'] ?? json['author'] ?? json['creator'];
    String? name;
    String? role;
    if (author is Map) {
      name = (author['name'] ?? author['nome'])?.toString();
      role = (author['role'] ?? author['tipo'] ?? author['type'])?.toString();
    } else if (author is String && author.trim().isNotEmpty) {
      name = author.trim();
      // Contrato portal: author "you" = cidadão.
      if (name.toLowerCase() == 'you' || name.toLowerCase() == 'voce') {
        role = 'citizen';
        name = 'Você';
      }
    }
    name ??=
        (json['author_name'] ??
                json['remetente'] ??
                json['sender_name'] ??
                json['from'])
            ?.toString();
    role ??= (json['author_role'] ?? json['role'] ?? json['sender_role'])
        ?.toString();

    final visibility = (json['visibility'] ?? json['visibilidade'] ?? 'public')
        .toString();
    final isInternal =
        _asBool(json['is_internal'] ?? json['internal']) ||
        visibility.toLowerCase() == 'internal' ||
        visibility.toLowerCase() == 'interna';

    final fromCabinet =
        _asBool(
          json['is_from_cabinet'] ??
              json['from_cabinet'] ??
              json['is_staff'] ??
              json['from_gabinete'],
        ) ||
        _roleIsCabinet(role) ||
        (name != null && name.toLowerCase().contains('gabinete'));

    final createdRaw =
        json['created_at'] ?? json['createdAt'] ?? json['sent_at'];
    final attachmentsRaw = json['attachments'] ?? json['anexos'] ?? const [];
    final bodyText =
        (json['body'] ??
                json['content'] ??
                json['message'] ??
                json['texto'] ??
                '')
            .toString();

    return ProtocolMessage(
      id: json['id'] ?? json['uuid'] ?? createdRaw ?? bodyText.hashCode,
      body: bodyText,
      authorName: name,
      createdAt: createdRaw != null
          ? DateTime.tryParse(createdRaw.toString())
          : null,
      isFromCabinet: fromCabinet,
      isUnread: _asBool(json['is_unread'] ?? json['unread'] ?? json['nova']),
      isInternal: isInternal,
      attachments: (attachmentsRaw is List)
          ? attachmentsRaw
                .whereType<Map>()
                .map(
                  (e) =>
                      ProtocolAttachment.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }
}

/// Alias legado.
typedef ProtocolComment = ProtocolMessage;

class ProtocolAttachment {
  ProtocolAttachment({required this.id, this.name, this.url, this.mimeType});

  final dynamic id;
  final String? name;
  final String? url;
  final String? mimeType;

  bool get isImage {
    final m = (mimeType ?? '').toLowerCase();
    final n = (name ?? '').toLowerCase();
    return m.startsWith('image/') ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png') ||
        n.endsWith('.webp') ||
        n.endsWith('.gif');
  }

  bool get isPdf {
    final m = (mimeType ?? '').toLowerCase();
    final n = (name ?? '').toLowerCase();
    return m == 'application/pdf' || n.endsWith('.pdf');
  }

  bool get isAudio {
    final m = (mimeType ?? '').toLowerCase();
    final n = (name ?? '').toLowerCase();
    return m.startsWith('audio/') ||
        n.endsWith('.mp3') ||
        n.endsWith('.m4a') ||
        n.endsWith('.wav') ||
        n.endsWith('.aac') ||
        n.endsWith('.ogg');
  }

  bool get isVideo {
    final m = (mimeType ?? '').toLowerCase();
    final n = (name ?? '').toLowerCase();
    return m.startsWith('video/') ||
        n.endsWith('.mp4') ||
        n.endsWith('.mov') ||
        n.endsWith('.webm') ||
        n.endsWith('.mkv');
  }

  String get kindLabel {
    if (isImage) return 'Imagem';
    if (isPdf) return 'PDF';
    if (isAudio) return 'Áudio';
    if (isVideo) return 'Vídeo';
    return 'Documento';
  }

  factory ProtocolAttachment.fromJson(Map<String, dynamic> json) {
    return ProtocolAttachment(
      id: json['id'] ?? json['uuid'] ?? json['name'],
      name: (json['name'] ?? json['filename'] ?? json['original_name'])
          ?.toString(),
      url:
          (json['url'] ??
                  json['path'] ??
                  json['download_url'] ??
                  json['signed_url'])
              ?.toString(),
      mimeType: (json['mime_type'] ?? json['content_type'])?.toString(),
    );
  }
}

class ProtocolHistoryEvent {
  ProtocolHistoryEvent({
    required this.id,
    required this.title,
    this.description,
    this.createdAt,
    this.kind,
  });

  final dynamic id;
  final String title;
  final String? description;
  final DateTime? createdAt;
  final String? kind;

  factory ProtocolHistoryEvent.fromJson(Map<String, dynamic> json) {
    final createdRaw =
        json['created_at'] ?? json['createdAt'] ?? json['occurred_at'];
    final kind =
        (json['kind'] ??
                json['type'] ??
                json['event'] ??
                json['status'] ??
                json['codigo'])
            ?.toString();
    final title =
        (json['title'] ??
                json['titulo'] ??
                json['label'] ??
                ProtocolHistoryLabels.titleFor(kind) ??
                'Atualização')
            .toString();
    return ProtocolHistoryEvent(
      id: json['id'] ?? json['uuid'] ?? createdRaw ?? title.hashCode,
      title: title,
      description:
          (json['description'] ??
                  json['descricao'] ??
                  json['body'] ??
                  json['message'])
              ?.toString(),
      createdAt: createdRaw != null
          ? DateTime.tryParse(createdRaw.toString())
          : null,
      kind: kind,
    );
  }

  bool get isInternal {
    final k = (kind ?? '').toLowerCase();
    return k.contains('internal') ||
        k.contains('interna') ||
        k.contains('nota');
  }
}

class ProtocolRating {
  ProtocolRating({required this.stars, this.resolved, this.comment});

  final int stars;
  final bool? resolved;
  final String? comment;

  factory ProtocolRating.fromJson(Map<String, dynamic> json) {
    final stars = _asInt(
      json['stars'] ?? json['rating'] ?? json['score'] ?? json['nota'],
    );
    return ProtocolRating(
      stars: stars.clamp(1, 5),
      resolved: _asBoolOrNull(
        json['resolved'] ?? json['problema_resolvido'] ?? json['was_resolved'],
      ),
      comment: (json['comment'] ?? json['comentario'] ?? json['feedback'])
          ?.toString(),
    );
  }
}

class ProtocolDetail extends ProtocolSummary {
  ProtocolDetail({
    required super.id,
    required super.title,
    super.number,
    super.status,
    super.statusLabel,
    super.priority,
    super.category,
    super.createdAt,
    super.updatedAt,
    super.description,
    super.unreadCount,
    super.hasUnread,
    super.lastMessagePreview,
    super.awaitingCitizen,
    this.address,
    this.publicAssignee,
    this.deadlineAt,
    this.deadlineLabel,
    this.isOverdue = false,
    this.messages = const [],
    this.history = const [],
    this.attachments = const [],
    this.pendingQuestion,
    this.canRate = false,
    this.canEditRating = false,
    this.rating,
    this.markReadUrl,
    this.rateUrl,
    this.raw,
  });

  final String? address;
  final String? publicAssignee;
  final DateTime? deadlineAt;
  final String? deadlineLabel;
  final bool isOverdue;
  final List<ProtocolMessage> messages;
  final List<ProtocolHistoryEvent> history;
  final List<ProtocolAttachment> attachments;
  final String? pendingQuestion;
  final bool canRate;
  final bool canEditRating;
  final ProtocolRating? rating;
  final String? markReadUrl;
  final String? rateUrl;
  final Map<String, dynamic>? raw;

  /// Compat: comentários = mensagens públicas.
  List<ProtocolMessage> get comments => messages;

  factory ProtocolDetail.fromJson(Map<String, dynamic> json) {
    final base = ProtocolSummary.fromJson(json);

    final messagesRaw =
        json['messages'] ??
        json['conversation'] ??
        json['public_messages'] ??
        json['comments'] ??
        const [];
    final historyRaw =
        json['history'] ??
        json['historico'] ??
        json['events'] ??
        json['status_history'] ??
        json['timeline'] ??
        const [];

    final attachmentsRaw = json['attachments'] ?? json['anexos'] ?? const [];

    final messages =
        _parseMessages(messagesRaw).where((m) => !m.isInternal).toList()
          ..sort((a, b) {
            final aAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aAt.compareTo(bAt);
          });

    var history = _parseHistory(historyRaw).where((e) => !e.isInternal).toList()
      ..sort((a, b) {
        final aAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aAt.compareTo(bAt);
      });
    // API atual: timeline = histórico; comments = conversa.
    // Se só comments existirem e timeline vazia, não inventar histórico.
    if (json['timeline'] == null &&
        json['history'] == null &&
        json['historico'] == null &&
        json['events'] == null &&
        json['status_history'] == null) {
      history = const [];
    }
    if (json['timeline'] != null && history.isEmpty) {
      history =
          _parseHistory(json['timeline']).where((e) => !e.isInternal).toList()
            ..sort((a, b) {
              final aAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return aAt.compareTo(bAt);
            });
    }

    final links = json['links'] ?? json['_links'] ?? json['actions'];
    String? markReadUrl;
    String? rateUrl;
    if (links is Map) {
      markReadUrl =
          (links['mark_read'] ??
                  links['read'] ??
                  links['messages_read'] ??
                  links['marcar_lida'])
              ?.toString();
      rateUrl =
          (links['rate'] ??
                  links['rating'] ??
                  links['avaliacao'] ??
                  links['evaluate'])
              ?.toString();
    }
    markReadUrl ??= (json['mark_read_url'] ?? json['read_url'])?.toString();
    rateUrl ??=
        (json['rate_url'] ?? json['rating_url'] ?? json['avaliacao_url'])
            ?.toString();

    final ratingRaw = json['rating'] ?? json['avaliacao'] ?? json['evaluation'];
    ProtocolRating? rating;
    if (ratingRaw is Map) {
      rating = ProtocolRating.fromJson(Map<String, dynamic>.from(ratingRaw));
    } else if (ratingRaw != null) {
      final stars = _asInt(ratingRaw);
      if (stars > 0) {
        rating = ProtocolRating(
          stars: stars.clamp(1, 5),
          resolved: _asBoolOrNull(json['rating_resolved']),
          comment: (json['rating_comment'] ?? json['comentario_avaliacao'])
              ?.toString(),
        );
      }
    }

    // links.rate pode vir null explicitamente.
    if (rateUrl == 'null' || rateUrl == 'NULL') rateUrl = null;
    if (markReadUrl == 'null' || markReadUrl == 'NULL') markReadUrl = null;

    final canRate =
        _asBool(
          json['can_rate'] ??
              json['can_evaluate'] ??
              json['avaliacao_disponivel'] ??
              json['permite_avaliacao'],
        ) ||
        (rateUrl != null && rateUrl.isNotEmpty && rating == null);

    final canEdit = _asBool(
      json['can_edit_rating'] ??
          json['permite_editar_avaliacao'] ??
          json['rating_editable'],
    );

    final deadlineRaw =
        json['deadline_at'] ??
        json['due_at'] ??
        json['prazo_em'] ??
        json['sla_due_at'];
    final deadlineLabel =
        (json['deadline_label'] ??
                json['prazo'] ??
                json['prazo_texto'] ??
                json['sla_label'])
            ?.toString();
    final overdue =
        _asBool(
          json['is_overdue'] ??
              json['atrasado'] ??
              json['breached'] ??
              json['sla_breached'],
        ) ||
        (deadlineLabel?.toLowerCase().contains('atras') ?? false);

    final pending =
        (json['pending_question'] ??
                json['pergunta_pendente'] ??
                json['info_request'] ??
                json['pedido_informacao'])
            ?.toString();

    final address =
        (json['address'] ??
                json['endereco'] ??
                json['location_label'] ??
                (json['metadata'] is Map
                    ? (json['metadata']['location_label'] ??
                          json['metadata']['address'] ??
                          json['metadata']['endereco'])
                    : null))
            ?.toString();

    final assigneeRaw =
        json['assignee_public'] ??
        json['responsavel_publico'] ??
        json['setor_publico'] ??
        json['public_assignee'] ??
        json['assigned_to_public'];
    String? assignee;
    if (assigneeRaw is Map) {
      assignee =
          (assigneeRaw['name'] ??
                  assigneeRaw['nome'] ??
                  assigneeRaw['setor'] ??
                  assigneeRaw['department'])
              ?.toString();
    } else if (assigneeRaw != null) {
      assignee = assigneeRaw.toString();
    }
    // Só exibe se marcado como público.
    final assigneeIsPublic =
        json.containsKey('assignee_public') ||
        json.containsKey('responsavel_publico') ||
        json.containsKey('setor_publico') ||
        json.containsKey('public_assignee') ||
        _asBool(json['show_assignee'] ?? json['exibir_responsavel']);
    if (!assigneeIsPublic) assignee = null;

    return ProtocolDetail(
      id: base.id,
      title: base.title,
      number: base.number,
      status: base.status,
      statusLabel: base.statusLabel,
      priority: base.priority,
      category: base.category,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      description: base.description,
      unreadCount: base.unreadCount,
      hasUnread: base.hasUnread || messages.any((m) => m.isUnread),
      lastMessagePreview: base.lastMessagePreview,
      awaitingCitizen:
          base.awaitingCitizen ||
          (pending != null && pending.trim().isNotEmpty),
      address: address != null && address.trim().isNotEmpty ? address : null,
      publicAssignee: assignee,
      deadlineAt: deadlineRaw != null
          ? DateTime.tryParse(deadlineRaw.toString())
          : null,
      deadlineLabel: deadlineLabel,
      isOverdue: overdue,
      messages: messages,
      history: history,
      attachments: _parseAttachments(attachmentsRaw),
      pendingQuestion: pending != null && pending.trim().isNotEmpty
          ? pending.trim()
          : null,
      canRate: canRate,
      canEditRating: canEdit,
      rating: rating,
      markReadUrl: markReadUrl,
      rateUrl: rateUrl,
      raw: json,
    );
  }

  static List<ProtocolMessage> _parseMessages(dynamic raw) {
    if (raw is! List) return const [];
    final out = <ProtocolMessage>[];
    for (final e in raw) {
      if (e is! Map) continue;
      try {
        final m = ProtocolMessage.fromJson(Map<String, dynamic>.from(e));
        if (m.body.trim().isNotEmpty || m.attachments.isNotEmpty) {
          out.add(m);
        }
      } catch (_) {
        // Item opcional inválido não derruba o detalhe.
      }
    }
    return out;
  }

  static List<ProtocolHistoryEvent> _parseHistory(dynamic raw) {
    if (raw is! List) return const [];
    final out = <ProtocolHistoryEvent>[];
    for (final e in raw) {
      if (e is! Map) continue;
      try {
        out.add(ProtocolHistoryEvent.fromJson(Map<String, dynamic>.from(e)));
      } catch (_) {
        // Item opcional inválido não derruba o detalhe.
      }
    }
    return out;
  }

  static List<ProtocolAttachment> _parseAttachments(dynamic raw) {
    if (raw is! List) return const [];
    final out = <ProtocolAttachment>[];
    for (final e in raw) {
      if (e is! Map) continue;
      try {
        out.add(ProtocolAttachment.fromJson(Map<String, dynamic>.from(e)));
      } catch (_) {}
    }
    return out;
  }
}

class ProtocolStatusLabel {
  /// Prefere `status_label` da API; cai no mapa PT do código.
  static String display({String? status, String? statusLabel}) {
    final label = statusLabel?.trim();
    if (label != null && label.isNotEmpty && label.toLowerCase() != 'null') {
      return label;
    }
    return pt(status);
  }

  static String pt(String? status) {
    return switch ((status ?? '').toLowerCase().trim()) {
      'new' || 'novo' => 'Novo',
      'open' || 'aberto' || 'recebido' || 'received' => 'Recebida',
      'em_analise' ||
      'em análise' ||
      'under_review' ||
      'analise' => 'Em análise',
      'encaminhado' ||
      'encaminhada' ||
      'forwarded' ||
      'assigned' => 'Encaminhada',
      'in_progress' ||
      'andamento' ||
      'em_andamento' ||
      'em_execucao' ||
      'em_execução' ||
      'executing' => 'Em execução',
      'aguardando_cidadao' ||
      'aguardando cidadão' ||
      'aguardando_informacao' ||
      'waiting_citizen' ||
      'info_requested' => 'Aguardando cidadão',
      'respondida' || 'answered' || 'replied' => 'Respondida',
      'waiting' || 'aguardando' => 'Aguardando',
      'resolved' || 'resolvido' || 'encerrado' => 'Resolvido',
      'closed' || 'fechado' || 'concluido' || 'concluído' => 'Concluído',
      'arquivado' || 'archived' => 'Arquivado',
      '' => '—',
      _ => status!,
    };
  }
}

class ProtocolPriorityLabel {
  static String pt(String? priority) {
    return switch ((priority ?? '').toLowerCase().trim()) {
      'low' || 'baixa' => 'Baixa',
      'medium' || 'media' || 'média' || 'normal' => 'Normal',
      'high' || 'alta' => 'Alta',
      'urgent' || 'urgente' => 'Urgente',
      '' => '—',
      _ => priority!,
    };
  }
}

class ProtocolHistoryLabels {
  static String? titleFor(String? kind) {
    return switch ((kind ?? '').toLowerCase().trim()) {
      'received' ||
      'recebido' ||
      'recebida' ||
      'created' ||
      'aberta' => 'Solicitação recebida',
      'under_review' || 'em_analise' || 'analise' => 'Em análise',
      'forwarded' ||
      'encaminhada' ||
      'encaminhado' ||
      'assigned' => 'Encaminhada',
      'in_progress' ||
      'em_andamento' ||
      'andamento' ||
      'em_execucao' ||
      'em_execução' => 'Em execução',
      'awaiting_citizen' ||
      'aguardando_cidadao' ||
      'aguardando_informacao' ||
      'info_requested' => 'Aguardando cidadão',
      'answered' || 'respondida' || 'replied' => 'Respondida',
      'resolved' ||
      'resolvida' ||
      'resolvido' ||
      'closed' ||
      'concluido' => 'Resolvido',
      'arquivado' || 'archived' => 'Arquivado',
      'new' || 'novo' => 'Novo',
      _ => null,
    };
  }

  static IconDataForHistory iconFor(String? kind) {
    return switch ((kind ?? '').toLowerCase().trim()) {
      'received' ||
      'recebido' ||
      'recebida' ||
      'created' ||
      'aberta' ||
      'new' ||
      'novo' => IconDataForHistory.inbox,
      'under_review' || 'em_analise' || 'analise' => IconDataForHistory.search,
      'forwarded' ||
      'encaminhada' ||
      'encaminhado' ||
      'assigned' => IconDataForHistory.forward,
      'in_progress' ||
      'em_andamento' ||
      'andamento' ||
      'em_execucao' ||
      'em_execução' => IconDataForHistory.progress,
      'awaiting_citizen' ||
      'aguardando_cidadao' ||
      'aguardando_informacao' ||
      'info_requested' => IconDataForHistory.help,
      'answered' || 'respondida' || 'replied' => IconDataForHistory.reply,
      'resolved' ||
      'resolvida' ||
      'resolvido' ||
      'closed' ||
      'arquivado' ||
      'archived' => IconDataForHistory.done,
      _ => IconDataForHistory.dot,
    };
  }
}

/// Evita importar Flutter em models; a UI mapeia para IconData.
enum IconDataForHistory {
  inbox,
  search,
  forward,
  progress,
  help,
  reply,
  done,
  dot,
}

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
      'in_progress' ||
      'andamento' ||
      'em_andamento' => RequestStatusFilter.inProgress,
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
            s == 'novo' ||
            s == 'new' ||
            s == 'recebido' ||
            s == 'received' ||
            s == 'em_analise' ||
            s == 'em análise' ||
            s == 'waiting' ||
            s == 'aguardando',
      RequestStatusFilter.inProgress =>
        s == 'in_progress' ||
            s == 'andamento' ||
            s == 'em_andamento' ||
            s == 'em_execucao' ||
            s == 'em_execução' ||
            s == 'encaminhado' ||
            s == 'aguardando_cidadao' ||
            s == 'aguardando cidadão' ||
            s == 'aguardando_informacao' ||
            s == 'respondida' ||
            protocol.awaitingCitizen,
      RequestStatusFilter.resolved =>
        s == 'resolved' ||
            s == 'resolvido' ||
            s == 'encerrado' ||
            s == 'closed' ||
            s == 'fechado' ||
            s == 'concluido' ||
            s == 'concluído' ||
            s == 'arquivado' ||
            s == 'archived',
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

  static List<RequestCategory> dropdownCategories({
    Iterable<RequestCategory>? source,
  }) {
    final list = uniqueById(
      source ?? formOptions,
    ).where((c) => c.id != 'acompanhar' && c.id != 'assistente').toList();
    return list;
  }

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

bool _statusIsAwaitingCitizen(String? status) {
  final s = (status ?? '').toLowerCase().trim();
  return s == 'aguardando_cidadao' ||
      s == 'aguardando cidadão' ||
      s == 'aguardando_informacao' ||
      s == 'waiting_citizen' ||
      s == 'info_requested';
}

bool _roleIsCabinet(String? role) {
  final r = (role ?? '').toLowerCase().trim();
  return r == 'staff' ||
      r == 'operator' ||
      r == 'operador' ||
      r == 'gabinete' ||
      r == 'cabinet' ||
      r == 'admin' ||
      r == 'agent';
}

String? _categoryLabel(dynamic raw) {
  if (raw == null) return null;
  if (raw is String) {
    final t = raw.trim();
    return t.isEmpty ? null : t;
  }
  if (raw is Map) {
    final name = (raw['name'] ?? raw['nome'] ?? raw['label'] ?? raw['slug'])
        ?.toString()
        .trim();
    if (name != null && name.isNotEmpty) return name;
  }
  return null;
}

int _asInt(dynamic v) {
  if (v is int) return v;
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  final s = v?.toString().toLowerCase().trim();
  return s == '1' || s == 'true' || s == 'yes' || s == 'sim';
}

bool? _asBoolOrNull(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase().trim();
  if (s == '1' || s == 'true' || s == 'yes' || s == 'sim') return true;
  if (s == '0' || s == 'false' || s == 'no' || s == 'nao' || s == 'não') {
    return false;
  }
  return null;
}
