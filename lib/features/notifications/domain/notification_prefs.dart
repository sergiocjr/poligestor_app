import 'package:shared_preferences/shared_preferences.dart';

/// Preferências remotas (`GET`/`PUT` notification-preferences) + cache local.
class NotificationPrefs {
  NotificationPrefs({
    this.pushEnabled = true,
    this.protocolMessagesEnabled = true,
    this.protocolStatusEnabled = true,
    this.importantOnly = false,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  });

  static const _kPush = 'notif_pref_push_enabled';
  static const _kMessages = 'notif_pref_protocol_messages';
  static const _kStatus = 'notif_pref_protocol_status';
  static const _kImportantOnly = 'notif_pref_important_only';
  static const _kQuiet = 'notif_pref_quiet_hours';
  static const _kQuietStart = 'notif_pref_quiet_start';
  static const _kQuietEnd = 'notif_pref_quiet_end';

  bool pushEnabled;
  bool protocolMessagesEnabled;
  bool protocolStatusEnabled;
  bool importantOnly;
  bool quietHoursEnabled;
  String quietHoursStart;
  String quietHoursEnd;

  /// Compatibilidade com UI antiga.
  bool get enabled => pushEnabled;
  set enabled(bool v) => pushEnabled = v;

  bool get messages => protocolMessagesEnabled;
  set messages(bool v) => protocolMessagesEnabled = v;

  bool get importantUpdates => protocolStatusEnabled;
  set importantUpdates(bool v) => protocolStatusEnabled = v;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) {
    return NotificationPrefs(
      pushEnabled: _bool(json['push_enabled'], true),
      protocolMessagesEnabled: _bool(json['protocol_messages_enabled'], true),
      protocolStatusEnabled: _bool(json['protocol_status_enabled'], true),
      importantOnly: _bool(json['important_only'], false),
      quietHoursEnabled: _bool(json['quiet_hours_enabled'], false),
      quietHoursStart:
          (json['quiet_hours_start'] ?? '22:00').toString(),
      quietHoursEnd: (json['quiet_hours_end'] ?? '07:00').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'push_enabled': pushEnabled,
        'protocol_messages_enabled': protocolMessagesEnabled,
        'protocol_status_enabled': protocolStatusEnabled,
        'important_only': importantOnly,
        'quiet_hours_enabled': quietHoursEnabled,
        'quiet_hours_start': quietHoursStart,
        'quiet_hours_end': quietHoursEnd,
      };

  Future<void> loadLocal() async {
    final p = await SharedPreferences.getInstance();
    pushEnabled = p.getBool(_kPush) ?? true;
    protocolMessagesEnabled = p.getBool(_kMessages) ?? true;
    protocolStatusEnabled = p.getBool(_kStatus) ?? true;
    importantOnly = p.getBool(_kImportantOnly) ?? false;
    quietHoursEnabled = p.getBool(_kQuiet) ?? false;
    quietHoursStart = p.getString(_kQuietStart) ?? '22:00';
    quietHoursEnd = p.getString(_kQuietEnd) ?? '07:00';
  }

  Future<void> saveLocal() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPush, pushEnabled);
    await p.setBool(_kMessages, protocolMessagesEnabled);
    await p.setBool(_kStatus, protocolStatusEnabled);
    await p.setBool(_kImportantOnly, importantOnly);
    await p.setBool(_kQuiet, quietHoursEnabled);
    await p.setString(_kQuietStart, quietHoursStart);
    await p.setString(_kQuietEnd, quietHoursEnd);
  }

  void copyFrom(NotificationPrefs other) {
    pushEnabled = other.pushEnabled;
    protocolMessagesEnabled = other.protocolMessagesEnabled;
    protocolStatusEnabled = other.protocolStatusEnabled;
    importantOnly = other.importantOnly;
    quietHoursEnabled = other.quietHoursEnabled;
    quietHoursStart = other.quietHoursStart;
    quietHoursEnd = other.quietHoursEnd;
  }

  static bool _bool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return fallback;
  }
}
