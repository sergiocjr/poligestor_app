import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_mode.dart';

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    this.body,
    this.readAt,
    this.createdAt,
    this.link,
  });

  final dynamic id;
  final String title;
  final String? body;
  final DateTime? readAt;
  final DateTime? createdAt;
  final String? link;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readRaw = json['read_at'] ?? json['readAt'];
    final createdRaw = json['created_at'] ?? json['createdAt'];
    return AppNotification(
      id: json['id'],
      title: (json['title'] ?? json['titulo'] ?? 'Notificação').toString(),
      body: (json['body'] ?? json['message'] ?? json['conteudo'])?.toString(),
      link: json['link']?.toString(),
      readAt: readRaw != null ? DateTime.tryParse(readRaw.toString()) : null,
      createdAt:
          createdRaw != null ? DateTime.tryParse(createdRaw.toString()) : null,
    );
  }
}

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
