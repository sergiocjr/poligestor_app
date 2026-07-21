import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'admin_cache.dart';
import 'admin_contracts.dart';
import 'admin_models.dart';

/// Administração do Sistema — namespace oficial `/v1/admin/*` (Fase 19).
class AdminRepository {
  AdminRepository(this._api, {AdminCache? cache})
    : _cache = cache ?? AdminCache();

  final ApiClient _api;
  final AdminCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asAdminMap(data) : data,
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

  List<AdminItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asAdminMapList(data)
        : asAdminMapList(asAdminMap(data));
    return list.map(AdminItem.fromJson).toList(growable: false);
  }

  Future<List<AdminItem>> _list(
    String tenantSlug,
    String cacheKey,
    String path, {
    Map<String, dynamic>? query,
    bool allowCache = true,
    String? liveSlug,
  }) async {
    final slug = liveSlug ?? cacheKey.replaceAll('_', '-');
    if (!adminPathLive(slug)) {
      return _itemsOf(DemoRepositorySupport.rootFor(path));
    }
    return _cachedGet(
      tenantSlug: tenantSlug,
      cacheKey: cacheKey,
      path: path,
      query: query,
      allowCache: allowCache,
      parse: (root, {fromCache = false, age}) => _itemsOf(root),
    );
  }

  Future<List<AdminItem>> dashboard({required String tenantSlug}) =>
      _list(tenantSlug, 'dashboard', _staff.adminDashboardPath);

  Future<List<AdminItem>> companies({required String tenantSlug}) =>
      _list(tenantSlug, 'companies', _staff.adminCompaniesPath);

  Future<List<AdminItem>> offices({required String tenantSlug}) =>
      _list(tenantSlug, 'offices', _staff.adminOfficesPath);

  Future<List<AdminItem>> users({required String tenantSlug}) =>
      _list(tenantSlug, 'users', _staff.adminUsersPath);

  Future<List<AdminItem>> profiles({required String tenantSlug}) =>
      _list(tenantSlug, 'profiles', _staff.adminProfilesPath);

  Future<List<AdminItem>> roles({required String tenantSlug}) =>
      _list(tenantSlug, 'roles', _staff.adminRolesPath);

  Future<List<AdminItem>> permissions({required String tenantSlug}) =>
      _list(tenantSlug, 'permissions', _staff.adminPermissionsPath);

  Future<List<AdminItem>> teams({required String tenantSlug}) =>
      _list(tenantSlug, 'teams', _staff.adminTeamsPath);

  Future<List<AdminItem>> departments({required String tenantSlug}) =>
      _list(tenantSlug, 'departments', _staff.adminDepartmentsPath);

  Future<List<AdminItem>> settings({required String tenantSlug}) =>
      _list(tenantSlug, 'settings', _staff.adminSettingsPath);

  Future<List<AdminItem>> licensing({required String tenantSlug}) =>
      _list(tenantSlug, 'licensing', _staff.adminLicensingPath);

  Future<List<AdminItem>> subscriptions({required String tenantSlug}) =>
      _list(tenantSlug, 'subscriptions', _staff.adminSubscriptionsPath);

  Future<List<AdminItem>> logs({required String tenantSlug}) =>
      _list(tenantSlug, 'logs', _staff.adminLogsPath);

  Future<List<AdminItem>> audit({required String tenantSlug}) =>
      _list(tenantSlug, 'audit', _staff.adminAuditPath);

  Future<List<AdminItem>> sessions({required String tenantSlug}) =>
      _list(tenantSlug, 'sessions', _staff.adminSessionsPath);

  Future<List<AdminItem>> apiKeys({required String tenantSlug}) =>
      _list(tenantSlug, 'api_keys', _staff.adminApiKeysPath, liveSlug: 'api-keys');

  Future<List<AdminItem>> integrations({required String tenantSlug}) =>
      _list(tenantSlug, 'integrations', _staff.adminIntegrationsPath);

  Future<List<AdminItem>> webhooks({required String tenantSlug}) =>
      _list(tenantSlug, 'webhooks', _staff.adminWebhooksPath);

  Future<List<AdminItem>> backup({required String tenantSlug}) =>
      _list(tenantSlug, 'backup', _staff.adminBackupPath);

  Future<List<AdminItem>> monitoring({required String tenantSlug}) =>
      _list(tenantSlug, 'monitoring', _staff.adminMonitoringPath);

  Future<List<AdminItem>> health({required String tenantSlug}) =>
      _list(tenantSlug, 'health', _staff.adminHealthPath);

  Future<List<AdminItem>> emailSettings({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'email_settings',
        _staff.adminEmailSettingsPath,
        liveSlug: 'email-settings',
      );

  Future<List<AdminItem>> notificationSettings({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'notification_settings',
    _staff.adminNotificationSettingsPath,
    liveSlug: 'notification-settings',
  );

  Future<List<AdminItem>> storageSettings({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'storage_settings',
        _staff.adminStorageSettingsPath,
        liveSlug: 'storage-settings',
      );

  Future<List<AdminItem>> reports({required String tenantSlug}) =>
      _list(tenantSlug, 'reports', _staff.adminReportsPath);

  Future<List<AdminItem>> exports({required String tenantSlug}) =>
      _list(tenantSlug, 'exports', _staff.adminExportsPath);

  Future<List<AdminItem>> filters({required String tenantSlug}) =>
      _list(tenantSlug, 'filters', _staff.adminFiltersPath);

  Future<List<AdminItem>> search({
    required String tenantSlug,
    required String query,
  }) => _list(
    tenantSlug,
    'search_${query.hashCode}',
    _staff.adminSearchPath,
    query: {'q': query},
    liveSlug: 'search',
  );
}
