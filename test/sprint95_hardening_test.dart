import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_state.dart';
import 'package:poligestor_app/features/mandate/domain/mandate_refresh_controller.dart';

void main() {
  group('Sprint 9.5 hardening', () {
    test('AuthUser masks document in cache json', () {
      final user = AuthUser(
        id: 1,
        name: 'Maria',
        email: 'm@demo.local',
        document: '123.456.789-00',
      );
      expect(user.maskedDocument, '***.***.***-00');
      final json = user.toJson();
      final person = json['person'] as Map;
      expect(person['document'], '***.***.***-00');
      expect(person['document'], isNot(contains('12345678900')));
    });

    test('AuthUser.maskDocument handles short and empty', () {
      expect(AuthUser.maskDocument(null), isNull);
      expect(AuthUser.maskDocument(''), isNull);
      expect(AuthUser.maskDocument('12'), '***');
    });

    test('MandateRefreshController throttles rapid bumps', () {
      final c = MandateRefreshController();
      c.bump(reason: 'a', force: true);
      expect(c.generation, 1);
      c.bump(reason: 'b');
      expect(c.generation, 1);
      c.bump(reason: 'c', force: true);
      expect(c.generation, 2);
    });
  });
}
