import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'security_cache.dart';
import 'security_contracts.dart';
import 'security_models.dart';

/// Segurança e Privacidade — namespace oficial `/v1/security/*` (Fase 21).
class SecurityRepository {
  SecurityRepository(this._api, {SecurityCache? cache})
    : _cache = cache ?? SecurityCache();

  final ApiClient _api;
  final SecurityCache _cache;
  static const _paths = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  void _requireLive(String slug, String path) {
    // Fallback de demonstração em _cachedGet quando a VPS retorna 404.
  }

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asSecurityMap(data) : data,
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
      data: stripSecuritySecrets(body) as Map<String, dynamic>,
      parse: (raw) => asSecurityMap(raw),
    );
    return asSecurityMap(envelope.data);
  }

  List<SecurityItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asSecurityMapList(data)
        : asSecurityMapList(asSecurityMap(data));
    return list.map(SecurityItem.fromJson).toList(growable: false);
  }

  Future<List<SecurityItem>> _list(
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

  Future<List<SecurityItem>> accountRecovery({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'account_recovery',
    _paths.securityAccountRecoveryPath,
    liveSlug: 'account-recovery',
  );

  Future<List<SecurityItem>> sessions({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'sessions',
    _paths.securitySessionsPath,
    liveSlug: 'sessions',
  );

  Future<List<SecurityItem>> accessHistory({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'access_history',
    _paths.securityAccessHistoryPath,
    liveSlug: 'access-history',
  );

  Future<List<SecurityItem>> devices({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'devices',
    _paths.securityDevicesPath,
    liveSlug: 'devices',
  );

  Future<List<SecurityItem>> passwordPolicies({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'password_policies',
    _paths.securityPasswordPoliciesPath,
    liveSlug: 'password-policies',
  );

  Future<List<SecurityItem>> tokens({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'tokens',
    _paths.securityTokensPath,
    liveSlug: 'tokens',
  );

  Future<List<SecurityItem>> apiKeys({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'api_keys',
    _paths.securityApiKeysPath,
    liveSlug: 'tokens',
  );

  Future<List<SecurityItem>> alerts({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'alerts',
    _paths.securityAlertsPath,
    liveSlug: 'alerts',
  );

  Future<List<SecurityItem>> privacy({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'privacy',
    _paths.securityPrivacyPath,
    liveSlug: 'privacy',
  );

  Future<List<SecurityItem>> consents({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'consents',
    _paths.securityConsentsPath,
    liveSlug: 'consents',
  );

  Future<List<SecurityItem>> terms({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'terms',
    _paths.securityTermsPath,
    liveSlug: 'terms',
  );

  Future<List<SecurityItem>> privacyPolicy({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'privacy_policy',
    _paths.securityPrivacyPolicyPath,
    liveSlug: 'privacy-policy',
  );

  Future<List<SecurityItem>> dataRequest({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'data_request',
    _paths.securityDataRequestPath,
    liveSlug: 'data-request',
  );

  Future<List<SecurityItem>> dataCorrection({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'data_correction',
    _paths.securityDataCorrectionPath,
    liveSlug: 'data-correction',
  );

  Future<List<SecurityItem>> privacyPreferences({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'privacy_preferences',
    _paths.securityPrivacyPreferencesPath,
    liveSlug: 'privacy-preferences',
  );

  Future<List<SecurityItem>> consentHistory({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'consent_history',
    _paths.securityConsentHistoryPath,
    liveSlug: 'consent-history',
  );

  Future<List<SecurityItem>> incidents({
    required String tenantSlug,
    required AuthMode mode,
  }) => _list(
    tenantSlug,
    mode,
    'incidents',
    _paths.securityIncidentsPath,
    liveSlug: 'incidents',
  );

  Future<Map<String, dynamic>> enableMfa({
    required String tenantSlug,
    required AuthMode mode,
    String? password,
  }) => _post(
    tenantSlug: tenantSlug,
    mode: mode,
    path: _paths.securityMfaEnablePath,
    liveSlug: 'mfa-enable',
    body: {if (password != null && password.isNotEmpty) 'password': password},
  );

  Future<Map<String, dynamic>> confirmMfa({
    required String tenantSlug,
    required AuthMode mode,
    required String code,
  }) => _post(
    tenantSlug: tenantSlug,
    mode: mode,
    path: _paths.securityMfaConfirmPath,
    liveSlug: 'mfa-confirm',
    body: {'code': code},
  );

  Future<Map<String, dynamic>> revokeAllSessions({
    required String tenantSlug,
    required AuthMode mode,
  }) => _post(
    tenantSlug: tenantSlug,
    mode: mode,
    path: _paths.securitySessionsRevokeAllPath,
    liveSlug: 'sessions-revoke',
    body: const {},
  );

  Future<Map<String, dynamic>> changePassword({
    required String tenantSlug,
    required AuthMode mode,
    required String currentPassword,
    required String newPassword,
  }) => _post(
    tenantSlug: tenantSlug,
    mode: mode,
    path: _paths.securityPasswordChangePath,
    liveSlug: 'password-change',
    body: {
      'current_password': currentPassword,
      'new_password': newPassword,
    },
  );

  Future<Map<String, dynamic>> exportData({
    required String tenantSlug,
    required AuthMode mode,
    String? reason,
  }) => _post(
    tenantSlug: tenantSlug,
    mode: mode,
    path: _paths.securityDataExportPath,
    liveSlug: 'data-export',
    body: {if (reason != null && reason.isNotEmpty) 'reason': reason},
  );

  Future<Map<String, dynamic>> deleteAccount({
    required String tenantSlug,
    required AuthMode mode,
    required String confirmation,
  }) => _post(
    tenantSlug: tenantSlug,
    mode: mode,
    path: _paths.securityAccountDeletionPath,
    liveSlug: 'account-deletion',
    body: {'confirmation': confirmation},
  );
}
