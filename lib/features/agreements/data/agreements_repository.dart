import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'agreements_cache.dart';
import 'agreements_models.dart';

/// Painel de Convênios — namespace LIVE `/v1/grants/*`.
class AgreementsRepository {
  AgreementsRepository(this._api, {AgreementsCache? cache})
    : _cache = cache ?? AgreementsCache();

  final ApiClient _api;
  final AgreementsCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asAgreementsMap(data) : data,
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

  List<AgreementsItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    if (data is Map && data is! List) {
      final map = asAgreementsMap(data);
      if (map.containsKey('agreements_by_status') ||
          map.containsKey('execution_totals')) {
        return _reportsOf(map);
      }
    }
    final list = data is List
        ? asAgreementsMapList(data)
        : asAgreementsMapList(asAgreementsMap(data));
    return list.map(AgreementsItem.fromJson).toList(growable: false);
  }

  List<AgreementsItem> _reportsOf(Map<String, dynamic> data) {
    final items = <AgreementsItem>[];
    final byStatus = asAgreementsMap(data['agreements_by_status']);
    for (final entry in byStatus.entries) {
      items.add(
        AgreementsItem(
          id: 'status-${entry.key}',
          title: 'Convênios — ${entry.key}',
          status: entry.key.toString(),
          amount: asAgreementsDouble(entry.value),
        ),
      );
    }
    final exec = asAgreementsMap(data['execution_totals']);
    if (exec.isNotEmpty) {
      items.add(
        AgreementsItem(
          id: 'execution-totals',
          title: 'Totais de execução',
          summary:
              'Empenhado: ${exec['committed'] ?? 0} · '
              'Pago: ${exec['paid'] ?? 0} · '
              'Executado: ${exec['executed'] ?? 0} · '
              'Saldo: ${exec['balance'] ?? 0}',
        ),
      );
    }
    final avgPhysical = data['avg_physical_percent'];
    final avgFinancial = data['avg_financial_percent'];
    if (avgPhysical != null || avgFinancial != null) {
      items.add(
        AgreementsItem(
          id: 'averages',
          title: 'Médias de avanço',
          summary:
              'Físico: ${avgPhysical ?? 0}% · Financeiro: ${avgFinancial ?? 0}%',
        ),
      );
    }
    return items;
  }

  Future<AgreementsDashboard> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'dashboard',
    path: _staff.agreementsDashboardPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => AgreementsDashboard.fromJson(
      root,
      fromCache: fromCache,
      cacheAgeLabel: age,
    ),
  );

  Future<List<AgreementsItem>> agreements({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'agreements', _staff.agreementsListPath, allowCache);

  Future<List<AgreementsItem>> resources({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'resources',
    _staff.agreementsResourcesPath,
    allowCache,
  );

  Future<List<AgreementsItem>> projects({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'projects', _staff.agreementsProjectsPath, allowCache);

  Future<List<AgreementsItem>> execution({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'execution',
    _staff.agreementsExecutionPath,
    allowCache,
  );

  Future<List<AgreementsItem>> accountability({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'accountability',
    _staff.agreementsAccountabilityPath,
    allowCache,
  );

  Future<List<AgreementsItem>> schedule({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'schedule', _staff.agreementsSchedulePath, allowCache);

  Future<List<AgreementsItem>> timeline({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'timeline', _staff.agreementsTimelinePath, allowCache);

  Future<List<AgreementsItem>> documents({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'documents',
    _staff.agreementsDocumentsPath,
    allowCache,
  );

  Future<List<AgreementsItem>> attachments({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'attachments',
    _staff.agreementsAttachmentsPath,
    allowCache,
  );

  Future<List<AgreementsItem>> indicators({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'indicators',
    _staff.agreementsIndicatorsPath,
    allowCache,
  );

  Future<List<AgreementsItem>> reports({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'reports', _staff.agreementsReportsPath, allowCache);

  Future<List<AgreementsItem>> _list(
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

  Future<AgreementsItem> agreementDetail(String id) async {
    final path = _staff.agreementsItemPath(id);
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        path,
        mode: _staff,
        parse: asAgreementsMap,
      );
      return AgreementsItem.fromJson(envelope.data);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        return AgreementsItem.fromJson(DemoRepositorySupport.firstItem(path));
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

  Future<void> search() => assertPending(_staff.agreementsSearchPath);
}
