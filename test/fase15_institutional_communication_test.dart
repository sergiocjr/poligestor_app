import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/institutional_communication/data/institutional_communication_cache.dart';
import 'package:poligestor_app/features/institutional_communication/data/institutional_communication_contracts.dart';
import 'package:poligestor_app/features/institutional_communication/data/institutional_communication_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 15 institutional communication paths', () {
    test('exposes official /v1/communication namespace', () {
      const m = AuthMode.staff;
      expect(m.institutionalCommunicationRootPath, '/v1/communication');
      expect(m.institutionalCommunicationFeedPath, '/v1/communication/feed');
      expect(
        m.institutionalCommunicationAnnouncementsPath,
        '/v1/communication/announcements',
      );
      expect(
        m.institutionalCommunicationCampaignsPath,
        '/v1/communication/campaigns',
      );
      expect(m.institutionalCommunicationMediaPath, '/v1/communication/media');
      expect(
        m.institutionalCommunicationPublicationsPath,
        '/v1/communication/publications',
      );
      expect(
        m.institutionalCommunicationSchedulePath,
        '/v1/communication/schedule',
      );
      expect(m.institutionalCommunicationPushPath, '/v1/communication/push');
      expect(m.institutionalCommunicationEmailPath, '/v1/communication/email');
      expect(
        m.institutionalCommunicationWhatsappPath,
        '/v1/communication/whatsapp',
      );
      expect(
        m.institutionalCommunicationHistoryPath,
        '/v1/communication/history',
      );
      expect(
        m.institutionalCommunicationSearchPath,
        '/v1/communication/search',
      );
      expect(
        m.institutionalCommunicationFiltersPath,
        '/v1/communication/filters',
      );
      expect(m.institutionalCommunicationSharePath, '/v1/communication/share');
      expect(
        m.institutionalCommunicationReportsPath,
        '/v1/communication/reports',
      );
    });
  });

  group('institutional communication LIVE contracts', () {
    test('no live slugs until VPS publishes', () {
      expect(kInstitutionalCommunicationLiveSlugs, isEmpty);
      expect(institutionalCommunicationPathLive('feed'), isFalse);
      expect(institutionalCommunicationPathLive('campaigns'), isFalse);
    });
  });

  group('institutional communication models', () {
    test('parses item', () {
      final item = InstitutionalCommunicationItem.fromJson({
        'id': '1',
        'title': 'Comunicado oficial',
        'channel': 'e-mail',
        'status': 'published',
      });
      expect(item.title, 'Comunicado oficial');
      expect(item.channel, 'e-mail');
    });
  });

  group('institutional communication cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = InstitutionalCommunicationCache();
      await cache.putMap('demo', 'feed', {
        'data': [
          {'id': '1', 'title': 'A'},
        ],
      });
      expect(await cache.getMap('other', 'feed'), isNull);
      expect(await cache.getMap('demo', 'feed'), isNotNull);
    });
  });

  group('deep links institutional communication', () {
    test('poligestor://comunicacao-institucional resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://comunicacao-institucional',
        ),
      );
      expect(target?.location, '/home/institutional-communication');
    });

    test('poligestor://institutional-communication/feed', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://institutional-communication/feed',
        ),
      );
      expect(target?.location, '/home/institutional-communication/feed');
    });
  });
}
