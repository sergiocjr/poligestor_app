import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/integrations/data/integrations_cache.dart';
import 'package:poligestor_app/features/integrations/data/integrations_contracts.dart';
import 'package:poligestor_app/features/integrations/data/integrations_models.dart';
import 'package:poligestor_app/features/integrations/presentation/integrations_pages.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 22 Integrations paths', () {
    test('exposes official /v1/integrations namespace', () {
      const m = AuthMode.staff;
      expect(m.integrationsRootPath, '/v1/integrations');
      expect(m.integrationsDashboardPath, '/v1/integrations/dashboard');
      expect(m.integrationsStatusPath, '/v1/integrations/status');
      expect(m.integrationsConfigPath, '/v1/integrations/config');
      expect(m.integrationsSyncPath, '/v1/integrations/sync');
      expect(m.integrationsHistoryPath, '/v1/integrations/history');
      expect(m.integrationsLogsPath, '/v1/integrations/logs');
      expect(m.integrationsGovbrPath, '/v1/integrations/govbr');
      expect(
        m.integrationsCamaraMunicipalPath,
        '/v1/integrations/camara-municipal',
      );
      expect(
        m.integrationsAssembleiaLegislativaPath,
        '/v1/integrations/assembleia-legislativa',
      );
      expect(
        m.integrationsCamaraDeputadosPath,
        '/v1/integrations/camara-deputados',
      );
      expect(
        m.integrationsSenadoFederalPath,
        '/v1/integrations/senado-federal',
      );
      expect(
        m.integrationsDiarioOficialPath,
        '/v1/integrations/diario-oficial',
      );
      expect(
        m.integrationsPortalTransparenciaPath,
        '/v1/integrations/portal-transparencia',
      );
      expect(m.integrationsESicPath, '/v1/integrations/e-sic');
      expect(m.integrationsOuvidoriaPath, '/v1/integrations/ouvidoria');
      expect(
        m.integrationsGoogleCalendarPath,
        '/v1/integrations/google-calendar',
      );
      expect(
        m.integrationsOutlookCalendarPath,
        '/v1/integrations/outlook-calendar',
      );
      expect(m.integrationsGmailPath, '/v1/integrations/gmail');
      expect(m.integrationsWhatsappPath, '/v1/integrations/whatsapp');
      expect(m.integrationsTelegramPath, '/v1/integrations/telegram');
      expect(
        m.integrationsFirebasePushPath,
        '/v1/integrations/firebase-push',
      );
      expect(
        m.integrationsExternalApisPath,
        '/v1/integrations/external-apis',
      );
      expect(m.integrationsWebhooksPath, '/v1/integrations/webhooks');
      expect(m.integrationsSearchPath, '/v1/integrations/search');
      expect(m.integrationsFiltersPath, '/v1/integrations/filters');
    });

    test('paths are identical for portal mode', () {
      const staff = AuthMode.staff;
      const portal = AuthMode.portal;
      expect(portal.integrationsRootPath, staff.integrationsRootPath);
      expect(portal.integrationsGovbrPath, staff.integrationsGovbrPath);
      expect(portal.integrationsWebhooksPath, staff.integrationsWebhooksPath);
    });
  });

  group('Integrations LIVE contracts', () {
    test('kIntegrationsLiveSlugs is empty (all VPS 404)', () {
      expect(kIntegrationsLiveSlugs, isEmpty);
      expect(integrationsPathLive('dashboard'), isFalse);
      expect(integrationsPathLive('govbr'), isFalse);
      expect(integrationsPathLive('whatsapp'), isFalse);
      expect(integrationsPathLive('webhooks'), isFalse);
      expect(integrationsPathLive('sync'), isFalse);
    });
  });

  group('Integrations hub', () {
    test('defines 25 hub cards', () {
      expect(integrationsSlugTitles.length, 25);
    });
  });

  group('Integrations models', () {
    test('parses item', () {
      final item = IntegrationItem.fromJson({
        'id': '1',
        'name': 'WhatsApp Gabinete',
        'status': 'active',
        'provider': 'whatsapp',
        'access_token': 'secret-must-strip',
      });
      expect(item.title, 'WhatsApp Gabinete');
      expect(item.provider, 'whatsapp');
      expect(item.raw.containsKey('access_token'), isFalse);
    });

    test('stripIntegrationsSecrets removes secrets', () {
      final cleaned =
          stripIntegrationsSecrets({
                'id': '1',
                'title': 'Webhook',
                'webhook_secret': 'abc',
                'client_secret': 'xyz',
                'nested': {'api_key': 'k', 'label': 'ok'},
              })
              as Map<String, dynamic>;
      expect(cleaned.containsKey('webhook_secret'), isFalse);
      expect(cleaned.containsKey('client_secret'), isFalse);
      expect((cleaned['nested'] as Map).containsKey('api_key'), isFalse);
      expect((cleaned['nested'] as Map)['label'], 'ok');
    });
  });

  group('Integrations cache', () {
    test('strips secrets before save', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = IntegrationsCache();
      await cache.putMap('demo', 'webhooks', {
        'data': [
          {
            'id': '1',
            'title': 'Hook',
            'webhook_secret': 'must-not-persist',
          },
        ],
      });
      final stored = await cache.getMap('demo', 'webhooks');
      expect(stored, isNotNull);
      final list = stored!.data['data'] as List;
      expect((list.first as Map).containsKey('webhook_secret'), isFalse);
    });

    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = IntegrationsCache();
      await cache.putMap('demo', 'status', {
        'data': [
          {'id': '1', 'title': 'A'},
        ],
      });
      expect(await cache.getMap('other', 'status'), isNull);
      expect(await cache.getMap('demo', 'status'), isNotNull);
    });
  });

  group('deep links Integrations', () {
    test('poligestor://integrations resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://integrations',
        ),
      );
      expect(target?.location, '/home/integrations');
    });

    test('poligestor://integracoes/govbr', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://integracoes/govbr',
        ),
      );
      expect(target?.location, '/home/integrations/govbr');
    });

    test('poligestor://central-integracoes/webhooks', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://central-integracoes/webhooks',
        ),
      );
      expect(target?.location, '/home/integrations/webhooks');
    });
  });
}
