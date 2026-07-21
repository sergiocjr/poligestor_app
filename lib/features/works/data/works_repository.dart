import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import '../../mandate/data/mandate_models.dart';
import '../../mandate/data/mandate_repository.dart';
import 'works_cache.dart';
import 'works_models.dart';

/// Painel Obras — namespace `/v1/works*` preparado; mapa reusa mandato LIVE.
class WorksRepository {
  WorksRepository(this._api, this._mandate, {WorksCache? cache})
    : _cache = cache ?? WorksCache();

  final ApiClient _api;
  final MandateRepository _mandate;
  final WorksCache _cache;
  static const _staff = AuthMode.staff;

  MandateRepository get mandate => _mandate;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asWorksMap(data) : data,
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
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        path,
        mode: _staff,
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

  List<WorksItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asWorksMapList(data)
        : asWorksMapList(asWorksMap(data));
    return list.map(WorksItem.fromJson).toList(growable: false);
  }

  Future<WorksDashboard> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'dashboard',
    path: _staff.worksDashboardPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) =>
        WorksDashboard.fromJson(root, fromCache: fromCache, cacheAgeLabel: age),
  );

  Future<List<WorksItem>> projects({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'projects', _staff.worksListPath, allowCache);

  Future<List<WorksItem>> demands({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'demands', _staff.worksDemandsPath, allowCache);

  Future<List<WorksItem>> inspections({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'inspections', _staff.worksInspectionsPath, allowCache);

  Future<List<WorksItem>> schedule({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'schedule', _staff.worksSchedulePath, allowCache);

  Future<List<WorksItem>> timeline({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'timeline', _staff.worksTimelinePath, allowCache);

  Future<List<WorksItem>> photos({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'photos', _staff.worksPhotosPath, allowCache);

  Future<List<WorksItem>> attachments({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'attachments', _staff.worksAttachmentsPath, allowCache);

  Future<List<WorksItem>> checklist({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'checklist', _staff.worksChecklistPath, allowCache);

  Future<List<WorksItem>> indicators({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'indicators', _staff.worksIndicatorsPath, allowCache);

  Future<List<WorksItem>> reports({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'reports', _staff.worksReportsPath, allowCache);

  Future<List<WorksItem>> _list(
    String tenantSlug,
    String cacheKey,
    String path,
    bool allowCache,
  ) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: cacheKey,
    path: path,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<WorksItem> projectDetail(String id) async {
    final path = _staff.worksItemPath(id);
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        path,
        mode: _staff,
        parse: asWorksMap,
      );
      return WorksItem.fromJson(envelope.data);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        return WorksItem.fromJson(DemoRepositorySupport.firstItem(path));
      }
      rethrow;
    }
  }

  Future<void> assertPending(String path) async {
    try {
      await _api.getEnvelope<dynamic>(path, mode: _staff, parse: (raw) => raw);
    } on ApiException catch (e) {
      if (_pending(e.statusCode) || e.statusCode == 500) {
        return;
      }
      rethrow;
    }
  }

  Future<void> worksMapContract() => assertPending(_staff.worksMapPath);
  Future<void> search() => assertPending(_staff.worksSearchPath);

  /// Mapa territorial — reuse contrato mandato LIVE enquanto obras/map pendente.
  Future<MandateMapData> mandateMap({
    MandateFilter filter = const MandateFilter(),
  }) => _mandate.map(filter: filter);
}
