import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'identity_models.dart';

class IdentityCache {
  IdentityCache();

  static const _orgKey = 'identity_organization_json';
  static const _brandingKey = 'identity_branding_json';
  static const _committedKey = 'identity_org_committed';

  Future<void> saveOrganization(TenantOrganization org) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_orgKey, jsonEncode(org.toJson()));
    await prefs.setBool(_committedKey, true);
  }

  Future<TenantOrganization?> getOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_orgKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      return TenantOrganization.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBranding(TenantBranding branding) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brandingKey, jsonEncode(branding.toJson()));
  }

  Future<TenantBranding?> getBranding() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_brandingKey);
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

  Future<void> clearOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_orgKey);
    await prefs.remove(_brandingKey);
    await prefs.setBool(_committedKey, false);
  }
}
