import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/agreements/data/agreements_cache.dart';
import 'package:poligestor_app/features/agreements/data/agreements_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 11.0 agreements paths', () {
    test('exposes prepared agreements namespace', () {
      const m = AuthMode.staff;
      expect(m.agreementsRootPath, '/v1/agreements');
      expect(m.agreementsDashboardPath, '/v1/agreements/dashboard');
      expect(m.agreementsListPath, '/v1/agreements/agreements');
      expect(m.agreementsItemPath('x'), '/v1/agreements/agreements/x');
      expect(m.agreementsResourcesPath, '/v1/agreements/resources');
      expect(m.agreementsProjectsPath, '/v1/agreements/projects');
      expect(m.agreementsExecutionPath, '/v1/agreements/execution');
      expect(m.agreementsAccountabilityPath, '/v1/agreements/accountability');
      expect(m.agreementsSchedulePath, '/v1/agreements/schedule');
      expect(m.agreementsTimelinePath, '/v1/agreements/timeline');
      expect(m.agreementsDocumentsPath, '/v1/agreements/documents');
      expect(m.agreementsAttachmentsPath, '/v1/agreements/attachments');
      expect(m.agreementsIndicatorsPath, '/v1/agreements/indicators');
      expect(m.agreementsReportsPath, '/v1/agreements/reports');
      expect(m.agreementsSearchPath, '/v1/agreements/search');
    });
  });

  group('agreements models', () {
    test('parses dashboard counts', () {
      final d = AgreementsDashboard.fromJson({
        'data': {
          'counts': {
            'agreements_open': 4,
            'agreements_in_progress': 2,
            'agreements_completed': 1,
            'resources_active': 3,
            'projects_open': 5,
            'execution_pending': 2,
            'accountability_open': 1,
            'schedule_upcoming': 6,
            'documents': 8,
          },
        },
      });
      expect(d.agreementsOpen, 4);
      expect(d.resourcesActive, 3);
      expect(d.accountabilityOpen, 1);
      expect(d.documentsCount, 8);
    });

    test('parses agreement item', () {
      final item = AgreementsItem.fromJson({
        'id': '9',
        'code': 'CV-01',
        'title': 'Convênio federal',
        'status': 'open',
        'partner': 'Ministério',
        'amount': 150000.5,
        'progress_pct': 40,
      });
      expect(item.id, '9');
      expect(item.code, 'CV-01');
      expect(item.partner, 'Ministério');
      expect(item.amount, 150000.5);
    });
  });

  group('agreements cache isolation', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = AgreementsCache();
      await cache.putMap('demo', 'dashboard', {
        'data': {
          'counts': {'agreements_open': 1},
        },
      });
      expect(await cache.getMap('other', 'dashboard'), isNull);
      expect(await cache.getMap('demo', 'dashboard'), isNotNull);
    });
  });

  group('deep links agreements', () {
    test('poligestor://convenios resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://convenios',
        ),
      );
      expect(target?.location, '/home/agreements');
    });

    test('poligestor://agreements/list', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://agreements/list',
        ),
      );
      expect(target?.location, '/home/agreements/list');
    });

    test('poligestor://painel-convenios/accountability', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://painel-convenios/accountability',
        ),
      );
      expect(target?.location, '/home/agreements/accountability');
    });
  });
}
