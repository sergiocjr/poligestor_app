import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_mode.dart';
import 'portal_home_models.dart';

class PortalHomeRepository {
  PortalHomeRepository(this._api);

  final ApiClient _api;
  Future<PortalHomeData>? _inFlight;

  static const path = '/v1/portal/home';

  /// Contador interno para testes de deduplicação.
  int fetchAttempts = 0;

  Future<PortalHomeData> fetchHome({String? tenantSlug}) {
    if (_inFlight != null) return _inFlight!;
    _inFlight = _fetch(tenantSlug: tenantSlug).whenComplete(() {
      _inFlight = null;
    });
    return _inFlight!;
  }

  Future<PortalHomeData> _fetch({String? tenantSlug}) async {
    fetchAttempts++;
    final envelope = await _api.getEnvelope<PortalHomeData>(
      path,
      mode: AuthMode.portal,
      tenantSlug: tenantSlug,
      parse: (raw) {
        if (raw is Map<String, dynamic>) {
          return PortalHomeData.fromJson(raw);
        }
        if (raw is Map) {
          return PortalHomeData.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('Resposta inválida de /v1/portal/home');
      },
    );
    return envelope.data;
  }
}
