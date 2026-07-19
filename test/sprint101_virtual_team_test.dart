import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/virtual_team/data/virtual_team_cache.dart';
import 'package:poligestor_app/features/virtual_team/data/virtual_team_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 10.1 paths', () {
    test('exposes full virtual-team contract', () {
      const m = AuthMode.staff;
      expect(m.virtualTeamRootPath, '/v1/virtual-team');
      expect(m.virtualTeamDashboardPath, '/v1/virtual-team/dashboard');
      expect(m.virtualTeamAgentsPath, '/v1/virtual-team/agents');
      expect(
        m.virtualTeamAgentPath('director'),
        '/v1/virtual-team/agents/director',
      );
      expect(
        m.virtualTeamAgentTasksPath('director'),
        '/v1/virtual-team/agents/director/tasks',
      );
      expect(
        m.virtualTeamAgentExecutionsPath('director'),
        '/v1/virtual-team/agents/director/executions',
      );
      expect(
        m.virtualTeamAgentLogsPath('director'),
        '/v1/virtual-team/agents/director/logs',
      );
      expect(
        m.virtualTeamAgentMetricsPath('director'),
        '/v1/virtual-team/agents/director/metrics',
      );
      expect(
        m.virtualTeamAgentTimelinePath('director'),
        '/v1/virtual-team/agents/director/timeline',
      );
      expect(m.virtualTeamLogsPath, '/v1/virtual-team/logs');
      expect(m.virtualTeamAuditPath, '/v1/virtual-team/audit');
      expect(m.virtualTeamSearchPath, '/v1/virtual-team/search');
      expect(m.virtualTeamMetricsPath, '/v1/virtual-team/metrics');
      expect(m.virtualTeamTimelinePath, '/v1/virtual-team/timeline');
      expect(m.virtualTeamAlertsPath, '/v1/virtual-team/alerts');
      expect(m.virtualTeamHandoffsPath, '/v1/virtual-team/handoffs');
      expect(m.aiTeamPath, '/v1/ai/team');
    });
  });

  group('VtDashboard.fromJson', () {
    test('parses KPI fields including decimals', () {
      final dash = VtDashboard.fromJson({
        'tasks_open': 3,
        'tasks_completed_24h': 10,
        'tasks_failed_24h': 1,
        'avg_duration_ms': 1488.43,
        'efficiency_pct': 87.5,
        'executions_24h': 12,
        'delegations_24h': 2,
        'handoffs_24h': 4,
        'learnings_current': 1,
        'agents_active': 5,
        'agents_total': 8,
        'audits_24h': 0,
        'queue_depth': 2,
      });
      expect(dash.agentsActive, 5);
      expect(dash.efficiencyPct, 87.5);
      expect(dash.avgDurationMs, 1488);
      expect(dash.queueDepth, 2);
    });
  });

  group('VtTask.fromJson', () {
    test('parses assigned_agent and priority_label', () {
      final t = VtTask.fromJson({
        'id': '1',
        'code': 'VT-1',
        'title': 'Lembrete',
        'status': 'completed',
        'priority_label': 'high',
        'assigned_agent': 'secretary',
        'created_by_agent': 'director',
        'created_at': '2026-07-19T05:11:07-03:00',
      });
      expect(t.code, 'VT-1');
      expect(t.agentSlug, 'secretary');
      expect(t.priority, 'high');
      expect(t.origin, 'director');
    });
  });

  group('VtLogEntry / VtAlert / VtTimelineItem', () {
    test('parse ops payloads', () {
      final log = VtLogEntry.fromJson({
        'id': 'l1',
        'source': 'audit',
        'level': 'info',
        'type': 'supervision',
        'message': 'Ciclo',
        'agent_slug': 'director',
        'created_at': '2026-07-19T05:20:28-03:00',
      });
      expect(log.message, 'Ciclo');

      final alert = VtAlert.fromJson({
        'id': 'a1',
        'source': 'noc',
        'severity': 'high',
        'title': 'SLA',
        'body': '6 vencidos',
        'status': 'open',
        'agent_slug': 'noc',
      });
      expect(alert.severity, 'high');

      final tl = VtTimelineItem.fromJson({
        'id': 'evt-1',
        'kind': 'task_event',
        'title': 'approved',
        'body': 'ok',
        'agent_slug': 'director',
      });
      expect(tl.kind, 'task_event');
    });
  });

  group('VtSearchResults.fromJson', () {
    test('parses grouped search', () {
      final r = VtSearchResults.fromJson(
        {
          'tasks': [
            {'id': '1', 'title': 'Atraso'},
          ],
          'agents': [],
          'handoffs': [],
          'memory': [],
          'executions': [],
        },
        meta: {'total': 1, 'q': 'atraso'},
        query: 'atraso',
      );
      expect(r.total, 1);
      expect(r.tasks.single['title'], 'Atraso');
      expect(r.isEmpty, isFalse);
    });
  });

  group('VtTeamRoot.fromJson', () {
    test('parses overview root', () {
      final root = VtTeamRoot.fromJson({
        'sprint': '10.1',
        'generated_at': '2026-07-19T02:22:00-03:00',
        'dashboard': {
          'tasks_open': 0,
          'tasks_completed_24h': 7,
          'tasks_failed_24h': 0,
          'efficiency_pct': 100,
          'executions_24h': 7,
          'delegations_24h': 7,
          'handoffs_24h': 7,
          'learnings_current': 2,
          'agents_active': 9,
          'agents_total': 9,
          'audits_24h': 31,
          'queue_depth': 0,
        },
        'agents_state': [
          {
            'id': '1',
            'slug': 'director',
            'name': 'Diretora',
            'description': '',
            'specialty': 'orquestração',
            'objective': '',
            'responsibilities': [],
            'priority': 1,
            'state': 'idle',
            'is_available': true,
            'is_online': true,
            'stats': {
              'tasks_completed': 0,
              'tasks_failed': 0,
              'delegations': 7,
            },
            'queue': 'vt-director',
          },
        ],
        'recent_handoffs': [
          {
            'id': 'h1',
            'from_agent': 'director',
            'to_agent': 'secretary',
            'reason': 'delegação',
            'status': 'completed',
          },
        ],
        'stats': {'noc_open': 2},
      });
      expect(root.sprint, '10.1');
      expect(root.agentsState.single.slug, 'director');
      expect(root.recentHandoffs.single.toAgent, 'secretary');
      expect(root.dashboard.efficiencyPct, 100);
    });
  });

  group('VirtualTeamCache', () {
    test('roundtrip stamped data', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = VirtualTeamCache();
      await cache.put('dashboard', {'agents_total': 3});
      final entry = await cache.get('dashboard');
      expect(entry, isNotNull);
      expect(entry!.data['agents_total'], 3);
    });
  });

  group('NotificationRouter virtual-team deep links', () {
    test('resolves poligestor://virtual-team/alerts', () {
      final target = const NotificationRouter().resolve(
        PushPayload(
          type: PushEventType.unknown,
          deepLink: 'poligestor://virtual-team/alerts',
        ),
      );
      expect(target?.location, '/home/virtual-team/alerts');
    });
  });
}
