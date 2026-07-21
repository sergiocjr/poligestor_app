import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/auth/auth_mode.dart';
import 'virtual_team_cache.dart';
import 'virtual_team_models.dart';

class VirtualTeamFilter {
  const VirtualTeamFilter({
    this.status,
    this.agentSlug,
    this.priority,
    this.page,
    this.perPage,
    this.q,
    this.from,
    this.to,
  });

  final String? status;
  final String? agentSlug;
  final String? priority;
  final int? page;
  final int? perPage;
  final String? q;
  final String? from;
  final String? to;

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      q[k] = v;
    }

    put('status', status);
    put('agent_slug', agentSlug);
    put('priority', priority);
    put('page', page);
    put('per_page', perPage);
    put('q', this.q);
    put('from', from);
    put('to', to);
    return q;
  }
}

class VirtualTeamRepository {
  VirtualTeamRepository(this._api, {VirtualTeamCache? cache})
    : _cache = cache ?? VirtualTeamCache();

  final ApiClient _api;
  final VirtualTeamCache _cache;
  static const _staff = AuthMode.staff;

  Future<VtTeamRoot> root({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.virtualTeamRootPath,
        mode: _staff,
        parse: asMap,
      );
      await _cache.put('root', envelope.data);
      return VtTeamRoot.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('root');
      if (cached != null) {
        return VtTeamRoot.fromJson(
          cached.data,
          fromCache: true,
          cacheAgeLabel: cached.ageLabel,
        );
      }
      rethrow;
    }
  }

  Future<VtDashboard> dashboard({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.virtualTeamDashboardPath,
        mode: _staff,
        parse: asMap,
      );
      await _cache.put('dashboard', envelope.data);
      return VtDashboard.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('dashboard');
      if (cached != null) {
        return VtDashboard.fromJson(
          cached.data,
          fromCache: true,
          cacheAgeLabel: cached.ageLabel,
        );
      }
      rethrow;
    }
  }

  Future<VtDashboard> metrics({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
    String? agentSlug,
  }) async {
    final path = agentSlug == null || agentSlug.isEmpty
        ? _staff.virtualTeamMetricsPath
        : _staff.virtualTeamAgentMetricsPath(agentSlug);
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      path,
      mode: _staff,
      query: filter.toQuery(),
      parse: asMap,
    );
    return VtDashboard.fromJson(envelope.data);
  }

  Future<List<VtAgent>> agents({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        _staff.virtualTeamAgentsPath,
        mode: _staff,
        parse: (raw) => raw,
      );
      final list = asMapList(envelope.data);
      await _cache.put('agents', {'items': list});
      return list.map(VtAgent.fromJson).toList();
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('agents');
      if (cached != null) {
        return asMapList(cached.data['items']).map(VtAgent.fromJson).toList();
      }
      rethrow;
    }
  }

  Future<VtAgent> agent(String slug) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      _staff.virtualTeamAgentPath(slug),
      mode: _staff,
      parse: asMap,
    );
    return VtAgent.fromJson(envelope.data);
  }

  Future<VtPagedList<VtTask>> tasks({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
    String? agentSlug,
  }) async {
    final slug = agentSlug ?? filter.agentSlug;
    final path = slug == null || slug.isEmpty
        ? _staff.virtualTeamTasksPath
        : _staff.virtualTeamAgentTasksPath(slug);
    final envelope = await _api.getEnvelope<dynamic>(
      path,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtTask.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  Future<VtPagedList<VtExecution>> executions({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
    String? agentSlug,
  }) async {
    final slug = agentSlug ?? filter.agentSlug;
    final path = slug == null || slug.isEmpty
        ? _staff.virtualTeamExecutionsPath
        : _staff.virtualTeamAgentExecutionsPath(slug);
    final envelope = await _api.getEnvelope<dynamic>(
      path,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtExecution.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  Future<VtPagedList<VtEvent>> events({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamEventsPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtEvent.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  Future<List<VtMemoryItem>> memory({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamMemoryPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return asMapList(envelope.data).map(VtMemoryItem.fromJson).toList();
  }

  Future<List<VtLearningItem>> learning({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamLearningPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return asMapList(envelope.data).map(VtLearningItem.fromJson).toList();
  }

  Future<List<VtQueueItem>> queue() async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamQueuePath,
      mode: _staff,
      parse: (raw) => raw,
    );
    return asMapList(envelope.data).map(VtQueueItem.fromJson).toList();
  }

  Future<VtPagedList<VtHandoff>> handoffs({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamHandoffsPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtHandoff.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  Future<VtPagedList<VtLogEntry>> logs({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
    String? agentSlug,
  }) async {
    final slug = agentSlug ?? filter.agentSlug;
    final path = slug == null || slug.isEmpty
        ? _staff.virtualTeamLogsPath
        : _staff.virtualTeamAgentLogsPath(slug);
    final envelope = await _api.getEnvelope<dynamic>(
      path,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtLogEntry.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  Future<VtPagedList<VtAuditEntry>> audit({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamAuditPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtAuditEntry.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  Future<VtPagedList<VtTimelineItem>> timeline({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
    String? agentSlug,
  }) async {
    final slug = agentSlug ?? filter.agentSlug;
    final path = slug == null || slug.isEmpty
        ? _staff.virtualTeamTimelinePath
        : _staff.virtualTeamAgentTimelinePath(slug);
    final envelope = await _api.getEnvelope<dynamic>(
      path,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtTimelineItem.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  Future<VtPagedList<VtAlert>> alerts({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamAlertsPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtAlert.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  Future<VtSearchResults> search({required String query}) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      _staff.virtualTeamSearchPath,
      mode: _staff,
      query: {'q': query},
      parse: asMap,
    );
    return VtSearchResults.fromJson(
      envelope.data,
      meta: envelope.meta,
      query: query,
    );
  }

  VtPageMeta? _metaOf(Map<String, dynamic>? meta) =>
      meta == null ? null : VtPageMeta.fromJson(meta);
}
