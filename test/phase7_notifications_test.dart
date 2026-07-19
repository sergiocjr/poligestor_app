import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/core/config.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_prefs.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';
import 'package:poligestor_app/features/protocols/domain/protocol_message_merge.dart';

void main() {
  group('Contrato URLs', () {
    test('Reverb e broadcasting auth', () {
      expect(AppConfig.publicHost, 'poligestor.onnexis.com.br');
      expect(AppConfig.reverbAppKey, 'z2wszkcgcaqhotnpvltx');
      expect(
        AppConfig.broadcastingAuthUrl,
        'https://poligestor.onnexis.com.br/broadcasting/auth',
      );
      expect(
        AppConfig.reverbWsUrl,
        'wss://poligestor.onnexis.com.br/app/z2wszkcgcaqhotnpvltx',
      );
      expect(AppConfig.restPollingInterval.inSeconds, inInclusiveRange(15, 30));
    });

    test('paths portal', () {
      const m = AuthMode.portal;
      expect(m.devicesRegisterPath, '/v1/portal/devices/register');
      expect(m.devicesCurrentPath, '/v1/portal/devices/current');
      expect(m.notificationReadPath(9), '/v1/portal/notifications/9/read');
      expect(m.notificationsReadAllPath, '/v1/portal/notifications/read-all');
      expect(
        m.notificationsUnreadCountPath,
        '/v1/portal/notifications/unread-count',
      );
      expect(
        m.notificationPreferencesPath,
        '/v1/portal/notification-preferences',
      );
      expect(m.protocolReadPath('abc'), '/v1/portal/protocols/abc/read');
      expect(m.privateUserChannel(12), 'private-portal-user.12');
    });
  });

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

    test('deep_link poligestor://protocols/{id}', () {
      final p = PushPayload.fromMap({
        'type': 'protocol_message',
        'protocol_id': 'uuid-1',
        'deep_link': 'poligestor://protocols/uuid-1',
      });
      expect(p.deepLink, 'poligestor://protocols/uuid-1');
      expect(p.effectiveLink, contains('protocols'));
    });

    test('protocol_information_requested', () {
      final p = PushPayload.fromMap({
        'type': 'protocol_information_requested',
        'protocol_id': 'x',
      });
      expect(p.type, PushEventType.protocolInformationRequested);
    });

    test('protocol_resolved', () {
      final p =
          PushPayload.fromMap({'type': 'protocol_resolved', 'protocol_id': '1'});
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

    test('protocol_reopened / created', () {
      expect(
        PushPayload.fromMap({'type': 'protocol_reopened'}).type,
        PushEventType.protocolReopened,
      );
      expect(
        PushPayload.fromMap({'type': 'protocol_created'}).type,
        PushEventType.protocolCreated,
      );
    });

    test('system_notice', () {
      final p = PushPayload.fromMap({'type': 'system_notice'});
      expect(p.type, PushEventType.systemNotice);
      expect(p.hasProtocolTarget, isFalse);
    });

    test('fromUri notifications', () {
      final p = PushPayload.fromUri(Uri.parse('poligestor://notifications'));
      expect(p.type, PushEventType.systemNotice);
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

    test('deep link protocols', () {
      final t = router.resolve(
        PushPayload.fromMap({
          'type': 'protocol_status_changed',
          'deep_link': 'poligestor://protocols/aa-bb',
        }),
      );
      expect(t!.location, '/citizen/requests/aa-bb');
    });

    test('deep link notifications', () {
      final t = router.resolve(
        PushPayload.fromMap({
          'type': 'protocol_message',
          'deep_link': 'poligestor://notifications',
        }),
      );
      expect(t!.location, '/citizen/notifications');
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

  group('NotificationPrefs contrato', () {
    test('json roundtrip', () {
      final prefs = NotificationPrefs.fromJson({
        'push_enabled': true,
        'protocol_messages_enabled': false,
        'protocol_status_enabled': true,
        'important_only': true,
        'quiet_hours_enabled': true,
        'quiet_hours_start': '23:00',
        'quiet_hours_end': '06:00',
      });
      expect(prefs.protocolMessagesEnabled, isFalse);
      expect(prefs.importantOnly, isTrue);
      expect(prefs.toJson()['quiet_hours_start'], '23:00');
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
