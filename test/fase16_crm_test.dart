import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/political_crm/data/crm_cache.dart';
import 'package:poligestor_app/features/political_crm/data/crm_contracts.dart';
import 'package:poligestor_app/features/political_crm/data/crm_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 16 CRM paths', () {
    test('exposes official /v1/crm namespace', () {
      const m = AuthMode.staff;
      expect(m.crmRootPath, '/v1/crm');
      expect(m.crmDashboardPath, '/v1/crm/dashboard');
      expect(m.crmLeadersPath, '/v1/crm/contacts');
      expect(m.crmSupportersPath, '/v1/crm/contacts');
      expect(m.crmVotersPath, '/v1/crm/contacts');
      expect(m.crmVolunteersPath, '/v1/crm/contacts');
      expect(m.crmTeamPath, '/v1/crm/contacts');
      expect(m.crmEntitiesPath, '/v1/crm/entities');
      expect(m.crmAssociationsPath, '/v1/crm/entities');
      expect(m.crmChurchesPath, '/v1/crm/entities');
      expect(m.crmCompaniesPath, '/v1/crm/entities');
      expect(m.crmInfluencersPath, '/v1/crm/contacts');
      expect(m.crmSegmentationPath, '/v1/crm/contacts');
      expect(m.crmTagsPath, '/v1/crm/tags');
      expect(m.crmGroupsPath, '/v1/crm/groups');
      expect(m.crmRegionsPath, '/v1/crm/regions');
      expect(m.crmNeighborhoodsPath, '/v1/crm/neighborhoods');
      expect(m.crmElectoralZonesPath, '/v1/crm/electoral-zones');
      expect(m.crmRelationshipHistoryPath, '/v1/crm/relationships');
      expect(m.crmInteractionsPath, '/v1/crm/interactions');
      expect(m.crmVisitsPath, '/v1/crm/visits');
      expect(m.crmCallsPath, '/v1/crm/interactions');
      expect(m.crmMessagesPath, '/v1/crm/interactions');
      expect(m.crmMeetingsPath, '/v1/crm/interactions');
      expect(m.crmLinkedDemandsPath, '/v1/crm/relationships');
      expect(m.crmLinkedProtocolsPath, '/v1/crm/relationships');
      expect(m.crmCampaignsPath, '/v1/crm/campaigns');
      expect(m.crmTasksPath, '/v1/crm/tasks');
      expect(m.crmRemindersPath, '/v1/crm/reminders');
      expect(m.crmSupportLevelPath, '/v1/crm/contacts');
      expect(m.crmInfluencePotentialPath, '/v1/crm/contacts');
      expect(m.crmRelationshipsPath, '/v1/crm/relationships');
      expect(m.crmImportPath, '/v1/crm/export');
      expect(m.crmExportPath, '/v1/crm/export');
      expect(m.crmSearchPath, '/v1/crm/search');
      expect(m.crmFiltersPath, '/v1/crm/tags');
      expect(m.crmIndicatorsPath, '/v1/crm/metrics');
      expect(m.crmReportsPath, '/v1/crm/reports');
    });
  });

  group('CRM LIVE contracts', () {
    test('kCrmLiveSlugs sync probe auth 2026-07-21', () {
      expect(crmPathLive('dashboard'), isTrue);
      expect(crmPathLive('entities'), isTrue);
      expect(crmPathLive('search'), isTrue);
      expect(crmPathLive('indicators'), isTrue);
      expect(crmPathLive('leaders'), isTrue);
      expect(kCrmLiveSlugs.length, 38);
    });
  });

  group('CRM models', () {
    test('parses item', () {
      final item = CrmItem.fromJson({
        'id': '1',
        'name': 'Líder Centro',
        'region': 'Centro',
        'status': 'active',
        'support_level': 'alto',
      });
      expect(item.title, 'Líder Centro');
      expect(item.region, 'Centro');
      expect(item.supportLevel, 'alto');
    });
  });

  group('CRM cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = CrmCache();
      await cache.putMap('demo', 'leaders', {
        'data': [
          {'id': '1', 'title': 'A'},
        ],
      });
      expect(await cache.getMap('other', 'leaders'), isNull);
      expect(await cache.getMap('demo', 'leaders'), isNotNull);
    });
  });

  group('deep links CRM', () {
    test('poligestor://crm-politico resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://crm-politico',
        ),
      );
      expect(target?.location, '/home/crm');
    });

    test('poligestor://crm/leaders', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://crm/leaders',
        ),
      );
      expect(target?.location, '/home/crm/leaders');
    });
  });
}
