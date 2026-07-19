import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'communication_models.dart';

/// Cache local (PoliGestor) para canais/templates/campanhas — isolamento por produto.
class CommunicationCache {
  CommunicationCache({SharedPreferences? prefs})
    : _prefsFuture = prefs != null
          ? Future.value(prefs)
          : SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefsFuture;

  static const _channelsKey = 'pg_comms_channels_v1';
  static const _templatesKey = 'pg_comms_templates_v1';
  static const _campaignsKey = 'pg_comms_campaigns_v1';

  Future<void> saveChannels(List<CommChannel> items) async {
    final prefs = await _prefsFuture;
    final raw = items
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'type': e.type,
            'provider': e.provider,
            'is_active': e.isActive,
            'is_default': e.isDefault,
          },
        )
        .toList();
    await prefs.setString(_channelsKey, jsonEncode(raw));
  }

  Future<List<CommChannel>?> getChannels() async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_channelsKey);
    if (s == null || s.isEmpty) return null;
    try {
      final list = jsonDecode(s);
      return asMapList(list).map(CommChannel.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTemplates(List<CommTemplate> items) async {
    final prefs = await _prefsFuture;
    final raw = items
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'slug': e.slug,
            'subject': e.subject,
            'body': e.body,
            'channel_type': e.channelType,
            'is_active': e.isActive,
            'variables': e.variables,
            'updated_at': e.updatedAt?.toIso8601String(),
          },
        )
        .toList();
    await prefs.setString(_templatesKey, jsonEncode(raw));
  }

  Future<List<CommTemplate>?> getTemplates() async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_templatesKey);
    if (s == null || s.isEmpty) return null;
    try {
      final list = jsonDecode(s);
      return asMapList(list).map(CommTemplate.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCampaigns(List<CommCampaign> items) async {
    final prefs = await _prefsFuture;
    final raw = items
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'status': e.status,
            'channel_id': e.channelId,
            'channel_type': e.channelType,
            'template_id': e.templateId,
            'subject': e.subject,
            'body': e.body,
            'scheduled_at': e.scheduledAt?.toIso8601String(),
            'started_at': e.startedAt?.toIso8601String(),
            'completed_at': e.completedAt?.toIso8601String(),
            'sent_count': e.sentCount,
            'failed_count': e.failedCount,
            'total_recipients': e.totalRecipients,
            'segment': e.segment,
          },
        )
        .toList();
    await prefs.setString(_campaignsKey, jsonEncode(raw));
  }

  Future<List<CommCampaign>?> getCampaigns() async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_campaignsKey);
    if (s == null || s.isEmpty) return null;
    try {
      final list = jsonDecode(s);
      return asMapList(list).map(CommCampaign.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  static const _conversationsKey = 'pg_comms_conversations_v1';
  static const _queueKey = 'pg_comms_queue_v1';
  static const _operatorsKey = 'pg_comms_operators_v1';

  Future<void> saveConversations(List<CommConversation> items) async {
    final prefs = await _prefsFuture;
    final raw = items
        .map(
          (e) => {
            'id': e.id,
            'title': e.title,
            'status': e.status,
            'channel_type': e.channelType,
            'contact_name': e.contactName,
            'assigned_to': e.assignedTo,
            'updated_at': e.updatedAt?.toIso8601String(),
            'unread_count': e.unreadCount,
          },
        )
        .toList();
    await prefs.setString(_conversationsKey, jsonEncode(raw));
  }

  Future<List<CommConversation>?> getConversations() async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_conversationsKey);
    if (s == null || s.isEmpty) return null;
    try {
      return asMapList(jsonDecode(s)).map(CommConversation.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveQueue(CommQueueSnapshot q) async {
    final prefs = await _prefsFuture;
    await prefs.setString(
      _queueKey,
      jsonEncode({
        'queue': q.queue,
        'assigned': q.assigned,
        'closed': q.closed,
        'operators': q.operators,
      }),
    );
  }

  Future<CommQueueSnapshot?> getQueue() async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_queueKey);
    if (s == null || s.isEmpty) return null;
    try {
      final map = jsonDecode(s);
      if (map is Map<String, dynamic>) return CommQueueSnapshot.fromJson(map);
      if (map is Map) {
        return CommQueueSnapshot.fromJson(Map<String, dynamic>.from(map));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveOperators(List<CommOperator> items) async {
    final prefs = await _prefsFuture;
    final raw = items
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'email': e.email,
            'status': e.status,
            'active_conversations': e.activeConversations,
            'last_seen_at': e.lastSeenAt?.toIso8601String(),
          },
        )
        .toList();
    await prefs.setString(_operatorsKey, jsonEncode(raw));
  }

  Future<List<CommOperator>?> getOperators() async {
    final prefs = await _prefsFuture;
    final s = prefs.getString(_operatorsKey);
    if (s == null || s.isEmpty) return null;
    try {
      return asMapList(jsonDecode(s)).map(CommOperator.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_channelsKey);
    await prefs.remove(_templatesKey);
    await prefs.remove(_campaignsKey);
    await prefs.remove(_conversationsKey);
    await prefs.remove(_queueKey);
    await prefs.remove(_operatorsKey);
  }
}
