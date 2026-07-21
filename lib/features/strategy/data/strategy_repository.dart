import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import '../../mandate/data/mandate_models.dart';
import '../../mandate/data/mandate_repository.dart';
import 'strategy_cache.dart';
import 'strategy_models.dart';

/// Painel Estratégico — LIVE `/v1/strategy/*` + reuse mandato quando necessário.
class StrategyRepository {
  StrategyRepository(this._api, this._mandate, {StrategyCache? cache})
    : _cache = cache ?? StrategyCache();

  final ApiClient _api;
  final MandateRepository _mandate;
  final StrategyCache _cache;
  static const _staff = AuthMode.staff;

  MandateRepository get mandate => _mandate;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asStrategyMap(data) : data,
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

  /// Prefer `/v1/strategy/dashboard`; se 404/500, KPIs LIVE.
  Future<StrategyKpiSummary> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) async {
    try {
      return await _cachedGet(
        tenantSlug: tenantSlug,
        cacheKey: 'dashboard',
        path: _staff.strategyDashboardPath,
        allowCache: allowCache,
        parse: (root, {fromCache = false, age}) => StrategyKpiSummary.fromJson(
          root,
          fromCache: fromCache,
          cacheAgeLabel: age,
        ),
      );
    } on EndpointUnavailableException {
      return kpis(tenantSlug: tenantSlug, allowCache: allowCache);
    } on ApiException catch (e) {
      if (e.statusCode == 500) {
        return kpis(tenantSlug: tenantSlug, allowCache: allowCache);
      }
      rethrow;
    }
  }

  Future<StrategyKpiSummary> kpis({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'kpis',
    path: _staff.strategyKpisPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => StrategyKpiSummary.fromJson(
      root,
      fromCache: fromCache,
      cacheAgeLabel: age,
    ),
  );

  Future<StrategyHeatmapData> heatmap({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'heatmap',
    path: _staff.strategyHeatmapPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => StrategyHeatmapData.fromJson(
      root,
      fromCache: fromCache,
      cacheAgeLabel: age,
    ),
  );

  Future<StrategyTrendsData> trends({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'trends',
    path: _staff.strategyTrendsPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => StrategyTrendsData.fromJson(
      root,
      fromCache: fromCache,
      cacheAgeLabel: age,
    ),
  );

  Future<List<StrategyAlert>> alerts({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'alerts',
    path: _staff.strategyAlertsPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) {
      final data = root['data'];
      final list = data is List
          ? asStrategyMapList(data)
          : asStrategyMapList(asStrategyMap(data)['items']);
      return list.map(StrategyAlert.fromJson).toList(growable: false);
    },
  );

  Future<StrategyRegionsData> regions({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'regions',
    path: _staff.strategyRegionsPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => StrategyRegionsData.fromJson(
      root,
      fromCache: fromCache,
      cacheAgeLabel: age,
    ),
  );

  Future<List<StrategyNeighborhood>> neighborhoods({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'neighborhoods',
    path: _staff.strategyNeighborhoodsPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) {
      final data = root['data'];
      final list = data is List
          ? asStrategyMapList(data)
          : asStrategyMapList(asStrategyMap(data)['items']);
      return list.map(StrategyNeighborhood.fromJson).toList(growable: false);
    },
  );

  Future<StrategyForecastsData> forecasts({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'forecasts',
    path: _staff.strategyForecastsPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => StrategyForecastsData.fromJson(
      root,
      fromCache: fromCache,
      cacheAgeLabel: age,
    ),
  );

  Future<List<StrategyReportItem>> reports({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'reports',
    path: _staff.strategyReportsPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) {
      final data = root['data'];
      final list = data is List
          ? asStrategyMapList(data)
          : asStrategyMapList(asStrategyMap(data)['items']);
      return list.map(StrategyReportItem.fromJson).toList(growable: false);
    },
  );

  Future<List<StrategyGoal>> goals({required String tenantSlug}) async {
    return _cachedGet(
      tenantSlug: tenantSlug,
      cacheKey: 'goals',
      path: _staff.strategyGoalsPath,
      allowCache: true,
      parse: (root, {fromCache = false, age}) {
        final data = root['data'];
        final list = data is List
            ? asStrategyMapList(data)
            : asStrategyMapList(
                asStrategyMap(data)['items'] ?? asStrategyMap(data)['goals'],
              );
        return list.map(StrategyGoal.fromJson).toList(growable: false);
      },
    );
  }

  Future<List<StrategyReportItem>> comparison({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'comparison',
    path: _staff.strategyComparePath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) {
      final data = root['data'];
      final list = data is List
          ? asStrategyMapList(data)
          : asStrategyMapList(
              asStrategyMap(data)['items'] ?? asStrategyMap(data)['comparisons'],
            );
      return list.map(StrategyReportItem.fromJson).toList(growable: false);
    },
  );

  /// Paths fora do catálogo LIVE c29c2ad — UI demo sem probe HTTP.
  Future<void> assertPending(String path) async {
    return;
  }

  Future<void> indicators() => assertPending(_staff.strategyIndicatorsPath);
  Future<void> predictions() => assertPending(_staff.strategyPredictionsPath);

  Future<void> strategyMapContract() async {
    final path = _staff.strategyMapPath;
    try {
      await _api.getEnvelope<dynamic>(path, mode: _staff, parse: (raw) => raw);
    } on ApiException catch (e) {
      if (_pending(e.statusCode) || e.statusCode == 500) {
        throw EndpointUnavailableException(path, statusCode: e.statusCode);
      }
      rethrow;
    }
  }

  /// Mapa territorial — reuse contrato mandato LIVE.
  Future<MandateMapData> mandateMap({
    MandateFilter filter = const MandateFilter(),
  }) => _mandate.map(filter: filter);
}
