import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/automation/data/automation_cache.dart';
import 'package:poligestor_app/features/automation/data/automation_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode sprint 10.6 paths', () {
    test('exposes automation pending namespace + VT reuse targets', () {
      const m = AuthMode.staff;
      expect(m.automationsRootPath, '/v1/automations');
      expect(m.automationsDashboardPath, '/v1/automations/dashboard');
      expect(m.automationsApprovalsPath, '/v1/automations/approvals');
      expect(m.automationsSchedulePath, '/v1/automations/schedule');
      expect(m.automationsAutonomyPath, '/v1/automations/autonomy');
      expect(m.automationPath('x'), '/v1/automations/x');
      expect(m.virtualTeamDashboardPath, '/v1/virtual-team/dashboard');
      expect(m.virtualTeamAgentsPath, '/v1/virtual-team/agents');
      expect(m.virtualTeamExecutionsPath, '/v1/virtual-team/executions');
      expect(m.virtualTeamAlertsPath, '/v1/virtual-team/alerts');
      expect(m.aiTeamPath, '/v1/ai/team');
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
    test('parses automation draft payload', () {
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
