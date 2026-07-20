import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'finance_models.dart';

/// Cache por tenant — Fase 14 Gestão Financeira.
class FinanceCache {
  FinanceCache({SharedPreferences? prefs})
    : _prefsFuture = prefs != null
          ? Future.value(prefs)
          : SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefsFuture;
  static const _prefix = 'pg_fin_';

  String _key(String tenant, String name) => '$_prefix${tenant}_$name';

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
        'payload': data,
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
      final m = asFinanceMap(jsonDecode(s));
      final saved = DateTime.tryParse('${m['saved_at']}');
      final payload = m['payload'];
      final data = payload is List
          ? <String, dynamic>{'data': payload}
          : asFinanceMap(payload);
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
