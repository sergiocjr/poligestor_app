import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/events/data/events_cache.dart';
import 'package:poligestor_app/features/events/data/events_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 11 events paths', () {
    test('exposes official /v1/events namespace', () {
      const m = AuthMode.staff;
      expect(m.eventsRootPath, '/v1/events');
      expect(m.eventsListPath, '/v1/events');
      expect(m.eventsPath, '/v1/events');
      expect(m.eventsDashboardPath, '/v1/events/dashboard');
      expect(m.eventsItemPath('x'), '/v1/events/x');
      expect(m.eventsAgendaPath, '/v1/events/agenda');
      expect(m.eventsCalendarPath, '/v1/events/calendar');
      expect(m.eventsAudiencesPath, '/v1/events/audiences');
      expect(m.eventsMeetingsPath, '/v1/events/meetings');
      expect(m.eventsParticipantsPath, '/v1/events/participants');
      expect(m.eventsInvitesPath, '/v1/events/invites');
      expect(m.eventsAttendancePath, '/v1/events/attendance');
      expect(m.eventsCheckInPath, '/v1/events/check-in');
      expect(m.eventsCheckOutPath, '/v1/events/check-out');
      expect(m.eventsQrCodePath, '/v1/events/qr-code');
      expect(m.eventsGalleryPath, '/v1/events/gallery');
      expect(m.eventsPhotosPath, '/v1/events/photos');
      expect(m.eventsVideosPath, '/v1/events/videos');
      expect(m.eventsDocumentsPath, '/v1/events/documents');
      expect(m.eventsCertificatesPath, '/v1/events/certificates');
      expect(m.eventsTimelinePath, '/v1/events/timeline');
      expect(m.eventsReportsPath, '/v1/events/reports');
      expect(m.eventsIndicatorsPath, '/v1/events/indicators');
      expect(m.eventsSearchPath, '/v1/events/search');
      expect(m.eventsMapPath, '/v1/events/map');
    });
  });

  group('events models', () {
    test('parses LIVE event item', () {
      final item = EventsItem.fromJson({
        'id': '4ac50ea4-40ce-4ae9-a4de-49297337e71c',
        'title': 'Call com equipe',
        'description': 'Reunião de obras',
        'type': 'meeting',
        'status': 'scheduled',
        'starts_at': '2026-07-17T13:00:00.000000Z',
        'ends_at': '2026-07-17T14:00:00.000000Z',
        'location': 'Gabinete',
        'priority': 'normal',
        'person': {'name': 'Maria Silva'},
      });
      expect(item.id, '4ac50ea4-40ce-4ae9-a4de-49297337e71c');
      expect(item.kind, 'meeting');
      expect(item.location, 'Gabinete');
      expect(item.personName, 'Maria Silva');
      expect(item.startsAt, isNotNull);
    });

    test('aggregates dashboard from items', () {
      final d = EventsDashboard.fromItems([
        EventsItem.fromJson({
          'id': '1',
          'title': 'A',
          'type': 'meeting',
          'status': 'scheduled',
          'starts_at': DateTime.now().toUtc().toIso8601String(),
        }),
        EventsItem.fromJson({
          'id': '2',
          'title': 'B',
          'type': 'appointment',
          'status': 'completed',
          'starts_at': DateTime.now()
              .add(const Duration(days: 2))
              .toUtc()
              .toIso8601String(),
        }),
      ]);
      expect(d.total, 2);
      expect(d.meetings, 1);
      expect(d.audiences, 1);
      expect(d.scheduled, 1);
      expect(d.completed, 1);
    });
  });

  group('events cache isolation', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = EventsCache();
      await cache.putMap('demo', 'events', {
        'data': [
          {'id': '1', 'title': 'X'},
        ],
      });
      expect(await cache.getMap('other', 'events'), isNull);
      expect(await cache.getMap('demo', 'events'), isNotNull);
    });
  });

  group('deep links events', () {
    test('poligestor://eventos resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://eventos',
        ),
      );
      expect(target?.location, '/home/events');
    });

    test('poligestor://events/list', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://events/list',
        ),
      );
      expect(target?.location, '/home/events/list');
    });

    test('poligestor://painel-eventos/agenda', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://painel-eventos/agenda',
        ),
      );
      expect(target?.location, '/home/events/agenda');
    });
  });
}
