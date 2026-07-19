import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache local com carimbo de tempo (dados antigos explícitos).
class MandateCache {
  MandateCache();

  static const _prefix = 'mandate_cache_';

  Future<void> put(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix$key',
      jsonEncode({
        'saved_at': DateTime.now().toIso8601String(),
        'data': data,
      }),
    );
  }

  Future<MandateCacheEntry?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final savedAt = DateTime.tryParse('${map['saved_at']}');
      final data = map['data'];
      if (savedAt == null || data is! Map) return null;
      return MandateCacheEntry(
        savedAt: savedAt,
        data: Map<String, dynamic>.from(data),
      );
    } catch (_) {
      return null;
    }
  }
}

class MandateCacheEntry {
  const MandateCacheEntry({required this.savedAt, required this.data});

  final DateTime savedAt;
  final Map<String, dynamic> data;

  bool get isStale {
    final age = DateTime.now().difference(savedAt);
    return age > const Duration(minutes: 15);
  }

  String get ageLabel {
    final m = DateTime.now().difference(savedAt).inMinutes;
    if (m < 1) return 'agora';
    if (m < 60) return 'há ${m}min';
    final h = m ~/ 60;
    return 'há ${h}h';
  }
}
