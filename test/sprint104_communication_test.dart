import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/communication/data/communication_cache.dart';
import 'package:poligestor_app/features/communication/data/communication_models.dart';
import 'package:poligestor_app/features/communication/data/communication_repository.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 10.4 paths', () {
    test('exposes LIVE communication contracts only', () {
      const m = AuthMode.staff;
      expect(m.communicationChannelsPath, '/v1/channels');
      expect(m.communicationTemplatesPath, '/v1/templates');
      expect(m.communicationCampaignsPath, '/v1/campaigns');
      expect(m.communicationConversationsPath, '/v1/omnichannel/conversations');
      expect(m.communicationQueuePath, '/v1/omnichannel/queue');
      expect(m.communicationOperatorsPath, '/v1/omnichannel/operators');
    });
  });

  group('CommunicationFilter', () {
    test('omits empty query keys', () {
      expect(const CommunicationFilter().toQuery(), isEmpty);
      expect(const CommunicationFilter(search: '  ').toQuery(), isEmpty);
      expect(
        const CommunicationFilter(
          search: 'alerta',
          status: 'draft',
          channelType: 'email',
          sort: 'name',
        ).toQuery(),
        {
          'search': 'alerta',
          'status': 'draft',
          'channel_type': 'email',
          'sort': 'name',
        },
      );
    });
  });

  group('Comm models parsing', () {
    test('channel from LIVE-shaped json', () {
      final c = CommChannel.fromJson({
        'id': 7,
        'name': 'WhatsApp Gabinete',
        'type': 'whatsapp',
        'provider': 'meta',
        'is_active': true,
        'is_default': 1,
      });
      expect(c.id, '7');
      expect(c.typeLabel, 'WhatsApp');
      expect(c.isDefault, isTrue);
    });

    test('template variables and channel label', () {
      final t = CommTemplate.fromJson({
        'uuid': 'tpl-1',
        'title': 'Boas-vindas',
        'channel_type': 'email',
        'subject': 'Olá {{name}}',
        'body': 'Bem-vindo',
        'variables': [
          'name',
          {'key': 'city'},
        ],
        'is_active': '1',
        'updated_at': '2026-07-18T12:00:00Z',
      });
      expect(t.id, 'tpl-1');
      expect(t.name, 'Boas-vindas');
      expect(t.channelLabel, 'E-mail');
      expect(t.variables, ['name', 'city']);
      expect(t.updatedAt, isNotNull);
    });

    test('campaign status labels and progress', () {
      final camp = CommCampaign.fromJson({
        'id': 'c1',
        'name': 'Campanha Julho',
        'status': 'running',
        'sent_count': 25,
        'total_recipients': 100,
        'failed_count': '2',
        'segment': {'name': 'Zona Norte'},
        'channel': {'type': 'sms'},
      });
      expect(camp.statusLabel, 'Em execução');
      expect(camp.progress, 0.25);
      expect(camp.failedCount, 2);
      expect(camp.segment, 'Zona Norte');
      expect(camp.channelType, 'sms');
    });

    test('asMapList unwraps data envelope', () {
      final list = asMapList({
        'data': [
          {'id': 1, 'name': 'A'},
          {'id': 2, 'name': 'B'},
        ],
      });
      expect(list.length, 2);
      expect(list.first['name'], 'A');
    });

    test('queue snapshot and operator from LIVE omnichannel json', () {
      final q = CommQueueSnapshot.fromJson({
        'queue': 1,
        'assigned': 2,
        'closed': 3,
        'operators': 4,
      });
      expect(q.queue, 1);
      expect(q.assigned, 2);
      expect(q.closed, 3);
      expect(q.operators, 4);

      final op = CommOperator.fromJson({
        'id': null,
        'user_id': 1,
        'name': 'Admin Demo',
        'email': 'admin@demo.local',
        'status': 'offline',
        'active_conversations': 0,
        'last_seen_at': null,
      });
      expect(op.id, '1');
      expect(op.statusLabel, 'Desconectado');
      expect(op.isOnline, isFalse);
    });

    test('conversation parses contact and status', () {
      final c = CommConversation.fromJson({
        'id': 'cv-1',
        'status': 'queued',
        'channel': {'type': 'whatsapp'},
        'contact': {'name': 'Maria'},
        'unread_count': 2,
      });
      expect(c.id, 'cv-1');
      expect(c.statusLabel, 'Na fila');
      expect(c.channelType, 'whatsapp');
      expect(c.contactName, 'Maria');
      expect(c.unreadCount, 2);
    });
  });

  group('CommunicationCache', () {
    test('round-trip channels/templates/campaigns', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = CommunicationCache();
      await cache.saveChannels([
        const CommChannel(id: '1', name: 'E-mail', type: 'email'),
      ]);
      await cache.saveTemplates([
        const CommTemplate(id: 't1', name: 'Tpl', channelType: 'sms'),
      ]);
      await cache.saveCampaigns([
        const CommCampaign(id: 'c1', name: 'Camp', status: 'draft'),
      ]);

      final channels = await cache.getChannels();
      final templates = await cache.getTemplates();
      final campaigns = await cache.getCampaigns();
      expect(channels!.single.name, 'E-mail');
      expect(templates!.single.channelType, 'sms');
      expect(campaigns!.single.status, 'draft');

      await cache.clear();
      expect(await cache.getChannels(), isNull);
    });
  });

  group('deep links communication', () {
    test('poligestor://communication resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://communication',
        ),
      );
      expect(target?.location, '/home/communication');
    });

    test('poligestor://comunicacao/campaigns/9 resolves detail path', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://comunicacao/campaigns/9',
        ),
      );
      expect(target?.location, '/home/communication/campaigns/9');
    });
  });
}
