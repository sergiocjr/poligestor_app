import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_mode.dart';

enum NotificationKind {
  newReply,
  statusChange,
  infoRequest,
  resolved,
  ratingAvailable,
  generic,
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    this.body,
    this.readAt,
    this.createdAt,
    this.link,
    this.protocolId,
    this.kind = NotificationKind.generic,
  });

  final dynamic id;
  final String title;
  final String? body;
  final DateTime? readAt;
  final DateTime? createdAt;
  final String? link;
  final String? protocolId;
  final NotificationKind kind;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readRaw = json['read_at'] ?? json['readAt'];
    final createdRaw = json['created_at'] ?? json['createdAt'];
    final type = (json['type'] ??
            json['kind'] ??
            json['categoria'] ??
            json['event'] ??
            '')
        .toString()
        .toLowerCase();
    final protocolId = (json['protocol_id'] ??
            json['protocolo_id'] ??
            json['request_id'] ??
            json['solicitacao_id'])
        ?.toString();
    final link = json['link']?.toString();

    return AppNotification(
      id: json['id'],
      title: (json['title'] ?? json['titulo'] ?? 'Aviso').toString(),
      body: (json['body'] ?? json['message'] ?? json['conteudo'])?.toString(),
      link: link,
      protocolId: protocolId ?? _protocolIdFromLink(link),
      kind: _kindFrom(type, title: json['title']?.toString(), body: json['body']?.toString()),
      readAt: readRaw != null ? DateTime.tryParse(readRaw.toString()) : null,
      createdAt:
          createdRaw != null ? DateTime.tryParse(createdRaw.toString()) : null,
    );
  }

  static String? _protocolIdFromLink(String? link) {
    if (link == null || link.isEmpty) return null;
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    for (var i = 0; i < segments.length - 1; i++) {
      if (segments[i] == 'requests' ||
          segments[i] == 'protocols' ||
          segments[i] == 'solicitacoes') {
        return segments[i + 1];
      }
    }
    final q = uri.queryParameters['id'] ?? uri.queryParameters['protocol_id'];
    return q;
  }

  static NotificationKind _kindFrom(
    String type, {
    String? title,
    String? body,
  }) {
    final blob = '$type ${title ?? ''} ${body ?? ''}'.toLowerCase();
    if (blob.contains('avali') || blob.contains('rating')) {
      return NotificationKind.ratingAvailable;
    }
    if (blob.contains('resolv') || blob.contains('encerr')) {
      return NotificationKind.resolved;
    }
    if (blob.contains('informa') ||
        blob.contains('aguardando') ||
        blob.contains('pedido')) {
      return NotificationKind.infoRequest;
    }
    if (blob.contains('status') ||
        blob.contains('andamento') ||
        blob.contains('atualiz')) {
      return NotificationKind.statusChange;
    }
    if (blob.contains('resposta') ||
        blob.contains('mensagem') ||
        blob.contains('reply') ||
        blob.contains('message')) {
      return NotificationKind.newReply;
    }
    return switch (type) {
      'new_reply' || 'message' || 'resposta' => NotificationKind.newReply,
      'status' || 'status_change' => NotificationKind.statusChange,
      'info_request' || 'awaiting_citizen' => NotificationKind.infoRequest,
      'resolved' || 'closed' => NotificationKind.resolved,
      'rating' || 'evaluation' => NotificationKind.ratingAvailable,
      _ => NotificationKind.generic,
    };
  }

  String get kindLabel => switch (kind) {
        NotificationKind.newReply => 'Nova resposta',
        NotificationKind.statusChange => 'Mudança de status',
        NotificationKind.infoRequest => 'Pedido de informação',
        NotificationKind.resolved => 'Solicitação resolvida',
        NotificationKind.ratingAvailable => 'Avaliação disponível',
        NotificationKind.generic => 'Aviso',
      };

  IconDataForNotification get kindIcon => switch (kind) {
        NotificationKind.newReply => IconDataForNotification.chat,
        NotificationKind.statusChange => IconDataForNotification.status,
        NotificationKind.infoRequest => IconDataForNotification.help,
        NotificationKind.resolved => IconDataForNotification.done,
        NotificationKind.ratingAvailable => IconDataForNotification.star,
        NotificationKind.generic => IconDataForNotification.bell,
      };
}

enum IconDataForNotification { chat, status, help, done, star, bell }

class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<List<AppNotification>> list({required AuthMode mode}) async {
    final envelope = await _api.getEnvelope<List<AppNotification>>(
      mode.notificationsPath,
      mode: mode,
      parse: (raw) {
        final list = raw is List
            ? raw
            : (raw is Map && raw['data'] is List)
                ? raw['data'] as List
                : const [];
        return list
            .whereType<Map>()
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return envelope.data;
  }

  Future<void> markRead({
    required AuthMode mode,
    required dynamic id,
  }) async {
    await _api.patchEnvelope<Map<String, dynamic>>(
      '${mode.notificationsPath}/$id',
      data: {'read': true},
      parse: (raw) {
        if (raw is Map<String, dynamic>) return raw;
        if (raw is Map) return Map<String, dynamic>.from(raw);
        return <String, dynamic>{};
      },
    );
  }

  Future<int> unreadCount({required AuthMode mode}) async {
    final items = await list(mode: mode);
    return items.where((e) => e.isUnread).length;
  }
}
