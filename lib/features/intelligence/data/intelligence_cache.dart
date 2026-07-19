import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache local carimbado para Inteligência (Fase 9).
class IntelligenceCache {
  IntelligenceCache();

  static const _prefix = 'intel_cache_';

  Future<void> put(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix$key',
      jsonEncode({'saved_at': DateTime.now().toIso8601String(), 'data': data}),
    );
  }

  Future<IntelligenceCacheEntry?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final savedAt = DateTime.tryParse('${map['saved_at']}');
      final data = map['data'];
      if (savedAt == null || data is! Map) return null;
      return IntelligenceCacheEntry(
        savedAt: savedAt,
        data: Map<String, dynamic>.from(data),
      );
    } catch (_) {
      return null;
    }
  }
}

class IntelligenceCacheEntry {
  const IntelligenceCacheEntry({required this.savedAt, required this.data});

  final DateTime savedAt;
  final Map<String, dynamic> data;

  /// Analytics: 120s no backend; tratamos como “antigo” após 2 min.
  bool isStaleFor({Duration threshold = const Duration(minutes: 2)}) {
    return DateTime.now().difference(savedAt) > threshold;
  }

  String get ageLabel {
    final s = DateTime.now().difference(savedAt).inSeconds;
    if (s < 60) return 'há ${s}s';
    final m = s ~/ 60;
    if (m < 60) return 'há ${m}min';
    return 'há ${m ~/ 60}h';
  }
}
