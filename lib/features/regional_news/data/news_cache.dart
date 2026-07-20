import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'news_models.dart';

/// Cache por tenant — metadados de notícias (sem corpo da matéria).
class NewsCache {
  NewsCache({SharedPreferences? prefs})
    : _prefsFuture = prefs != null
          ? Future.value(prefs)
          : SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefsFuture;
  static const _prefix = 'pg_news_';

  String _key(String tenant, String name) => '$_prefix${tenant}_$name';

  Map<String, dynamic> _stripBody(Map<String, dynamic> data) {
    dynamic clean(dynamic v) {
      if (v is Map) {
        final out = <String, dynamic>{};
        for (final e in v.entries) {
          final k = e.key.toString().toLowerCase();
          if (k == 'content' ||
              k == 'body' ||
              k == 'full_text' ||
              k == 'html' ||
              k == 'article_body') {
            continue;
          }
          out[e.key.toString()] = clean(e.value);
        }
        return out;
      }
      if (v is List) return v.map(clean).toList();
      return v;
    }

    return Map<String, dynamic>.from(clean(data) as Map);
  }

  Future<void> putMap(
    String tenant,
    String name,
    Map<String, dynamic> data,
  ) async {
    final prefs = await _prefsFuture;
    await prefs.setString(
      _key(tenant, name),
      jsonEncode({
        'saved_at': DateTime.now().toIso8601String(),
        'payload': _stripBody(data),
      }),
    );
  }

  Future<({Map<String, dynamic> data, String? ageLabel})?> getMap(
    String tenant,
    String name,
  ) async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_key(tenant, name));
    if (s == null || s.isEmpty) return null;
    try {
      final m = asNewsMap(jsonDecode(s));
      final saved = DateTime.tryParse('${m['saved_at']}');
      final payload = m['payload'];
      final data = payload is List
          ? <String, dynamic>{'data': payload}
          : asNewsMap(payload);
      if (data.isEmpty) return null;
      return (data: data, ageLabel: saved == null ? null : _age(saved));
    } catch (_) {
      return null;
    }
  }

  String _age(DateTime savedAt) {
    final s = DateTime.now().difference(savedAt).inSeconds;
    if (s < 60) return 'há ${s}s';
    final m = s ~/ 60;
    if (m < 60) return 'há ${m}min';
    return 'há ${m ~/ 60}h';
  }
}
