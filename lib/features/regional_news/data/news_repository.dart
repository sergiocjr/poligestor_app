import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'news_cache.dart';
import 'news_contracts.dart';
import 'news_models.dart';

/// Notícias Regionais — namespace oficial `/v1/news/*` (Fase 24).
class NewsRepository {
  NewsRepository(this._api, {NewsCache? cache})
    : _cache = cache ?? NewsCache();

  final ApiClient _api;
  final NewsCache _cache;
  static const _paths = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  void _requireLive(String slug, String path) {
    if (!newsPathLive(slug)) {
      throw EndpointUnavailableException(path, statusCode: 404);
    }
  }

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asNewsMap(data) : data,
    };
    if (meta != null) root['meta'] = meta;
    return root;
  }

  Future<T> _cachedGet<T>({
    required String tenantSlug,
    required AuthMode mode,
    required String cacheKey,
    required String path,
    required String liveSlug,
    required T Function(
      Map<String, dynamic> root, {
      bool fromCache,
      String? age,
    })
    parse,
    Map<String, dynamic>? query,
    bool allowCache = true,
  }) async {
    _requireLive(liveSlug, path);
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        path,
        mode: mode,
        query: query,
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

  Future<Map<String, dynamic>> _post({
    required AuthMode mode,
    required String path,
    required String liveSlug,
    required Map<String, dynamic> body,
  }) async {
    _requireLive(liveSlug, path);
    final envelope = await _api.postEnvelope<Map<String, dynamic>>(
      path,
      mode: mode,
      data: body,
      parse: (raw) => asNewsMap(raw),
    );
    return asNewsMap(envelope.data);
  }

  Future<Map<String, dynamic>> _delete({
    required AuthMode mode,
    required String path,
    required String liveSlug,
  }) async {
    _requireLive(liveSlug, path);
    final envelope = await _api.deleteEnvelope<Map<String, dynamic>>(
      path,
      mode: mode,
      parse: (raw) => asNewsMap(raw),
    );
    return asNewsMap(envelope.data);
  }

  List<RegionalNewsItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asNewsMapList(data)
        : asNewsMapList(asNewsMap(data));
    return list.map(RegionalNewsItem.fromJson).toList(growable: false);
  }

  Future<List<RegionalNewsItem>> recent({
    required String tenantSlug,
    required AuthMode mode,
    int limit = 5,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'recent_$limit',
    path: _paths.newsRecentPath,
    liveSlug: 'recent',
    query: {'limit': limit},
    parse: (root, {fromCache = false, age}) =>
        _itemsOf(root).take(limit.clamp(3, 5)).toList(growable: false),
  );

  Future<List<RegionalNewsItem>> feed({
    required String tenantSlug,
    required AuthMode mode,
    String? city,
    String? source,
    String? period,
    String? topic,
    String? q,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'feed_${city}_${source}_${period}_${topic}_$q',
    path: _paths.newsFeedPath,
    liveSlug: 'feed',
    query: {
      if (city != null && city.isNotEmpty) 'city': city,
      if (source != null && source.isNotEmpty) 'source': source,
      if (period != null && period.isNotEmpty) 'period': period,
      if (topic != null && topic.isNotEmpty) 'topic': topic,
      if (q != null && q.isNotEmpty) 'q': q,
    },
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<List<RegionalNewsItem>> search({
    required String tenantSlug,
    required AuthMode mode,
    required String q,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'search_$q',
    path: _paths.newsSearchPath,
    liveSlug: 'search',
    query: {'q': q},
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<List<NewsFilterOption>> filters({
    required String tenantSlug,
    required AuthMode mode,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'filters',
    path: _paths.newsFiltersPath,
    liveSlug: 'filters',
    parse: (root, {fromCache = false, age}) {
      final data = root['data'];
      final list = data is List
          ? asNewsMapList(data)
          : asNewsMapList(asNewsMap(data));
      return list.map(NewsFilterOption.fromJson).toList(growable: false);
    },
  );

  Future<List<RegionalNewsItem>> mentions({
    required String tenantSlug,
    required AuthMode mode,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'mentions',
    path: _paths.newsMentionsPath,
    liveSlug: 'mentions',
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<List<RegionalNewsItem>> favorites({
    required String tenantSlug,
    required AuthMode mode,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'favorites',
    path: _paths.newsFavoritesPath,
    liveSlug: 'favorites',
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<List<RegionalNewsItem>> alerts({
    required String tenantSlug,
    required AuthMode mode,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'alerts',
    path: _paths.newsAlertsPath,
    liveSlug: 'alerts',
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<RegionalNewsItem> detail({
    required String tenantSlug,
    required AuthMode mode,
    required String id,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'detail_$id',
    path: _paths.newsItemPath(id),
    liveSlug: 'detail',
    parse: (root, {fromCache = false, age}) {
      final data = root['data'];
      if (data is Map) return RegionalNewsItem.fromJson(asNewsMap(data));
      final list = _itemsOf(root);
      if (list.isNotEmpty) return list.first;
      throw EndpointUnavailableException(
        _paths.newsItemPath(id),
        statusCode: 404,
      );
    },
  );

  Future<Map<String, dynamic>> addFavorite({
    required AuthMode mode,
    required String id,
  }) => _post(
    mode: mode,
    path: _paths.newsFavoritesPath,
    liveSlug: 'favorites',
    body: {'news_id': id},
  );

  Future<Map<String, dynamic>> removeFavorite({
    required AuthMode mode,
    required String id,
  }) => _delete(
    mode: mode,
    path: '${_paths.newsFavoritesPath}/$id',
    liveSlug: 'favorites',
  );
}
