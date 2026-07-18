/// Ambiente da API (dev local via 10.0.2.2 no emulador, ou produção HTTPS).
enum AppEnvironment { development, production }

class AppConfig {
  AppConfig._();

  static const String _envName =
      String.fromEnvironment('APP_ENV', defaultValue: 'production');

  static AppEnvironment get environment =>
      _envName == 'development'
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

  static const int primaryTeal = 0xFF0D9488;
  static const int seedNavy = 0xFF0B1F3A;

  static bool get isProduction => environment == AppEnvironment.production;
}
