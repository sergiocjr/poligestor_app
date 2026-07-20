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

  List<Map<String, dynamic>> _rowsOf(Map<String, dynamic> root) {
    final data = root['data'];
    if (data is List) return asNewsMapList(data);
    if (data is Map) return asNewsMapList(asNewsMap(data));
    return asNewsMapList(root);
  }

  RegionalNewsItem _itemFromRow(Map<String, dynamic> row) {
    final nested = row['article'];
    if (nested is Map) {
      final article = RegionalNewsItem.fromJson(asNewsMap(nested));
      return article.copyWith(
        favorite: article.favorite ||
            row['favorite'] == true ||
            row['is_favorite'] == true,
      );
    }
    final articleId = asNewsString(row['article_id']);
    if (articleId != null &&
        (row['title'] == null && row['headline'] == null)) {
      return RegionalNewsItem.fromJson(<String, dynamic>{
        ...row,
        'id': articleId,
        'mentions_politician': true,
      });
    }
    if (row['body'] != null && row['title'] != null && articleId != null) {
      return RegionalNewsItem.fromJson(<String, dynamic>{
        'id': articleId,
        'title': row['title'],
        'summary': row['body'],
        'mentions_politician': true,
        'category': row['category'],
        'published_at': row['created_at'],
      });
    }
    return RegionalNewsItem.fromJson(row);
  }

  List<RegionalNewsItem> _itemsOf(Map<String, dynamic> root) =>
      _rowsOf(root).map(_itemFromRow).toList(growable: false);

  Future<RegionalNewsItem> _fetchArticle({
    required String tenantSlug,
    required AuthMode mode,
    required String articleId,
    bool mentionsPolitician = false,
  }) async {
    final item = await detail(
      tenantSlug: tenantSlug,
      mode: mode,
      id: articleId,
    );
    if (mentionsPolitician && !item.mentionsPolitician) {
      return RegionalNewsItem(
        id: item.id,
        title: item.title,
        summary: item.summary,
        source: item.source,
        city: item.city,
        topic: item.topic,
        imageUrl: item.imageUrl,
        originalUrl: item.originalUrl,
        publishedAt: item.publishedAt,
        mentionsPolitician: true,
        favorite: item.favorite,
        raw: item.raw,
      );
    }
    return item;
  }

  Future<List<RegionalNewsItem>> _hydrateArticles({
    required String tenantSlug,
    required AuthMode mode,
    required List<RegionalNewsItem> seeds,
    int? limit,
    bool mentionsOnly = false,
  }) async {
    final seen = <String>{};
    final out = <RegionalNewsItem>[];
    for (final seed in seeds) {
      if (limit != null && out.length >= limit) break;
      final articleId = seed.id;
      if (articleId.isEmpty || seen.contains(articleId)) continue;
      seen.add(articleId);
      final needsHydration =
          seed.title == 'Notícia' ||
          (seed.summary == null || seed.summary!.isEmpty);
      try {
        final item = needsHydration
            ? await _fetchArticle(
                tenantSlug: tenantSlug,
                mode: mode,
                articleId: articleId,
                mentionsPolitician: mentionsOnly || seed.mentionsPolitician,
              )
            : seed;
        out.add(item);
      } catch (_) {
        if (!needsHydration) out.add(seed);
      }
    }
    out.sort((a, b) {
      final ad = a.publishedAt;
      final bd = b.publishedAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return limit == null ? out : out.take(limit).toList(growable: false);
  }

  bool _matchesFilters(
    RegionalNewsItem item, {
    String? city,
    String? source,
    String? period,
    String? topic,
    String? q,
  }) {
    if (q != null && q.isNotEmpty) {
      final hay = '${item.title} ${item.summary ?? ''} ${item.source ?? ''}'
          .toLowerCase();
      if (!hay.contains(q.toLowerCase())) return false;
    }
    if (city != null && city.isNotEmpty) {
      final c = (item.city ?? '').toLowerCase();
      if (c != city.toLowerCase() && !c.contains(city.toLowerCase())) {
        return false;
      }
    }
    if (source != null && source.isNotEmpty) {
      final s = (item.source ?? item.raw['source_name'] ?? '').toString();
      if (s.toLowerCase() != source.toLowerCase() &&
          !s.toLowerCase().contains(source.toLowerCase())) {
        return false;
      }
    }
    if (topic != null && topic.isNotEmpty) {
      final t = (item.topic ?? item.raw['category'] ?? '').toString();
      if (t.toLowerCase() != topic.toLowerCase() &&
          !t.toLowerCase().contains(topic.toLowerCase())) {
        return false;
      }
    }
    if (period != null && period.isNotEmpty && item.publishedAt != null) {
      final days = switch (period) {
        '7d' || '7' || 'week' => 7,
        '30d' || '30' || 'month' => 30,
        '90d' || '90' => 90,
        _ => 0,
      };
      if (days > 0) {
        final cutoff = DateTime.now().subtract(Duration(days: days));
        if (item.publishedAt!.isBefore(cutoff)) return false;
      }
    }
    return true;
  }

  Future<Map<String, dynamic>> dashboard({
    required String tenantSlug,
    required AuthMode mode,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: 'dashboard',
    path: _paths.newsDashboardPath,
    liveSlug: 'dashboard',
    parse: (root, {fromCache = false, age}) => asNewsMap(root['data']),
  );

  Future<List<RegionalNewsItem>> recent({
    required String tenantSlug,
    required AuthMode mode,
    int limit = 5,
  }) async {
    final mentions = await this.mentions(
      tenantSlug: tenantSlug,
      mode: mode,
    );
    return _hydrateArticles(
      tenantSlug: tenantSlug,
      mode: mode,
      seeds: mentions,
      limit: limit.clamp(3, 5),
    );
  }

  Future<List<RegionalNewsItem>> feed({
    required String tenantSlug,
    required AuthMode mode,
    String? city,
    String? source,
    String? period,
    String? topic,
    String? q,
  }) async {
    final mentions = await this.mentions(
      tenantSlug: tenantSlug,
      mode: mode,
    );
    final hydrated = await _hydrateArticles(
      tenantSlug: tenantSlug,
      mode: mode,
      seeds: mentions,
    );
    return hydrated
        .where(
          (item) => _matchesFilters(
            item,
            city: city,
            source: source,
            period: period,
            topic: topic,
            q: q,
          ),
        )
        .toList(growable: false);
  }

  Future<List<RegionalNewsItem>> search({
    required String tenantSlug,
    required AuthMode mode,
    required String q,
  }) => feed(tenantSlug: tenantSlug, mode: mode, q: q);

  Future<List<NewsFilterOption>> filters({
    required String tenantSlug,
    required AuthMode mode,
  }) async {
    if (newsPathLive('filters')) {
      return _cachedGet(
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
    }
    _requireLive('sources', _paths.newsSourcesPath);
    final sources = await _cachedGet<List<Map<String, dynamic>>>(
      tenantSlug: tenantSlug,
      mode: mode,
      cacheKey: 'sources',
      path: _paths.newsSourcesPath,
      liveSlug: 'sources',
      parse: (root, {fromCache = false, age}) => _rowsOf(root),
    );
    final options = <NewsFilterOption>[];
    final cities = <String>{};
    for (final row in sources) {
      final name = asNewsString(row['name']) ?? 'Fonte';
      final slug = asNewsString(row['slug'] ?? row['id']) ?? name;
      options.add(
        NewsFilterOption(id: slug, label: name, group: 'source'),
      );
      final city = asNewsString(row['city']);
      if (city != null) cities.add(city);
    }
    for (final city in cities) {
      options.add(NewsFilterOption(id: city, label: city, group: 'city'));
    }
    for (final period in [
      ('7d', 'Últimos 7 dias'),
      ('30d', 'Últimos 30 dias'),
      ('90d', 'Últimos 90 dias'),
    ]) {
      options.add(
        NewsFilterOption(id: period.$1, label: period.$2, group: 'period'),
      );
    }
    return options;
  }

  Future<List<RegionalNewsItem>> mentions({
    required String tenantSlug,
    required AuthMode mode,
  }) async {
    final seeds = await _cachedGet(
      tenantSlug: tenantSlug,
      mode: mode,
      cacheKey: 'mentions',
      path: _paths.newsMentionsPath,
      liveSlug: 'mentions',
      parse: (root, {fromCache = false, age}) => _itemsOf(root),
    );
    return _hydrateArticles(
      tenantSlug: tenantSlug,
      mode: mode,
      seeds: seeds,
      mentionsOnly: true,
    );
  }

  Future<List<RegionalNewsItem>> favorites({
    required String tenantSlug,
    required AuthMode mode,
  }) async {
    final seeds = await _cachedGet(
      tenantSlug: tenantSlug,
      mode: mode,
      cacheKey: 'favorites',
      path: _paths.newsFavoritesPath,
      liveSlug: 'favorites',
      parse: (root, {fromCache = false, age}) {
        return _itemsOf(root)
            .map((e) => e.copyWith(favorite: true))
            .toList(growable: false);
      },
    );
    return _hydrateArticles(tenantSlug: tenantSlug, mode: mode, seeds: seeds);
  }

  Future<List<RegionalNewsItem>> alerts({
    required String tenantSlug,
    required AuthMode mode,
  }) async {
    final seeds = await _cachedGet(
      tenantSlug: tenantSlug,
      mode: mode,
      cacheKey: 'alerts',
      path: _paths.newsAlertsPath,
      liveSlug: 'alerts',
      parse: (root, {fromCache = false, age}) => _itemsOf(root),
    );
    return _hydrateArticles(
      tenantSlug: tenantSlug,
      mode: mode,
      seeds: seeds,
      mentionsOnly: true,
    );
  }

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
    body: {'news_id': id, 'article_id': id},
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
