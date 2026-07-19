import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/virtual_team/data/virtual_team_cache.dart';
import 'package:poligestor_app/features/virtual_team/data/virtual_team_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 10.1 paths', () {
    test('exposes live and reserved virtual-team paths', () {
      const m = AuthMode.staff;
      expect(m.virtualTeamDashboardPath, '/v1/virtual-team/dashboard');
      expect(m.virtualTeamAgentsPath, '/v1/virtual-team/agents');
      expect(
        m.virtualTeamAgentPath('director'),
        '/v1/virtual-team/agents/director',
      );
      expect(m.virtualTeamTasksPath, '/v1/virtual-team/tasks');
      expect(m.virtualTeamExecutionsPath, '/v1/virtual-team/executions');
      expect(m.virtualTeamEventsPath, '/v1/virtual-team/events');
      expect(m.virtualTeamMemoryPath, '/v1/virtual-team/memory');
      expect(m.virtualTeamLearningPath, '/v1/virtual-team/learning');
      expect(m.virtualTeamQueuePath, '/v1/virtual-team/queue');
      expect(m.aiHandoffsPath, '/v1/ai/handoffs');
      expect(m.virtualTeamLogsPath, '/v1/virtual-team/logs');
      expect(m.virtualTeamAuditPath, '/v1/virtual-team/audit');
      expect(m.virtualTeamSearchPath, '/v1/virtual-team/search');
    });
  });

  group('VtDashboard.fromJson', () {
    test('parses KPI fields', () {
      final dash = VtDashboard.fromJson({
        'tasks_open': 3,
        'tasks_completed_24h': 10,
        'tasks_failed_24h': 1,
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
      expect(dash.queueDepth, 2);
    });
  });

  group('VtAgent.fromJson', () {
    test('parses agent card by slug', () {
      final agent = VtAgent.fromJson({
        'id': '1',
        'slug': 'protocol-agent',
        'name': 'Protocolos',
        'description': 'Cuida de protocolos',
        'specialty': 'Atendimento',
        'objective': 'Resolver demanda',
        'responsibilities': ['triagem', 'resposta'],
        'priority': 1,
        'state': 'idle',
        'is_available': true,
        'is_online': true,
        'stats': {
          'tasks_completed': 9,
          'tasks_failed': 0,
          'delegations': 1,
        },
        'queue': 'default',
        'limits': {'max_concurrent': 2},
      });
      expect(agent.slug, 'protocol-agent');
      expect(agent.stateLabel, 'Aguardando');
      expect(agent.stats.tasksCompleted, 9);
      expect(agent.maxConcurrent, 2);
      expect(agent.responsibilities, ['triagem', 'resposta']);
    });
  });

  group('VtHandoff.fromJson', () {
    test('parses ai handoff', () {
      final h = VtHandoff.fromJson({
        'id': 'h1',
        'from_agent': 'director',
        'to_agent': 'protocol-agent',
        'reason': 'escalation',
        'status': 'completed',
        'created_at': '2026-07-18T10:00:00Z',
      });
      expect(h.fromAgent, 'director');
      expect(h.toAgent, 'protocol-agent');
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
      expect(entry.ageLabel, isNotEmpty);
    });
  });

  group('NotificationRouter virtual-team deep links', () {
    test('resolves poligestor://virtual-team', () {
      final target = const NotificationRouter().resolve(
        PushPayload(
          type: PushEventType.unknown,
          deepLink: 'poligestor://virtual-team',
        ),
      );
      expect(target?.location, '/home/virtual-team');
    });

    test('resolves agent slug path', () {
      final target = const NotificationRouter().resolve(
        PushPayload(
          type: PushEventType.unknown,
          deepLink: 'poligestor://virtual-team/agents/director',
        ),
      );
      expect(target?.location, '/home/virtual-team/agents/director');
    });
  });
}
