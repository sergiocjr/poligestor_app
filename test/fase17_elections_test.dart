import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/electoral_management/data/elections_cache.dart';
import 'package:poligestor_app/features/electoral_management/data/elections_contracts.dart';
import 'package:poligestor_app/features/electoral_management/data/elections_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 17 Elections paths', () {
    test('exposes official /v1/elections namespace', () {
      const m = AuthMode.staff;
      expect(m.electionsRootPath, '/v1/elections');
      expect(m.electionsDashboardPath, '/v1/elections/dashboard');
      expect(m.electionsPreCampaignPath, '/v1/elections/campaigns');
      expect(m.electionsCampaignsPath, '/v1/elections/campaigns');
      expect(m.electionsCandidatesPath, '/v1/elections/candidates');
      expect(m.electionsCoordinationPath, '/v1/elections/campaigns');
      expect(m.electionsTeamsPath, '/v1/elections/teams');
      expect(m.electionsCanvassersPath, '/v1/elections/members');
      expect(m.electionsVolunteersPath, '/v1/elections/members');
      expect(m.electionsLeadersPath, '/v1/elections/members');
      expect(m.electionsSupportersPath, '/v1/elections/members');
      expect(m.electionsGoalsPath, '/v1/elections/goals');
      expect(m.electionsRegionsPath, '/v1/elections/regions');
      expect(m.electionsNeighborhoodsPath, '/v1/elections/neighborhoods');
      expect(m.electionsElectoralZonesPath, '/v1/elections/zones');
      expect(m.electionsElectoralSectionsPath, '/v1/elections/sections');
      expect(m.electionsPollingStationsPath, '/v1/elections/polling-places');
      expect(m.electionsMapPath, '/v1/elections/map');
      expect(m.electionsCampaignAgendaPath, '/v1/elections/events');
      expect(m.electionsEventsPath, '/v1/elections/events');
      expect(m.electionsWalksPath, '/v1/elections/events');
      expect(m.electionsMeetingsPath, '/v1/elections/events');
      expect(m.electionsVisitsPath, '/v1/elections/events');
      expect(m.electionsRalliesPath, '/v1/elections/events');
      expect(m.electionsMobilizationsPath, '/v1/elections/events');
      expect(m.electionsCampaignMaterialsPath, '/v1/elections/materials');
      expect(m.electionsInventoryPath, '/v1/elections/stock');
      expect(m.electionsDistributionPath, '/v1/elections/material-requests');
      expect(
        m.electionsMaterialRequestsPath,
        '/v1/elections/material-requests',
      );
      expect(m.electionsPollsPath, '/v1/elections/surveys');
      expect(m.electionsScenariosPath, '/v1/elections/projections');
      expect(m.electionsVoteIntentionPath, '/v1/elections/projections');
      expect(m.electionsRejectionPath, '/v1/elections/projections');
      expect(m.electionsComparativesPath, '/v1/elections/projections');
      expect(m.electionsProjectionsPath, '/v1/elections/projections');
      expect(m.electionsRegionalPerformancePath, '/v1/elections/projections');
      expect(m.electionsAccountabilityPath, '/v1/elections/accountability');
      expect(m.electionsRevenuesPath, '/v1/elections/finance');
      expect(m.electionsExpensesPath, '/v1/elections/finance');
      expect(m.electionsDonationsPath, '/v1/elections/finance');
      expect(m.electionsSuppliersPath, '/v1/elections/vendors');
      expect(m.electionsReceiptsPath, '/v1/elections/receipts');
      expect(m.electionsReportsPath, '/v1/elections/reports');
      expect(m.electionsExportsPath, '/v1/elections/export');
      expect(m.electionsSearchPath, '/v1/elections/campaigns');
      expect(m.electionsFiltersPath, '/v1/elections/regions');
    });
  });

  group('Elections LIVE contracts', () {
    test('marks HTTP 200 VPS routes as live', () {
      expect(kElectionsLiveSlugs.length, 46);
      expect(electionsPathLive('dashboard'), isTrue);
      expect(electionsPathLive('candidates'), isTrue);
      expect(electionsPathLive('campaigns'), isTrue);
      expect(electionsPathLive('reports'), isTrue);
      expect(electionsPathLive('material-requests'), isTrue);
      expect(electionsPathLive('electoral-zones'), isTrue);
      expect(electionsPathLive('polling-stations'), isTrue);
      expect(electionsPathLive('campaign-materials'), isTrue);
      expect(electionsPathLive('polls'), isTrue);
      expect(electionsPathLive('exports'), isTrue);
      expect(electionsPathLive('pre-campaign'), isTrue);
      expect(electionsPathLive('coordination'), isTrue);
    });
  });

  group('Elections models', () {
    test('parses item', () {
      final item = ElectionsItem.fromJson({
        'id': '1',
        'name': 'Candidato Centro',
        'region': 'Centro',
        'status': 'active',
        'support_level': 'alto',
      });
      expect(item.title, 'Candidato Centro');
      expect(item.region, 'Centro');
      expect(item.supportLevel, 'alto');
    });

    test('flattens dashboard summary into indicator rows', () {
      final rows = asElectionsMapList({
        'product': 'poligestor',
        'summary': {'campaigns': 1, 'active_campaigns': 1, 'candidates': 0},
      });
      expect(rows.length, 3);
      expect(rows.first['title'], 'Campanhas');
      expect(rows.first['summary'], '1');
    });
  });

  group('Elections cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = ElectionsCache();
      await cache.putMap('demo', 'candidates', {
        'data': [
          {'id': '1', 'title': 'A'},
        ],
      });
      expect(await cache.getMap('other', 'candidates'), isNull);
      expect(await cache.getMap('demo', 'candidates'), isNotNull);
    });
  });

  group('deep links Elections', () {
    test('poligestor://gestao-eleitoral resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://gestao-eleitoral',
        ),
      );
      expect(target?.location, '/home/elections');
    });

    test('poligestor://elections/candidates', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://elections/candidates',
        ),
      );
      expect(target?.location, '/home/elections/candidates');
    });
  });
}
