import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'documents_cache.dart';
import 'documents_models.dart';

/// Gestão Documental — namespace oficial `/v1/documents/*` (Fase 13).
class DocumentsRepository {
  DocumentsRepository(this._api, {DocumentsCache? cache})
    : _cache = cache ?? DocumentsCache();

  final ApiClient _api;
  final DocumentsCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asDocsMap(data) : data,
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

  List<DocumentItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asDocsMapList(data)
        : asDocsMapList(asDocsMap(data));
    return list.map(DocumentItem.fromJson).toList(growable: false);
  }

  Future<List<DocumentItem>> _list(
    String tenantSlug,
    String cacheKey,
    String path, {
    Map<String, dynamic>? query,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: cacheKey,
    path: path,
    query: query,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<List<DocumentItem>> list({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'list',
    _staff.documentsListPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> search({
    required String tenantSlug,
    required String query,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'search_${query.hashCode}',
    _staff.documentsSearchPath,
    query: {'q': query},
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> filters({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'filters',
    _staff.documentsFiltersPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> categories({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'categories',
    _staff.documentsCategoriesPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> favorites({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'favorites',
    _staff.documentsFavoritesPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> history({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'history',
    _staff.documentsHistoryPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> timeline({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'timeline',
    _staff.documentsTimelinePath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> viewer({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'viewer',
    _staff.documentsViewerPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> signatures({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'signatures',
    _staff.documentsSignaturesPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> approvals({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'approvals',
    _staff.documentsApprovalsPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> share({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'share',
    _staff.documentsSharePath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> templates({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'templates',
    _staff.documentsTemplatesPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> download({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'download',
    _staff.documentsDownloadPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> upload({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'upload',
    _staff.documentsUploadPath,
    allowCache: allowCache,
  );

  Future<List<DocumentItem>> attachments({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'attachments',
    _staff.documentsAttachmentsPath,
    allowCache: allowCache,
  );
}
