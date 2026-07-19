import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class VirtualTeamCache {
  VirtualTeamCache();

  static const _prefix = 'vt_cache_';

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

  Future<VirtualTeamCacheEntry?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final savedAt = DateTime.tryParse('${map['saved_at']}');
      final data = map['data'];
      if (savedAt == null || data is! Map) return null;
      return VirtualTeamCacheEntry(
        savedAt: savedAt,
        data: Map<String, dynamic>.from(data),
      );
    } catch (_) {
      return null;
    }
  }
}

class VirtualTeamCacheEntry {
  const VirtualTeamCacheEntry({required this.savedAt, required this.data});

  final DateTime savedAt;
  final Map<String, dynamic> data;

  String get ageLabel {
    final s = DateTime.now().difference(savedAt).inSeconds;
    if (s < 60) return 'há ${s}s';
    final m = s ~/ 60;
    if (m < 60) return 'há ${m}min';
    return 'há ${m ~/ 60}h';
  }
}
