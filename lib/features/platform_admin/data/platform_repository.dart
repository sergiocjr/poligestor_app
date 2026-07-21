import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'platform_cache.dart';
import 'platform_contracts.dart';
import 'platform_models.dart';

/// Portal Administrativo Web — namespace oficial `/v1/platform/*` (Fase 20).
class PlatformRepository {
  PlatformRepository(this._api, {PlatformCache? cache})
    : _cache = cache ?? PlatformCache();

  final ApiClient _api;
  final PlatformCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asPlatformMap(data) : data,
    };
    if (meta != null) root['meta'] = meta;
    return root;
  }

  Future<T> _cachedGet<T>({
    required String tenantSlug,
    required String cacheKey,
    required String path,
    required T Function(
      Map<String, dynamic> root, {
      bool fromCache,
      String? age,
    })
    parse,
    Map<String, dynamic>? query,
    bool allowCache = true,
  }) async {
    try {
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
      await _cache.putMap(tenantSlug, cacheKey, root);
      return parse(
        root,
        fromCache: false,
        age: DemoRepositorySupport.ageForRoot(root),
      );
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        return parse(
          DemoRepositorySupport.rootFor(path),
          fromCache: false,
          age: DemoRepositorySupport.ageLabel,
        );
      }
      if (allowCache) {
        final cached = await _cache.getMap(tenantSlug, cacheKey);
        if (cached != null) {
          return parse(cached.data, fromCache: true, age: cached.ageLabel);
        }
      }
      rethrow;
    } catch (e) {
      if (e is EndpointUnavailableException) rethrow;
      if (allowCache) {
        final cached = await _cache.getMap(tenantSlug, cacheKey);
        if (cached != null) {
          return parse(cached.data, fromCache: true, age: cached.ageLabel);
        }
      }
      rethrow;
    }
  }

  List<PlatformItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asPlatformMapList(data)
        : asPlatformMapList(asPlatformMap(data));
    return list.map(PlatformItem.fromJson).toList(growable: false);
  }

  Future<List<PlatformItem>> _list(
    String tenantSlug,
    String cacheKey,
    String path, {
    Map<String, dynamic>? query,
    bool allowCache = true,
    String? liveSlug,
  }) async {
    return _cachedGet(
      tenantSlug: tenantSlug,
      cacheKey: cacheKey,
      path: path,
      query: query,
      allowCache: allowCache,
      parse: (root, {fromCache = false, age}) => _itemsOf(root),
    );
  }

  Future<List<PlatformItem>> dashboard({required String tenantSlug}) =>
      _list(tenantSlug, 'dashboard', _staff.platformDashboardPath);

  Future<List<PlatformItem>> companies({required String tenantSlug}) =>
      _list(tenantSlug, 'companies', _staff.platformCompaniesPath);

  Future<List<PlatformItem>> offices({required String tenantSlug}) =>
      _list(tenantSlug, 'offices', _staff.platformOfficesPath);

  Future<List<PlatformItem>> users({required String tenantSlug}) =>
      _list(tenantSlug, 'users', _staff.platformUsersPath);

  Future<List<PlatformItem>> profiles({required String tenantSlug}) =>
      _list(tenantSlug, 'profiles', _staff.platformProfilesPath);

  Future<List<PlatformItem>> permissions({required String tenantSlug}) =>
      _list(tenantSlug, 'permissions', _staff.platformPermissionsPath);

  Future<List<PlatformItem>> plans({required String tenantSlug}) =>
      _list(tenantSlug, 'plans', _staff.platformPlansPath);

  Future<List<PlatformItem>> licensing({required String tenantSlug}) =>
      _list(tenantSlug, 'licensing', _staff.platformLicensingPath);

  Future<List<PlatformItem>> subscriptions({required String tenantSlug}) =>
      _list(tenantSlug, 'subscriptions', _staff.platformSubscriptionsPath);

  Future<List<PlatformItem>> charges({required String tenantSlug}) =>
      _list(tenantSlug, 'charges', _staff.platformChargesPath);

  Future<List<PlatformItem>> invoices({required String tenantSlug}) =>
      _list(tenantSlug, 'invoices', _staff.platformInvoicesPath);

  Future<List<PlatformItem>> payments({required String tenantSlug}) =>
      _list(tenantSlug, 'payments', _staff.platformPaymentsPath);

  Future<List<PlatformItem>> consumption({required String tenantSlug}) =>
      _list(tenantSlug, 'consumption', _staff.platformConsumptionPath);

  Future<List<PlatformItem>> planLimits({required String tenantSlug}) => _list(
    tenantSlug,
    'plan_limits',
    _staff.platformPlanLimitsPath,
    liveSlug: 'plan-limits',
  );

  Future<List<PlatformItem>> metrics({required String tenantSlug}) =>
      _list(tenantSlug, 'metrics', _staff.platformMetricsPath);

  Future<List<PlatformItem>> monitoring({required String tenantSlug}) =>
      _list(tenantSlug, 'monitoring', _staff.platformMonitoringPath);

  Future<List<PlatformItem>> health({required String tenantSlug}) =>
      _list(tenantSlug, 'health', _staff.platformHealthPath);

  Future<List<PlatformItem>> logs({required String tenantSlug}) =>
      _list(tenantSlug, 'logs', _staff.platformLogsPath);

  Future<List<PlatformItem>> audit({required String tenantSlug}) =>
      _list(tenantSlug, 'audit', _staff.platformAuditPath);

  Future<List<PlatformItem>> sessions({required String tenantSlug}) =>
      _list(tenantSlug, 'sessions', _staff.platformSessionsPath);

  Future<List<PlatformItem>> integrations({required String tenantSlug}) =>
      _list(tenantSlug, 'integrations', _staff.platformIntegrationsPath);

  Future<List<PlatformItem>> webhooks({required String tenantSlug}) =>
      _list(tenantSlug, 'webhooks', _staff.platformWebhooksPath);

  Future<List<PlatformItem>> globalSettings({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'global_settings',
        _staff.platformGlobalSettingsPath,
        liveSlug: 'global-settings',
      );

  Future<List<PlatformItem>> tenantSettings({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'tenant_settings',
        _staff.platformTenantSettingsPath,
        liveSlug: 'tenant-settings',
      );

  Future<List<PlatformItem>> support({required String tenantSlug}) =>
      _list(tenantSlug, 'support', _staff.platformSupportPath);

  Future<List<PlatformItem>> tickets({required String tenantSlug}) =>
      _list(tenantSlug, 'tickets', _staff.platformTicketsPath);

  Future<List<PlatformItem>> knowledgeBase({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'knowledge_base',
        _staff.platformKnowledgeBasePath,
        liveSlug: 'knowledge-base',
      );

  Future<List<PlatformItem>> announcements({required String tenantSlug}) =>
      _list(tenantSlug, 'announcements', _staff.platformAnnouncementsPath);

  Future<List<PlatformItem>> releases({required String tenantSlug}) =>
      _list(tenantSlug, 'releases', _staff.platformReleasesPath);

  Future<List<PlatformItem>> maintenances({required String tenantSlug}) =>
      _list(tenantSlug, 'maintenances', _staff.platformMaintenancesPath);

  Future<List<PlatformItem>> reports({required String tenantSlug}) =>
      _list(tenantSlug, 'reports', _staff.platformReportsPath);

  Future<List<PlatformItem>> exports({required String tenantSlug}) =>
      _list(tenantSlug, 'exports', _staff.platformExportsPath);

  Future<List<PlatformItem>> filters({required String tenantSlug}) =>
      _list(tenantSlug, 'filters', _staff.platformFiltersPath);

  Future<List<PlatformItem>> search({
    required String tenantSlug,
    required String query,
  }) => _list(
    tenantSlug,
    'search_${query.hashCode}',
    _staff.platformSearchPath,
    query: {'q': query},
    liveSlug: 'search',
  );
}
