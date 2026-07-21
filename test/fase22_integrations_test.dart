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
    test('exposes official LIVE /v1/integrations namespace', () {
      const m = AuthMode.staff;
      expect(m.integrationsRootPath, '/v1/integrations');
      expect(m.integrationsDashboardPath, '/v1/integrations/dashboard');
      expect(m.integrationsStatusPath, '/v1/integrations/health');
      expect(m.integrationsConfigPath, '/v1/integrations/settings');
      expect(m.integrationsCatalogPath, '/v1/integrations/catalog');
      expect(m.integrationsProvidersPath, '/v1/integrations/providers');
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
      expect(m.integrationsSenadoFederalPath, '/v1/integrations/senado');
      expect(
        m.integrationsDiarioOficialPath,
        '/v1/integrations/diario-oficial',
      );
      expect(
        m.integrationsPortalTransparenciaPath,
        '/v1/integrations/portal-transparencia',
      );
      expect(m.integrationsESicPath, '/v1/integrations/esic');
      expect(m.integrationsOuvidoriaPath, '/v1/integrations/ouvidoria');
      expect(
        m.integrationsGoogleCalendarPath,
        '/v1/integrations/google-calendar',
      );
      expect(m.integrationsOutlookCalendarPath, '/v1/integrations/outlook');
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
  });

  group('Integrations LIVE contracts', () {
    test('marks published hub slugs as LIVE', () {
      expect(kIntegrationsLiveSlugs.length, 25);
      expect(integrationsPathLive('dashboard'), isTrue);
      expect(integrationsPathLive('status'), isTrue);
      expect(integrationsPathLive('config'), isTrue);
      expect(integrationsPathLive('sync'), isTrue);
      expect(integrationsPathLive('govbr'), isTrue);
      expect(integrationsPathLive('camara-municipal'), isTrue);
      expect(integrationsPathLive('assembleia-legislativa'), isTrue);
      expect(integrationsPathLive('camara-deputados'), isTrue);
      expect(integrationsPathLive('senado-federal'), isTrue);
      expect(integrationsPathLive('diario-oficial'), isTrue);
      expect(integrationsPathLive('portal-transparencia'), isTrue);
      expect(integrationsPathLive('e-sic'), isTrue);
      expect(integrationsPathLive('google-calendar'), isTrue);
      expect(integrationsPathLive('outlook-calendar'), isTrue);
      expect(integrationsPathLive('firebase-push'), isTrue);
      expect(integrationsPathLive('external-apis'), isTrue);
      expect(integrationsPathLive('webhooks'), isTrue);
      expect(integrationsPathLive('catalog'), isTrue);
      expect(integrationsPathLive('providers'), isTrue);
    });

    test('keeps search and filters pending', () {
      expect(integrationsPathLive('search'), isFalse);
      expect(integrationsPathLive('filters'), isFalse);
      expect(kIntegrationsLiveSlugs.contains('search'), isFalse);
      expect(kIntegrationsLiveSlugs.contains('filters'), isFalse);
    });
  });

  group('Integrations hub', () {
    test('defines 25 hub cards', () {
      expect(integrationsSlugTitles.length, 25);
    });
  });

  group('Integrations models', () {
    test('parses provider object', () {
      final item = IntegrationItem.fromJson({
        'slug': 'govbr',
        'name': 'Gov.br',
        'status': 'active',
        'access_token': 'secret-must-strip',
      });
      expect(item.title, 'Gov.br');
      expect(item.code, 'govbr');
      expect(item.raw.containsKey('access_token'), isFalse);
    });

    test('parses string list as items', () {
      final list = asIntegrationsMapList(['govbr', 'whatsapp']);
      expect(list.length, 2);
      expect(list.first['title'], 'govbr');
    });

    test('parses summary metrics when alone', () {
      final list = asIntegrationsMapList({
        'summary': {'providers': 28, 'live_contracts': 21},
      });
      expect(list.length, 2);
      expect(list.first['title'], 'Provedores');
    });

    test('parses live_providers string list', () {
      final list = asIntegrationsMapList({
        'live_providers': ['govbr', 'gmail'],
      });
      expect(list.length, 2);
      expect(list.first['title'], 'govbr');
    });

    test('parses history sync_runs merge', () {
      final list = asIntegrationsMapList({
        'sync_runs': [
          {'id': '1', 'status': 'ok'},
        ],
        'logs': [
          {'id': '2', 'message': 'log'},
        ],
      });
      expect(list.length, 2);
    });

    test('stripIntegrationsSecrets removes secrets', () {
      final cleaned =
          stripIntegrationsSecrets({
                'id': '1',
                'webhook_secret': 'abc',
                'nested': {'api_key': 'k', 'label': 'ok'},
              })
              as Map<String, dynamic>;
      expect(cleaned.containsKey('webhook_secret'), isFalse);
      expect((cleaned['nested'] as Map)['label'], 'ok');
    });
  });

  group('Integrations cache', () {
    test('strips secrets before save', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = IntegrationsCache();
      await cache.putMap('demo', 'webhooks', {
        'data': [
          {'id': '1', 'title': 'Hook', 'webhook_secret': 'x'},
        ],
      });
      final stored = await cache.getMap('demo', 'webhooks');
      final list = stored!.data['data'] as List;
      expect((list.first as Map).containsKey('webhook_secret'), isFalse);
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
  });
}
