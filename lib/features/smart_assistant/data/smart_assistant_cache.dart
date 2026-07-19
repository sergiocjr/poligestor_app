import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'smart_assistant_models.dart';

/// Cache local Sprint 10.5 — isolamento PoliGestor.
class SmartAssistantCache {
  SmartAssistantCache({SharedPreferences? prefs})
    : _prefsFuture = prefs != null
          ? Future.value(prefs)
          : SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefsFuture;

  static const _briefingKey = 'pg_sa_briefing_v1';
  static const _briefingsKey = 'pg_sa_briefings_v1';
  static const _insightsKey = 'pg_sa_insights_v1';
  static const _conversationsKey = 'pg_sa_conversations_v1';

  Future<void> saveJson(String key, Map<String, dynamic> data) async {
    final prefs = await _prefsFuture;
    await prefs.setString(key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(key);
    if (s == null || s.isEmpty) return null;
    try {
      final decoded = jsonDecode(s);
      return asMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBriefing(SaBriefingView view) => saveJson(_briefingKey, {
    'title': view.title,
    'bullets': view.bullets,
    'generated_at': view.generatedAt?.toIso8601String(),
    'scope': view.scope,
  });

  Future<SaBriefingView?> getBriefing() async {
    final m = await getJson(_briefingKey);
    if (m == null) return null;
    return SaBriefingView.fromJson(m).copyWithCache();
  }

  Future<void> saveBriefings(SaBriefingView view) => saveJson(_briefingsKey, {
    'title': view.title,
    'bullets': view.bullets,
    'generated_at': view.generatedAt?.toIso8601String(),
    'scope': view.scope,
  });

  Future<SaBriefingView?> getBriefings() async {
    final m = await getJson(_briefingsKey);
    if (m == null) return null;
    return SaBriefingView.fromJson(m).copyWithCache();
  }

  Future<void> saveInsights(List<SaInsightItem> items) async {
    final prefs = await _prefsFuture;
    await prefs.setString(
      _insightsKey,
      jsonEncode(
        items
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'body': e.body,
                'priority': e.priority,
                'type': e.type,
              },
            )
            .toList(),
      ),
    );
  }

  Future<List<SaInsightItem>?> getInsights() async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_insightsKey);
    if (s == null || s.isEmpty) return null;
    try {
      return asMapList(jsonDecode(s)).map(SaInsightItem.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveConversations(List<SaConversationItem> items) async {
    final prefs = await _prefsFuture;
    await prefs.setString(
      _conversationsKey,
      jsonEncode(
        items
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'updated_at': e.updatedAt?.toIso8601String(),
                'message_count': e.messageCount,
              },
            )
            .toList(),
      ),
    );
  }

  Future<List<SaConversationItem>?> getConversations() async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_conversationsKey);
    if (s == null || s.isEmpty) return null;
    try {
      return asMapList(jsonDecode(s)).map(SaConversationItem.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_briefingKey);
    await prefs.remove(_briefingsKey);
    await prefs.remove(_insightsKey);
    await prefs.remove(_conversationsKey);
  }
}

extension on SaBriefingView {
  SaBriefingView copyWithCache() => SaBriefingView(
    title: title,
    bullets: bullets,
    generatedAt: generatedAt,
    scope: scope,
    fromCache: true,
  );
}
