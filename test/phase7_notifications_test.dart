import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';
import 'package:poligestor_app/features/protocols/domain/protocol_message_merge.dart';

void main() {
  group('PushPayload parsing', () {
    test('protocol_message', () {
      final p = PushPayload.fromMap({
        'type': 'protocol_message',
        'title': 'Nova mensagem',
        'data': {
          'protocol_id': 'abc-1',
          'protocol_number': 'PG-2026-1',
        },
      });
      expect(p.type, PushEventType.protocolMessage);
      expect(p.protocolId, 'abc-1');
      expect(p.protocolNumber, 'PG-2026-1');
    });

    test('protocol_information_requested', () {
      final p = PushPayload.fromMap({
        'type': 'protocol_information_requested',
        'protocol_id': 'x',
      });
      expect(p.type, PushEventType.protocolInformationRequested);
    });

    test('protocol_resolved', () {
      final p = PushPayload.fromMap({'type': 'protocol_resolved', 'protocol_id': '1'});
      expect(p.type, PushEventType.protocolResolved);
    });

    test('protocol_rating_available', () {
      final p = PushPayload.fromMap({
        'type': 'protocol_rating_available',
        'link': '/portal/solicitacoes/99',
      });
      expect(p.type, PushEventType.protocolRatingAvailable);
      expect(p.link, contains('solicitacoes'));
    });

    test('system_notice', () {
      final p = PushPayload.fromMap({'type': 'system_notice'});
      expect(p.type, PushEventType.systemNotice);
      expect(p.hasProtocolTarget, isFalse);
    });

    test('payload inválido / desconhecido sem protocolo', () {
      final p = PushPayload.fromMap({'type': 'foo_bar'});
      expect(p.type, PushEventType.unknown);
      expect(p.hasProtocolTarget, isFalse);
    });
  });

  group('NotificationRouter', () {
    const router = NotificationRouter();

    test('mensagem abre detalhe na conversa', () {
      final t = router.resolve(
        PushPayload.fromMap({
          'type': 'protocol_message',
          'protocol_id': 'uuid-9',
        }),
      );
      expect(t, isNotNull);
      expect(t!.location, '/citizen/requests/uuid-9');
      expect(t.highlightConversation, isTrue);
    });

    test('avaliação abre detalhe com highlight', () {
      final t = router.resolve(
        PushPayload.fromMap({
          'type': 'protocol_rating_available',
          'protocol_id': 'r1',
        }),
      );
      expect(t!.highlightRating, isTrue);
      expect(t.location, '/citizen/requests/r1');
    });

    test('system_notice abre central', () {
      final t = router.resolve(PushPayload.fromMap({'type': 'system_notice'}));
      expect(t!.location, '/citizen/notifications');
    });

    test('payload sem protocolo válido retorna null no detalhe', () {
      final t = router.resolve(
        PushPayload.fromMap({
          'type': 'protocol_message',
        }),
      );
      expect(t, isNull);
    });

    test('link web vira rota interna', () {
      final t = router.resolve(
        PushPayload.fromMap({
          'type': 'protocol_status_changed',
          'link': 'https://x/portal/solicitacoes/55',
        }),
      );
      expect(t!.location, '/citizen/requests/55');
    });
  });

  group('mergeProtocolMessages', () {
    test('não duplica por id', () {
      final a = ProtocolMessage(
        id: '1',
        body: 'ola',
        createdAt: DateTime.parse('2026-07-18T10:00:00Z'),
      );
      final b = ProtocolMessage(
        id: '1',
        body: 'ola editada',
        createdAt: DateTime.parse('2026-07-18T10:00:00Z'),
      );
      final c = ProtocolMessage(
        id: '2',
        body: 'nova',
        createdAt: DateTime.parse('2026-07-18T11:00:00Z'),
      );
      final merged = mergeProtocolMessages([a], [b, c]);
      expect(merged, hasLength(2));
      expect(merged.first.body, 'ola editada');
      expect(merged.last.id, '2');
    });

    test('isNearScrollEnd', () {
      expect(isNearScrollEnd(0, 0), isTrue);
      expect(isNearScrollEnd(880, 1000), isTrue);
      expect(isNearScrollEnd(100, 1000), isFalse);
    });
  });
}
