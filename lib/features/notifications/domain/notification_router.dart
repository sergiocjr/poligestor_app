import '../../protocols/data/protocol_navigation.dart';
import '../data/push_payload.dart';

/// Destino interno após toque em push / aviso / deep link.
class NotificationRouteTarget {
  const NotificationRouteTarget({
    required this.location,
    this.highlightConversation = false,
    this.highlightRating = false,
    this.highlightInfoRequest = false,
  });

  final String location;
  final bool highlightConversation;
  final bool highlightRating;
  final bool highlightInfoRequest;
}

class NotificationRouter {
  const NotificationRouter();

  /// Converte payload em rota interna. Retorna null se inválido.
  NotificationRouteTarget? resolve(PushPayload payload) {
    final deep = payload.deepLink ?? payload.link;
    if (deep != null && deep.startsWith('poligestor://')) {
      final uri = Uri.tryParse(deep);
      if (uri != null) {
        if (uri.host == 'notifications' || uri.host == 'notification') {
          return const NotificationRouteTarget(
            location: '/citizen/notifications',
          );
        }
        // Sprint 10.1 — Equipe Virtual
        if (uri.host == 'virtual-team' ||
            uri.host == 'virtual_team' ||
            uri.host == 'equipe-virtual') {
          final rest = uri.pathSegments.where((s) => s.isNotEmpty).join('/');
          final location = rest.isEmpty
              ? '/home/virtual-team'
              : '/home/virtual-team/$rest';
          return NotificationRouteTarget(location: location);
        }
        // Sprint 10.6 — Central de Automação
        if (uri.host == 'automation' ||
            uri.host == 'automacao' ||
            uri.host == 'automations') {
          final rest = uri.pathSegments.where((s) => s.isNotEmpty).join('/');
          final location = rest.isEmpty
              ? '/home/automation'
              : '/home/automation/$rest';
          return NotificationRouteTarget(location: location);
        }
        // Sprint 10.7 — Painel Estratégico
        if (uri.host == 'strategy' ||
            uri.host == 'estrategia' ||
            uri.host == 'strategic' ||
            uri.host == 'painel-estrategico') {
          final rest = uri.pathSegments.where((s) => s.isNotEmpty).join('/');
          final location = rest.isEmpty
              ? '/home/strategy'
              : '/home/strategy/$rest';
          return NotificationRouteTarget(location: location);
        }
        // Sprint 10.5 — Assistente Inteligente
        if (uri.host == 'assistant' ||
            uri.host == 'assistente' ||
            uri.host == 'chat' ||
            uri.host == 'ai') {
          final rest = uri.pathSegments.where((s) => s.isNotEmpty).join('/');
          final location = rest.isEmpty ? '/home/chat' : '/home/chat/$rest';
          return NotificationRouteTarget(location: location);
        }
        // Sprint 10.4 — Central de Comunicação (somente PoliGestor)
        if (uri.host == 'communication' ||
            uri.host == 'comunicacao' ||
            uri.host == 'comms') {
          final rest = uri.pathSegments.where((s) => s.isNotEmpty).join('/');
          final location = rest.isEmpty
              ? '/home/communication'
              : '/home/communication/$rest';
          return NotificationRouteTarget(location: location);
        }
        // Sprint 10.2 — Organização / tenant
        if (uri.host == 'org' ||
            uri.host == 'tenant' ||
            uri.host == 'organization' ||
            uri.host == 'organizacao') {
          final slug = uri.pathSegments.isNotEmpty
              ? uri.pathSegments.first
              : (uri.queryParameters['slug'] ?? '');
          final location = slug.isEmpty
              ? '/org'
              : Uri(path: '/org', queryParameters: {'slug': slug}).toString();
          return NotificationRouteTarget(location: location);
        }
      }
    }

    switch (payload.type) {
      case PushEventType.systemNotice:
        return const NotificationRouteTarget(
          location: '/citizen/notifications',
        );
      case PushEventType.protocolMessage:
        return _protocolRoute(payload, highlightConversation: true);
      case PushEventType.protocolInformationRequested:
        return _protocolRoute(
          payload,
          highlightConversation: true,
          highlightInfoRequest: true,
        );
      case PushEventType.protocolStatusChanged:
      case PushEventType.protocolResolved:
      case PushEventType.protocolReopened:
      case PushEventType.protocolCreated:
      case PushEventType.protocolInformationSubmitted:
      case PushEventType.protocolAssigneeChanged:
      case PushEventType.protocolRatingReceived:
        return _protocolRoute(payload);
      case PushEventType.protocolRatingAvailable:
        return _protocolRoute(payload, highlightRating: true);
      case PushEventType.unknown:
        if (payload.hasProtocolTarget) {
          return _protocolRoute(payload);
        }
        return const NotificationRouteTarget(
          location: '/citizen/notifications',
        );
    }
  }

  NotificationRouteTarget? _protocolRoute(
    PushPayload payload, {
    bool highlightConversation = false,
    bool highlightRating = false,
    bool highlightInfoRequest = false,
  }) {
    final target = ProtocolNavigationTarget.resolve(
      protocolId: payload.protocolId,
      protocolNumber: payload.protocolNumber,
      link: payload.effectiveLink,
    );
    if (target == null) return null;
    return NotificationRouteTarget(
      location: target.citizenDetailPath,
      highlightConversation: highlightConversation,
      highlightRating: highlightRating,
      highlightInfoRequest: highlightInfoRequest,
    );
  }
}
