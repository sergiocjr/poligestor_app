import 'notification_kind_map.dart';
import 'notifications_repository.dart';

/// Tipos de push / broadcast do contrato Fase 7.
enum PushEventType {
  protocolCreated,
  protocolMessage,
  protocolInformationRequested,
  protocolInformationSubmitted,
  protocolStatusChanged,
  protocolResolved,
  protocolReopened,
  protocolRatingAvailable,
  protocolRatingReceived,
  protocolAssigneeChanged,
  systemNotice,
  unknown,
}

class PushPayload {
  const PushPayload({
    required this.type,
    this.protocolId,
    this.protocolNumber,
    this.link,
    this.deepLink,
    this.title,
    this.body,
    this.notificationId,
    this.tenantId,
    this.raw = const {},
  });

  final PushEventType type;
  final String? protocolId;
  final String? protocolNumber;
  final String? link;
  final String? deepLink;
  final String? title;
  final String? body;
  final String? notificationId;
  final String? tenantId;
  final Map<String, dynamic> raw;

  String? get effectiveLink =>
      (deepLink != null && deepLink!.trim().isNotEmpty) ? deepLink : link;

  bool get hasProtocolTarget =>
      (protocolId != null && protocolId!.trim().isNotEmpty) ||
      (protocolNumber != null && protocolNumber!.trim().isNotEmpty) ||
      (effectiveLink != null && effectiveLink!.trim().isNotEmpty);

  factory PushPayload.fromMap(Map<String, dynamic> map) {
    final data = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : <String, dynamic>{};
    final merged = <String, dynamic>{...map, ...data};

    final typeRaw =
        (merged['type'] ??
                merged['event'] ??
                merged['kind'] ??
                merged['categoria'] ??
                '')
            .toString();

    final protocolId =
        (merged['protocol_id'] ??
                merged['protocolo_id'] ??
                merged['request_id'] ??
                data['protocol_id'])
            ?.toString();
    final protocolNumber =
        (merged['protocol_number'] ??
                merged['number'] ??
                merged['numero'] ??
                merged['protocolo'])
            ?.toString();
    final deepLink = merged['deep_link']?.toString();
    final link = (merged['link'] ?? merged['url'] ?? merged['path'] ?? deepLink)
        ?.toString();

    return PushPayload(
      type: pushEventTypeFrom(typeRaw),
      protocolId: protocolId,
      protocolNumber: protocolNumber,
      link: link,
      deepLink: deepLink,
      title: (merged['title'] ?? merged['titulo'])?.toString(),
      body: (merged['body'] ?? merged['message'] ?? merged['conteudo'])
          ?.toString(),
      notificationId: (merged['notification_id'] ?? merged['id'])?.toString(),
      tenantId: merged['tenant_id']?.toString(),
      raw: merged,
    );
  }

  factory PushPayload.fromUri(Uri uri) {
    if (uri.scheme == 'poligestor') {
      if (uri.host == 'notifications' || uri.host == 'notification') {
        return const PushPayload(type: PushEventType.systemNotice);
      }
      if (uri.host == 'protocols' || uri.host == 'protocol') {
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        return PushPayload(
          type: PushEventType.unknown,
          protocolId: id,
          deepLink: uri.toString(),
          link: uri.toString(),
        );
      }
    }
    return PushPayload(
      type: PushEventType.unknown,
      link: uri.toString(),
      deepLink: uri.toString(),
    );
  }

  NotificationKind get asNotificationKind => switch (type) {
    PushEventType.protocolMessage => NotificationKind.newReply,
    PushEventType.protocolInformationRequested => NotificationKind.infoRequest,
    PushEventType.protocolStatusChanged ||
    PushEventType.protocolReopened ||
    PushEventType.protocolCreated ||
    PushEventType.protocolAssigneeChanged ||
    PushEventType.protocolInformationSubmitted => NotificationKind.statusChange,
    PushEventType.protocolResolved => NotificationKind.resolved,
    PushEventType.protocolRatingAvailable ||
    PushEventType.protocolRatingReceived => NotificationKind.ratingAvailable,
    PushEventType.systemNotice ||
    PushEventType.unknown => NotificationKind.generic,
  };
}
