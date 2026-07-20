import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'territorial_intelligence_cache.dart';
import 'territorial_intelligence_models.dart';

/// Inteligência Territorial — namespace oficial `/v1/intelligence/*` (Fase 12).
class TerritorialIntelligenceRepository {
  TerritorialIntelligenceRepository(
    this._api, {
    TerritorialIntelligenceCache? cache,
  }) : _cache = cache ?? TerritorialIntelligenceCache();

  final ApiClient _api;
  final TerritorialIntelligenceCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asTiMap(data) : data,
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
      final root = _rootOf(envelope.data, envelope.meta);
      await _cache.putMap(tenantSlug, cacheKey, root);
      return parse(root, fromCache: false, age: null);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(path, statusCode: e.statusCode);
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

  List<TerritorialItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asTiMapList(data)
        : asTiMapList(asTiMap(data));
    return list.map(TerritorialItem.fromJson).toList(growable: false);
  }

  Future<TerritorialDashboard> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'dashboard',
    path: _staff.intelligenceDashboardPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => TerritorialDashboard.fromJson(
      root,
      fromCache: fromCache,
      cacheAgeLabel: age,
    ),
  );

  Future<List<TerritorialItem>> bi({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'bi', _staff.intelligenceBiPath, allowCache);

  Future<List<TerritorialItem>> kpis({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'kpis', _staff.intelligenceKpisPath, allowCache);

  Future<List<TerritorialItem>> indicators({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'indicators',
    _staff.intelligenceIndicatorsPath,
    allowCache,
  );

  Future<List<TerritorialItem>> charts({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'charts', _staff.intelligenceChartsPath, allowCache);

  Future<List<TerritorialItem>> heatmap({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'heatmap', _staff.intelligenceHeatmapPath, allowCache);

  Future<List<TerritorialItem>> map({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'map', _staff.intelligenceMapPath, allowCache);

  Future<List<TerritorialItem>> neighborhoods({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'neighborhoods',
    _staff.intelligenceNeighborhoodsPath,
    allowCache,
  );

  Future<List<TerritorialItem>> regions({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'regions', _staff.intelligenceRegionsPath, allowCache);

  Future<List<TerritorialItem>> electoralZones({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'electoral_zones',
    _staff.intelligenceElectoralZonesPath,
    allowCache,
  );

  Future<List<TerritorialItem>> leaderships({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'leaderships',
    _staff.intelligenceLeadershipsPath,
    allowCache,
  );

  Future<List<TerritorialItem>> demands({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'demands', _staff.intelligenceDemandsPath, allowCache);

  Future<List<TerritorialItem>> works({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'works', _staff.intelligenceWorksPath, allowCache);

  Future<List<TerritorialItem>> protocols({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'protocols',
    _staff.intelligenceProtocolsPath,
    allowCache,
  );

  Future<List<TerritorialItem>> attendances({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'attendances',
    _staff.intelligenceAttendancesPath,
    allowCache,
  );

  Future<List<TerritorialItem>> comparatives({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'comparatives',
    _staff.intelligenceComparativesPath,
    allowCache,
  );

  Future<List<TerritorialItem>> evolution({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'evolution',
    _staff.intelligenceEvolutionPath,
    allowCache,
  );

  Future<List<TerritorialItem>> trends({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'trends', _staff.intelligenceTrendsPath, allowCache);

  Future<List<TerritorialItem>> projections({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'projections',
    _staff.intelligenceProjectionsPath,
    allowCache,
  );

  Future<List<TerritorialItem>> filters({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'filters', _staff.intelligenceFiltersPath, allowCache);

  Future<List<TerritorialItem>> exports({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'exports', _staff.intelligenceExportsPath, allowCache);

  Future<List<TerritorialItem>> _list(
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
}
