import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/automation/data/automation_cache.dart';
import 'package:poligestor_app/features/automation/data/automation_contracts.dart';
import 'package:poligestor_app/features/automation/data/automation_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 10.6 paths', () {
    test('exposes automation LIVE namespace (catálogo c29c2ad) + VT reuse', () {
      const m = AuthMode.staff;
      expect(m.automationsRootPath, '/v1/automation/rules');
      expect(m.automationsDashboardPath, '/v1/automation/dashboard');
      expect(m.automationsExecutionsPath, '/v1/automation/executions');
      expect(m.automationsApprovalsPath, '/v1/automation/approvals');
      expect(m.automationsAlertsPath, '/v1/automation/alerts');
      expect(m.automationsMetricsPath, '/v1/automation/metrics');
      expect(m.automationsSchedulePath, '/v1/automation/schedules');
      expect(m.automationsLogsPath, '/v1/automation/logs');
      expect(m.automationsAgentsPath, '/v1/automation/agents');
      expect(m.automationPath('x'), '/v1/automation/rules/x');
      expect(m.virtualTeamDashboardPath, '/v1/virtual-team/dashboard');
      expect(m.virtualTeamAgentsPath, '/v1/virtual-team/agents');
      expect(m.virtualTeamExecutionsPath, '/v1/virtual-team/executions');
      expect(m.virtualTeamAlertsPath, '/v1/virtual-team/alerts');
      expect(m.aiTeamPath, '/v1/ai/team');
    });
  });

  group('automation contracts', () {
    test('LIVE slugs cover published catalog paths', () {
      expect(
        kAutomationLiveSlugs,
        containsAll(<String>{
          'dashboard',
          'rules',
          'rule-detail',
          'executions',
          'approvals',
          'alerts',
          'metrics',
          'logs',
          'schedules',
          'agents',
        }),
      );
      expect(automationPathLive('rules'), isTrue);
      expect(automationPathLive('schedules'), isTrue);
      expect(automationPathLive('editor'), isTrue);
      expect(automationPathLive('autonomy'), isTrue);
    });
  });

  group('autonomy levels', () {
    test('maps raw strings to levels 0-5', () {
      expect(AutonomyLevel.fromRaw('suggest').value, 2);
      expect(AutonomyLevel.fromRaw('auto').label, 'Executar automaticamente');
      expect(AutonomyLevel.fromRaw('disabled').value, 0);
      expect(AutonomyLevel.fromRaw('4').value, 4);
    });
  });

  group('automation models', () {
    test('parses automation rule payload', () {
      final a = AutoAutomation.fromJson({
        'id': 'a1',
        'name': 'SLA reminder',
        'status': 'active',
        'agent_slug': 'director',
        'trigger': 'sla_overdue',
        'autonomy_level': 'approve',
      });
      expect(a.statusLabel, 'Ativa');
      expect(a.autonomy, AutonomyLevel.approve);
    });

    test('parses live dashboard payload tolerantly', () {
      final d = AutoDashboardSnapshot.fromJson({
        'agents_active': 3,
        'agents_total': '6',
        'executions_24h': 12,
        'success_today': 10,
        'failures_today': 2,
        'queue_depth': 1,
        'alerts_critical': 4,
        'efficiency_pct': '83.3',
        'pending_approvals': 5,
      });
      expect(d.agentsActive, 3);
      expect(d.agentsTotal, 6);
      expect(d.executionsToday, 12);
      expect(d.successToday, 10);
      expect(d.failuresToday, 2);
      expect(d.queueDepth, 1);
      expect(d.alertsCritical, 4);
      expect(d.efficiencyPct, closeTo(83.3, 0.001));
      expect(d.pendingApprovals, 5);
    });

    test('parses approval payload', () {
      final a = AutoApproval.fromJson({
        'id': 'ap1',
        'title': 'Publicar resumo',
        'status': 'pending',
        'rule_name': 'Resumo diário',
        'agent_slug': 'director',
        'created_at': '2026-07-20T10:00:00Z',
      });
      expect(a.statusLabel, 'Pendente');
      expect(a.ruleName, 'Resumo diário');
      expect(a.requestedAt, isNotNull);
    });
  });

  group('automation cache isolation', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = AutomationCache();
      await cache.saveDashboard(
        'demo',
        const AutoDashboardSnapshot(
          agentsActive: 2,
          agentsTotal: 6,
          executionsToday: 9,
          successToday: 9,
          failuresToday: 0,
          queueDepth: 0,
          alertsCritical: 1,
          efficiencyPct: 100,
        ),
      );
      expect(await cache.getDashboard('other'), isNull);
      final demo = await cache.getDashboard('demo');
      expect(demo!.agentsActive, 2);
      expect(demo.fromCache, isTrue);
    });
  });

  group('deep links automation', () {
    test('poligestor://automation resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://automation',
        ),
      );
      expect(target?.location, '/home/automation');
    });

    test('poligestor://automacao/approvals', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://automacao/approvals',
        ),
      );
      expect(target?.location, '/home/automation/approvals');
    });
  });
}
