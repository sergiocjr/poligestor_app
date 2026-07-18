import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/config.dart';

void main() {
  test('AppConfig defaults', () {
    expect(AppConfig.appName, 'PoliGestor');
    expect(AppConfig.apiBaseUrl, contains('poligestor'));
    expect(AppConfig.defaultTenantSlug, 'demo');
  });
}
