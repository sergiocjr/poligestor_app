import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import '../../virtual_team/data/virtual_team_models.dart';
import '../../virtual_team/data/virtual_team_repository.dart';
import 'automation_cache.dart';
import 'automation_contracts.dart';
import 'automation_models.dart';

/// Hub Automação — namespace LIVE `/v1/automation/*` (catálogo c29c2ad).
/// A Equipe Virtual permanece apenas onde a UI depende dos modelos VT
/// sem contrato de automação equivalente (agentes, linha do tempo) e como
/// fallback operacional quando um contrato responder pending.
class AutomationRepository {
  AutomationRepository(this._api, this._virtualTeam, {AutomationCache? cache})
    : _cache = cache ?? AutomationCache();

  final ApiClient _api;
  final VirtualTeamRepository _virtualTeam;
  final AutomationCache _cache;
  static const _staff = AuthMode.staff;

  VirtualTeamRepository get virtualTeam => _virtualTeam;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  /// Painel LIVE `GET /v1/automation/dashboard`; fallback Equipe Virtual
  /// (também LIVE) se o contrato regredir para pending; cache offline por
  /// tenant em falha de rede.
  Future<AutoDashboardSnapshot> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.automationsDashboardPath,
        mode: _staff,
        parse: asAutoMap,
      );
      final snap = AutoDashboardSnapshot.fromJson(envelope.data);
      await _cache.saveDashboard(tenantSlug, snap);
      return snap;
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        return _dashboardFromVirtualTeam(tenantSlug);
      }
      if (allowCache) {
        final cached = await _cache.getDashboard(tenantSlug);
        if (cached != null) return cached;
      }
      rethrow;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getDashboard(tenantSlug);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<AutoDashboardSnapshot> _dashboardFromVirtualTeam(
    String tenantSlug,
  ) async {
    final results = await Future.wait([
      _virtualTeam.dashboard(),
      _virtualTeam.alerts(),
      _virtualTeam.queue(),
    ]);
    final dash = results[0] as VtDashboard;
    final alerts = (results[1] as VtPagedList<VtAlert>).items;
    final queue = results[2] as List<VtQueueItem>;
    final critical = alerts
        .where(
          (a) =>
              a.severity.toLowerCase() == 'high' ||
              a.severity.toLowerCase() == 'critical',
        )
        .length;
    final snap = AutoDashboardSnapshot(
      agentsActive: dash.agentsActive,
      agentsTotal: dash.agentsTotal,
      executionsToday: dash.executions24h,
      successToday: dash.tasksCompleted24h,
      failuresToday: dash.tasksFailed24h,
      queueDepth: dash.queueDepth > 0 ? dash.queueDepth : queue.length,
      alertsCritical: critical,
      efficiencyPct: dash.efficiencyPct,
    );
    await _cache.saveDashboard(tenantSlug, snap);
    return snap;
  }

  /// Agentes — UI depende de `VtAgent` (navega ao detalhe da Equipe Virtual).
  Future<List<VtAgent>> agents({bool allowCache = true}) =>
      _virtualTeam.agents(allowCache: allowCache);

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) => {
    'data': data,
    'meta': ?meta,
  };

  Future<List<Map<String, dynamic>>> _liveList(
    String path, {
    required String liveSlug,
    Map<String, dynamic>? query,
  }) async {
    final envelope = await _api.getEnvelope<dynamic>(
      path,
      mode: _staff,
      query: query,
      parse: (raw) => raw,
    );
    final root = DemoRepositorySupport.coerceRoot(
      path,
      _rootOf(envelope.data, envelope.meta),
    );
    return asAutoMapList(root['data']);
  }

  /// Execuções LIVE `GET /v1/automation/executions` — parsing no DTO VT
  /// (UI compartilha widgets com a Equipe Virtual).
  Future<VtPagedList<VtExecution>> executions({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        _staff.automationsExecutionsPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: (raw) => raw,
      );
      return VtPagedList(
        items: asMapList(envelope.data).map(VtExecution.fromJson).toList(),
        meta: _metaOf(envelope.meta),
      );
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        return _virtualTeam.executions(filter: filter);
      }
      rethrow;
    }
  }

  /// Alertas LIVE `GET /v1/automation/alerts`.
  Future<VtPagedList<VtAlert>> alerts({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        _staff.automationsAlertsPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: (raw) => raw,
      );
      return VtPagedList(
        items: asMapList(envelope.data).map(VtAlert.fromJson).toList(),
        meta: _metaOf(envelope.meta),
      );
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) return _virtualTeam.alerts(filter: filter);
      rethrow;
    }
  }

  /// Métricas LIVE `GET /v1/automation/metrics` (KPIs no formato VT).
  Future<VtDashboard> metrics({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.automationsMetricsPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: asAutoMap,
      );
      return VtDashboard.fromJson(envelope.data);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) return _virtualTeam.metrics(filter: filter);
      rethrow;
    }
  }

  /// Registros LIVE `GET /v1/automation/logs`.
  Future<VtPagedList<VtLogEntry>> logs({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        _staff.automationsLogsPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: (raw) => raw,
      );
      return VtPagedList(
        items: asMapList(envelope.data).map(VtLogEntry.fromJson).toList(),
        meta: _metaOf(envelope.meta),
      );
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) return _virtualTeam.logs(filter: filter);
      rethrow;
    }
  }

  /// Linha do tempo — sem contrato de automação no catálogo c29c2ad;
  /// reuse LIVE da Equipe Virtual.
  Future<VtPagedList<VtTimelineItem>> timeline({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) => _virtualTeam.timeline(filter: filter);

  /// Autonomia (leitura) — LIVE `GET /v1/automation/agents`;
  /// fallback legado `/v1/ai/team` se o contrato regredir.
  Future<List<AutoAgentAutonomy>> agentAutonomies() async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        _staff.automationsAgentsPath,
        mode: _staff,
        parse: (raw) => raw,
      );
      final list = asAutoMapList(envelope.data)
          .map(AutoAgentAutonomy.fromJson)
          .where((a) => a.agentSlug.isNotEmpty)
          .toList(growable: false);
      if (list.isNotEmpty) return list;
      return _autonomiesFromAiTeam();
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) return _autonomiesFromAiTeam();
      rethrow;
    }
  }

  Future<List<AutoAgentAutonomy>> _autonomiesFromAiTeam() async {
    final envelope = await _api.getEnvelope<List<AutoAgentAutonomy>>(
      _staff.aiTeamPath,
      mode: _staff,
      parse: (raw) {
        final map = asAutoMap(raw);
        final list = <AutoAgentAutonomy>[];
        void add(dynamic node) {
          if (node is Map) {
            list.add(
              AutoAgentAutonomy.fromJson(Map<String, dynamic>.from(node)),
            );
          }
        }

        add(map['director']);
        final agents = map['agents'] ?? map['specialists'] ?? map['team'];
        if (agents is List) {
          for (final a in agents) {
            add(a);
          }
        }
        if (list.isEmpty) {
          for (final e in map.entries) {
            if (e.value is Map &&
                (e.value as Map).containsKey('autonomy_level')) {
              add(e.value);
            }
          }
        }
        return list;
      },
    );
    return envelope.data;
  }

  /// Lista LIVE `GET /v1/automation/rules`.
  Future<List<AutoAutomation>> automations() async {
    final path = _staff.automationsRootPath;
    try {
      final items = await _liveList(path, liveSlug: 'rules');
      return items.map(AutoAutomation.fromJson).toList(growable: false);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        final root = DemoRepositorySupport.rootFor(path);
        return asAutoMapList(
          root['data'],
        ).map(AutoAutomation.fromJson).toList(growable: false);
      }
      rethrow;
    }
  }

  /// Detalhe LIVE `GET /v1/automation/rules/{id}`.
  Future<AutoAutomation> automationDetail(String id) async {
    final path = _staff.automationPath(id);
    if (DemoRepositorySupport.isDemoId(id)) {
      return AutoAutomation.fromJson(DemoRepositorySupport.firstItem(path));
    }
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        path,
        mode: _staff,
        parse: asAutoMap,
      );
      return AutoAutomation.fromJson(envelope.data);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        return AutoAutomation.fromJson(DemoRepositorySupport.firstItem(path));
      }
      rethrow;
    }
  }

  /// Aprovações LIVE `GET /v1/automation/approvals`.
  Future<List<AutoApproval>> approvals() async {
    final path = _staff.automationsApprovalsPath;
    try {
      final items = await _liveList(path, liveSlug: 'approvals');
      return items.map(AutoApproval.fromJson).toList(growable: false);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        final root = DemoRepositorySupport.rootFor(path);
        return asAutoMapList(
          root['data'],
        ).map(AutoApproval.fromJson).toList(growable: false);
      }
      rethrow;
    }
  }

  /// Agenda LIVE `GET /v1/automation/schedules`.
  Future<List<AutoAutomation>> schedules() async {
    final path = _staff.automationsSchedulePath;
    try {
      final items = await _liveList(path, liveSlug: 'schedules');
      return items.map(AutoAutomation.fromJson).toList(growable: false);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        final root = DemoRepositorySupport.rootFor(path);
        return asAutoMapList(
          root['data'],
        ).map(AutoAutomation.fromJson).toList(growable: false);
      }
      rethrow;
    }
  }

  /// Escrita de autonomia — contrato de escrita ainda não publicado
  /// no catálogo c29c2ad; mantém estado pendente honesto.
  Future<void> autonomyWrite() async {
    throw EndpointUnavailableException(
      _staff.automationsAgentsPath,
      statusCode: 405,
    );
  }

  VtPageMeta? _metaOf(Map<String, dynamic>? meta) =>
      meta == null ? null : VtPageMeta.fromJson(meta);
}
