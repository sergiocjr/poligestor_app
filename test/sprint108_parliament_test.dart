import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/parliament/data/parliament_cache.dart';
import 'package:poligestor_app/features/parliament/data/parliament_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 10.8 parliament paths', () {
    test('exposes LIVE parliament namespace', () {
      const m = AuthMode.staff;
      expect(m.parliamentDashboardPath, '/v1/parliament/dashboard');
      expect(m.parliamentBillsPath, '/v1/parliament/bills');
      expect(m.parliamentBillPath('x'), '/v1/parliament/bills/x');
      expect(m.parliamentIndicationsPath, '/v1/parliament/indications');
      expect(m.parliamentRequestsPath, '/v1/parliament/requests');
      expect(m.parliamentMotionsPath, '/v1/parliament/motions');
      expect(m.parliamentAmendmentsPath, '/v1/parliament/amendments');
      expect(m.parliamentAgendaPath, '/v1/parliament/agenda');
      expect(m.parliamentSessionsPath, '/v1/parliament/sessions');
      expect(m.parliamentVotesPath, '/v1/parliament/votes');
      expect(m.parliamentSupportBasePath, '/v1/parliament/support-base');
      expect(m.parliamentDemandsPath, '/v1/parliament/demands');
      expect(m.parliamentPromisesPath, '/v1/parliament/promises');
      expect(m.parliamentSearchPath, '/v1/parliament/search');
    });
  });

  group('parliament models', () {
    test('parses dashboard counts', () {
      final d = ParliamentDashboard.fromJson({
        'data': {
          'counts': {
            'bills': 3,
            'votes_open': 2,
            'demands_open': 1,
            'promises_avg_progress': 40.5,
          },
        },
      });
      expect(d.counts.bills, 3);
      expect(d.counts.votesOpen, 2);
      expect(d.counts.promisesAvgProgress, 40.5);
    });

    test('parses bill item', () {
      final b = ParliamentItem.fromJson({
        'id': '1',
        'number': 'PL 10/2026',
        'title': 'Iluminação',
        'status': 'open',
        'summary': 'Melhoria',
        'authors': [
          {'name': 'Ver. Demo'},
        ],
      });
      expect(b.number, 'PL 10/2026');
      expect(b.authors.single, 'Ver. Demo');
    });
  });

  group('parliament cache isolation', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = ParliamentCache();
      await cache.putMap('demo', 'dashboard', {
        'data': {
          'counts': {'bills': 1},
        },
      });
      expect(await cache.getMap('other', 'dashboard'), isNull);
      expect(await cache.getMap('demo', 'dashboard'), isNotNull);
    });
  });

  group('deep links parliament', () {
    test('poligestor://parliament resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://parliament',
        ),
      );
      expect(target?.location, '/home/parliament');
    });

    test('poligestor://legislativo/bills', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://legislativo/bills',
        ),
      );
      expect(target?.location, '/home/parliament/bills');
    });
  });
}
