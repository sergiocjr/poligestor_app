import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/system_admin/data/admin_cache.dart';
import 'package:poligestor_app/features/system_admin/data/admin_contracts.dart';
import 'package:poligestor_app/features/system_admin/data/admin_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 19 Admin paths', () {
    test('exposes official /v1/admin namespace', () {
      const m = AuthMode.staff;
      expect(m.adminRootPath, '/v1/admin');
      expect(m.adminDashboardPath, '/v1/admin/dashboard');
      expect(m.adminCompaniesPath, '/v1/admin/companies');
      expect(m.adminOfficesPath, '/v1/admin/cabinets');
      expect(m.adminUsersPath, '/v1/admin/users');
      expect(m.adminProfilesPath, '/v1/admin/profiles');
      expect(m.adminRolesPath, '/v1/admin/roles');
      expect(m.adminPermissionsPath, '/v1/admin/permissions');
      expect(m.adminTeamsPath, '/v1/admin/teams');
      expect(m.adminDepartmentsPath, '/v1/admin/departments');
      expect(m.adminSettingsPath, '/v1/admin/settings/general');
      expect(m.adminLicensingPath, '/v1/admin/licenses');
      expect(m.adminSubscriptionsPath, '/v1/admin/subscriptions');
      expect(m.adminLogsPath, '/v1/admin/logs');
      expect(m.adminAuditPath, '/v1/admin/audit');
      expect(m.adminSessionsPath, '/v1/admin/sessions');
      expect(m.adminApiKeysPath, '/v1/admin/api-keys');
      expect(m.adminIntegrationsPath, '/v1/admin/integrations');
      expect(m.adminWebhooksPath, '/v1/admin/webhooks');
      expect(m.adminBackupPath, '/v1/admin/backups');
      expect(m.adminMonitoringPath, '/v1/admin/monitoring');
      expect(m.adminHealthPath, '/v1/admin/health');
      expect(m.adminEmailSettingsPath, '/v1/admin/config/email');
      expect(m.adminNotificationSettingsPath, '/v1/admin/config/notifications');
      expect(m.adminStorageSettingsPath, '/v1/admin/config/storage');
      expect(m.adminReportsPath, '/v1/admin/reports');
      expect(m.adminExportsPath, '/v1/admin/export');
      expect(m.adminSearchPath, '/v1/admin/reports');
      expect(m.adminFiltersPath, '/v1/admin/settings/general');
    });
  });

  group('Admin LIVE contracts', () {
    test('kAdminLiveSlugs sync probe auth 2026-07-21', () {
      expect(adminPathLive('dashboard'), isTrue);
      expect(adminPathLive('users'), isTrue);
      expect(adminPathLive('offices'), isTrue);
      expect(adminPathLive('settings'), isTrue);
      expect(adminPathLive('backup'), isTrue);
      expect(adminPathLive('exports'), isTrue);
      expect(kAdminLiveSlugs.length, 34);
    });
  });

  group('Admin models', () {
    test('parses item', () {
      final item = AdminItem.fromJson({
        'id': '1',
        'name': 'Operador Demo',
        'email': 'admin@demo.local',
        'status': 'active',
        'scope': 'demo',
      });
      expect(item.title, 'Operador Demo');
      expect(item.email, 'admin@demo.local');
      expect(item.scope, 'demo');
    });

    test('flattens dashboard summary into indicator rows', () {
      final rows = asAdminMapList({
        'product': 'poligestor',
        'summary': {'companies': 2, 'users': 5, 'sessions': 1},
      });
      expect(rows.length, 3);
      expect(rows.first['title'], 'Empresas');
      expect(rows.first['summary'], '2');
    });
  });

  group('Admin cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = AdminCache();
      await cache.putMap('demo', 'users', {
        'data': [
          {'id': '1', 'title': 'A'},
        ],
      });
      expect(await cache.getMap('other', 'users'), isNull);
      expect(await cache.getMap('demo', 'users'), isNotNull);
    });
  });

  group('deep links Admin', () {
    test('poligestor://administracao resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://administracao',
        ),
      );
      expect(target?.location, '/home/system-admin');
    });

    test('poligestor://system-admin/users', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://system-admin/users',
        ),
      );
      expect(target?.location, '/home/system-admin/users');
    });
  });
}
