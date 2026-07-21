import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../core/config.dart';

/// Dispositivos FCM — contrato Fase 7.
class DevicesRepository {
  DevicesRepository(this._api);

  final ApiClient _api;

  /// Contrato: `android` | `ios`.
  static String platformName() {
    if (!kIsWeb && Platform.isIOS) return 'ios';
    return 'android';
  }

  Future<void> register({
    required AuthMode mode,
    required String token,
    String? deviceName,
    String? appVersion,
  }) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;

    await _api.postEnvelope<Map<String, dynamic>>(
      mode.devicesRegisterPath,
      data: {
        'token': trimmed,
        'platform': platformName(),
        'device_name': deviceName ?? ApiClient.deviceName(),
        'app_version': appVersion ?? AppConfig.appVersion,
      },
      mode: mode,
      parse: _asMap,
    );
  }

  /// Logout do device: `DELETE …/devices/current` (body opcional com token).
  Future<void> unregisterCurrent({
    required AuthMode mode,
    String? token,
  }) async {
    final body = <String, dynamic>{};
    final trimmed = token?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      body['token'] = trimmed;
    }

    await _api.deleteEnvelope<Map<String, dynamic>>(
      mode.devicesCurrentPath,
      data: body.isEmpty ? null : body,
      mode: mode,
      parse: _asMap,
    );
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }
}
