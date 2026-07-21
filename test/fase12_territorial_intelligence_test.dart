import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/territorial_intelligence/data/territorial_intelligence_cache.dart';
import 'package:poligestor_app/features/territorial_intelligence/data/territorial_intelligence_contracts.dart';
import 'package:poligestor_app/features/territorial_intelligence/data/territorial_intelligence_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 12 intelligence paths', () {
    test('exposes official /v1/intelligence namespace', () {
      const m = AuthMode.staff;
      expect(m.intelligenceRootPath, '/v1/intelligence');
      expect(m.intelligenceDashboardPath, '/v1/intelligence/dashboard');
      expect(m.intelligenceBiPath, '/v1/intelligence/dashboard');
      expect(m.intelligenceKpisPath, '/v1/intelligence/kpis');
      expect(m.intelligenceIndicatorsPath, '/v1/intelligence/kpis');
      expect(m.intelligenceChartsPath, '/v1/intelligence/charts');
      expect(m.intelligenceHeatmapPath, '/v1/intelligence/heatmaps');
      expect(m.intelligenceMapPath, '/v1/intelligence/maps');
      expect(m.intelligenceNeighborhoodsPath, '/v1/intelligence/neighborhoods');
      expect(m.intelligenceRegionsPath, '/v1/intelligence/regions');
      expect(m.intelligenceElectoralZonesPath, '/v1/intelligence/zones');
      expect(m.intelligenceLeadershipsPath, '/v1/intelligence/leaders');
      expect(m.intelligenceDemandsPath, '/v1/intelligence/demands-by-region');
      expect(m.intelligenceWorksPath, '/v1/intelligence/works-by-region');
      expect(
        m.intelligenceProtocolsPath,
        '/v1/intelligence/protocols-by-region',
      );
      expect(
        m.intelligenceAttendancesPath,
        '/v1/intelligence/attendances-by-region',
      );
      expect(m.intelligenceComparativesPath, '/v1/intelligence/comparison');
      expect(m.intelligenceEvolutionPath, '/v1/intelligence/history');
      expect(m.intelligenceTrendsPath, '/v1/intelligence/trends');
      expect(m.intelligenceProjectionsPath, '/v1/intelligence/projections');
      expect(m.intelligenceFiltersPath, '/v1/intelligence/regions');
      expect(m.intelligenceExportsPath, '/v1/intelligence/exports/pdf');
    });
  });

  group('territorial intelligence LIVE contracts', () {
    test('marks VPS-published slugs as live', () {
      expect(territorialIntelligencePathLive('dashboard'), isTrue);
      expect(territorialIntelligencePathLive('kpis'), isTrue);
      expect(territorialIntelligencePathLive('charts'), isTrue);
      expect(territorialIntelligencePathLive('neighborhoods'), isTrue);
      expect(territorialIntelligencePathLive('regions'), isTrue);
      expect(territorialIntelligencePathLive('trends'), isTrue);
      expect(territorialIntelligencePathLive('projections'), isTrue);
      expect(territorialIntelligencePathLive('heatmap'), isTrue);
      expect(territorialIntelligencePathLive('map'), isTrue);
      expect(territorialIntelligencePathLive('exports'), isTrue);
      expect(kTerritorialIntelligenceLiveSlugs.length, 26);
      expect(territorialIntelligencePathLive('bi'), isTrue);
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

    test('parses territorial item from neighborhoods key', () {
      final list = asTiMapList({
        'neighborhoods': [
          {'id': '1', 'name': 'Centro', 'value': 10},
        ],
      });
      expect(list, hasLength(1));
      final item = TerritorialItem.fromJson(list.first);
      expect(item.title, 'Centro');
      expect(item.value, 10);
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
