import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../config.dart';
import '../storage/token_storage.dart';
import 'auth_mode.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required ApiClient api,
    required TokenStorage storage,
  })  : _api = api,
        _storage = storage {
    _api.setOnSessionExpired(_handleSessionExpired);
  }

  final ApiClient _api;
  final TokenStorage _storage;

  AuthSession? _session;
  bool _booting = true;
  bool _busy = false;
  String? _error;
  bool _apiDegraded = false;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get isBooting => _booting;
  bool get isBusy => _busy;
  String? get error => _error;
  AuthMode get mode => _session?.mode ?? AuthMode.staff;
  bool get apiDegraded => _apiDegraded;

  Future<void> bootstrap() async {
    _booting = true;
    _apiDegraded = false;
    notifyListeners();

    try {
      final access = await _storage.getAccessToken();
      final refresh = await _storage.getRefreshToken();
      final mode = await _storage.getAuthMode();
      final tenant =
          await _storage.getTenantSlug() ?? AppConfig.defaultTenantSlug;

      if (access == null || access.isEmpty || mode == null) {
        _session = null;
        return;
      }

      _api.setSessionContext(mode: mode, tenantSlug: tenant);

      try {
        final user = await _fetchMe(mode);
        await _storage.saveUserJson(user.toJson());
        _session = AuthSession(mode: mode, user: user, tenantSlug: tenant);
        await _registerDeviceSilently(mode);
      } on ApiException catch (e) {
        // Portal: tokens emitidos no login mas /me pode falhar (bug backend 401).
        // Mantém sessão com perfil cacheado para não perder UX após login fresco.
        final cached = await _storage.getUserJson();
        if (mode == AuthMode.portal && cached != null && e.isUnauthorized) {
          _apiDegraded = true;
          _session = AuthSession(
            mode: mode,
            user: AuthUser.fromJson(cached),
            tenantSlug: tenant,
          );
        } else if (refresh != null && refresh.isNotEmpty) {
          rethrow;
        } else {
          rethrow;
        }
      }
    } catch (_) {
      await _storage.clearTokens();
      _session = null;
    } finally {
      _booting = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required AuthMode mode,
    required String email,
    required String password,
    String? tenantSlug,
  }) async {
    _busy = true;
    _error = null;
    _apiDegraded = false;
    notifyListeners();

    final tenant = (tenantSlug?.trim().isNotEmpty == true)
        ? tenantSlug!.trim()
        : AppConfig.defaultTenantSlug;

    try {
      _api.setSessionContext(mode: mode, tenantSlug: tenant);

      final envelope = await _api.postEnvelope<Map<String, dynamic>>(
        mode.loginPath,
        data: {
          'email': email.trim(),
          'password': password,
          'device_name': ApiClient.deviceName(),
        },
        skipAuth: true,
        skipRefresh: true,
        mode: mode,
        tenantSlug: tenant,
        parse: (raw) {
          if (raw is Map<String, dynamic>) return raw;
          if (raw is Map) return Map<String, dynamic>.from(raw);
          return <String, dynamic>{};
        },
      );

      final data = envelope.data;
      final access =
          (data['access_token'] ?? data['token'] ?? data['accessToken'])
              ?.toString();
      final refresh =
          (data['refresh_token'] ?? data['refreshToken'])?.toString();

      if (access == null || access.isEmpty) {
        throw ApiException(message: 'Resposta de login sem token.');
      }

      await _storage.saveTokens(
        accessToken: access,
        refreshToken: refresh ?? '',
      );
      await _storage.saveSessionMeta(
        mode: mode,
        tenantSlug: tenant,
        email: email.trim(),
      );

      AuthUser user;
      final nestedUser = data['user'] ?? data['usuario'];
      if (nestedUser is Map<String, dynamic>) {
        user = AuthUser.fromJson(nestedUser);
      } else if (nestedUser is Map) {
        user = AuthUser.fromJson(Map<String, dynamic>.from(nestedUser));
      } else {
        user = await _fetchMe(mode);
      }

      await _storage.saveUserJson(
        nestedUser is Map
            ? Map<String, dynamic>.from(nestedUser)
            : user.toJson(),
      );

      _session = AuthSession(mode: mode, user: user, tenantSlug: tenant);
      await _registerDeviceSilently(mode);

      // Detecta API portal degradada (token inválido nas rotas protegidas).
      if (mode == AuthMode.portal) {
        try {
          await _fetchMe(mode);
          _apiDegraded = false;
        } on ApiException catch (e) {
          if (e.isUnauthorized) {
            _apiDegraded = true;
          }
        }
      }
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    _session = null;
    _apiDegraded = false;
    _api.setSessionContext(mode: null, tenantSlug: null);
    notifyListeners();
  }

  Future<AuthUser> _fetchMe(AuthMode mode) async {
    final envelope = await _api.getEnvelope<AuthUser>(
      mode.mePath,
      mode: mode,
      parse: (raw) {
        if (raw is Map<String, dynamic>) return AuthUser.fromJson(raw);
        if (raw is Map) {
          return AuthUser.fromJson(Map<String, dynamic>.from(raw));
        }
        throw ApiException(message: 'Resposta /me inválida.');
      },
    );
    return envelope.data;
  }

  Future<void> _registerDeviceSilently(AuthMode mode) async {
    try {
      await _api.postEnvelope<Map<String, dynamic>>(
        mode.devicesPath,
        data: {
          'token':
              'flutter-placeholder-${DateTime.now().millisecondsSinceEpoch}',
          'platform': ApiClient.deviceName().replaceFirst('flutter-', ''),
          'device_name': ApiClient.deviceName(),
        },
        mode: mode,
        parse: (raw) {
          if (raw is Map<String, dynamic>) return raw;
          if (raw is Map) return Map<String, dynamic>.from(raw);
          return <String, dynamic>{};
        },
      );
    } catch (_) {}
  }

  Future<void> _handleSessionExpired() async {
    await _storage.clearTokens();
    _session = null;
    _apiDegraded = false;
    notifyListeners();
  }
}
