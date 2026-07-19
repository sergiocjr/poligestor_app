import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'identity_models.dart';

/// Cache de organização/branding **por tenant** (isolamento Sprint 10.2).
class IdentityCache {
  IdentityCache();

  static const _activeSlugKey = 'identity_active_tenant_slug';
  static const _committedKey = 'identity_org_committed';

  String _orgKey(String slug) => 'identity_organization_json_$slug';
  String _brandingKey(String slug) => 'identity_branding_json_$slug';

  Future<void> saveOrganization(TenantOrganization org) async {
    final prefs = await SharedPreferences.getInstance();
    final slug = org.slug.trim().toLowerCase();
    await prefs.setString(_orgKey(slug), jsonEncode(org.toJson()));
    await prefs.setString(_activeSlugKey, slug);
    await prefs.setBool(_committedKey, true);
  }

  Future<TenantOrganization?> getOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    final slug = prefs.getString(_activeSlugKey);
    if (slug == null || slug.isEmpty) {
      // Legado pré-isolamento (chave única).
      final legacy = prefs.getString('identity_organization_json');
      if (legacy == null || legacy.isEmpty) return null;
      try {
        final map = jsonDecode(legacy);
        if (map is! Map) return null;
        final org = TenantOrganization.fromJson(Map<String, dynamic>.from(map));
        if (org.slug.isNotEmpty) {
          await saveOrganization(org);
          await prefs.remove('identity_organization_json');
        }
        return org;
      } catch (_) {
        return null;
      }
    }
    final raw = prefs.getString(_orgKey(slug));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      return TenantOrganization.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBranding(
    TenantBranding branding, {
    required String slug,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final s = slug.trim().toLowerCase();
    await prefs.setString(_brandingKey(s), jsonEncode(branding.toJson()));
  }

  Future<TenantBranding?> getBranding({String? slug}) async {
    final prefs = await SharedPreferences.getInstance();
    final s = (slug ?? prefs.getString(_activeSlugKey) ?? '')
        .trim()
        .toLowerCase();
    if (s.isEmpty) {
      final legacy = prefs.getString('identity_branding_json');
      if (legacy == null || legacy.isEmpty) return null;
      try {
        final map = jsonDecode(legacy);
        if (map is! Map) return null;
        return TenantBranding.fromJson(Map<String, dynamic>.from(map));
      } catch (_) {
        return null;
      }
    }
    final raw = prefs.getString(_brandingKey(s));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      return TenantBranding.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  Future<bool> isOrganizationCommitted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_committedKey) ?? false;
  }

  /// Remove org/branding ativos e chaves legadas. Não toca em outros tenants
  /// armazenados (podem ser limpos no switch via [purgeAllTenantData]).
  Future<void> clearOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    final slug = prefs.getString(_activeSlugKey);
    if (slug != null && slug.isNotEmpty) {
      await prefs.remove(_orgKey(slug));
      await prefs.remove(_brandingKey(slug));
    }
    await prefs.remove(_activeSlugKey);
    await prefs.remove(_committedKey);
    await prefs.remove('identity_organization_json');
    await prefs.remove('identity_branding_json');
  }

  /// Isolamento ao trocar organização: remove todos os caches identity_*.
  Future<void> purgeAllTenantData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
      (k) =>
          k.startsWith('identity_organization_json') ||
          k.startsWith('identity_branding_json') ||
          k == _activeSlugKey ||
          k == _committedKey,
    );
    for (final k in keys.toList()) {
      await prefs.remove(k);
    }
  }
}
