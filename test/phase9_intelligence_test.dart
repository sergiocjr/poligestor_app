import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/intelligence/data/intelligence_cache.dart';
import 'package:poligestor_app/features/intelligence/data/intelligence_models.dart';
import 'package:poligestor_app/features/intelligence/presentation/widgets/intelligence_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode phase9 paths', () {
    test('exposes exact contract paths', () {
      const m = AuthMode.staff;
      expect(m.mandateBriefingPath, '/v1/mandate/briefing');
      expect(m.mandateAnalyticsPath, '/v1/mandate/analytics');
      expect(m.mandateTrendsPath, '/v1/mandate/trends');
      expect(m.mandateInsightsPath, '/v1/mandate/insights');
      expect(m.mandateBriefingsPath, '/v1/mandate/briefings');
    });
  });

  group('IntelligenceFilter', () {
    test('serializes period and generate flag', () {
      const f = IntelligenceFilter(period: '7d', generate: true, scope: 'daily');
      final q = f.toQuery();
      expect(q['period'], '7d');
      expect(q['generate'], 1);
      expect(q['scope'], 'daily');
    });

    test('omits empty strings', () {
      const f = IntelligenceFilter(district: '', category: 'iluminacao');
      final q = f.toQuery();
      expect(q.containsKey('district'), isFalse);
      expect(q['category'], 'iluminacao');
    });
  });

  group('IntelligenceInsight.fromJson', () {
    test('parses card fields and opportunity flag', () {
      final item = IntelligenceInsight.fromJson({
        'id': '1',
        'type': 'overdue_pressure',
        'priority': 'attention',
        'title': 'Há atendimentos atrasados',
        'body': 'Existem 6 solicitações atrasadas agora.',
        'data': {'overdue': 6},
      });
      expect(item.title, contains('atrasados'));
      expect(item.body, contains('6'));
      expect(item.categoryLabel, 'Atrasos');
      expect(item.recommendedAction, isNotEmpty);
      expect(item.isOpportunity, isTrue);
      expect(item.routeHint, '/home/protocols');
    });
  });

  group('IntelligenceTrendsData.fromJson', () {
    test('parses series and signals', () {
      final data = IntelligenceTrendsData.fromJson({
        'daily': [
          {'date': '2026-07-18', 'created': 10, 'resolved': 2},
        ],
        'weekly': [],
        'monthly': [
          {'month': '2026-07', 'created': 24, 'resolved': 7},
        ],
        'signals': {
          'created_slope': 0.09,
          'resolved_slope': 0.02,
          'created_vs_resolved': 19,
          'momentum': 'stable',
        },
      });
      expect(data.daily.single.created, 10);
      expect(data.signals.momentumLabel, 'Estável');
      expect(data.monthly.single.label, '2026-07');
    });
  });

  group('IntelligenceAnalyticsData.fromJson', () {
    test('parses neighborhoods subjects and team', () {
      final data = IntelligenceAnalyticsData.fromJson({
        'executive_snapshot': {
          'protocols_open': 21,
          'protocols_resolved_today': 0,
          'waiting_citizen': 2,
          'overdue': 6,
          'new_today': 0,
        },
        'neighborhoods': {
          'items': [
            {
              'district': 'Taquaral',
              'total': 15,
              'open': 10,
              'resolved': 5,
              'overdue': 0,
              'growth_pct': 1400,
              'top_subjects': [
                {'name': 'iluminacao', 'count': 4},
              ],
            },
          ],
          'summary': {'hottest': 'Taquaral'},
        },
        'subjects': {
          'items': [
            {
              'theme': 'outros',
              'label': 'Outros assuntos',
              'total': 11,
              'trend': 'up',
              'growth_pct': 1000,
            },
          ],
          'summary': {'leading': 'Outros assuntos'},
        },
        'team': {
          'members': [
            {
              'rank': 1,
              'assignee_name': 'Admin Demo',
              'attended': 14,
              'in_progress': 11,
              'completed': 4,
              'overdue': 2,
              'avg_hours': 10,
              'avg_rating': 4.5,
              'score': 60,
            },
          ],
          'summary': {'top_performer': 'Admin Demo'},
        },
      });
      expect(data.snapshot.open, 21);
      expect(data.neighborhoods.single.district, 'Taquaral');
      expect(data.subjects.single.trendLabel, 'Crescimento');
      expect(data.team.single.name, 'Admin Demo');
    });
  });

  group('IntelligenceBriefingsHistory', () {
    test('parses empty history message', () {
      final h = IntelligenceBriefingsHistory.fromJson({
        'scope': 'weekly',
        'bullets': [],
        'message': 'Nenhum briefing persistido ainda.',
        'source': 'none',
      });
      expect(h.scope, 'weekly');
      expect(h.bullets, isEmpty);
      expect(h.message, contains('persistido'));
    });
  });

  group('IntelligenceCache', () {
    test('stores stamped entry', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = IntelligenceCache();
      await cache.put('trends', {'ok': true});
      final entry = await cache.get('trends');
      expect(entry, isNotNull);
      expect(entry!.data['ok'], true);
      expect(entry.isStaleFor(threshold: const Duration(hours: 1)), isFalse);
      expect(entry.ageLabel, isNotEmpty);
    });
  });

  group('Intelligence widgets', () {
    testWidgets('InsightCard shows title description priority action',
        (tester) async {
      final insight = IntelligenceInsight.fromJson({
        'id': 'x',
        'type': 'subject_rising',
        'priority': 'attention',
        'title': 'Aumento em Iluminação',
        'body': 'As solicitações cresceram no período.',
        'data': {},
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InsightCard(insight: insight)),
        ),
      );
      expect(find.text('Aumento em Iluminação'), findsOneWidget);
      expect(find.textContaining('cresceram'), findsOneWidget);
      expect(find.textContaining('Sugestão:'), findsOneWidget);
      expect(find.text('Prioritário'), findsOneWidget);
    });
  });
}
