import 'notification_kind_map.dart';
import 'notifications_repository.dart';

/// Tipos de push / deep link definidos na especificação da Fase 7 (cliente).
/// Nomes de eventos WebSocket do backend NÃO são inventados aqui.
enum PushEventType {
  protocolMessage,
  protocolInformationRequested,
  protocolStatusChanged,
  protocolResolved,
  protocolRatingAvailable,
  systemNotice,
  unknown,
}

class PushPayload {
  const PushPayload({
    required this.type,
    this.protocolId,
    this.protocolNumber,
    this.link,
    this.title,
    this.body,
    this.notificationId,
    this.raw = const {},
  });

  final PushEventType type;
  final String? protocolId;
  final String? protocolNumber;
  final String? link;
  final String? title;
  final String? body;
  final String? notificationId;
  final Map<String, dynamic> raw;

  bool get hasProtocolTarget =>
      (protocolId != null && protocolId!.trim().isNotEmpty) ||
      (protocolNumber != null && protocolNumber!.trim().isNotEmpty) ||
      (link != null && link!.trim().isNotEmpty);

  factory PushPayload.fromMap(Map<String, dynamic> map) {
    final data = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : <String, dynamic>{};
    final merged = <String, dynamic>{...map, ...data};

    final typeRaw = (merged['type'] ??
            merged['event'] ??
            merged['kind'] ??
            merged['categoria'] ??
            '')
        .toString();

    final protocolId = (merged['protocol_id'] ??
            merged['protocolo_id'] ??
            merged['request_id'] ??
            data['protocol_id'])
        ?.toString();
    final protocolNumber = (merged['protocol_number'] ??
            merged['number'] ??
            merged['numero'] ??
            merged['protocolo'])
        ?.toString();
    final link = (merged['link'] ?? merged['url'] ?? merged['path'])?.toString();

    return PushPayload(
      type: pushEventTypeFrom(typeRaw),
      protocolId: protocolId,
      protocolNumber: protocolNumber,
      link: link,
      title: (merged['title'] ?? merged['titulo'])?.toString(),
      body: (merged['body'] ?? merged['message'] ?? merged['conteudo'])
          ?.toString(),
      notificationId: (merged['notification_id'] ?? merged['id'])?.toString(),
      raw: merged,
    );
  }

  NotificationKind get asNotificationKind => switch (type) {
        PushEventType.protocolMessage => NotificationKind.newReply,
        PushEventType.protocolInformationRequested =>
          NotificationKind.infoRequest,
        PushEventType.protocolStatusChanged => NotificationKind.statusChange,
        PushEventType.protocolResolved => NotificationKind.resolved,
        PushEventType.protocolRatingAvailable => NotificationKind.ratingAvailable,
        PushEventType.systemNotice || PushEventType.unknown =>
          NotificationKind.generic,
      };
}
