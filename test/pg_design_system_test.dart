import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/shared/widgets/pg_design_system.dart';

void main() {
  group('pgFormatResolutionHours', () {
    test('zero or negative returns dash', () {
      expect(pgFormatResolutionHours(0), '—');
      expect(pgFormatResolutionHours(-1), '—');
      expect(pgFormatResolutionHours(null), '—');
    });

    test('sub-hour returns minutes', () {
      expect(pgFormatResolutionHours(0.5), '30 min');
    });

    test('normal hours', () {
      expect(pgFormatResolutionHours(2.4), '2.4 h');
    });
  });
}
