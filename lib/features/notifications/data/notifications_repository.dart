import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
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
    this.protocolNumber,
    this.kind = NotificationKind.generic,
  });

  final dynamic id;
  final String title;
  final String? body;
  final DateTime? readAt;
  final DateTime? createdAt;
  final String? link;
  final String? protocolId;
  final String? protocolNumber;
  final NotificationKind kind;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readRaw = json['read_at'] ?? json['readAt'];
    final createdRaw = json['created_at'] ?? json['createdAt'];
    final type =
        (json['type'] ??
                json['kind'] ??
                json['categoria'] ??
                json['event'] ??
                '')
            .toString()
            .toLowerCase();
    final data = json['data'];
    String? protocolId =
        (json['protocol_id'] ??
                json['protocolo_id'] ??
                json['request_id'] ??
                json['solicitacao_id'])
            ?.toString();
    String? protocolNumber =
        (json['protocol_number'] ??
                json['number'] ??
                json['numero'] ??
                json['protocolo'])
            ?.toString();
    if (data is Map) {
      protocolId ??=
          (data['protocol_id'] ?? data['protocolo_id'] ?? data['request_id'])
              ?.toString();
      protocolNumber ??=
          (data['protocol_number'] ??
                  data['number'] ??
                  data['numero'] ??
                  data['protocolo'])
              ?.toString();
    }
    final link = (json['deep_link'] ?? json['link'] ?? json['url'])?.toString();

    return AppNotification(
      id: json['id'],
      title: (json['title'] ?? json['titulo'] ?? 'Aviso').toString(),
      body: (json['body'] ?? json['message'] ?? json['conteudo'])?.toString(),
      link: link,
      protocolId: protocolId ?? _protocolIdFromLink(link),
      protocolNumber: protocolNumber,
      kind: _kindFrom(
        type,
        title: json['title']?.toString(),
        body: json['body']?.toString(),
      ),
      readAt: readRaw != null ? DateTime.tryParse(readRaw.toString()) : null,
      createdAt: createdRaw != null
          ? DateTime.tryParse(createdRaw.toString())
          : null,
    );
  }

  static String? _protocolIdFromLink(String? link) {
    if (link == null || link.isEmpty) return null;
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    if (uri.scheme == 'poligestor' &&
        (uri.host == 'protocols' || uri.host == 'protocol')) {
      if (uri.pathSegments.isNotEmpty) return uri.pathSegments.first;
    }
    final segments = uri.pathSegments;
    for (var i = 0; i < segments.length - 1; i++) {
      if (segments[i] == 'requests' ||
          segments[i] == 'protocols' ||
          segments[i] == 'solicitacoes' ||
          segments[i] == 'solicitação' ||
          segments[i] == 'protocolos') {
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
    final t = type.toLowerCase();
    return switch (t) {
      'protocol_message' ||
      'new_reply' ||
      'message' ||
      'resposta' => NotificationKind.newReply,
      'protocol_information_requested' ||
      'info_request' ||
      'awaiting_citizen' => NotificationKind.infoRequest,
      'protocol_status_changed' ||
      'protocol_assignee_changed' ||
      'status_change' ||
      'status' => NotificationKind.statusChange,
      'protocol_resolved' ||
      'resolved' ||
      'closed' => NotificationKind.resolved,
      'protocol_rating_available' ||
      'protocol_rating_received' ||
      'rating' => NotificationKind.ratingAvailable,
      'protocol_reopened' ||
      'protocol_created' => NotificationKind.statusChange,
      _ => () {
        final blob = '$t ${title ?? ''} ${body ?? ''}'.toLowerCase();
        if (blob.contains('avali') || blob.contains('rating')) {
          return NotificationKind.ratingAvailable;
        }
        if (blob.contains('resolv') || blob.contains('encerr')) {
          return NotificationKind.resolved;
        }
        if (blob.contains('informa') || blob.contains('aguardando')) {
          return NotificationKind.infoRequest;
        }
        if (blob.contains('status') || blob.contains('andamento')) {
          return NotificationKind.statusChange;
        }
        if (blob.contains('mensagem') || blob.contains('message')) {
          return NotificationKind.newReply;
        }
        return NotificationKind.generic;
      }(),
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

class NotificationsPage {
  const NotificationsPage({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total,
  });

  final List<AppNotification> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int? total;

  bool get hasMore => currentPage < lastPage;
}

class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<NotificationsPage> list({
    required AuthMode mode,
    String filter = 'all',
    bool? unreadOnly,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = <String, dynamic>{
      'filter': filter,
      'per_page': perPage,
      'page': page,
    };
    if (unreadOnly == true) {
      query['unread'] = 1;
    }

    final envelope = await _api.getEnvelope<List<AppNotification>>(
      mode.notificationsPath,
      mode: mode,
      query: query,
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

    final meta = envelope.meta ?? const <String, dynamic>{};
    return NotificationsPage(
      items: envelope.data,
      currentPage: _int(meta['current_page'] ?? meta['page'], page),
      lastPage: _int(meta['last_page'] ?? meta['lastPage'], 1),
      perPage: _int(meta['per_page'] ?? meta['perPage'], perPage),
      total: meta['total'] is num ? (meta['total'] as num).toInt() : null,
    );
  }

  Future<void> markRead({required AuthMode mode, required dynamic id}) async {
    await _api.postEnvelope<Map<String, dynamic>>(
      mode.notificationReadPath(id),
      data: const {},
      mode: mode,
      parse: _asMap,
    );
  }

  Future<void> markAllRead({required AuthMode mode}) async {
    await _api.postEnvelope<Map<String, dynamic>>(
      mode.notificationsReadAllPath,
      data: const {},
      mode: mode,
      parse: _asMap,
    );
  }

  Future<int> unreadCount({required AuthMode mode}) async {
    final envelope = await _api.getEnvelope<int>(
      mode.notificationsUnreadCountPath,
      mode: mode,
      parse: (raw) {
        if (raw is num) return raw.toInt();
        if (raw is Map) {
          final map = Map<String, dynamic>.from(raw);
          final nested =
              map['unread_count'] ??
              map['count'] ??
              (map['data'] is Map
                  ? (map['data'] as Map)['unread_count']
                  : null);
          if (nested is num) return nested.toInt();
        }
        return 0;
      },
    );
    return envelope.data;
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  static int _int(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
