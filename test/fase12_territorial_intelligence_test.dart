import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/territorial_intelligence/data/territorial_intelligence_cache.dart';
import 'package:poligestor_app/features/territorial_intelligence/data/territorial_intelligence_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 12 intelligence paths', () {
    test('exposes official /v1/intelligence namespace', () {
      const m = AuthMode.staff;
      expect(m.intelligenceRootPath, '/v1/intelligence');
      expect(m.intelligenceDashboardPath, '/v1/intelligence/dashboard');
      expect(m.intelligenceBiPath, '/v1/intelligence/bi');
      expect(m.intelligenceKpisPath, '/v1/intelligence/kpis');
      expect(m.intelligenceIndicatorsPath, '/v1/intelligence/indicators');
      expect(m.intelligenceChartsPath, '/v1/intelligence/charts');
      expect(m.intelligenceHeatmapPath, '/v1/intelligence/heatmap');
      expect(m.intelligenceMapPath, '/v1/intelligence/map');
      expect(m.intelligenceNeighborhoodsPath, '/v1/intelligence/neighborhoods');
      expect(m.intelligenceRegionsPath, '/v1/intelligence/regions');
      expect(
        m.intelligenceElectoralZonesPath,
        '/v1/intelligence/electoral-zones',
      );
      expect(m.intelligenceLeadershipsPath, '/v1/intelligence/leaderships');
      expect(m.intelligenceDemandsPath, '/v1/intelligence/demands');
      expect(m.intelligenceWorksPath, '/v1/intelligence/works');
      expect(m.intelligenceProtocolsPath, '/v1/intelligence/protocols');
      expect(m.intelligenceAttendancesPath, '/v1/intelligence/attendances');
      expect(m.intelligenceComparativesPath, '/v1/intelligence/comparatives');
      expect(m.intelligenceEvolutionPath, '/v1/intelligence/evolution');
      expect(m.intelligenceTrendsPath, '/v1/intelligence/trends');
      expect(m.intelligenceProjectionsPath, '/v1/intelligence/projections');
      expect(m.intelligenceFiltersPath, '/v1/intelligence/filters');
      expect(m.intelligenceExportsPath, '/v1/intelligence/exports');
    });
  });

  group('territorial intelligence models', () {
    test('parses dashboard counts', () {
      final d = TerritorialDashboard.fromJson({
        'data': {
          'counts': {
            'kpis_total': 12,
            'demands_open': 4,
            'works_active': 2,
            'protocols_open': 7,
            'neighborhoods': 9,
          },
        },
      });
      expect(d.kpisTotal, 12);
      expect(d.demandsOpen, 4);
      expect(d.neighborhoods, 9);
    });

    test('parses territorial item', () {
      final item = TerritorialItem.fromJson({
        'id': '1',
        'title': 'Bairro Centro',
        'status': 'active',
        'region': 'Norte',
        'neighborhood': 'Centro',
        'value': 42,
      });
      expect(item.title, 'Bairro Centro');
      expect(item.region, 'Norte');
      expect(item.value, 42);
    });
  });

  group('territorial intelligence cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = TerritorialIntelligenceCache();
      await cache.putMap('demo', 'dashboard', {
        'data': {
          'counts': {'kpis_total': 1},
        },
      });
      expect(await cache.getMap('other', 'dashboard'), isNull);
      expect(await cache.getMap('demo', 'dashboard'), isNotNull);
    });
  });

  group('deep links territorial intelligence', () {
    test('poligestor://inteligencia-territorial resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://inteligencia-territorial',
        ),
      );
      expect(target?.location, '/home/territorial-intelligence');
    });

    test('poligestor://territorial-intelligence/heatmap', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://territorial-intelligence/heatmap',
        ),
      );
      expect(target?.location, '/home/territorial-intelligence/heatmap');
    });
  });
}
