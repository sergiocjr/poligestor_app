import '../../agenda/data/appointments_repository.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../protocols/data/protocol_models.dart';

class PortalHomeUser {
  PortalHomeUser({
    required this.id,
    required this.nome,
    this.foto,
    this.bairro,
    this.cidade,
  });

  final dynamic id;
  final String nome;
  final String? foto;
  final String? bairro;
  final String? cidade;

  String get firstName {
    final parts = nome.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? 'Cidadão' : parts.first;
  }

  String get neighborhoodLabel {
    if (bairro != null && bairro!.isNotEmpty) {
      if (cidade != null && cidade!.isNotEmpty) return '$bairro · $cidade';
      return bairro!;
    }
    if (cidade != null && cidade!.isNotEmpty) return cidade!;
    return 'Meu bairro';
  }

  factory PortalHomeUser.fromJson(Map<String, dynamic> json) {
    return PortalHomeUser(
      id: json['id'],
      nome: (json['nome'] ?? json['name'] ?? 'Cidadão').toString(),
      foto: json['foto']?.toString() ?? json['photo']?.toString(),
      bairro: json['bairro']?.toString() ?? json['district']?.toString(),
      cidade: json['cidade']?.toString() ?? json['city']?.toString(),
    );
  }
}

class PortalHomeSummary {
  PortalHomeSummary({
    required this.protocolosAbertos,
    required this.protocolosAndamento,
    required this.protocolosResolvidos,
    required this.notificacoesNaoLidas,
    required this.proximosCompromissos,
    this.mensagensNaoLidas = 0,
    this.aguardandoResposta = 0,
  });

  final int protocolosAbertos;
  final int protocolosAndamento;
  final int protocolosResolvidos;
  final int notificacoesNaoLidas;
  final int proximosCompromissos;
  final int mensagensNaoLidas;
  final int aguardandoResposta;

  factory PortalHomeSummary.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return PortalHomeSummary(
      protocolosAbertos: asInt(json['protocolos_abertos']),
      protocolosAndamento: asInt(json['protocolos_andamento']),
      protocolosResolvidos: asInt(json['protocolos_resolvidos']),
      notificacoesNaoLidas: asInt(json['notificacoes_nao_lidas']),
      proximosCompromissos: asInt(json['proximos_compromissos']),
      mensagensNaoLidas: asInt(
        json['mensagens_nao_lidas'] ??
            json['unread_messages'] ??
            json['protocol_unread_messages'],
      ),
      aguardandoResposta: asInt(
        json['aguardando_resposta'] ??
            json['aguardando_cidadao'] ??
            json['awaiting_citizen'] ??
            json['needs_citizen_reply'],
      ),
    );
  }
}

class PortalQuickAction {
  PortalQuickAction({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String key;
  final String title;
  final String description;
  final String icon;

  factory PortalQuickAction.fromJson(Map<String, dynamic> json) {
    return PortalQuickAction(
      key: (json['key'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['label'] ?? '').toString(),
      description: (json['description'] ?? json['subtitle'] ?? '').toString(),
      icon: (json['icon'] ?? 'help').toString(),
    );
  }

  RequestCategory toRequestCategory() {
    final id = RequestCategory.normalizeId(key);
    return RequestCategory(
      id: id.isEmpty ? key : id,
      label: title,
      iconName: icon,
      description: description,
    );
  }
}

class PortalHomeAssistant {
  PortalHomeAssistant({required this.message});

  final String message;

  factory PortalHomeAssistant.fromJson(Map<String, dynamic> json) {
    return PortalHomeAssistant(
      message: (json['message'] ??
              json['prompt'] ??
              'Como podemos ajudar você hoje?')
          .toString(),
    );
  }
}

class PortalHomeData {
  PortalHomeData({
    required this.user,
    required this.summary,
    required this.quickActions,
    required this.recentProtocols,
    required this.appointments,
    required this.notifications,
    required this.assistant,
  });

  final PortalHomeUser user;
  final PortalHomeSummary summary;
  final List<PortalQuickAction> quickActions;
  final List<ProtocolSummary> recentProtocols;
  final List<AppointmentItem> appointments;
  final List<AppNotification> notifications;
  final PortalHomeAssistant assistant;

  factory PortalHomeData.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> asMapList(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final userRaw = json['user'];
    final summaryRaw = json['summary'];
    final assistantRaw = json['assistant'];

    return PortalHomeData(
      user: PortalHomeUser.fromJson(
        userRaw is Map
            ? Map<String, dynamic>.from(userRaw)
            : <String, dynamic>{'nome': 'Cidadão'},
      ),
      summary: PortalHomeSummary.fromJson(
        summaryRaw is Map
            ? Map<String, dynamic>.from(summaryRaw)
            : <String, dynamic>{},
      ),
      quickActions: asMapList(json['quick_actions'])
          .map(PortalQuickAction.fromJson)
          .toList(),
      recentProtocols: asMapList(json['recent_protocols'])
          .map(_protocolFromHomeJson)
          .toList(),
      appointments: asMapList(json['appointments'])
          .map(AppointmentItem.fromJson)
          .toList(),
      notifications: asMapList(json['notifications'])
          .map(AppNotification.fromJson)
          .toList(),
      assistant: PortalHomeAssistant.fromJson(
        assistantRaw is Map
            ? Map<String, dynamic>.from(assistantRaw)
            : <String, dynamic>{},
      ),
    );
  }

  static ProtocolSummary _protocolFromHomeJson(Map<String, dynamic> json) {
    final updated = json['ultima_atualizacao'] ??
        json['updated_at'] ??
        json['created_at'];
    final unread = () {
      final v = json['unread_count'] ??
          json['mensagens_nao_lidas'] ??
          json['unread_messages'];
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }();
    return ProtocolSummary(
      id: json['id'],
      title: (json['titulo'] ?? json['title'] ?? json['subject'] ?? 'Solicitação')
          .toString(),
      number: (json['protocolo'] ?? json['number'] ?? json['numero'])
          ?.toString(),
      status: (json['status'] ?? json['situacao'])?.toString(),
      category: (json['categoria'] ?? json['category'])?.toString(),
      createdAt: updated != null ? DateTime.tryParse(updated.toString()) : null,
      updatedAt: updated != null ? DateTime.tryParse(updated.toString()) : null,
      description: json['description']?.toString(),
      unreadCount: unread,
      hasUnread: unread > 0,
      lastMessagePreview: (json['last_message_preview'] ??
              json['ultima_resposta'] ??
              json['preview'])
          ?.toString(),
      awaitingCitizen: (json['awaiting_citizen'] == true) ||
          (json['aguardando_cidadao'] == true) ||
          (json['status']?.toString() == 'aguardando_cidadao'),
    );
  }
}
