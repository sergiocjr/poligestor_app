import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/agreements/data/agreements_cache.dart';
import 'package:poligestor_app/features/agreements/data/agreements_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 11.0 grants paths', () {
    test('exposes LIVE grants namespace', () {
      const m = AuthMode.staff;
      expect(m.agreementsRootPath, '/v1/grants');
      expect(m.agreementsDashboardPath, '/v1/grants/dashboard');
      expect(m.agreementsListPath, '/v1/grants/agreements');
      expect(m.agreementsItemPath('x'), '/v1/grants/agreements/x');
      expect(m.agreementsResourcesPath, '/v1/grants/funds');
      expect(m.agreementsProjectsPath, '/v1/grants/projects');
      expect(m.agreementsExecutionPath, '/v1/grants/execution');
      expect(m.agreementsAccountabilityPath, '/v1/grants/accountability');
      expect(m.agreementsSchedulePath, '/v1/grants/timeline');
      expect(m.agreementsTimelinePath, '/v1/grants/timeline');
      expect(m.agreementsDocumentsPath, '/v1/grants/documents');
      expect(m.agreementsAttachmentsPath, '/v1/grants/documents');
      expect(m.agreementsIndicatorsPath, '/v1/grants/reports');
      expect(m.agreementsReportsPath, '/v1/grants/reports');
      expect(m.agreementsSearchPath, '/v1/grants/agreements');
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

    test('parses LIVE dashboard kpis', () {
      final d = AgreementsDashboard.fromJson({
        'data': {
          'summary': {'committed': 10, 'balance': 3},
          'kpis': {
            'agreements_active': 2,
            'projects_active': 1,
            'accountability_open': 4,
          },
        },
      });
      expect(d.agreementsOpen, 2);
      expect(d.agreementsInProgress, 1);
      expect(d.resourcesActive, 10);
      expect(d.executionPending, 3);
      expect(d.accountabilityOpen, 4);
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

    test('parses LIVE agreement and timeline fields', () {
      final agreement = AgreementsItem.fromJson({
        'id': '74ff5f79',
        'number': 'SM-1',
        'title': 'Smoke convênio',
        'agency': 'Órgão X',
        'amount': 1000,
        'status': 'active',
        'starts_on': '2026-01-01',
        'ends_on': '2026-12-31',
      });
      expect(agreement.code, 'SM-1');
      expect(agreement.partner, 'Órgão X');
      expect(agreement.startedAt, isNotNull);
      expect(agreement.dueAt, isNotNull);

      final event = AgreementsItem.fromJson({
        'id': 'evt-1',
        'event': 'created',
        'body': 'Convênio cadastrado',
        'occurred_at': '2026-07-19T23:16:14.000000Z',
      });
      expect(event.title, 'Convênio cadastrado');
      expect(event.startedAt, isNotNull);
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
