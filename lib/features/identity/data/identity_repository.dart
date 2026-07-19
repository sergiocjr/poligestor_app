import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import 'identity_models.dart';

class IdentityRepository {
  IdentityRepository(this._api);

  final ApiClient _api;

  /// Preferência portal (contrato org-first). Staff aliases ficam no auth mode.
  static const _publicMode = AuthMode.portal;

  /// LIVE: `GET /v1/identity/tenants/resolve`
  Future<TenantOrganization> resolve({
    String? slug,
    String? code,
    String? domain,
    String? query,
  }) async {
    final q = <String, dynamic>{};
    if (slug != null && slug.trim().isNotEmpty) q['slug'] = slug.trim();
    if (code != null && code.trim().isNotEmpty) q['code'] = code.trim();
    if (domain != null && domain.trim().isNotEmpty) q['domain'] = domain.trim();
    if (query != null && query.trim().isNotEmpty) q['q'] = query.trim();

    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        AuthMode.staff.tenantsResolvePath,
        mode: _publicMode,
        tenantSlug: slug?.trim().isNotEmpty == true ? slug!.trim() : null,
        query: q.isEmpty ? null : q,
        parse: idAsMap,
      );
      return TenantOrganization.fromJson(envelope.data);
    } on ApiException catch (e) {
      _rethrowUnavailable(AuthMode.staff.tenantsResolvePath, e);
    }
  }

  /// LIVE: `GET /v1/portal/branding`
  Future<TenantBranding> branding({required String tenantSlug}) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        AuthMode.portal.brandingPath,
        mode: _publicMode,
        tenantSlug: tenantSlug,
        parse: idAsMap,
      );
      return TenantBranding.fromJson(envelope.data);
    } on ApiException catch (e) {
      _rethrowUnavailable(AuthMode.portal.brandingPath, e);
    }
  }

  /// LIVE: `GET …/auth/providers` (portal ou staff conforme [mode]).
  Future<List<AuthProviderInfo>> providers({
    required AuthMode mode,
    required String tenantSlug,
  }) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        mode.authProvidersPath,
        mode: mode,
        tenantSlug: tenantSlug,
        parse: (raw) => raw,
      );
      final list = envelope.data is List
          ? idAsMapList(envelope.data)
          : idAsMapList(idAsMap(envelope.data)['providers']);
      return list.map(AuthProviderInfo.fromJson).toList();
    } on ApiException catch (e) {
      _rethrowUnavailable(mode.authProvidersPath, e);
    }
  }

  Never _rethrowUnavailable(String path, ApiException e) {
    if (e.statusCode == 404 ||
        e.statusCode == 500 ||
        e.statusCode == 501 ||
        e.statusCode == 503) {
      throw EndpointUnavailableException(path, statusCode: e.statusCode);
    }
    throw e;
  }
}
