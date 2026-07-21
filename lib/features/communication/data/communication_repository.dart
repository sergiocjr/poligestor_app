import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/auth/auth_mode.dart';
import 'communication_cache.dart';
import 'communication_models.dart';

class CommunicationFilter {
  const CommunicationFilter({
    this.search,
    this.status,
    this.channelType,
    this.sort,
  });

  final String? search;
  final String? status;
  final String? channelType;
  final String? sort;

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{};
    final s = search?.trim();
    if (s != null && s.isNotEmpty) q['search'] = s;
    if (status != null && status!.isNotEmpty) q['status'] = status;
    if (channelType != null && channelType!.isNotEmpty) {
      q['channel_type'] = channelType;
    }
    if (sort != null && sort!.isNotEmpty) q['sort'] = sort;
    return q;
  }
}

/// Repositório exclusivo PoliGestor — contratos LIVE `/v1/channels|templates|campaigns`.
class CommunicationRepository {
  CommunicationRepository(this._api, {CommunicationCache? cache})
    : _cache = cache ?? CommunicationCache();

  final ApiClient _api;
  final CommunicationCache _cache;

  Future<List<CommChannel>> channels({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<List<CommChannel>>(
        AuthMode.staff.communicationChannelsPath,
        mode: AuthMode.staff,
        parse: (raw) =>
            asMapList(raw).map(CommChannel.fromJson).toList(growable: false),
      );
      await _cache.saveChannels(envelope.data);
      return envelope.data;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getChannels();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<List<CommTemplate>> templates({
    CommunicationFilter filter = const CommunicationFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<List<CommTemplate>>(
        AuthMode.staff.communicationTemplatesPath,
        mode: AuthMode.staff,
        query: filter.toQuery(),
        parse: (raw) =>
            asMapList(raw).map(CommTemplate.fromJson).toList(growable: false),
      );
      if (filter.search == null &&
          filter.channelType == null &&
          filter.status == null) {
        await _cache.saveTemplates(envelope.data);
      }
      return envelope.data;
    } catch (e) {
      if (allowCache && filter.toQuery().isEmpty) {
        final cached = await _cache.getTemplates();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<CommTemplate> templateById(String id) async {
    final envelope = await _api.getEnvelope<CommTemplate>(
      '${AuthMode.staff.communicationTemplatesPath}/$id',
      mode: AuthMode.staff,
      parse: (raw) {
        if (raw is Map<String, dynamic>) return CommTemplate.fromJson(raw);
        if (raw is Map) {
          return CommTemplate.fromJson(Map<String, dynamic>.from(raw));
        }
        throw StateError('Template inválido');
      },
    );
    return envelope.data;
  }

  Future<List<CommCampaign>> campaigns({
    CommunicationFilter filter = const CommunicationFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<List<CommCampaign>>(
        AuthMode.staff.communicationCampaignsPath,
        mode: AuthMode.staff,
        query: filter.toQuery(),
        parse: (raw) =>
            asMapList(raw).map(CommCampaign.fromJson).toList(growable: false),
      );
      if (filter.toQuery().isEmpty) {
        await _cache.saveCampaigns(envelope.data);
      }
      return envelope.data;
    } catch (e) {
      if (allowCache && filter.toQuery().isEmpty) {
        final cached = await _cache.getCampaigns();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<CommCampaign> campaignById(String id) async {
    final envelope = await _api.getEnvelope<CommCampaign>(
      '${AuthMode.staff.communicationCampaignsPath}/$id',
      mode: AuthMode.staff,
      parse: (raw) {
        if (raw is Map<String, dynamic>) return CommCampaign.fromJson(raw);
        if (raw is Map) {
          return CommCampaign.fromJson(Map<String, dynamic>.from(raw));
        }
        throw StateError('Campanha inválida');
      },
    );
    return envelope.data;
  }

  Future<List<CommConversation>> conversations({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<List<CommConversation>>(
        AuthMode.staff.communicationConversationsPath,
        mode: AuthMode.staff,
        parse: (raw) => asMapList(
          raw,
        ).map(CommConversation.fromJson).toList(growable: false),
      );
      await _cache.saveConversations(envelope.data);
      return envelope.data;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getConversations();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<CommQueueSnapshot> queue({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<CommQueueSnapshot>(
        AuthMode.staff.communicationQueuePath,
        mode: AuthMode.staff,
        parse: (raw) {
          if (raw is Map<String, dynamic>) {
            return CommQueueSnapshot.fromJson(raw);
          }
          if (raw is Map) {
            return CommQueueSnapshot.fromJson(Map<String, dynamic>.from(raw));
          }
          return const CommQueueSnapshot();
        },
      );
      await _cache.saveQueue(envelope.data);
      return envelope.data;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getQueue();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<List<CommOperator>> operators({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<List<CommOperator>>(
        AuthMode.staff.communicationOperatorsPath,
        mode: AuthMode.staff,
        parse: (raw) =>
            asMapList(raw).map(CommOperator.fromJson).toList(growable: false),
      );
      await _cache.saveOperators(envelope.data);
      return envelope.data;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getOperators();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }
}
