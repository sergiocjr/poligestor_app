import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/auth/auth_mode.dart';
import '../domain/notification_prefs.dart';

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._api);

  final ApiClient _api;

  Future<NotificationPrefs> get({required AuthMode mode}) async {
    final envelope = await _api.getEnvelope<NotificationPrefs>(
      mode.notificationPreferencesPath,
      mode: mode,
      parse: (raw) {
        final map = _asMap(raw);
        return NotificationPrefs.fromJson(map);
      },
    );
    return envelope.data;
  }

  Future<NotificationPrefs> save({
    required AuthMode mode,
    required NotificationPrefs prefs,
  }) async {
    final envelope = await _api.putEnvelope<NotificationPrefs>(
      mode.notificationPreferencesPath,
      data: prefs.toJson(),
      mode: mode,
      parse: (raw) {
        final map = _asMap(raw);
        if (map.isEmpty) return prefs;
        return NotificationPrefs.fromJson(map);
      },
    );
    return envelope.data;
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }
}
