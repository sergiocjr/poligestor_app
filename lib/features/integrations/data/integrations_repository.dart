import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'integrations_cache.dart';
import 'integrations_contracts.dart';
import 'integrations_models.dart';

/// Integrações — namespace oficial `/v1/integrations/*` (Fase 22).
class IntegrationsRepository {
  IntegrationsRepository(this._api, {IntegrationsCache? cache})
    : _cache = cache ?? IntegrationsCache();

  final ApiClient _api;
  final IntegrationsCache _cache;
  static const _paths = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  void _requireLive(String slug, String path) {
    if (!integrationsPathLive(slug)) {
      throw EndpointUnavailableException(path, statusCode: 404);
    }
  }

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asIntegrationsMap(data) : data,
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
    required String tenantSlug,
    required AuthMode mode,
    required String path,
    required String liveSlug,
    required Map<String, dynamic> body,
  }) async {
    _requireLive(liveSlug, path);
    final envelope = await _api.postEnvelope<Map<String, dynamic>>(
      path,
      mode: mode,
      data: stripIntegrationsSecrets(body) as Map<String, dynamic>,
      parse: (raw) => asIntegrationsMap(raw),
    );
    return asIntegrationsMap(envelope.data);
  }

  List<IntegrationItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asIntegrationsMapList(data)
        : asIntegrationsMapList(asIntegrationsMap(data));
    return list.map(IntegrationItem.fromJson).toList(growable: false);
  }

  Future<List<IntegrationItem>> _list(
    String tenantSlug,
    AuthMode mode,
    String cacheKey,
    String path, {
    required String liveSlug,
    Map<String, dynamic>? query,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    mode: mode,
    cacheKey: cacheKey,
    path: path,
    liveSlug: liveSlug,
    query: query,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<List<IntegrationItem>> dashboard({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'dashboard',
    _paths.integrationsDashboardPath,
    liveSlug: 'dashboard',
  );

  Future<List<IntegrationItem>> status({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'status',
    _paths.integrationsStatusPath,
    liveSlug: 'status',
  );

  Future<List<IntegrationItem>> config({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'config',
    _paths.integrationsConfigPath,
    liveSlug: 'config',
  );

  Future<List<IntegrationItem>> sync({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'sync',
    _paths.integrationsSyncPath,
    liveSlug: 'sync',
  );

  Future<List<IntegrationItem>> history({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'history',
    _paths.integrationsHistoryPath,
    liveSlug: 'history',
  );

  Future<List<IntegrationItem>> logs({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'logs',
    _paths.integrationsLogsPath,
    liveSlug: 'logs',
  );

  Future<List<IntegrationItem>> govbr({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'govbr',
    _paths.integrationsGovbrPath,
    liveSlug: 'govbr',
  );

  Future<List<IntegrationItem>> camaraMunicipal({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'camara_municipal',
    _paths.integrationsCamaraMunicipalPath,
    liveSlug: 'camara-municipal',
  );

  Future<List<IntegrationItem>> assembleiaLegislativa({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'assembleia_legislativa',
    _paths.integrationsAssembleiaLegislativaPath,
    liveSlug: 'assembleia-legislativa',
  );

  Future<List<IntegrationItem>> camaraDeputados({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'camara_deputados',
    _paths.integrationsCamaraDeputadosPath,
    liveSlug: 'camara-deputados',
  );

  Future<List<IntegrationItem>> senadoFederal({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'senado_federal',
    _paths.integrationsSenadoFederalPath,
    liveSlug: 'senado-federal',
  );

  Future<List<IntegrationItem>> diarioOficial({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'diario_oficial',
    _paths.integrationsDiarioOficialPath,
    liveSlug: 'diario-oficial',
  );

  Future<List<IntegrationItem>> portalTransparencia({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'portal_transparencia',
    _paths.integrationsPortalTransparenciaPath,
    liveSlug: 'portal-transparencia',
  );

  Future<List<IntegrationItem>> eSic({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'e_sic',
    _paths.integrationsESicPath,
    liveSlug: 'e-sic',
  );

  Future<List<IntegrationItem>> ouvidoria({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'ouvidoria',
    _paths.integrationsOuvidoriaPath,
    liveSlug: 'ouvidoria',
  );

  Future<List<IntegrationItem>> googleCalendar({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'google_calendar',
    _paths.integrationsGoogleCalendarPath,
    liveSlug: 'google-calendar',
  );

  Future<List<IntegrationItem>> outlookCalendar({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'outlook_calendar',
    _paths.integrationsOutlookCalendarPath,
    liveSlug: 'outlook-calendar',
  );

  Future<List<IntegrationItem>> gmail({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'gmail',
    _paths.integrationsGmailPath,
    liveSlug: 'gmail',
  );

  Future<List<IntegrationItem>> whatsapp({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'whatsapp',
    _paths.integrationsWhatsappPath,
    liveSlug: 'whatsapp',
  );

  Future<List<IntegrationItem>> telegram({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'telegram',
    _paths.integrationsTelegramPath,
    liveSlug: 'telegram',
  );

  Future<List<IntegrationItem>> firebasePush({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'firebase_push',
    _paths.integrationsFirebasePushPath,
    liveSlug: 'firebase-push',
  );

  Future<List<IntegrationItem>> externalApis({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'external_apis',
    _paths.integrationsExternalApisPath,
    liveSlug: 'external-apis',
  );

  Future<List<IntegrationItem>> webhooks({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'webhooks',
    _paths.integrationsWebhooksPath,
    liveSlug: 'webhooks',
  );

  Future<List<IntegrationItem>> search({
    required String tenantSlug,
    required AuthMode mode,
    String? q,
  }) => _list(
    tenantSlug,
    mode,
    'search',
    _paths.integrationsSearchPath,
    liveSlug: 'search',
    query: {if (q != null && q.isNotEmpty) 'q': q},
  );

  Future<List<IntegrationItem>> filters({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'filters',
    _paths.integrationsFiltersPath,
    liveSlug: 'filters',
  );

  Future<Map<String, dynamic>> triggerSync({
    required String tenantSlug,
    required AuthMode mode,
    String? provider,
  }) => _post(
    tenantSlug: tenantSlug,
    mode: mode,
    path: _paths.integrationsSyncPath,
    liveSlug: 'sync',
    body: {
      if (provider != null && provider.isNotEmpty) 'provider': provider,
    },
  );

  Future<Map<String, dynamic>> saveConfig({
    required String tenantSlug,
    required AuthMode mode,
    required Map<String, dynamic> body,
  }) => _post(
    tenantSlug: tenantSlug,
    mode: mode,
    path: _paths.integrationsConfigPath,
    liveSlug: 'config',
    body: body,
  );
}
