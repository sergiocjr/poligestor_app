/// Modelos da Central de Comunicação — PoliGestor/MandatoOS apenas.
/// Parsing defensivo dos contratos LIVE `/v1/channels|templates|campaigns`.
library;

class CommChannel {
  const CommChannel({
    required this.id,
    required this.name,
    this.type,
    this.provider,
    this.isActive = true,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String? type;
  final String? provider;
  final bool isActive;
  final bool isDefault;

  factory CommChannel.fromJson(Map<String, dynamic> json) {
    return CommChannel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['label'] ?? 'Canal').toString(),
      type: (json['type'] ?? json['channel_type'])?.toString(),
      provider: json['provider']?.toString(),
      isActive: _asBool(json['is_active'] ?? json['enabled'] ?? true),
      isDefault: _asBool(json['is_default']),
    );
  }

  String get typeLabel => switch ((type ?? '').toLowerCase()) {
    'email' || 'e-mail' => 'E-mail',
    'sms' => 'SMS',
    'whatsapp' || 'wa' => 'WhatsApp',
    'push' => 'Push',
    'voice' || 'voz' => 'Voz',
    '' => '—',
    _ => type!,
  };
}

class CommTemplate {
  const CommTemplate({
    required this.id,
    required this.name,
    this.slug,
    this.subject,
    this.body,
    this.channelType,
    this.isActive = true,
    this.variables = const [],
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? slug;
  final String? subject;
  final String? body;
  final String? channelType;
  final bool isActive;
  final List<String> variables;
  final DateTime? updatedAt;

  factory CommTemplate.fromJson(Map<String, dynamic> json) {
    final varsRaw = json['variables'];
    final vars = <String>[];
    if (varsRaw is List) {
      for (final v in varsRaw) {
        if (v == null) continue;
        if (v is String) {
          vars.add(v);
        } else if (v is Map) {
          final n = (v['name'] ?? v['key'] ?? v['slug'])?.toString();
          if (n != null && n.isNotEmpty) vars.add(n);
        } else {
          vars.add(v.toString());
        }
      }
    }
    final updated = json['updated_at'] ?? json['updatedAt'];
    return CommTemplate(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? 'Template').toString(),
      slug: json['slug']?.toString(),
      subject: json['subject']?.toString(),
      body: json['body']?.toString(),
      channelType: (json['channel_type'] ?? json['type'])?.toString(),
      isActive: _asBool(json['is_active'] ?? json['active'] ?? true),
      variables: vars,
      updatedAt: updated == null ? null : DateTime.tryParse(updated.toString()),
    );
  }

  String get channelLabel => switch ((channelType ?? '').toLowerCase()) {
    'email' || 'e-mail' => 'E-mail',
    'sms' => 'SMS',
    'whatsapp' || 'wa' => 'WhatsApp',
    'push' => 'Push',
    '' => '—',
    _ => channelType!,
  };
}

class CommCampaign {
  const CommCampaign({
    required this.id,
    required this.name,
    this.status,
    this.channelId,
    this.channelType,
    this.templateId,
    this.subject,
    this.body,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.sentCount = 0,
    this.failedCount = 0,
    this.totalRecipients = 0,
    this.segment,
  });

  final String id;
  final String name;
  final String? status;
  final String? channelId;
  final String? channelType;
  final String? templateId;
  final String? subject;
  final String? body;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int sentCount;
  final int failedCount;
  final int totalRecipients;
  final String? segment;

  factory CommCampaign.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    final seg = json['segment'];
    String? segLabel;
    if (seg is Map) {
      segLabel = (seg['name'] ?? seg['label'] ?? seg['slug'])?.toString();
    } else if (seg != null) {
      segLabel = seg.toString();
    }
    return CommCampaign(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? 'Campanha').toString(),
      status: json['status']?.toString(),
      channelId: json['channel_id']?.toString(),
      channelType:
          (json['channel_type'] ??
                  (json['channel'] is Map ? json['channel']['type'] : null))
              ?.toString(),
      templateId: json['template_id']?.toString(),
      subject: json['subject']?.toString(),
      body: json['body']?.toString(),
      scheduledAt: parseDt(json['scheduled_at']),
      startedAt: parseDt(json['started_at']),
      completedAt: parseDt(json['completed_at']),
      sentCount: _asInt(json['sent_count']),
      failedCount: _asInt(json['failed_count']),
      totalRecipients: _asInt(json['total_recipients']),
      segment: segLabel,
    );
  }

  String get statusLabel => switch ((status ?? '').toLowerCase()) {
    'draft' || 'rascunho' => 'Rascunho',
    'scheduled' || 'agendada' || 'agendado' => 'Agendada',
    'running' || 'executing' || 'in_progress' || 'enviando' => 'Em execução',
    'completed' || 'done' || 'concluida' || 'concluída' => 'Concluída',
    'failed' || 'error' || 'falha' => 'Falha',
    'cancelled' || 'canceled' || 'cancelada' => 'Cancelada',
    'paused' || 'pausada' => 'Pausada',
    '' => '—',
    _ => status!,
  };

  double get progress {
    if (totalRecipients <= 0) return 0;
    return (sentCount / totalRecipients).clamp(0, 1);
  }
}

class CommConversation {
  const CommConversation({
    required this.id,
    required this.title,
    this.status,
    this.channelType,
    this.contactName,
    this.assignedTo,
    this.updatedAt,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final String? status;
  final String? channelType;
  final String? contactName;
  final String? assignedTo;
  final DateTime? updatedAt;
  final int unreadCount;

  factory CommConversation.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    final contact = json['contact'] ?? json['citizen'] ?? json['customer'];
    String? contactName;
    if (contact is Map) {
      contactName =
          (contact['name'] ?? contact['display_name'] ?? contact['email'])
              ?.toString();
    } else if (contact != null) {
      contactName = contact.toString();
    }
    final assigned =
        json['assigned_to'] ?? json['operator'] ?? json['assignee'];
    String? assignedTo;
    if (assigned is Map) {
      assignedTo = (assigned['name'] ?? assigned['email'])?.toString();
    } else if (assigned != null) {
      assignedTo = assigned.toString();
    }
    return CommConversation(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      title:
          (json['title'] ??
                  json['subject'] ??
                  json['preview'] ??
                  contactName ??
                  'Conversa')
              .toString(),
      status: json['status']?.toString(),
      channelType: () {
        final ch = json['channel'];
        if (ch is Map) {
          return (ch['type'] ?? ch['channel_type'])?.toString();
        }
        return (json['channel_type'] ?? json['channel'])?.toString();
      }(),
      contactName: contactName ?? json['contact_name']?.toString(),
      assignedTo: assignedTo,
      updatedAt: parseDt(
        json['updated_at'] ?? json['last_message_at'] ?? json['created_at'],
      ),
      unreadCount: _asInt(json['unread_count'] ?? json['unread']),
    );
  }

  String get statusLabel => switch ((status ?? '').toLowerCase()) {
    'open' || 'opened' || 'aberta' || 'aberto' => 'Aberta',
    'queued' || 'queue' || 'na_fila' || 'waiting' => 'Na fila',
    'assigned' || 'atribuida' || 'atribuída' => 'Atribuída',
    'closed' || 'resolved' || 'fechada' || 'resolvida' => 'Fechada',
    'pending' || 'pendente' => 'Pendente',
    '' => '—',
    _ => status!,
  };
}

class CommQueueSnapshot {
  const CommQueueSnapshot({
    this.queue = 0,
    this.assigned = 0,
    this.closed = 0,
    this.operators = 0,
  });

  final int queue;
  final int assigned;
  final int closed;
  final int operators;

  factory CommQueueSnapshot.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final src = nested is Map ? Map<String, dynamic>.from(nested) : json;
    return CommQueueSnapshot(
      queue: _asInt(src['queue'] ?? src['waiting'] ?? src['pending']),
      assigned: _asInt(src['assigned'] ?? src['in_progress']),
      closed: _asInt(src['closed'] ?? src['resolved']),
      operators: _asInt(src['operators'] ?? src['operators_online']),
    );
  }
}

class CommOperator {
  const CommOperator({
    required this.id,
    required this.name,
    this.email,
    this.status,
    this.activeConversations = 0,
    this.lastSeenAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? status;
  final int activeConversations;
  final DateTime? lastSeenAt;

  factory CommOperator.fromJson(Map<String, dynamic> json) {
    return CommOperator(
      id: (json['id'] ?? json['user_id'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['display_name'] ?? 'Operador').toString(),
      email: json['email']?.toString(),
      status: json['status']?.toString(),
      activeConversations: _asInt(
        json['active_conversations'] ?? json['active'],
      ),
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.tryParse(json['last_seen_at'].toString()),
    );
  }

  String get statusLabel => switch ((status ?? '').toLowerCase()) {
    'online' || 'disponivel' || 'disponível' => 'Conectado',
    'offline' => 'Desconectado',
    'busy' || 'ocupado' || 'away' => 'Ocupado',
    '' => '—',
    _ => status!,
  };

  bool get isOnline => (status ?? '').toLowerCase() == 'online';
}

List<dynamic> _asList(dynamic raw) {
  if (raw is List) return raw;
  if (raw is Map) {
    for (final key in ['data', 'items', 'results']) {
      final v = raw[key];
      if (v is List) return v;
    }
  }
  return const [];
}

List<Map<String, dynamic>> asMapList(dynamic raw) {
  return _asList(
    raw,
  ).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  final s = v?.toString().toLowerCase().trim();
  return s == '1' || s == 'true' || s == 'yes' || s == 'sim';
}

int _asInt(dynamic v) {
  if (v is int) return v;
  return int.tryParse(v?.toString() ?? '') ?? 0;
}
