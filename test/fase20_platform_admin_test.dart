import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/platform_admin/data/platform_cache.dart';
import 'package:poligestor_app/features/platform_admin/data/platform_contracts.dart';
import 'package:poligestor_app/features/platform_admin/data/platform_models.dart';
import 'package:poligestor_app/features/platform_admin/presentation/platform_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 20 Platform paths', () {
    test('exposes official /v1/platform namespace', () {
      const m = AuthMode.staff;
      expect(m.platformRootPath, '/v1/platform');
      expect(m.platformDashboardPath, '/v1/platform/dashboard');
      expect(m.platformCompaniesPath, '/v1/platform/companies');
      expect(m.platformOfficesPath, '/v1/platform/offices');
      expect(m.platformUsersPath, '/v1/platform/users');
      expect(m.platformProfilesPath, '/v1/platform/profiles');
      expect(m.platformPermissionsPath, '/v1/platform/permissions');
      expect(m.platformPlansPath, '/v1/platform/plans');
      expect(m.platformLicensingPath, '/v1/platform/licensing');
      expect(m.platformSubscriptionsPath, '/v1/platform/subscriptions');
      expect(m.platformChargesPath, '/v1/platform/charges');
      expect(m.platformInvoicesPath, '/v1/platform/invoices');
      expect(m.platformPaymentsPath, '/v1/platform/payments');
      expect(m.platformConsumptionPath, '/v1/platform/consumption');
      expect(m.platformPlanLimitsPath, '/v1/platform/plan-limits');
      expect(m.platformMetricsPath, '/v1/platform/metrics');
      expect(m.platformMonitoringPath, '/v1/platform/monitoring');
      expect(m.platformHealthPath, '/v1/platform/health');
      expect(m.platformLogsPath, '/v1/platform/logs');
      expect(m.platformAuditPath, '/v1/platform/audit');
      expect(m.platformSessionsPath, '/v1/platform/sessions');
      expect(m.platformIntegrationsPath, '/v1/platform/integrations');
      expect(m.platformWebhooksPath, '/v1/platform/webhooks');
      expect(m.platformGlobalSettingsPath, '/v1/platform/global-settings');
      expect(m.platformTenantSettingsPath, '/v1/platform/tenant-settings');
      expect(m.platformSupportPath, '/v1/platform/support');
      expect(m.platformTicketsPath, '/v1/platform/tickets');
      expect(m.platformKnowledgeBasePath, '/v1/platform/knowledge-base');
      expect(m.platformAnnouncementsPath, '/v1/platform/announcements');
      expect(m.platformReleasesPath, '/v1/platform/releases');
      expect(m.platformMaintenancesPath, '/v1/platform/maintenances');
      expect(m.platformReportsPath, '/v1/platform/reports');
      expect(m.platformExportsPath, '/v1/platform/exports');
      expect(m.platformSearchPath, '/v1/platform/search');
      expect(m.platformFiltersPath, '/v1/platform/filters');
    });
  });

  group('Platform LIVE contracts', () {
    test('kPlatformLiveSlugs sync probe auth 2026-07-21', () {
      expect(platformPathLive('dashboard'), isTrue);
      expect(platformPathLive('users'), isTrue);
      expect(platformPathLive('permissions'), isTrue);
      expect(platformPathLive('profiles'), isFalse);
      expect(platformPathLive('offices'), isFalse);
      expect(kPlatformLiveSlugs.length, 23);
    });
  });

  group('Platform hub', () {
    test('defines 33 hub cards', () {
      expect(platformSlugTitles.length, greaterThanOrEqualTo(33));
    });
  });

  group('Platform models', () {
    test('parses item', () {
      final item = PlatformItem.fromJson({
        'id': '1',
        'name': 'Empresa Demo',
        'email': 'admin@demo.local',
        'status': 'active',
        'scope': 'demo',
      });
      expect(item.title, 'Empresa Demo');
      expect(item.email, 'admin@demo.local');
      expect(item.scope, 'demo');
    });

    test('flattens dashboard summary into indicator rows', () {
      final rows = asPlatformMapList({
        'product': 'poligestor',
        'summary': {
          'companies': 2,
          'users': 5,
          'sessions': 1,
        },
      });
      expect(rows.length, 3);
      expect(rows.first['title'], 'Empresas');
      expect(rows.first['summary'], '2');
    });
  });

  group('Platform cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = PlatformCache();
      await cache.putMap('demo', 'users', {
        'data': [
          {'id': '1', 'title': 'A'},
        ],
      });
      expect(await cache.getMap('other', 'users'), isNull);
      expect(await cache.getMap('demo', 'users'), isNotNull);
    });
  });

  group('deep links Platform', () {
    test('poligestor://platform resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://platform',
        ),
      );
      expect(target?.location, '/platform');
    });

    test('poligestor://portal-admin/users', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://portal-admin/users',
        ),
      );
      expect(target?.location, '/platform/users');
    });

    test('poligestor://portal-administrativo/charges', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://portal-administrativo/charges',
        ),
      );
      expect(target?.location, '/platform/charges');
    });

    test('poligestor://admin-web/dashboard', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://admin-web/dashboard',
        ),
      );
      expect(target?.location, '/platform/dashboard');
    });
  });
}
