import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';

class AccountRepository {
  AccountRepository(this._api);

  final ApiClient _api;

  /// LIVE: `GET /v1/auth/sessions` (staff). Portal espelha path.
  Future<List<AuthSessionInfo>> sessions({required AuthMode mode}) async {
    final envelope = await _api.getEnvelope<dynamic>(
      mode.sessionsPath,
      mode: mode,
      parse: (raw) => raw,
    );
    return idAsMapList(envelope.data).map(AuthSessionInfo.fromJson).toList();
  }

  /// LIVE: `DELETE /v1/auth/sessions/{id}`
  Future<void> revokeSession({
    required AuthMode mode,
    required String sessionId,
  }) async {
    await _api.deleteEnvelope(
      mode.sessionPath(sessionId),
      mode: mode,
      parse: (raw) => raw,
    );
  }

  /// `DELETE …/sessions/revoke-all` — rota existe (método DELETE).
  Future<void> revokeAllSessions({required AuthMode mode}) async {
    try {
      await _api.deleteEnvelope(
        mode.sessionsRevokeAllPath,
        mode: mode,
        parse: (raw) => raw,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405) {
        throw EndpointUnavailableException(
          mode.sessionsRevokeAllPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  /// `POST …/logout` — rota staff existe.
  Future<void> logoutRemote({required AuthMode mode}) async {
    try {
      await _api.postEnvelope<dynamic>(
        mode.logoutPath,
        mode: mode,
        data: const {},
        parse: (raw) => raw,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw EndpointUnavailableException(
          mode.logoutPath,
          statusCode: e.statusCode,
        );
      }
      // 401 = já inválido — ok.
      if (e.isUnauthorized) return;
      rethrow;
    }
  }

  Future<void> register({
    required AuthMode mode,
    required String tenantSlug,
    required String name,
    required String email,
    required String password,
    String? passwordConfirmation,
    String? document,
  }) async {
    try {
      await _api.postEnvelope<Map<String, dynamic>>(
        mode.registerPath,
        mode: mode,
        tenantSlug: tenantSlug,
        skipAuth: true,
        skipRefresh: true,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation ?? password,
          if (document != null && document.trim().isNotEmpty)
            'document': document.trim(),
        },
        parse: idAsMap,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 500) {
        throw EndpointUnavailableException(
          mode.registerPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<void> forgotPassword({
    required AuthMode mode,
    required String tenantSlug,
    required String email,
  }) async {
    try {
      await _api.postEnvelope<dynamic>(
        mode.forgotPasswordPath,
        mode: mode,
        tenantSlug: tenantSlug,
        skipAuth: true,
        skipRefresh: true,
        data: {'email': email.trim()},
        parse: (raw) => raw,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 500) {
        throw EndpointUnavailableException(
          mode.forgotPasswordPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<void> resetPassword({
    required AuthMode mode,
    required String tenantSlug,
    required String email,
    required String code,
    required String password,
    String? passwordConfirmation,
  }) async {
    try {
      await _api.postEnvelope<dynamic>(
        mode.resetPasswordPath,
        mode: mode,
        tenantSlug: tenantSlug,
        skipAuth: true,
        skipRefresh: true,
        data: {
          'email': email.trim(),
          'code': code.trim(),
          'token': code.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation ?? password,
        },
        parse: (raw) => raw,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 500) {
        throw EndpointUnavailableException(
          mode.resetPasswordPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<List<LinkedAccount>> linkedAccounts({required AuthMode mode}) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        mode.linkedAccountsPath,
        mode: mode,
        parse: (raw) => raw,
      );
      final list = envelope.data is List
          ? idAsMapList(envelope.data)
          : idAsMapList(idAsMap(envelope.data)['accounts']);
      return list.map(LinkedAccount.fromJson).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 500) {
        throw EndpointUnavailableException(
          mode.linkedAccountsPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required AuthMode mode,
    required Map<String, dynamic> body,
  }) async {
    try {
      final envelope = await _api.putEnvelope<Map<String, dynamic>>(
        mode.profilePath,
        mode: mode,
        data: body,
        parse: idAsMap,
      );
      return envelope.data;
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405 || e.statusCode == 500) {
        throw EndpointUnavailableException(
          mode.profilePath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> oauthSignIn({
    required AuthMode mode,
    required String provider,
    required String tenantSlug,
    required Map<String, dynamic> payload,
  }) async {
    final path = switch (provider) {
      'google' => mode.oauthGooglePath,
      'apple' => mode.oauthApplePath,
      'govbr' || 'gov.br' => mode.oauthGovBrPath,
      _ => mode.oauthGooglePath,
    };
    try {
      final envelope = await _api.postEnvelope<Map<String, dynamic>>(
        path,
        mode: mode,
        tenantSlug: tenantSlug,
        skipAuth: true,
        skipRefresh: true,
        data: payload,
        parse: idAsMap,
      );
      return envelope.data;
    } on ApiException catch (e) {
      if (e.statusCode == 404 ||
          e.statusCode == 405 ||
          e.statusCode == 501 ||
          e.statusCode == 503) {
        throw EndpointUnavailableException(path, statusCode: e.statusCode);
      }
      rethrow;
    }
  }
}
