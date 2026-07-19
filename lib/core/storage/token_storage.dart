import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_mode.dart';

/// Tokens sensíveis no secure storage; meta de sessão e perfil cacheado no SharedPreferences.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage, SharedPreferences? prefs})
    : _secure =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          ),
      _prefs = prefs;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kMode = 'auth_mode';
  static const _kTenant = 'tenant_slug';
  static const _kEmail = 'last_email';
  static const _kUser = 'cached_user_json';

  final FlutterSecureStorage _secure;
  SharedPreferences? _prefs;

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secure.write(key: _kAccess, value: accessToken);
    await _secure.write(key: _kRefresh, value: refreshToken);
  }

  Future<String?> getAccessToken() => _secure.read(key: _kAccess);

  Future<String?> getRefreshToken() => _secure.read(key: _kRefresh);

  Future<void> clearTokens() async {
    await _secure.delete(key: _kAccess);
    await _secure.delete(key: _kRefresh);
  }

  Future<void> saveSessionMeta({
    required AuthMode mode,
    required String tenantSlug,
    String? email,
  }) async {
    final prefs = await _preferences();
    await prefs.setString(_kMode, mode.name);
    await prefs.setString(_kTenant, tenantSlug);
    if (email != null) {
      await prefs.setString(_kEmail, email);
    }
  }

  Future<void> saveUserJson(Map<String, dynamic> user) async {
    final prefs = await _preferences();
    await prefs.setString(_kUser, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUserJson() async {
    final prefs = await _preferences();
    final raw = prefs.getString(_kUser);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

  Future<AuthMode?> getAuthMode() async {
    final prefs = await _preferences();
    final raw = prefs.getString(_kMode);
    if (raw == null) return null;
    for (final mode in AuthMode.values) {
      if (mode.name == raw) return mode;
    }
    return null;
  }

  Future<String?> getTenantSlug() async {
    final prefs = await _preferences();
    return prefs.getString(_kTenant);
  }

  Future<String?> getLastEmail() async {
    final prefs = await _preferences();
    return prefs.getString(_kEmail);
  }

  Future<void> clearAll() async {
    await clearTokens();
    final prefs = await _preferences();
    await prefs.remove(_kMode);
    await prefs.remove(_kUser);
  }

  /// Troca de organização: remove tokens, modo, usuário, tenant e e-mail.
  Future<void> clearSessionAndTenant() async {
    await clearAll();
    final prefs = await _preferences();
    await prefs.remove(_kTenant);
    await prefs.remove(_kEmail);
  }
}
