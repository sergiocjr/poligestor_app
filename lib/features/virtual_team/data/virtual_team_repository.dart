import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
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

  Future<List<VtAgent>> agents({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        _staff.virtualTeamAgentsPath,
        mode: _staff,
        parse: (raw) => raw,
      );
      final list = asMapList(envelope.data);
      final root = <String, dynamic>{'items': list};
      await _cache.put('agents', root);
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
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamTasksPath,
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
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamExecutionsPath,
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

  Future<List<VtMemoryItem>> memory() async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamMemoryPath,
      mode: _staff,
      parse: (raw) => raw,
    );
    return asMapList(envelope.data).map(VtMemoryItem.fromJson).toList();
  }

  Future<List<VtLearningItem>> learning() async {
    final envelope = await _api.getEnvelope<dynamic>(
      _staff.virtualTeamLearningPath,
      mode: _staff,
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
      _staff.aiHandoffsPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: (raw) => raw,
    );
    return VtPagedList(
      items: asMapList(envelope.data).map(VtHandoff.fromJson).toList(),
      meta: _metaOf(envelope.meta),
    );
  }

  /// Endpoints ainda ausentes (404) — estrutura pronta, sem mock.
  Future<VtPagedList<Map<String, dynamic>>> logs({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) =>
      _unavailableList(_staff.virtualTeamLogsPath, filter);

  Future<VtPagedList<Map<String, dynamic>>> audit({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) =>
      _unavailableList(_staff.virtualTeamAuditPath, filter);

  Future<VtPagedList<Map<String, dynamic>>> metrics({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) =>
      _unavailableList(_staff.virtualTeamMetricsPath, filter);

  Future<VtPagedList<Map<String, dynamic>>> timeline({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) =>
      _unavailableList(_staff.virtualTeamTimelinePath, filter);

  Future<VtPagedList<Map<String, dynamic>>> alerts({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) =>
      _unavailableList(_staff.virtualTeamAlertsPath, filter);

  /// Preferência futura: quando `/v1/virtual-team/handoffs` existir.
  Future<VtPagedList<Map<String, dynamic>>> virtualTeamHandoffs({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) =>
      _unavailableList(_staff.virtualTeamHandoffsPath, filter);

  Future<Map<String, List<Map<String, dynamic>>>> search({
    required String query,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.virtualTeamSearchPath,
        mode: _staff,
        query: {'q': query},
        parse: asMap,
      );
      final groups = <String, List<Map<String, dynamic>>>{};
      for (final e in envelope.data.entries) {
        if (e.value is List) {
          groups[e.key] = asMapList(e.value);
        }
      }
      return groups;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw EndpointUnavailableException(_staff.virtualTeamSearchPath);
      }
      rethrow;
    }
  }

  Future<VtPagedList<Map<String, dynamic>>> _unavailableList(
    String path,
    VirtualTeamFilter filter,
  ) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        path,
        mode: _staff,
        query: filter.toQuery(),
        parse: (raw) => raw,
      );
      return VtPagedList(
        items: asMapList(envelope.data),
        meta: _metaOf(envelope.meta),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw EndpointUnavailableException(path);
      }
      rethrow;
    }
  }

  VtPageMeta? _metaOf(Map<String, dynamic>? meta) =>
      meta == null ? null : VtPageMeta.fromJson(meta);
}
