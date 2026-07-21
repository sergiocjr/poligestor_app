import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/works/data/works_cache.dart';
import 'package:poligestor_app/features/works/data/works_contracts.dart';
import 'package:poligestor_app/features/works/data/works_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 10.9 works paths', () {
    test('exposes prepared works namespace', () {
      const m = AuthMode.staff;
      expect(m.worksRootPath, '/v1/works');
      expect(m.worksDashboardPath, '/v1/works/dashboard');
      expect(m.worksListPath, '/v1/works');
      expect(m.worksItemPath('x'), '/v1/works/x');
      expect(m.worksDemandsPath, '/v1/works/demands');
      expect(m.worksInspectionsPath, '/v1/works/inspections');
      expect(m.worksSchedulePath, '/v1/works/schedule');
      expect(m.worksMapPath, '/v1/works/map');
      expect(m.worksTimelinePath, '/v1/works/timeline');
      expect(m.worksPhotosPath, '/v1/works/photos');
      expect(m.worksAttachmentsPath, '/v1/works/attachments');
      expect(m.worksChecklistPath, '/v1/works/demands');
      expect(m.worksIndicatorsPath, '/v1/works/dashboard');
      expect(m.worksReportsPath, '/v1/works/reports');
      expect(m.worksSearchPath, '/v1/works');
    });
  });

  group('Works LIVE contracts', () {
    test('marks catalog cards live with assumed AuthMode remaps', () {
      expect(kWorksLiveSlugs.length, 13);
      expect(worksPathLive('list'), isTrue);
      expect(worksPathLive('dashboard'), isTrue);
      expect(worksPathLive('demands'), isTrue);
      expect(worksPathLive('inspections'), isTrue);
      expect(worksPathLive('schedule'), isTrue);
      expect(worksPathLive('map'), isTrue);
      expect(worksPathLive('timeline'), isTrue);
      expect(worksPathLive('photos'), isTrue);
      expect(worksPathLive('attachments'), isTrue);
      expect(worksPathLive('reports'), isTrue);
      expect(worksPathLive('checklist'), isTrue);
      expect(worksPathLive('indicators'), isTrue);
      expect(worksPathLive('projects'), isFalse);
      expect(worksPathLive('search'), isTrue);
    });
  });

  group('works models', () {
    test('parses dashboard counts', () {
      final d = WorksDashboard.fromJson({
        'data': {
          'counts': {
            'works_open': 4,
            'works_in_progress': 2,
            'works_completed': 1,
            'demands_open': 3,
            'inspections_pending': 5,
            'schedule_upcoming': 2,
            'checklist_open': 7,
            'photos': 9,
          },
        },
      });
      expect(d.worksOpen, 4);
      expect(d.worksInProgress, 2);
      expect(d.worksCompleted, 1);
      expect(d.demandsOpen, 3);
      expect(d.inspectionsPending, 5);
      expect(d.photosCount, 9);
    });

    test('parses works item', () {
      final item = WorksItem.fromJson({
        'id': '42',
        'code': 'OB-01',
        'title': 'Pavimentação',
        'status': 'in_progress',
        'district': 'Centro',
        'progress_pct': 55,
        'summary': 'Asfalto',
      });
      expect(item.id, '42');
      expect(item.code, 'OB-01');
      expect(item.title, 'Pavimentação');
      expect(item.progressPct, 55);
      expect(item.district, 'Centro');
    });
  });

  group('works cache isolation', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = WorksCache();
      await cache.putMap('demo', 'dashboard', {
        'data': {
          'counts': {'works_open': 1},
        },
      });
      expect(await cache.getMap('other', 'dashboard'), isNull);
      expect(await cache.getMap('demo', 'dashboard'), isNotNull);
    });
  });

  group('deep links works', () {
    test('poligestor://works resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://works',
        ),
      );
      expect(target?.location, '/home/works');
    });

    test('poligestor://obras/list', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://obras/list',
        ),
      );
      expect(target?.location, '/home/works/list');
    });

    test('poligestor://painel-obras/map', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://painel-obras/map',
        ),
      );
      expect(target?.location, '/home/works/map');
    });

    test('Uri scheme poligestor maps to internal works paths', () {
      const router = NotificationRouter();
      for (final input in [
        ('poligestor://obras', '/home/works'),
        ('poligestor://obras/', '/home/works'),
        ('poligestor://obras/dashboard', '/home/works/dashboard'),
        ('poligestor://works/list', '/home/works/list'),
        ('poligestor://obras/inspections', '/home/works/inspections'),
      ]) {
        final target = router.resolve(
          PushPayload(type: PushEventType.systemNotice, deepLink: input.$1),
        );
        expect(target?.location, input.$2, reason: input.$1);
      }
    });
  });
}
