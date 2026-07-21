import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'parliament_cache.dart';
import 'parliament_models.dart';

/// Painel Parlamentar — LIVE `/v1/parliament/*`.
class ParliamentRepository {
  ParliamentRepository(this._api, {ParliamentCache? cache})
    : _cache = cache ?? ParliamentCache();

  final ApiClient _api;
  final ParliamentCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asParlMap(data) : data,
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

  List<ParliamentItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asParlMapList(data)
        : asParlMapList(asParlMap(data)['items']);
    return list.map(ParliamentItem.fromJson).toList(growable: false);
  }

  Future<ParliamentDashboard> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'dashboard',
    path: _staff.parliamentDashboardPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => ParliamentDashboard.fromJson(
      root,
      fromCache: fromCache,
      cacheAgeLabel: age,
    ),
  );

  Future<List<ParliamentItem>> bills({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'bills', _staff.parliamentBillsPath, allowCache);

  Future<List<ParliamentItem>> projects({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'projects', _staff.parliamentProjectsPath, allowCache);

  Future<List<ParliamentItem>> indications({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'indications',
    _staff.parliamentIndicationsPath,
    allowCache,
  );

  Future<List<ParliamentItem>> requests({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'requests', _staff.parliamentRequestsPath, allowCache);

  Future<List<ParliamentItem>> motions({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'motions', _staff.parliamentMotionsPath, allowCache);

  Future<List<ParliamentItem>> amendments({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'amendments',
    _staff.parliamentAmendmentsPath,
    allowCache,
  );

  Future<List<ParliamentItem>> agenda({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'agenda', _staff.parliamentAgendaPath, allowCache);

  Future<List<ParliamentItem>> sessions({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'sessions', _staff.parliamentSessionsPath, allowCache);

  Future<List<ParliamentItem>> votes({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'votes', _staff.parliamentVotesPath, allowCache);

  Future<List<ParliamentItem>> supportBase({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'support_base',
    _staff.parliamentSupportBasePath,
    allowCache,
  );

  Future<List<ParliamentItem>> demands({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'demands', _staff.parliamentDemandsPath, allowCache);

  Future<List<ParliamentItem>> promises({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'campaign_promises',
    _staff.parliamentPromisesPath,
    allowCache,
  );

  Future<List<ParliamentItem>> _list(
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

  Future<ParliamentItem> billDetail(String id) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.parliamentBillPath(id),
        mode: _staff,
        parse: asParlMap,
      );
      return ParliamentItem.fromJson(envelope.data);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.parliamentBillPath(id),
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ParliamentItem> itemDetail({
    required String collectionPath,
    required String id,
  }) async {
    final path = '$collectionPath/$id';
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        path,
        mode: _staff,
        parse: asParlMap,
      );
      return ParliamentItem.fromJson(envelope.data);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        return ParliamentItem.fromJson(DemoRepositorySupport.firstItem(path));
      }
      rethrow;
    }
  }

  /// Paths fora do catálogo LIVE c29c2ad — UI demo sem probe HTTP.
  Future<void> assertPending(String path) async {
    return;
  }

  Future<void> search() => assertPending(_staff.parliamentSearchPath);
  Future<void> timeline() => assertPending(_staff.parliamentTimelinePath);
  Future<void> history() => assertPending(_staff.parliamentHistoryPath);
  Future<void> attachments() => assertPending(_staff.parliamentAttachmentsPath);

  /// Pesquisa local em listas LIVE (enquanto `/search` estiver pendente).
  Future<List<ParliamentItem>> localSearch({
    required String tenantSlug,
    required String query,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final results = await Future.wait([
      bills(tenantSlug: tenantSlug),
      projects(tenantSlug: tenantSlug),
      indications(tenantSlug: tenantSlug),
      requests(tenantSlug: tenantSlug),
      motions(tenantSlug: tenantSlug),
      demands(tenantSlug: tenantSlug),
    ]);
    final all = results.expand((e) => e);
    return all
        .where((i) {
          final hay =
              '${i.number ?? ''} ${i.title} ${i.summary ?? ''} ${i.status ?? ''}'
                  .toLowerCase();
          return hay.contains(q);
        })
        .toList(growable: false);
  }
}
