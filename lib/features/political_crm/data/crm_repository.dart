import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'crm_cache.dart';
import 'crm_models.dart';

/// CRM Político — namespace oficial `/v1/crm/*` (Fase 16).
class CrmRepository {
  CrmRepository(this._api, {CrmCache? cache}) : _cache = cache ?? CrmCache();

  final ApiClient _api;
  final CrmCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asCrmMap(data) : data,
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

  List<CrmItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asCrmMapList(data)
        : asCrmMapList(asCrmMap(data));
    return list.map(CrmItem.fromJson).toList(growable: false);
  }

  Future<List<CrmItem>> _list(
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

  Future<List<CrmItem>> dashboard({required String tenantSlug}) =>
      _list(tenantSlug, 'dashboard', _staff.crmDashboardPath);

  Future<List<CrmItem>> leaders({required String tenantSlug}) =>
      _list(tenantSlug, 'leaders', _staff.crmLeadersPath);

  Future<List<CrmItem>> supporters({required String tenantSlug}) =>
      _list(tenantSlug, 'supporters', _staff.crmSupportersPath);

  Future<List<CrmItem>> voters({required String tenantSlug}) =>
      _list(tenantSlug, 'voters', _staff.crmVotersPath);

  Future<List<CrmItem>> volunteers({required String tenantSlug}) =>
      _list(tenantSlug, 'volunteers', _staff.crmVolunteersPath);

  Future<List<CrmItem>> team({required String tenantSlug}) =>
      _list(tenantSlug, 'team', _staff.crmTeamPath);

  Future<List<CrmItem>> entities({required String tenantSlug}) =>
      _list(tenantSlug, 'entities', _staff.crmEntitiesPath);

  Future<List<CrmItem>> associations({required String tenantSlug}) =>
      _list(tenantSlug, 'associations', _staff.crmAssociationsPath);

  Future<List<CrmItem>> churches({required String tenantSlug}) =>
      _list(tenantSlug, 'churches', _staff.crmChurchesPath);

  Future<List<CrmItem>> companies({required String tenantSlug}) =>
      _list(tenantSlug, 'companies', _staff.crmCompaniesPath);

  Future<List<CrmItem>> influencers({required String tenantSlug}) =>
      _list(tenantSlug, 'influencers', _staff.crmInfluencersPath);

  Future<List<CrmItem>> segmentation({required String tenantSlug}) =>
      _list(tenantSlug, 'segmentation', _staff.crmSegmentationPath);

  Future<List<CrmItem>> tags({required String tenantSlug}) =>
      _list(tenantSlug, 'tags', _staff.crmTagsPath);

  Future<List<CrmItem>> groups({required String tenantSlug}) =>
      _list(tenantSlug, 'groups', _staff.crmGroupsPath);

  Future<List<CrmItem>> regions({required String tenantSlug}) =>
      _list(tenantSlug, 'regions', _staff.crmRegionsPath);

  Future<List<CrmItem>> neighborhoods({required String tenantSlug}) =>
      _list(tenantSlug, 'neighborhoods', _staff.crmNeighborhoodsPath);

  Future<List<CrmItem>> electoralZones({required String tenantSlug}) =>
      _list(tenantSlug, 'electoral_zones', _staff.crmElectoralZonesPath);

  Future<List<CrmItem>> relationshipHistory({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'relationship_history',
        _staff.crmRelationshipHistoryPath,
      );

  Future<List<CrmItem>> interactions({required String tenantSlug}) =>
      _list(tenantSlug, 'interactions', _staff.crmInteractionsPath);

  Future<List<CrmItem>> visits({required String tenantSlug}) =>
      _list(tenantSlug, 'visits', _staff.crmVisitsPath);

  Future<List<CrmItem>> calls({required String tenantSlug}) =>
      _list(tenantSlug, 'calls', _staff.crmCallsPath);

  Future<List<CrmItem>> messages({required String tenantSlug}) =>
      _list(tenantSlug, 'messages', _staff.crmMessagesPath);

  Future<List<CrmItem>> meetings({required String tenantSlug}) =>
      _list(tenantSlug, 'meetings', _staff.crmMeetingsPath);

  Future<List<CrmItem>> linkedDemands({required String tenantSlug}) =>
      _list(tenantSlug, 'linked_demands', _staff.crmLinkedDemandsPath);

  Future<List<CrmItem>> linkedProtocols({required String tenantSlug}) =>
      _list(tenantSlug, 'linked_protocols', _staff.crmLinkedProtocolsPath);

  Future<List<CrmItem>> campaigns({required String tenantSlug}) =>
      _list(tenantSlug, 'campaigns', _staff.crmCampaignsPath);

  Future<List<CrmItem>> tasks({required String tenantSlug}) =>
      _list(tenantSlug, 'tasks', _staff.crmTasksPath);

  Future<List<CrmItem>> reminders({required String tenantSlug}) =>
      _list(tenantSlug, 'reminders', _staff.crmRemindersPath);

  Future<List<CrmItem>> supportLevel({required String tenantSlug}) =>
      _list(tenantSlug, 'support_level', _staff.crmSupportLevelPath);

  Future<List<CrmItem>> influencePotential({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'influence_potential',
        _staff.crmInfluencePotentialPath,
      );

  Future<List<CrmItem>> relationships({required String tenantSlug}) =>
      _list(tenantSlug, 'relationships', _staff.crmRelationshipsPath);

  Future<List<CrmItem>> importData({required String tenantSlug}) =>
      _list(tenantSlug, 'import', _staff.crmImportPath);

  Future<List<CrmItem>> exportData({required String tenantSlug}) =>
      _list(tenantSlug, 'export', _staff.crmExportPath);

  Future<List<CrmItem>> filters({required String tenantSlug}) =>
      _list(tenantSlug, 'filters', _staff.crmFiltersPath);

  Future<List<CrmItem>> indicators({required String tenantSlug}) =>
      _list(tenantSlug, 'indicators', _staff.crmIndicatorsPath);

  Future<List<CrmItem>> reports({required String tenantSlug}) =>
      _list(tenantSlug, 'reports', _staff.crmReportsPath);

  Future<List<CrmItem>> search({
    required String tenantSlug,
    required String query,
  }) => _list(
    tenantSlug,
    'search_${query.hashCode}',
    _staff.crmSearchPath,
    query: {'q': query},
  );
}
