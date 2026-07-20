import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'institutional_communication_cache.dart';
import 'institutional_communication_models.dart';

/// Comunicação Institucional — namespace oficial `/v1/communication/*` (Fase 15).
class InstitutionalCommunicationRepository {
  InstitutionalCommunicationRepository(
    this._api, {
    InstitutionalCommunicationCache? cache,
  }) : _cache = cache ?? InstitutionalCommunicationCache();

  final ApiClient _api;
  final InstitutionalCommunicationCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asIcMap(data) : data,
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

  List<InstitutionalCommunicationItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asIcMapList(data)
        : asIcMapList(asIcMap(data));
    return list
        .map(InstitutionalCommunicationItem.fromJson)
        .toList(growable: false);
  }

  Future<List<InstitutionalCommunicationItem>> _list(
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

  Future<List<InstitutionalCommunicationItem>> feed({
    required String tenantSlug,
  }) => _list(tenantSlug, 'feed', _staff.institutionalCommunicationFeedPath);

  Future<List<InstitutionalCommunicationItem>> announcements({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'announcements',
    _staff.institutionalCommunicationAnnouncementsPath,
  );

  Future<List<InstitutionalCommunicationItem>> campaigns({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'campaigns',
    _staff.institutionalCommunicationCampaignsPath,
  );

  Future<List<InstitutionalCommunicationItem>> media({
    required String tenantSlug,
  }) => _list(tenantSlug, 'media', _staff.institutionalCommunicationMediaPath);

  Future<List<InstitutionalCommunicationItem>> publications({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'publications',
    _staff.institutionalCommunicationPublicationsPath,
  );

  Future<List<InstitutionalCommunicationItem>> schedule({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'schedule',
    _staff.institutionalCommunicationSchedulePath,
  );

  Future<List<InstitutionalCommunicationItem>> push({
    required String tenantSlug,
  }) => _list(tenantSlug, 'push', _staff.institutionalCommunicationPushPath);

  Future<List<InstitutionalCommunicationItem>> email({
    required String tenantSlug,
  }) => _list(tenantSlug, 'email', _staff.institutionalCommunicationEmailPath);

  Future<List<InstitutionalCommunicationItem>> whatsapp({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'whatsapp',
    _staff.institutionalCommunicationWhatsappPath,
  );

  Future<List<InstitutionalCommunicationItem>> history({
    required String tenantSlug,
  }) =>
      _list(tenantSlug, 'history', _staff.institutionalCommunicationHistoryPath);

  Future<List<InstitutionalCommunicationItem>> filters({
    required String tenantSlug,
  }) =>
      _list(tenantSlug, 'filters', _staff.institutionalCommunicationFiltersPath);

  Future<List<InstitutionalCommunicationItem>> share({
    required String tenantSlug,
  }) => _list(tenantSlug, 'share', _staff.institutionalCommunicationSharePath);

  Future<List<InstitutionalCommunicationItem>> reports({
    required String tenantSlug,
  }) =>
      _list(tenantSlug, 'reports', _staff.institutionalCommunicationReportsPath);

  Future<List<InstitutionalCommunicationItem>> search({
    required String tenantSlug,
    required String query,
  }) => _list(
    tenantSlug,
    'search_${query.hashCode}',
    _staff.institutionalCommunicationSearchPath,
    query: {'q': query},
  );
}
