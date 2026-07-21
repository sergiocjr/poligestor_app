import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/shared/demo/demo_repository_support.dart';

void main() {
  group('DemoRepositorySupport', () {
    test('rootFor list path returns demo meta', () {
      final root = DemoRepositorySupport.rootFor('/v1/crm/leaders');
      expect(DemoRepositorySupport.isDemoRoot(root), isTrue);
      expect((root['data'] as List).length, greaterThan(0));
    });

    test('coerceRoot replaces empty LIVE list', () {
      final coerced = DemoRepositorySupport.coerceRoot(
        '/v1/finance/transactions',
        {'data': <Map<String, dynamic>>[]},
      );
      expect(DemoRepositorySupport.isDemoRoot(coerced), isTrue);
    });

    test('isDemoId detects demo prefix', () {
      expect(DemoRepositorySupport.isDemoId('demo-news-0'), isTrue);
      expect(DemoRepositorySupport.isDemoId('live-1'), isFalse);
    });

    test('news titles are regional', () {
      final item = DemoRepositorySupport.firstItem('/v1/news/mentions');
      expect(item['title'].toString(), contains('Volta Redonda'));
    });
  });
}
