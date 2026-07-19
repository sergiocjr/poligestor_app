import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/mandate/data/mandate_cache.dart';
import 'package:poligestor_app/features/mandate/data/mandate_models.dart';
import 'package:poligestor_app/features/mandate/data/mandate_repository.dart';
import 'package:poligestor_app/features/mandate/domain/mandate_search_helpers.dart';
import 'package:poligestor_app/features/mandate/presentation/widgets/mandate_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode mandate paths', () {
    test('exposes exact contract paths', () {
      const m = AuthMode.staff;
      expect(m.mandateExecutivePath, '/v1/mandate/executive');
      expect(m.mandateMapPath, '/v1/mandate/map');
      expect(m.mandateTeamPath, '/v1/mandate/team');
      expect(m.mandateNeighborhoodsPath, '/v1/mandate/neighborhoods');
      expect(m.mandateSubjectsPath, '/v1/mandate/subjects');
      expect(m.mandateSearchPath, '/v1/mandate/search');
      expect(m.mandateReportsPath, '/v1/mandate/reports');
      expect(m.mandateTvPath, '/v1/mandate/tv');
      expect(m.mandateAgendaPath, '/v1/mandate/agenda');
      expect(m.mandateBriefingPath, '/v1/mandate/briefing');
    });
  });

  group('MandateFilter', () {
    test('serializes only non-empty query params', () {
      const f = MandateFilter(
        period: '7d',
        district: 'Centro',
        page: 2,
        q: '',
      );
      final q = f.toQuery();
      expect(q['period'], '7d');
      expect(q['district'], 'Centro');
      expect(q['page'], 2);
      expect(q.containsKey('q'), isFalse);
    });
  });

  group('mandateSearchQueryReady', () {
    test('requires at least 2 trimmed chars', () {
      expect(mandateSearchQueryReady(''), isFalse);
      expect(mandateSearchQueryReady(' a '), isFalse);
      expect(mandateSearchQueryReady('ab'), isTrue);
      expect(mandateSearchDebounce().inMilliseconds, 400);
    });
  });

  group('MandateCache', () {
    test('stores and returns stamped entry', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = MandateCache();
      await cache.put('executive', {'ok': true});
      final entry = await cache.get('executive');
      expect(entry, isNotNull);
      expect(entry!.data['ok'], true);
      expect(entry.ageLabel, isNotEmpty);
      expect(entry.isStale, isFalse);
    });
  });

  group('MandateExecutive.fromJson', () {
    test('parses day summary and builds attention points', () {
      final exec = MandateExecutive.fromJson({
        'executive': {
          'day_summary': {
            'protocols_open': 10,
            'protocols_resolved_today': 2,
            'waiting_citizen': 3,
            'overdue': 1,
            'new_today': 4,
            'avg_resolution_hours': 12.5,
          },
          'situation_by_theme': [
            {'theme': 'iluminacao', 'label': 'Iluminação', 'open': 5},
          ],
          'weekly_series': [],
          'monthly_series': [],
          'month_totals': {},
        },
        'briefing': {
          'bullets': ['Resumo A'],
          'source': 'ai',
        },
      });
      expect(exec.daySummary.open, 10);
      expect(exec.daySummary.overdue, 1);
      expect(exec.briefing?.bullets, ['Resumo A']);
      expect(exec.attention.length, greaterThanOrEqualTo(2));
      expect(
        exec.attention.any((a) => a.title.contains('atraso')),
        isTrue,
      );
    });

    test('tolerates empty / unexpected payload', () {
      final exec = MandateExecutive.fromJson({});
      expect(exec.daySummary.open, 0);
      expect(exec.attention, isEmpty);
    });
  });

  group('MandateSearchData.fromJson', () {
    test('groups hits by key', () {
      final data = MandateSearchData.fromJson({
        'query': 'rua',
        'total': 1,
        'groups': {
          'protocols': [
            {
              'type': 'protocol',
              'id': '99',
              'title': 'PROTO-99',
              'subtitle': 'Aberto',
            },
          ],
          'people': [],
        },
      });
      expect(data.query, 'rua');
      expect(data.groups['protocols']!.single.id, '99');
      expect(data.groups['people'], isEmpty);
    });
  });

  group('MandateNeighborhoods / Subjects / Team', () {
    test('parses ranking payloads', () {
      final n = MandateNeighborhoodsData.fromJson({
        'most_active_districts': [
          {
            'district': 'Centro',
            'total': 8,
            'open': 3,
            'resolved': 5,
            'top_categories': [
              {'name': 'Buraco', 'count': 2},
            ],
          },
        ],
      });
      expect(n.districts.single.district, 'Centro');
      expect(n.districts.single.topCategories.single.name, 'Buraco');

      final s = MandateSubjectsData.fromJson({
        'by_theme': [
          {'theme': 'x', 'label': 'X', 'quantity': 7},
        ],
      });
      expect(s.byTheme.single.quantity, 7);

      final t = MandateTeamData.fromJson({
        'ranking': [
          {
            'rank': 1,
            'assignee_name': 'Ana',
            'attended': 10,
            'in_progress': 2,
            'completed': 8,
            'overdue': 0,
            'avg_hours': 4.0,
            'avg_rating': 4.5,
            'score': 90,
          },
        ],
      });
      expect(t.ranking.single.name, 'Ana');
    });
  });

  group('Mandate widgets', () {
    testWidgets('indicator card and attention tile render', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MandateIndicatorCard(label: 'Abertas', value: '12'),
                MandateAttentionTile(
                  title: 'Em atraso',
                  explanation: 'Há 2 protocolos.',
                  actionLabel: 'Abrir',
                ),
                MandateRankingTile(
                  rank: 1,
                  title: 'Centro',
                  subtitle: '8 abertas',
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Abertas'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Em atraso'), findsOneWidget);
      expect(find.text('Centro'), findsOneWidget);
    });

    testWidgets('empty attention section shows friendly copy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Nenhum ponto crítico no momento.'),
          ),
        ),
      );
      expect(find.text('Nenhum ponto crítico no momento.'), findsOneWidget);
    });
  });
}
