/// Ambiente da API (dev local via 10.0.2.2 no emulador, ou produção HTTPS).
enum AppEnvironment { development, production }

class AppConfig {
  AppConfig._();

  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  static AppEnvironment get environment => _envName == 'development'
      ? AppEnvironment.development
      : AppEnvironment.production;

  /// Produção: domínio HTTPS público.
  /// Dev no emulador Android apontando para API neste PC: use `10.0.2.2`
  /// (nunca `localhost`).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://poligestor.onnexis.com.br/api',
  );

  static const String defaultTenantSlug = String.fromEnvironment(
    'TENANT_SLUG',
    defaultValue: 'demo',
  );

  static const String appName = 'PoliGestor';

  /// Espelha `pubspec.yaml` version até haver package_info em runtime.
  static const String appVersion = '1.0.0+1';

  /// Host público (REST + WSS + broadcasting auth).
  static const String publicHost = String.fromEnvironment(
    'PUBLIC_HOST',
    defaultValue: 'poligestor.onnexis.com.br',
  );

  /// Auth de canais privados (fora de `/api`).
  static String get broadcastingAuthUrl =>
      'https://$publicHost/broadcasting/auth';

  /// Reverb app key pública (nunca o secret).
  static const String reverbAppKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: 'z2wszkcgcaqhotnpvltx',
  );

  static const int reverbPort = int.fromEnvironment(
    'REVERB_PORT',
    defaultValue: 443,
  );

  static const bool reverbTls = bool.fromEnvironment(
    'REVERB_TLS',
    defaultValue: true,
  );

  /// WSS canônico: `wss://{host}/app/{key}`.
  static String get reverbWsUrl {
    final scheme = reverbTls ? 'wss' : 'ws';
    final portSuffix =
        (reverbTls && reverbPort == 443) || (!reverbTls && reverbPort == 80)
        ? ''
        : ':$reverbPort';
    return '$scheme://$publicHost$portSuffix/app/$reverbAppKey';
  }

  /// Intervalo de polling REST na tela aberta (fallback obrigatório 15–30s).
  static const Duration restPollingInterval = Duration(seconds: 20);

  /// FCM real (Android). Requer `android/app/google-services.json`.
  static const bool pushEnabled = bool.fromEnvironment(
    'PUSH_ENABLED',
    defaultValue: true,
  );

  static const int primaryTeal = 0xFF0D9488;
  static const int seedNavy = 0xFF0B1F3A;

  static bool get isProduction => environment == AppEnvironment.production;
}
