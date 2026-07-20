import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'elections_cache.dart';
import 'elections_models.dart';

/// Gestão Eleitoral — namespace oficial `/v1/elections/*` (Fase 17).
class ElectionsRepository {
  ElectionsRepository(this._api, {ElectionsCache? cache})
    : _cache = cache ?? ElectionsCache();

  final ApiClient _api;
  final ElectionsCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asElectionsMap(data) : data,
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

  List<ElectionsItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asElectionsMapList(data)
        : asElectionsMapList(asElectionsMap(data));
    return list.map(ElectionsItem.fromJson).toList(growable: false);
  }

  Future<List<ElectionsItem>> _list(
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

  Future<List<ElectionsItem>> dashboard({required String tenantSlug}) =>
      _list(tenantSlug, 'dashboard', _staff.electionsDashboardPath);

  Future<List<ElectionsItem>> preCampaign({required String tenantSlug}) =>
      _list(tenantSlug, 'pre_campaign', _staff.electionsPreCampaignPath);

  Future<List<ElectionsItem>> campaigns({required String tenantSlug}) =>
      _list(tenantSlug, 'campaigns', _staff.electionsCampaignsPath);

  Future<List<ElectionsItem>> candidates({required String tenantSlug}) =>
      _list(tenantSlug, 'candidates', _staff.electionsCandidatesPath);

  Future<List<ElectionsItem>> coordination({required String tenantSlug}) =>
      _list(tenantSlug, 'coordination', _staff.electionsCoordinationPath);

  Future<List<ElectionsItem>> teams({required String tenantSlug}) =>
      _list(tenantSlug, 'teams', _staff.electionsTeamsPath);

  Future<List<ElectionsItem>> canvassers({required String tenantSlug}) =>
      _list(tenantSlug, 'canvassers', _staff.electionsCanvassersPath);

  Future<List<ElectionsItem>> volunteers({required String tenantSlug}) =>
      _list(tenantSlug, 'volunteers', _staff.electionsVolunteersPath);

  Future<List<ElectionsItem>> leaders({required String tenantSlug}) =>
      _list(tenantSlug, 'leaders', _staff.electionsLeadersPath);

  Future<List<ElectionsItem>> supporters({required String tenantSlug}) =>
      _list(tenantSlug, 'supporters', _staff.electionsSupportersPath);

  Future<List<ElectionsItem>> goals({required String tenantSlug}) =>
      _list(tenantSlug, 'goals', _staff.electionsGoalsPath);

  Future<List<ElectionsItem>> regions({required String tenantSlug}) =>
      _list(tenantSlug, 'regions', _staff.electionsRegionsPath);

  Future<List<ElectionsItem>> neighborhoods({required String tenantSlug}) =>
      _list(tenantSlug, 'neighborhoods', _staff.electionsNeighborhoodsPath);

  Future<List<ElectionsItem>> electoralZones({required String tenantSlug}) =>
      _list(tenantSlug, 'electoral_zones', _staff.electionsElectoralZonesPath);

  Future<List<ElectionsItem>> electoralSections({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'electoral_sections',
        _staff.electionsElectoralSectionsPath,
      );

  Future<List<ElectionsItem>> pollingStations({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'polling_stations',
        _staff.electionsPollingStationsPath,
      );

  Future<List<ElectionsItem>> map({required String tenantSlug}) =>
      _list(tenantSlug, 'map', _staff.electionsMapPath);

  Future<List<ElectionsItem>> campaignAgenda({required String tenantSlug}) =>
      _list(tenantSlug, 'campaign_agenda', _staff.electionsCampaignAgendaPath);

  Future<List<ElectionsItem>> events({required String tenantSlug}) =>
      _list(tenantSlug, 'events', _staff.electionsEventsPath);

  Future<List<ElectionsItem>> walks({required String tenantSlug}) =>
      _list(tenantSlug, 'walks', _staff.electionsWalksPath);

  Future<List<ElectionsItem>> meetings({required String tenantSlug}) =>
      _list(tenantSlug, 'meetings', _staff.electionsMeetingsPath);

  Future<List<ElectionsItem>> visits({required String tenantSlug}) =>
      _list(tenantSlug, 'visits', _staff.electionsVisitsPath);

  Future<List<ElectionsItem>> rallies({required String tenantSlug}) =>
      _list(tenantSlug, 'rallies', _staff.electionsRalliesPath);

  Future<List<ElectionsItem>> mobilizations({required String tenantSlug}) =>
      _list(tenantSlug, 'mobilizations', _staff.electionsMobilizationsPath);

  Future<List<ElectionsItem>> campaignMaterials({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'campaign_materials',
        _staff.electionsCampaignMaterialsPath,
      );

  Future<List<ElectionsItem>> inventory({required String tenantSlug}) =>
      _list(tenantSlug, 'inventory', _staff.electionsInventoryPath);

  Future<List<ElectionsItem>> distribution({required String tenantSlug}) =>
      _list(tenantSlug, 'distribution', _staff.electionsDistributionPath);

  Future<List<ElectionsItem>> materialRequests({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'material_requests',
        _staff.electionsMaterialRequestsPath,
      );

  Future<List<ElectionsItem>> polls({required String tenantSlug}) =>
      _list(tenantSlug, 'polls', _staff.electionsPollsPath);

  Future<List<ElectionsItem>> scenarios({required String tenantSlug}) =>
      _list(tenantSlug, 'scenarios', _staff.electionsScenariosPath);

  Future<List<ElectionsItem>> voteIntention({required String tenantSlug}) =>
      _list(tenantSlug, 'vote_intention', _staff.electionsVoteIntentionPath);

  Future<List<ElectionsItem>> rejection({required String tenantSlug}) =>
      _list(tenantSlug, 'rejection', _staff.electionsRejectionPath);

  Future<List<ElectionsItem>> comparatives({required String tenantSlug}) =>
      _list(tenantSlug, 'comparatives', _staff.electionsComparativesPath);

  Future<List<ElectionsItem>> projections({required String tenantSlug}) =>
      _list(tenantSlug, 'projections', _staff.electionsProjectionsPath);

  Future<List<ElectionsItem>> regionalPerformance({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'regional_performance',
    _staff.electionsRegionalPerformancePath,
  );

  Future<List<ElectionsItem>> accountability({required String tenantSlug}) =>
      _list(tenantSlug, 'accountability', _staff.electionsAccountabilityPath);

  Future<List<ElectionsItem>> revenues({required String tenantSlug}) =>
      _list(tenantSlug, 'revenues', _staff.electionsRevenuesPath);

  Future<List<ElectionsItem>> expenses({required String tenantSlug}) =>
      _list(tenantSlug, 'expenses', _staff.electionsExpensesPath);

  Future<List<ElectionsItem>> donations({required String tenantSlug}) =>
      _list(tenantSlug, 'donations', _staff.electionsDonationsPath);

  Future<List<ElectionsItem>> suppliers({required String tenantSlug}) =>
      _list(tenantSlug, 'suppliers', _staff.electionsSuppliersPath);

  Future<List<ElectionsItem>> receipts({required String tenantSlug}) =>
      _list(tenantSlug, 'receipts', _staff.electionsReceiptsPath);

  Future<List<ElectionsItem>> reports({required String tenantSlug}) =>
      _list(tenantSlug, 'reports', _staff.electionsReportsPath);

  Future<List<ElectionsItem>> exports({required String tenantSlug}) =>
      _list(tenantSlug, 'exports', _staff.electionsExportsPath);

  Future<List<ElectionsItem>> filters({required String tenantSlug}) =>
      _list(tenantSlug, 'filters', _staff.electionsFiltersPath);

  Future<List<ElectionsItem>> search({
    required String tenantSlug,
    required String query,
  }) => _list(
    tenantSlug,
    'search_${query.hashCode}',
    _staff.electionsSearchPath,
    query: {'q': query},
  );
}
