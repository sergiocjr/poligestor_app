import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../auth/auth_mode.dart';
import '../config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'api_response.dart';

typedef OnSessionExpired = Future<void> Function();

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    String? baseUrl,
    OnSessionExpired? onSessionExpired,
  }) : _storage = tokenStorage,
       _onSessionExpired = onSessionExpired {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  late final Dio _dio;
  final TokenStorage _storage;
  OnSessionExpired? _onSessionExpired;
  AuthMode? _mode;
  String? _tenantSlug;
  bool _refreshing = false;

  Dio get raw => _dio;

  void setSessionContext({AuthMode? mode, String? tenantSlug}) {
    _mode = mode;
    _tenantSlug = tenantSlug;
  }

  void setOnSessionExpired(OnSessionExpired callback) {
    _onSessionExpired = callback;
  }

  static String deviceName() {
    if (kIsWeb) return 'flutter-web';
    try {
      if (Platform.isAndroid) return 'flutter-android';
      if (Platform.isIOS) return 'flutter-ios';
      if (Platform.isWindows) return 'flutter-windows';
      if (Platform.isMacOS) return 'flutter-macos';
      if (Platform.isLinux) return 'flutter-linux';
    } catch (_) {}
    return 'flutter-unknown';
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.extra['skipAuth'] == true;
    if (!skipAuth) {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    final mode = options.extra['authMode'] as AuthMode? ?? _mode;
    final tenant = options.extra['tenantSlug'] as String? ?? _tenantSlug;
    // Identity / portal públicos e rotas autenticadas com tenant.
    if (tenant != null && tenant.isNotEmpty) {
      options.headers['X-Tenant-Slug'] = tenant;
    } else if (mode == AuthMode.portal &&
        _tenantSlug != null &&
        _tenantSlug!.isNotEmpty) {
      options.headers['X-Tenant-Slug'] = _tenantSlug;
    }

    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final skipRefresh = err.requestOptions.extra['skipRefresh'] == true;

    if (status == 401 && !skipRefresh && !_refreshing) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        try {
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          if (e is DioException) return handler.next(e);
          return handler.next(err);
        }
      }
      await _onSessionExpired?.call();
    }

    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _storage.getRefreshToken();
    final mode = _mode;
    if (refresh == null || refresh.isEmpty || mode == null) return false;

    _refreshing = true;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        mode.refreshPath,
        data: {'refresh_token': refresh},
        options: Options(
          extra: {
            'skipAuth': true,
            'skipRefresh': true,
            'authMode': mode,
            if (_tenantSlug != null) 'tenantSlug': _tenantSlug,
          },
        ),
      );

      final body = response.data ?? {};
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      final access = (data['access_token'] ?? data['token'])?.toString();
      final newRefresh = (data['refresh_token'] ?? refresh).toString();

      if (access == null || access.isEmpty) return false;

      await _storage.saveTokens(accessToken: access, refreshToken: newRefresh);
      return true;
    } catch (_) {
      await _storage.clearTokens();
      return false;
    } finally {
      _refreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions request) async {
    final token = await _storage.getAccessToken();
    final headers = Map<String, dynamic>.from(request.headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return _dio.request(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      options: Options(
        method: request.method,
        headers: headers,
        extra: {...request.extra, 'skipRefresh': true},
        contentType: request.contentType,
        responseType: request.responseType,
      ),
    );
  }

  Future<ApiEnvelope<T>> getEnvelope<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic raw) parse,
    AuthMode? mode,
    String? tenantSlug,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
        options: Options(
          extra: {
            if (mode != null) 'authMode': mode,
            if (tenantSlug != null) 'tenantSlug': tenantSlug,
          },
        ),
      );
      return ApiEnvelope.fromJson(response.data ?? {}, parse);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ApiEnvelope<T>> postEnvelope<T>(
    String path, {
    Object? data,
    required T Function(dynamic raw) parse,
    AuthMode? mode,
    String? tenantSlug,
    bool skipAuth = false,
    bool skipRefresh = false,
    Duration? connectTimeout,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(
          extra: {
            'skipAuth': skipAuth,
            'skipRefresh': skipRefresh,
            if (mode != null) 'authMode': mode,
            if (tenantSlug != null) 'tenantSlug': tenantSlug,
          },
          connectTimeout: connectTimeout,
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
        ),
      );
      return ApiEnvelope.fromJson(response.data ?? {}, parse);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ApiEnvelope<T>> putEnvelope<T>(
    String path, {
    Object? data,
    required T Function(dynamic raw) parse,
    AuthMode? mode,
    String? tenantSlug,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(
          extra: {
            if (mode != null) 'authMode': mode,
            if (tenantSlug != null) 'tenantSlug': tenantSlug,
          },
        ),
      );
      return ApiEnvelope.fromJson(response.data ?? {}, parse);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ApiEnvelope<T>> patchEnvelope<T>(
    String path, {
    Object? data,
    required T Function(dynamic raw) parse,
    AuthMode? mode,
    String? tenantSlug,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(
          extra: {
            if (mode != null) 'authMode': mode,
            if (tenantSlug != null) 'tenantSlug': tenantSlug,
          },
        ),
      );
      return ApiEnvelope.fromJson(response.data ?? {}, parse);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// POST que aceita corpo bruto (ex.: broadcasting auth `{ "auth": "..." }`).
  Future<Map<String, dynamic>> postRawMap(
    String path, {
    Object? data,
    AuthMode? mode,
    String? tenantSlug,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        options: Options(
          headers: headers,
          extra: {
            if (mode != null) 'authMode': mode,
            if (tenantSlug != null) 'tenantSlug': tenantSlug,
          },
        ),
      );
      final body = response.data;
      if (body is Map<String, dynamic>) return body;
      if (body is Map) return Map<String, dynamic>.from(body);
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ApiEnvelope<T>> deleteEnvelope<T>(
    String path, {
    Object? data,
    required T Function(dynamic raw) parse,
    AuthMode? mode,
    String? tenantSlug,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(
          extra: {
            if (mode != null) 'authMode': mode,
            if (tenantSlug != null) 'tenantSlug': tenantSlug,
          },
        ),
      );
      return ApiEnvelope.fromJson(response.data ?? {}, parse);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      dynamic rawMessage =
          data['message'] ??
          data['error'] ??
          data['msg'] ??
          'Erro na requisição';
      if (rawMessage is Map) {
        rawMessage =
            rawMessage['message'] ?? rawMessage['code'] ?? 'Erro na requisição';
      }
      final message = rawMessage.toString();
      final errors = data['errors'] is Map<String, dynamic>
          ? data['errors'] as Map<String, dynamic>
          : null;
      return ApiException(message: message, statusCode: status, errors: errors);
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException(
        message: 'Tempo esgotado. Verifique sua conexão.',
        statusCode: status,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Sem conexão com o servidor.',
        statusCode: status,
      );
    }

    return ApiException(
      message: e.message ?? 'Erro inesperado',
      statusCode: status,
    );
  }
}
