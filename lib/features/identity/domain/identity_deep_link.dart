/// Parse de deep links de organização (Sprint 10.2).
///
/// Formatos:
/// - poligestor://org/{slug}
/// - poligestor://tenant/{slug}
/// - poligestor://organization/{slug}
/// - https://{slug}.poligestor... (host handled by TenantController)
class IdentityDeepLink {
  IdentityDeepLink._();

  static bool isIdentityUri(Uri uri) {
    if (uri.scheme == 'poligestor') {
      return uri.host == 'org' ||
          uri.host == 'tenant' ||
          uri.host == 'organization' ||
          uri.host == 'organizacao';
    }
    return false;
  }

  /// Extrai slug do deep link; null se inválido.
  static String? slugFrom(Uri uri) {
    if (!isIdentityUri(uri)) return null;
    if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first.trim().toLowerCase();
    }
    final q =
        uri.queryParameters['slug'] ??
        uri.queryParameters['code'] ??
        uri.queryParameters['tenant'];
    return q?.trim().toLowerCase();
  }

  /// Localização GoRouter pública (não exige auth).
  static String toOrgLocation(Uri uri) {
    final slug = slugFrom(uri);
    if (slug == null || slug.isEmpty) return '/org';
    return Uri(path: '/org', queryParameters: {'slug': slug}).toString();
  }
}
