import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import '../../virtual_team/data/virtual_team_models.dart';
import '../../virtual_team/data/virtual_team_repository.dart';
import 'automation_cache.dart';
import 'automation_models.dart';

/// Hub Automação — LIVE via Equipe Virtual; namespace `/v1/automations*` pending.
class AutomationRepository {
  AutomationRepository(this._api, this._virtualTeam, {AutomationCache? cache})
    : _cache = cache ?? AutomationCache();

  final ApiClient _api;
  final VirtualTeamRepository _virtualTeam;
  final AutomationCache _cache;
  static const _staff = AuthMode.staff;

  VirtualTeamRepository get virtualTeam => _virtualTeam;

  Future<AutoDashboardSnapshot> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) async {
    try {
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
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getDashboard(tenantSlug);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<List<VtAgent>> agents({bool allowCache = true}) =>
      _virtualTeam.agents(allowCache: allowCache);

  Future<VtPagedList<VtExecution>> executions({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) => _virtualTeam.executions(filter: filter);

  Future<VtPagedList<VtAlert>> alerts({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) => _virtualTeam.alerts(filter: filter);

  Future<VtDashboard> metrics({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) => _virtualTeam.metrics(filter: filter);

  Future<VtPagedList<VtLogEntry>> logs({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) => _virtualTeam.logs(filter: filter);

  Future<VtPagedList<VtTimelineItem>> timeline({
    VirtualTeamFilter filter = const VirtualTeamFilter(),
  }) => _virtualTeam.timeline(filter: filter);

  Future<List<AutoAgentAutonomy>> agentAutonomies() async {
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

  Future<List<AutoAutomation>> automations() async {
    try {
      final envelope = await _api.getEnvelope<List<AutoAutomation>>(
        _staff.automationsRootPath,
        mode: _staff,
        parse: (raw) => asAutoMapList(
          raw,
        ).map(AutoAutomation.fromJson).toList(growable: false),
      );
      return envelope.data;
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.automationsRootPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<void> assertPending(String path) async {
    try {
      await _api.getEnvelope<dynamic>(path, mode: _staff, parse: (raw) => raw);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        return;
      }
      rethrow;
    }
  }

  Future<void> approvals() => assertPending(_staff.automationsApprovalsPath);
  Future<void> schedule() => assertPending(_staff.automationsSchedulePath);
  Future<void> autonomyWrite() => assertPending(_staff.automationsAutonomyPath);

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;
}
