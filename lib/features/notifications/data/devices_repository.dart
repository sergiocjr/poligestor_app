import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../core/config.dart';

/// Registro de dispositivo no endpoint já existente (`AuthMode.devicesPath`).
/// Não inventa rotas de remoção — logout apenas limpa token local até o contrato.
class DevicesRepository {
  DevicesRepository(this._api);

  final ApiClient _api;

  static String platformName() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
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
      mode.devicesPath,
      data: {
        'token': trimmed,
        'platform': platformName(),
        'device_name': deviceName ?? ApiClient.deviceName(),
        'app_version': appVersion ?? AppConfig.appVersion,
      },
      mode: mode,
      parse: (raw) {
        if (raw is Map<String, dynamic>) return raw;
        if (raw is Map) return Map<String, dynamic>.from(raw);
        return <String, dynamic>{};
      },
    );
  }
}
