import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/strategy/data/strategy_cache.dart';
import 'package:poligestor_app/features/strategy/data/strategy_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 10.7 strategy paths', () {
    test('exposes LIVE strategy namespace', () {
      const m = AuthMode.staff;
      expect(m.strategyRootPath, '/v1/strategy');
      expect(m.strategyKpisPath, '/v1/strategy/kpis');
      expect(m.strategyHeatmapPath, '/v1/strategy/heatmap');
      expect(m.strategyAlertsPath, '/v1/strategy/alerts');
      expect(m.strategyRegionsPath, '/v1/strategy/regions');
      expect(m.strategyForecastsPath, '/v1/strategy/forecasts');
      expect(m.strategyComparePath, '/v1/strategy/comparison');
      expect(m.strategyGoalsPath, '/v1/strategy/goals');
      expect(m.mandateExecutivePath, '/v1/mandate/executive');
      expect(m.mandateMapPath, '/v1/mandate/map');
    });
  });

  group('strategy models', () {
    test('parses KPI summary payload', () {
      final k = StrategyKpiSummary.fromJson({
        'data': {
          'summary': {
            'protocols_open': 10,
            'protocols_created': 4,
            'protocols_resolved': 3,
            'protocols_overdue': 1,
            'avg_resolution_hours': 12.5,
            'avg_rating': 4.2,
            'nps': 40,
            'growth_percent': 5,
            'sla_at_risk': 2,
            'sla_breached': 1,
            'campaigns': 0,
            'satisfaction': 4.1,
          },
          'by_category': {'saude': 2},
        },
      });
      expect(k.protocolsOpen, 10);
      expect(k.byCategory['saude'], 2);
      expect(k.avgResolutionHours, 12.5);
    });

    test('parses heatmap points', () {
      final h = StrategyHeatmapData.fromJson({
        'data': {
          'points': [
            {
              'city': 'Demo',
              'district': 'Centro',
              'total': 9,
              'open': 4,
              'resolved': 5,
            },
          ],
        },
      });
      expect(h.points.single.district, 'Centro');
      expect(h.points.single.total, 9);
    });

    test('parses alert', () {
      final a = StrategyAlert.fromJson({
        'id': '1',
        'title': 'SLA',
        'body': 'risco',
        'severity': 'high',
        'status': 'open',
      });
      expect(a.severity, 'high');
    });
  });

  group('strategy cache isolation', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = StrategyCache();
      await cache.putMap('demo', 'kpis', {
        'data': {
          'summary': {'protocols_open': 7},
        },
      });
      expect(await cache.getMap('other', 'kpis'), isNull);
      final demo = await cache.getMap('demo', 'kpis');
      expect(demo, isNotNull);
      expect(asStrategyMap(demo!.data['data'])['summary'], isNotNull);
    });
  });

  group('deep links strategy', () {
    test('poligestor://strategy resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://strategy',
        ),
      );
      expect(target?.location, '/home/strategy');
    });

    test('poligestor://estrategia/alerts', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://estrategia/alerts',
        ),
      );
      expect(target?.location, '/home/strategy/alerts');
    });
  });
}
