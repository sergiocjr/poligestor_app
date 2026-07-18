import 'package:shared_preferences/shared_preferences.dart';

/// Preferências locais até o backend publicar endpoints de preferências.
class NotificationPrefs {
  NotificationPrefs();

  static const _kEnabled = 'notif_pref_enabled';
  static const _kMessages = 'notif_pref_messages';
  static const _kImportant = 'notif_pref_important';
  static const _kImportantOnly = 'notif_pref_important_only';

  bool enabled = true;
  bool messages = true;
  bool importantUpdates = true;
  bool importantOnly = false;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    enabled = p.getBool(_kEnabled) ?? true;
    messages = p.getBool(_kMessages) ?? true;
    importantUpdates = p.getBool(_kImportant) ?? true;
    importantOnly = p.getBool(_kImportantOnly) ?? false;
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, enabled);
    await p.setBool(_kMessages, messages);
    await p.setBool(_kImportant, importantUpdates);
    await p.setBool(_kImportantOnly, importantOnly);
  }
}
