import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_mode.dart';
import '../../features/account/presentation/account_profile_page.dart';
import '../../features/account/presentation/account_sessions_page.dart';
import '../../features/agenda/presentation/agenda_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/automation/presentation/automation_pages.dart';
import '../../features/strategy/presentation/strategy_pages.dart';
import '../../features/parliament/presentation/parliament_pages.dart';
import '../../features/works/presentation/works_pages.dart';
import '../../features/agreements/presentation/agreements_pages.dart';
import '../../features/events/presentation/events_pages.dart';
import '../../features/documents/presentation/documents_pages.dart';
import '../../features/finance/presentation/finance_pages.dart';
import '../../features/institutional_communication/presentation/institutional_communication_pages.dart';
import '../../features/political_crm/presentation/crm_pages.dart';
import '../../features/electoral_management/presentation/elections_pages.dart';
import '../../features/territorial_intelligence/presentation/territorial_intelligence_pages.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../../features/smart_assistant/presentation/smart_assistant_pages.dart';
import '../../features/assistant/presentation/assistant_chat_page.dart';
import '../../features/citizen/presentation/citizen_content_pages.dart';
import '../../features/citizen/presentation/citizen_home_page.dart';
import '../../features/citizen/presentation/citizen_notifications_page.dart';
import '../../features/citizen/presentation/citizen_profile_page.dart';
import '../../features/citizen/presentation/citizen_requests_page.dart';
import '../../features/citizen/presentation/citizen_shell.dart';
import '../../features/citizen/presentation/new_request_page.dart';
import '../../features/citizen/presentation/request_detail_page.dart';
import '../../features/home/presentation/gabinete_dashboard_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/identity/domain/tenant_controller.dart';
import '../../features/identity/presentation/organization_select_page.dart';
import '../../features/intelligence/presentation/intelligence_analytics_page.dart';
import '../../features/intelligence/presentation/intelligence_briefing_page.dart';
import '../../features/intelligence/presentation/intelligence_dashboard_page.dart';
import '../../features/intelligence/presentation/intelligence_insights_page.dart';
import '../../features/intelligence/presentation/intelligence_summaries_page.dart';
import '../../features/intelligence/presentation/intelligence_trends_page.dart';
import '../../features/mandate/presentation/mandate_agenda_page.dart';
import '../../features/mandate/presentation/mandate_map_page.dart';
import '../../features/mandate/presentation/mandate_neighborhoods_page.dart';
import '../../features/mandate/presentation/mandate_overview_page.dart';
import '../../features/mandate/presentation/mandate_reports_page.dart';
import '../../features/mandate/presentation/mandate_search_page.dart';
import '../../features/mandate/presentation/mandate_subjects_page.dart';
import '../../features/mandate/presentation/mandate_team_page.dart';
import '../../features/mandate/presentation/mandate_tv_page.dart';
import '../../features/communication/presentation/communication_pages.dart';
import '../../features/more/presentation/more_page.dart';
import '../../features/notifications/data/push_payload.dart';
import '../../features/notifications/domain/notification_router.dart';
import '../../features/protocols/presentation/protocol_detail_page.dart';
import '../../features/protocols/presentation/protocols_page.dart';
import '../../features/virtual_team/presentation/virtual_team_agent_detail_page.dart';
import '../../features/virtual_team/presentation/virtual_team_agents_page.dart';
import '../../features/virtual_team/presentation/virtual_team_dashboard_page.dart';
import '../../features/virtual_team/presentation/virtual_team_lists_page.dart';
import '../../features/virtual_team/presentation/virtual_team_ops_pages.dart';

/// Navigator raiz — detalhes de solicitação sobem acima do CitizenShell
/// para não cair no IndexedStack da aba (tela branca com AppBar/nav).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter({
  required AuthController auth,
  required TenantController tenant,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([auth, tenant]),
    redirect: (context, state) {
      // Intent filters Android entregam `poligestor://…` ao GoRouter.
      // Converte para rotas internas antes do match (evita Page Not Found).
      if (state.uri.scheme == 'poligestor') {
        final target = const NotificationRouter().resolve(
          PushPayload(
            type: PushEventType.systemNotice,
            deepLink: state.uri.toString(),
          ),
        );
        if (target != null) return target.location;
      }

      final booting = auth.isBooting || !tenant.ready;
      final loggedIn = auth.isAuthenticated;
      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final isOrg = loc == '/org';
      final isLoginFlow = loc == '/login' || loc.startsWith('/login/');

      if (booting) return isSplash ? null : '/splash';

      if (!loggedIn) {
        if (!tenant.hasOrganization) {
          return isOrg ? null : '/org';
        }
        return isLoginFlow ? null : '/login';
      }

      final isCitizenPath = loc.startsWith('/citizen');
      final isStaffPath = loc.startsWith('/home');
      final isAccountPath = loc.startsWith('/account');
      final isMandatePath = loc.startsWith('/home/mandate');
      final isIntelPath = loc.startsWith('/home/intelligence');
      final isVirtualTeamPath = loc.startsWith('/home/virtual-team');
      final isCommunicationPath = loc.startsWith('/home/communication');
      final isAutomationPath = loc.startsWith('/home/automation');
      final isStrategyPath = loc.startsWith('/home/strategy');
      final isParliamentPath = loc.startsWith('/home/parliament');
      final isWorksPath = loc.startsWith('/home/works');
      final isAgreementsPath = loc.startsWith('/home/agreements');
      final isEventsPath = loc.startsWith('/home/events');
      final isTerritorialIntelPath = loc.startsWith(
        '/home/territorial-intelligence',
      );
      final isDocumentsPath = loc.startsWith('/home/documents');
      final isFinancePath = loc.startsWith('/home/finance');
      final isInstitutionalCommunicationPath = loc.startsWith(
        '/home/institutional-communication',
      );
      final isCrmPath = loc.startsWith('/home/crm');
      final isElectionsPath = loc.startsWith('/home/elections');

      if (isSplash || isLoginFlow || isOrg) {
        return auth.mode == AuthMode.portal
            ? '/citizen/home'
            : '/home/dashboard';
      }

      if (auth.mode == AuthMode.portal && isStaffPath) {
        return '/citizen/home';
      }
      if (auth.mode == AuthMode.staff && isCitizenPath) {
        return '/home/dashboard';
      }
      // Mandato / Inteligência / Equipe Virtual / Comunicação / Automação / Estratégia exclusivos de staff.
      if ((isMandatePath ||
              isIntelPath ||
              isVirtualTeamPath ||
              isCommunicationPath ||
              isAutomationPath ||
              isStrategyPath ||
              isParliamentPath ||
              isWorksPath ||
              isAgreementsPath ||
              isEventsPath ||
              isTerritorialIntelPath ||
              isDocumentsPath ||
              isFinancePath ||
              isInstitutionalCommunicationPath ||
              isCrmPath ||
              isElectionsPath) &&
          auth.mode != AuthMode.staff) {
        return '/citizen/home';
      }

      // Conta compartilhada staff/portal.
      if (isAccountPath) return null;

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/org', builder: (_, _) => const OrganizationSelectPage()),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginPage(),
        routes: [
          GoRoute(path: 'register', builder: (_, _) => const RegisterPage()),
          GoRoute(
            path: 'forgot',
            builder: (_, _) => const ForgotPasswordPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/account/profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AccountProfilePage(),
      ),
      GoRoute(
        path: '/account/sessions',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AccountSessionsPage(),
      ),

      // Staff shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/dashboard',
                builder: (_, _) => const GabineteDashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/protocols',
                builder: (_, _) => const ProtocolsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        ProtocolDetailPage(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/agenda',
                builder: (_, _) => const AgendaPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/mandate',
                builder: (_, _) => const MandateOverviewPage(),
                routes: [
                  GoRoute(
                    path: 'agenda',
                    builder: (_, _) => const MandateAgendaPage(),
                  ),
                  GoRoute(
                    path: 'neighborhoods',
                    builder: (_, _) => const MandateNeighborhoodsPage(),
                  ),
                  GoRoute(
                    path: 'subjects',
                    builder: (_, _) => const MandateSubjectsPage(),
                  ),
                  GoRoute(
                    path: 'team',
                    builder: (_, _) => const MandateTeamPage(),
                  ),
                  GoRoute(
                    path: 'search',
                    builder: (_, _) => const MandateSearchPage(),
                  ),
                  GoRoute(
                    path: 'reports',
                    builder: (_, _) => const MandateReportsPage(),
                  ),
                  GoRoute(
                    path: 'map',
                    builder: (_, _) => const MandateMapPage(),
                  ),
                  GoRoute(path: 'tv', builder: (_, _) => const MandateTvPage()),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home/more', builder: (_, _) => const MorePage()),
            ],
          ),
        ],
      ),

      // Inteligência (Fase 9) — fora do shell; acessível por Mais / atalhos.
      GoRoute(
        path: '/home/intelligence',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const IntelligenceDashboardPage(),
        routes: [
          GoRoute(
            path: 'briefing',
            builder: (_, _) => const IntelligenceBriefingPage(),
          ),
          GoRoute(
            path: 'insights',
            builder: (_, _) => const IntelligenceInsightsPage(),
          ),
          GoRoute(
            path: 'opportunities',
            builder: (_, _) =>
                const IntelligenceInsightsPage(opportunitiesOnly: true),
          ),
          GoRoute(
            path: 'trends',
            builder: (_, _) => const IntelligenceTrendsPage(),
          ),
          GoRoute(
            path: 'summaries',
            builder: (_, _) => const IntelligenceSummariesPage(),
          ),
          GoRoute(
            path: 'analytics/neighborhoods',
            builder: (_, _) => const IntelligenceAnalyticsPage(
              focus: AnalyticsFocus.neighborhoods,
            ),
          ),
          GoRoute(
            path: 'analytics/subjects',
            builder: (_, _) => const IntelligenceAnalyticsPage(
              focus: AnalyticsFocus.subjects,
            ),
          ),
          GoRoute(
            path: 'analytics/team',
            builder: (_, _) => const IntelligenceAnalyticsPage(
              focus: AnalyticsFocus.team,
            ),
          ),
          GoRoute(
            path: 'analytics/productivity',
            builder: (_, _) => const IntelligenceAnalyticsPage(
              focus: AnalyticsFocus.productivity,
            ),
          ),
        ],
      ),

      // Painel Parlamentar (Sprint 10.8) — staff only.
      GoRoute(
        path: '/home/parliament',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ParliamentHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => const ParliamentDashboardPage(),
          ),
          GoRoute(
            path: 'bills',
            builder: (_, _) => ParliamentListPage(
              title: 'Projetos de Lei',
              detailRoutePrefix: '/home/parliament/bills',
              emptyMessage: 'Nenhum projeto de lei encontrado.',
              loader: (repo, tenant) => repo.bills(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ParliamentDetailPage(
                  title: 'Detalhe do projeto de lei',
                  id: state.pathParameters['id']!,
                  loader: (repo) =>
                      repo.billDetail(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'projects',
            builder: (_, _) => ParliamentListPage(
              title: 'Projetos',
              detailRoutePrefix: '/home/parliament/projects',
              emptyMessage: 'Nenhum projeto encontrado.',
              loader: (repo, tenant) => repo.projects(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ParliamentDetailPage(
                  title: 'Detalhe do projeto',
                  id: state.pathParameters['id']!,
                  loader: (repo) => repo.itemDetail(
                    collectionPath: AuthMode.staff.parliamentProjectsPath,
                    id: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'indications',
            builder: (_, _) => ParliamentListPage(
              title: 'Indicações',
              detailRoutePrefix: '/home/parliament/indications',
              emptyMessage: 'Nenhuma indicação encontrada.',
              loader: (repo, tenant) => repo.indications(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ParliamentDetailPage(
                  title: 'Detalhe da indicação',
                  id: state.pathParameters['id']!,
                  loader: (repo) => repo.itemDetail(
                    collectionPath: AuthMode.staff.parliamentIndicationsPath,
                    id: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'requests',
            builder: (_, _) => ParliamentListPage(
              title: 'Requerimentos',
              detailRoutePrefix: '/home/parliament/requests',
              emptyMessage: 'Nenhum requerimento encontrado.',
              loader: (repo, tenant) => repo.requests(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ParliamentDetailPage(
                  title: 'Detalhe do requerimento',
                  id: state.pathParameters['id']!,
                  loader: (repo) => repo.itemDetail(
                    collectionPath: AuthMode.staff.parliamentRequestsPath,
                    id: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'motions',
            builder: (_, _) => ParliamentListPage(
              title: 'Moções',
              detailRoutePrefix: '/home/parliament/motions',
              emptyMessage: 'Nenhuma moção encontrada.',
              loader: (repo, tenant) => repo.motions(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ParliamentDetailPage(
                  title: 'Detalhe da moção',
                  id: state.pathParameters['id']!,
                  loader: (repo) => repo.itemDetail(
                    collectionPath: AuthMode.staff.parliamentMotionsPath,
                    id: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'amendments',
            builder: (_, _) => ParliamentListPage(
              title: 'Emendas',
              detailRoutePrefix: '/home/parliament/amendments',
              emptyMessage: 'Nenhuma emenda encontrada.',
              loader: (repo, tenant) => repo.amendments(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ParliamentDetailPage(
                  title: 'Detalhe da emenda',
                  id: state.pathParameters['id']!,
                  loader: (repo) => repo.itemDetail(
                    collectionPath: AuthMode.staff.parliamentAmendmentsPath,
                    id: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'agenda',
            builder: (_, _) => ParliamentListPage(
              title: 'Agenda',
              detailRoutePrefix: '/home/parliament/agenda',
              emptyMessage: 'Agenda vazia.',
              loader: (repo, tenant) => repo.agenda(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'sessions',
            builder: (_, _) => ParliamentListPage(
              title: 'Sessões',
              detailRoutePrefix: '/home/parliament/sessions',
              emptyMessage: 'Nenhuma sessão encontrada.',
              loader: (repo, tenant) => repo.sessions(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ParliamentDetailPage(
                  title: 'Detalhe da sessão',
                  id: state.pathParameters['id']!,
                  loader: (repo) => repo.itemDetail(
                    collectionPath: AuthMode.staff.parliamentSessionsPath,
                    id: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'votes',
            builder: (_, _) => ParliamentListPage(
              title: 'Votações',
              detailRoutePrefix: '/home/parliament/votes',
              emptyMessage: 'Nenhuma votação encontrada.',
              loader: (repo, tenant) => repo.votes(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'promises',
            builder: (_, _) => ParliamentPendingPage(
              title: 'Promessas',
              path: AuthMode.staff.parliamentPromisesPath,
              probe: (repo) => repo.promises(),
            ),
          ),
          GoRoute(
            path: 'support-base',
            builder: (_, _) => ParliamentListPage(
              title: 'Base de Apoio',
              detailRoutePrefix: '/home/parliament/support-base',
              emptyMessage: 'Nenhum registro na base de apoio.',
              loader: (repo, tenant) => repo.supportBase(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'demands',
            builder: (_, _) => ParliamentListPage(
              title: 'Demandas',
              detailRoutePrefix: '/home/parliament/demands',
              emptyMessage: 'Nenhuma demanda encontrada.',
              loader: (repo, tenant) => repo.demands(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (_, _) => const ParliamentSearchPage(),
          ),
          GoRoute(
            path: 'timeline',
            builder: (_, _) => ParliamentPendingPage(
              title: 'Linha do Tempo',
              path: AuthMode.staff.parliamentTimelinePath,
              probe: (repo) => repo.timeline(),
            ),
          ),
          GoRoute(
            path: 'history',
            builder: (_, _) => ParliamentPendingPage(
              title: 'Histórico',
              path: AuthMode.staff.parliamentHistoryPath,
              probe: (repo) => repo.history(),
            ),
          ),
          GoRoute(
            path: 'attachments',
            builder: (_, _) => ParliamentPendingPage(
              title: 'Anexos',
              path: AuthMode.staff.parliamentAttachmentsPath,
              probe: (repo) => repo.attachments(),
            ),
          ),
        ],
      ),

      // Painel Obras (Sprint 10.9) — staff only.
      GoRoute(
        path: '/home/works',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const WorksHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => const WorksDashboardPage(),
          ),
          GoRoute(
            path: 'list',
            builder: (_, _) => WorksListPage(
              title: 'Obras',
              detailRoutePrefix: '/home/works/list',
              emptyMessage: 'Nenhuma obra encontrada.',
              loader: (repo, tenant) => repo.projects(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    WorksDetailPage(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: 'demands',
            builder: (_, _) => WorksListPage(
              title: 'Demandas',
              detailRoutePrefix: '/home/works/demands',
              emptyMessage: 'Nenhuma demanda encontrada.',
              loader: (repo, tenant) => repo.demands(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'inspections',
            builder: (_, _) => WorksListPage(
              title: 'Fiscalizações',
              detailRoutePrefix: '/home/works/inspections',
              emptyMessage: 'Nenhuma fiscalização encontrada.',
              loader: (repo, tenant) => repo.inspections(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'schedule',
            builder: (_, _) => WorksListPage(
              title: 'Cronograma',
              detailRoutePrefix: '/home/works/schedule',
              emptyMessage: 'Cronograma vazio.',
              loader: (repo, tenant) => repo.schedule(tenantSlug: tenant),
            ),
          ),
          GoRoute(path: 'map', builder: (_, _) => const WorksMapPage()),
          GoRoute(
            path: 'timeline',
            builder: (_, _) => WorksListPage(
              title: 'Linha do Tempo',
              detailRoutePrefix: '/home/works/timeline',
              emptyMessage: 'Linha do tempo vazia.',
              loader: (repo, tenant) => repo.timeline(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'photos',
            builder: (_, _) => WorksListPage(
              title: 'Fotos',
              detailRoutePrefix: '/home/works/photos',
              emptyMessage: 'Nenhuma foto encontrada.',
              loader: (repo, tenant) => repo.photos(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'attachments',
            builder: (_, _) => WorksListPage(
              title: 'Anexos',
              detailRoutePrefix: '/home/works/attachments',
              emptyMessage: 'Nenhum anexo encontrado.',
              loader: (repo, tenant) => repo.attachments(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'checklist',
            builder: (_, _) => WorksListPage(
              title: 'Checklist',
              detailRoutePrefix: '/home/works/checklist',
              emptyMessage: 'Checklist vazio.',
              loader: (repo, tenant) => repo.checklist(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'indicators',
            builder: (_, _) => WorksListPage(
              title: 'Indicadores',
              detailRoutePrefix: '/home/works/indicators',
              emptyMessage: 'Nenhum indicador encontrado.',
              loader: (repo, tenant) => repo.indicators(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => WorksListPage(
              title: 'Relatórios',
              detailRoutePrefix: '/home/works/reports',
              emptyMessage: 'Nenhum relatório encontrado.',
              loader: (repo, tenant) => repo.reports(tenantSlug: tenant),
            ),
          ),
          GoRoute(path: 'search', builder: (_, _) => const WorksSearchPage()),
        ],
      ),

      // Painel de Convênios (Sprint 11.0) — staff only.
      GoRoute(
        path: '/home/agreements',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AgreementsHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => const AgreementsDashboardPage(),
          ),
          GoRoute(
            path: 'list',
            builder: (_, _) => AgreementsListPage(
              title: 'Convênios',
              detailRoutePrefix: '/home/agreements/list',
              emptyMessage: 'Nenhum convênio encontrado.',
              loader: (repo, tenant) => repo.agreements(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    AgreementsDetailPage(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: 'resources',
            builder: (_, _) => AgreementsListPage(
              title: 'Recursos',
              detailRoutePrefix: '/home/agreements/resources',
              emptyMessage: 'Nenhum recurso encontrado.',
              loader: (repo, tenant) => repo.resources(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'projects',
            builder: (_, _) => AgreementsListPage(
              title: 'Projetos',
              detailRoutePrefix: '/home/agreements/projects',
              emptyMessage: 'Nenhum projeto encontrado.',
              loader: (repo, tenant) => repo.projects(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'execution',
            builder: (_, _) => AgreementsListPage(
              title: 'Execução',
              detailRoutePrefix: '/home/agreements/execution',
              emptyMessage: 'Nenhum registro de execução.',
              loader: (repo, tenant) => repo.execution(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'accountability',
            builder: (_, _) => AgreementsListPage(
              title: 'Prestação de Contas',
              detailRoutePrefix: '/home/agreements/accountability',
              emptyMessage: 'Nenhuma prestação de contas encontrada.',
              loader: (repo, tenant) => repo.accountability(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'schedule',
            builder: (_, _) => AgreementsListPage(
              title: 'Cronograma',
              detailRoutePrefix: '/home/agreements/schedule',
              emptyMessage: 'Cronograma vazio.',
              loader: (repo, tenant) => repo.schedule(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'timeline',
            builder: (_, _) => AgreementsListPage(
              title: 'Linha do Tempo',
              detailRoutePrefix: '/home/agreements/timeline',
              emptyMessage: 'Linha do tempo vazia.',
              loader: (repo, tenant) => repo.timeline(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'documents',
            builder: (_, _) => AgreementsListPage(
              title: 'Documentos',
              detailRoutePrefix: '/home/agreements/documents',
              emptyMessage: 'Nenhum documento encontrado.',
              loader: (repo, tenant) => repo.documents(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'attachments',
            builder: (_, _) => AgreementsListPage(
              title: 'Anexos',
              detailRoutePrefix: '/home/agreements/attachments',
              emptyMessage: 'Nenhum anexo encontrado.',
              loader: (repo, tenant) => repo.attachments(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'indicators',
            builder: (_, _) => AgreementsListPage(
              title: 'Indicadores',
              detailRoutePrefix: '/home/agreements/indicators',
              emptyMessage: 'Nenhum indicador encontrado.',
              loader: (repo, tenant) => repo.indicators(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => AgreementsListPage(
              title: 'Relatórios',
              detailRoutePrefix: '/home/agreements/reports',
              emptyMessage: 'Nenhum relatório encontrado.',
              loader: (repo, tenant) => repo.reports(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (_, _) => const AgreementsSearchPage(),
          ),
        ],
      ),

      // Fase 11 — Painel de Eventos (Gestão Institucional) — staff only.
      GoRoute(
        path: '/home/events',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const EventsHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => const EventsDashboardPage(),
          ),
          GoRoute(
            path: 'list',
            builder: (_, _) => EventsListPage(
              title: 'Eventos',
              detailRoutePrefix: '/home/events/list',
              emptyMessage: 'Nenhum evento encontrado.',
              loader: (repo, tenant) => repo.events(tenantSlug: tenant),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    EventsDetailPage(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: 'agenda',
            builder: (_, _) => const EventsAgendaPage(),
          ),
          GoRoute(
            path: 'calendar',
            builder: (_, _) => const EventsCalendarPage(),
          ),
          GoRoute(
            path: 'audiences',
            builder: (_, _) => EventsListPage(
              title: 'Audiências',
              detailRoutePrefix: '/home/events/list',
              emptyMessage: 'Nenhuma audiência encontrada.',
              loader: (repo, tenant) => repo.audiences(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'meetings',
            builder: (_, _) => EventsListPage(
              title: 'Reuniões',
              detailRoutePrefix: '/home/events/list',
              emptyMessage: 'Nenhuma reunião encontrada.',
              loader: (repo, tenant) => repo.meetings(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'participants',
            builder: (_, _) => EventsListPage(
              title: 'Participantes',
              detailRoutePrefix: '/home/events/participants',
              emptyMessage: 'Nenhum participante encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.participants(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'invites',
            builder: (_, _) => EventsListPage(
              title: 'Convites',
              detailRoutePrefix: '/home/events/invites',
              emptyMessage: 'Nenhum convite encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.invites(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'attendance',
            builder: (_, _) => EventsListPage(
              title: 'Presença',
              detailRoutePrefix: '/home/events/attendance',
              emptyMessage: 'Nenhum registro de presença.',
              openDetail: false,
              loader: (repo, tenant) => repo.attendance(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'check-in',
            builder: (_, _) => EventsListPage(
              title: 'Check-in',
              detailRoutePrefix: '/home/events/check-in',
              emptyMessage: 'Nenhum check-in encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.checkIn(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'check-out',
            builder: (_, _) => EventsListPage(
              title: 'Check-out',
              detailRoutePrefix: '/home/events/check-out',
              emptyMessage: 'Nenhum check-out encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.checkOut(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'qr-code',
            builder: (_, _) => EventsListPage(
              title: 'QR Code',
              detailRoutePrefix: '/home/events/qr-code',
              emptyMessage: 'Nenhum QR Code encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.qrCode(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'gallery',
            builder: (_, _) => EventsListPage(
              title: 'Galeria',
              detailRoutePrefix: '/home/events/gallery',
              emptyMessage: 'Galeria vazia.',
              openDetail: false,
              loader: (repo, tenant) => repo.gallery(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'photos',
            builder: (_, _) => EventsListPage(
              title: 'Fotos',
              detailRoutePrefix: '/home/events/photos',
              emptyMessage: 'Nenhuma foto encontrada.',
              openDetail: false,
              loader: (repo, tenant) => repo.photos(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'videos',
            builder: (_, _) => EventsListPage(
              title: 'Vídeos',
              detailRoutePrefix: '/home/events/videos',
              emptyMessage: 'Nenhum vídeo encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.videos(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'documents',
            builder: (_, _) => EventsListPage(
              title: 'Documentos',
              detailRoutePrefix: '/home/events/documents',
              emptyMessage: 'Nenhum documento encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.documents(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'certificates',
            builder: (_, _) => EventsListPage(
              title: 'Certificados',
              detailRoutePrefix: '/home/events/certificates',
              emptyMessage: 'Nenhum certificado encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.certificates(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'timeline',
            builder: (_, _) => EventsListPage(
              title: 'Linha do Tempo',
              detailRoutePrefix: '/home/events/timeline',
              emptyMessage: 'Linha do tempo vazia.',
              openDetail: false,
              loader: (repo, tenant) => repo.timeline(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'map',
            builder: (_, _) => EventsListPage(
              title: 'Mapa',
              detailRoutePrefix: '/home/events/map',
              emptyMessage: 'Mapa indisponível.',
              openDetail: false,
              loader: (repo, tenant) => repo.map(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'indicators',
            builder: (_, _) => EventsListPage(
              title: 'Indicadores',
              detailRoutePrefix: '/home/events/indicators',
              emptyMessage: 'Nenhum indicador encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.indicators(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => EventsListPage(
              title: 'Relatórios',
              detailRoutePrefix: '/home/events/reports',
              emptyMessage: 'Nenhum relatório encontrado.',
              openDetail: false,
              loader: (repo, tenant) => repo.reports(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (_, _) => const EventsSearchPage(),
          ),
        ],
      ),

      // Fase 12 — Inteligência Territorial — staff only.
      GoRoute(
        path: '/home/territorial-intelligence',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const TerritorialIntelligenceHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => const TerritorialIntelligenceDashboardPage(),
          ),
          GoRoute(
            path: 'bi',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Painel Analítico',
              emptyMessage: 'Nenhum dado analítico encontrado.',
              loader: (repo, tenant) => repo.bi(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'kpis',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Indicadores-chave',
              emptyMessage: 'Nenhum indicador-chave encontrado.',
              loader: (repo, tenant) => repo.kpis(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'indicators',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Indicadores',
              emptyMessage: 'Nenhum indicador encontrado.',
              loader: (repo, tenant) => repo.indicators(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'charts',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Gráficos',
              emptyMessage: 'Nenhum gráfico disponível.',
              loader: (repo, tenant) => repo.charts(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'heatmap',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Mapas de calor',
              emptyMessage: 'Mapa de calor indisponível.',
              loader: (repo, tenant) => repo.heatmap(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'map',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Mapa territorial',
              emptyMessage: 'Mapa territorial indisponível.',
              loader: (repo, tenant) => repo.map(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'neighborhoods',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Bairros',
              emptyMessage: 'Nenhum bairro encontrado.',
              loader: (repo, tenant) => repo.neighborhoods(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'regions',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Regiões',
              emptyMessage: 'Nenhuma região encontrada.',
              loader: (repo, tenant) => repo.regions(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'electoral-zones',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Zonas eleitorais',
              emptyMessage: 'Nenhuma zona eleitoral encontrada.',
              loader: (repo, tenant) =>
                  repo.electoralZones(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'leaderships',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Lideranças',
              emptyMessage: 'Nenhuma liderança encontrada.',
              loader: (repo, tenant) => repo.leaderships(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'demands',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Demandas',
              emptyMessage: 'Nenhuma demanda encontrada.',
              loader: (repo, tenant) => repo.demands(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'works',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Obras',
              emptyMessage: 'Nenhuma obra encontrada.',
              loader: (repo, tenant) => repo.works(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'protocols',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Protocolos',
              emptyMessage: 'Nenhum protocolo encontrado.',
              loader: (repo, tenant) => repo.protocols(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'attendances',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Atendimentos',
              emptyMessage: 'Nenhum atendimento encontrado.',
              loader: (repo, tenant) => repo.attendances(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'comparatives',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Comparativos',
              emptyMessage: 'Nenhum comparativo disponível.',
              loader: (repo, tenant) => repo.comparatives(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'evolution',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Evolução',
              emptyMessage: 'Nenhuma evolução disponível.',
              loader: (repo, tenant) => repo.evolution(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'trends',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Tendências',
              emptyMessage: 'Nenhuma tendência disponível.',
              loader: (repo, tenant) => repo.trends(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'projections',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Projeções',
              emptyMessage: 'Nenhuma projeção disponível.',
              loader: (repo, tenant) => repo.projections(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'filters',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Filtros',
              emptyMessage: 'Nenhum filtro publicado.',
              loader: (repo, tenant) => repo.filters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'exports',
            builder: (_, _) => TerritorialIntelligenceListPage(
              title: 'Exportações',
              emptyMessage: 'Nenhuma exportação disponível.',
              loader: (repo, tenant) => repo.exports(tenantSlug: tenant),
            ),
          ),
        ],
      ),

      // Fase 13 — Gestão Documental — staff only.
      GoRoute(
        path: '/home/documents',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const DocumentsHubPage(),
        routes: [
          GoRoute(
            path: 'list',
            builder: (_, _) => DocumentsListPage(
              title: 'Documentos',
              emptyMessage: 'Nenhum documento encontrado.',
              loader: (repo, tenant) => repo.list(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (_, _) => const DocumentsSearchPage(),
          ),
          GoRoute(
            path: 'filters',
            builder: (_, _) => DocumentsListPage(
              title: 'Filtros',
              emptyMessage: 'Nenhum filtro disponível.',
              loader: (repo, tenant) => repo.filters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'categories',
            builder: (_, _) => DocumentsListPage(
              title: 'Categorias',
              emptyMessage: 'Nenhuma categoria encontrada.',
              loader: (repo, tenant) => repo.categories(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'favorites',
            builder: (_, _) => DocumentsListPage(
              title: 'Favoritos',
              emptyMessage: 'Nenhum favorito encontrado.',
              loader: (repo, tenant) => repo.favorites(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'history',
            builder: (_, _) => DocumentsListPage(
              title: 'Histórico',
              emptyMessage: 'Nenhum histórico disponível.',
              loader: (repo, tenant) => repo.history(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'timeline',
            builder: (_, _) => DocumentsListPage(
              title: 'Linha do tempo',
              emptyMessage: 'Nenhum evento na linha do tempo.',
              loader: (repo, tenant) => repo.timeline(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'viewer',
            builder: (_, _) => DocumentsListPage(
              title: 'Visualizador PDF',
              emptyMessage: 'Nenhum PDF disponível para visualização.',
              loader: (repo, tenant) => repo.viewer(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'signatures',
            builder: (_, _) => DocumentsListPage(
              title: 'Assinaturas',
              emptyMessage: 'Nenhuma assinatura encontrada.',
              loader: (repo, tenant) => repo.signatures(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'approvals',
            builder: (_, _) => DocumentsListPage(
              title: 'Aprovações',
              emptyMessage: 'Nenhuma aprovação pendente.',
              loader: (repo, tenant) => repo.approvals(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'share',
            builder: (_, _) => DocumentsListPage(
              title: 'Compartilhamento',
              emptyMessage: 'Nenhum compartilhamento encontrado.',
              loader: (repo, tenant) => repo.share(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'templates',
            builder: (_, _) => DocumentsListPage(
              title: 'Modelos',
              emptyMessage: 'Nenhum modelo encontrado.',
              loader: (repo, tenant) => repo.templates(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'download',
            builder: (_, _) => DocumentsListPage(
              title: 'Download',
              emptyMessage: 'Nenhum download disponível.',
              loader: (repo, tenant) => repo.download(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'upload',
            builder: (_, _) => DocumentsListPage(
              title: 'Upload',
              emptyMessage: 'Upload preparado. Aguardando contrato LIVE.',
              loader: (repo, tenant) => repo.upload(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'attachments',
            builder: (_, _) => DocumentsListPage(
              title: 'Anexos',
              emptyMessage: 'Nenhum anexo encontrado.',
              loader: (repo, tenant) => repo.attachments(tenantSlug: tenant),
            ),
          ),
        ],
      ),

      // Fase 14 — Gestão Financeira do Mandato — staff only.
      GoRoute(
        path: '/home/finance',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const FinanceHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => const FinanceDashboardPage(),
          ),
          GoRoute(
            path: 'indicators',
            builder: (_, _) => FinanceListPage(
              title: 'Indicadores',
              emptyMessage: 'Nenhum indicador encontrado.',
              loader: (repo, tenant) => repo.indicators(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'balance',
            builder: (_, _) => FinanceListPage(
              title: 'Saldo',
              emptyMessage: 'Nenhum saldo disponível.',
              loader: (repo, tenant) => repo.balance(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'revenues',
            builder: (_, _) => FinanceListPage(
              title: 'Receitas',
              emptyMessage: 'Nenhuma receita encontrada.',
              loader: (repo, tenant) => repo.revenues(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'expenses',
            builder: (_, _) => FinanceListPage(
              title: 'Despesas',
              emptyMessage: 'Nenhuma despesa encontrada.',
              loader: (repo, tenant) => repo.expenses(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'transactions',
            builder: (_, _) => FinanceListPage(
              title: 'Transações',
              emptyMessage: 'Nenhuma transação encontrada.',
              loader: (repo, tenant) => repo.transactions(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'payments',
            builder: (_, _) => FinanceListPage(
              title: 'Pagamentos',
              emptyMessage: 'Nenhum pagamento encontrado.',
              loader: (repo, tenant) => repo.payments(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'bank-accounts',
            builder: (_, _) => FinanceListPage(
              title: 'Contas bancárias',
              emptyMessage: 'Nenhuma conta bancária encontrada.',
              loader: (repo, tenant) => repo.bankAccounts(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'categories',
            builder: (_, _) => FinanceListPage(
              title: 'Categorias',
              emptyMessage: 'Nenhuma categoria encontrada.',
              loader: (repo, tenant) => repo.categories(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'cost-centers',
            builder: (_, _) => FinanceListPage(
              title: 'Centros de custo',
              emptyMessage: 'Nenhum centro de custo encontrado.',
              loader: (repo, tenant) => repo.costCenters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'suppliers',
            builder: (_, _) => FinanceListPage(
              title: 'Fornecedores',
              emptyMessage: 'Nenhum fornecedor encontrado.',
              loader: (repo, tenant) => repo.suppliers(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'contracts',
            builder: (_, _) => FinanceListPage(
              title: 'Contratos',
              emptyMessage: 'Nenhum contrato encontrado.',
              loader: (repo, tenant) => repo.contracts(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'refunds',
            builder: (_, _) => FinanceListPage(
              title: 'Reembolsos',
              emptyMessage: 'Nenhum reembolso encontrado.',
              loader: (repo, tenant) => repo.refunds(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'advances',
            builder: (_, _) => FinanceListPage(
              title: 'Adiantamentos',
              emptyMessage: 'Nenhum adiantamento encontrado.',
              loader: (repo, tenant) => repo.advances(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'funds',
            builder: (_, _) => FinanceListPage(
              title: 'Verbas',
              emptyMessage: 'Nenhuma verba encontrada.',
              loader: (repo, tenant) => repo.funds(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'budget',
            builder: (_, _) => FinanceListPage(
              title: 'Orçamento',
              emptyMessage: 'Nenhum orçamento encontrado.',
              loader: (repo, tenant) => repo.budget(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'budget-execution',
            builder: (_, _) => FinanceListPage(
              title: 'Execução orçamentária',
              emptyMessage: 'Nenhuma execução encontrada.',
              loader: (repo, tenant) =>
                  repo.budgetExecution(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'accountability',
            builder: (_, _) => FinanceListPage(
              title: 'Prestação de contas',
              emptyMessage: 'Nenhuma prestação de contas encontrada.',
              loader: (repo, tenant) =>
                  repo.accountability(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'receipts',
            builder: (_, _) => FinanceListPage(
              title: 'Comprovantes',
              emptyMessage: 'Nenhum comprovante encontrado.',
              loader: (repo, tenant) => repo.receipts(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'attachments',
            builder: (_, _) => FinanceListPage(
              title: 'Anexos',
              emptyMessage: 'Nenhum anexo encontrado.',
              loader: (repo, tenant) => repo.attachments(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'approvals',
            builder: (_, _) => FinanceListPage(
              title: 'Aprovações',
              emptyMessage: 'Nenhuma aprovação encontrada.',
              loader: (repo, tenant) => repo.approvals(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'reconciliation',
            builder: (_, _) => FinanceListPage(
              title: 'Conciliação',
              emptyMessage: 'Nenhuma conciliação encontrada.',
              loader: (repo, tenant) =>
                  repo.reconciliation(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'cash-flow',
            builder: (_, _) => FinanceListPage(
              title: 'Fluxo de caixa',
              emptyMessage: 'Nenhum fluxo de caixa encontrado.',
              loader: (repo, tenant) => repo.cashFlow(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'payables',
            builder: (_, _) => FinanceListPage(
              title: 'Contas a pagar',
              emptyMessage: 'Nenhuma conta a pagar encontrada.',
              loader: (repo, tenant) => repo.payables(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'receivables',
            builder: (_, _) => FinanceListPage(
              title: 'Contas a receber',
              emptyMessage: 'Nenhuma conta a receber encontrada.',
              loader: (repo, tenant) => repo.receivables(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'alerts',
            builder: (_, _) => FinanceListPage(
              title: 'Alertas',
              emptyMessage: 'Nenhum alerta encontrado.',
              loader: (repo, tenant) => repo.alerts(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'history',
            builder: (_, _) => FinanceListPage(
              title: 'Histórico',
              emptyMessage: 'Nenhum histórico encontrado.',
              loader: (repo, tenant) => repo.history(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'filters',
            builder: (_, _) => FinanceListPage(
              title: 'Filtros',
              emptyMessage: 'Nenhum filtro disponível.',
              loader: (repo, tenant) => repo.filters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (_, _) => const FinanceSearchPage(),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => FinanceListPage(
              title: 'Relatórios',
              emptyMessage: 'Nenhum relatório encontrado.',
              loader: (repo, tenant) => repo.reports(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'exports',
            builder: (_, _) => FinanceListPage(
              title: 'Exportação',
              emptyMessage: 'Nenhuma exportação disponível.',
              loader: (repo, tenant) => repo.exports(tenantSlug: tenant),
            ),
          ),
        ],
      ),

      // Fase 15 — Comunicação Institucional — staff only.
      GoRoute(
        path: '/home/institutional-communication',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const InstitutionalCommunicationHubPage(),
        routes: [
          GoRoute(
            path: 'feed',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Feed de notícias',
              emptyMessage: 'Nenhuma notícia encontrada.',
              loader: (repo, tenant) => repo.feed(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'announcements',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Comunicados',
              emptyMessage: 'Nenhum comunicado encontrado.',
              loader: (repo, tenant) => repo.announcements(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'campaigns',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Campanhas',
              emptyMessage: 'Nenhuma campanha encontrada.',
              loader: (repo, tenant) => repo.campaigns(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'media',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Biblioteca de mídia',
              emptyMessage: 'Nenhum arquivo de mídia encontrado.',
              loader: (repo, tenant) => repo.media(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'publications',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Publicações',
              emptyMessage: 'Nenhuma publicação encontrada.',
              loader: (repo, tenant) => repo.publications(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'schedule',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Agenda de publicações',
              emptyMessage: 'Nenhum item na agenda.',
              loader: (repo, tenant) => repo.schedule(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'push',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Notificação push',
              emptyMessage: 'Nenhum envio push encontrado.',
              loader: (repo, tenant) => repo.push(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'email',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'E-mail',
              emptyMessage: 'Nenhum e-mail encontrado.',
              loader: (repo, tenant) => repo.email(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'whatsapp',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'WhatsApp',
              emptyMessage: 'Nenhuma mensagem WhatsApp encontrada.',
              loader: (repo, tenant) => repo.whatsapp(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'history',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Histórico',
              emptyMessage: 'Nenhum histórico encontrado.',
              loader: (repo, tenant) => repo.history(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (_, _) => const InstitutionalCommunicationSearchPage(),
          ),
          GoRoute(
            path: 'filters',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Filtros',
              emptyMessage: 'Nenhum filtro disponível.',
              loader: (repo, tenant) => repo.filters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'share',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Compartilhamento',
              emptyMessage: 'Nenhum compartilhamento encontrado.',
              loader: (repo, tenant) => repo.share(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => InstitutionalCommunicationListPage(
              title: 'Relatórios',
              emptyMessage: 'Nenhum relatório encontrado.',
              loader: (repo, tenant) => repo.reports(tenantSlug: tenant),
            ),
          ),
        ],
      ),

      // Fase 16 — CRM Político — staff only.
      GoRoute(
        path: '/home/crm',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const CrmHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => CrmListPage(
              title: 'Painel',
              emptyMessage: 'Nenhum indicador no painel.',
              loader: (repo, tenant) => repo.dashboard(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'leaders',
            builder: (_, _) => CrmListPage(
              title: 'Líderes',
              emptyMessage: 'Nenhum líder encontrado.',
              loader: (repo, tenant) => repo.leaders(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'supporters',
            builder: (_, _) => CrmListPage(
              title: 'Apoiadores',
              emptyMessage: 'Nenhum apoiador encontrado.',
              loader: (repo, tenant) => repo.supporters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'voters',
            builder: (_, _) => CrmListPage(
              title: 'Eleitores',
              emptyMessage: 'Nenhum eleitor encontrado.',
              loader: (repo, tenant) => repo.voters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'volunteers',
            builder: (_, _) => CrmListPage(
              title: 'Voluntários',
              emptyMessage: 'Nenhum voluntário encontrado.',
              loader: (repo, tenant) => repo.volunteers(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'team',
            builder: (_, _) => CrmListPage(
              title: 'Equipe',
              emptyMessage: 'Nenhum membro da equipe encontrado.',
              loader: (repo, tenant) => repo.team(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'entities',
            builder: (_, _) => CrmListPage(
              title: 'Entidades',
              emptyMessage: 'Nenhuma entidade encontrada.',
              loader: (repo, tenant) => repo.entities(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'associations',
            builder: (_, _) => CrmListPage(
              title: 'Associações',
              emptyMessage: 'Nenhuma associação encontrada.',
              loader: (repo, tenant) => repo.associations(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'churches',
            builder: (_, _) => CrmListPage(
              title: 'Igrejas',
              emptyMessage: 'Nenhuma igreja encontrada.',
              loader: (repo, tenant) => repo.churches(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'companies',
            builder: (_, _) => CrmListPage(
              title: 'Empresas',
              emptyMessage: 'Nenhuma empresa encontrada.',
              loader: (repo, tenant) => repo.companies(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'influencers',
            builder: (_, _) => CrmListPage(
              title: 'Influenciadores',
              emptyMessage: 'Nenhum influenciador encontrado.',
              loader: (repo, tenant) => repo.influencers(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'segmentation',
            builder: (_, _) => CrmListPage(
              title: 'Segmentação',
              emptyMessage: 'Nenhum segmento encontrado.',
              loader: (repo, tenant) => repo.segmentation(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'tags',
            builder: (_, _) => CrmListPage(
              title: 'Etiquetas',
              emptyMessage: 'Nenhuma etiqueta encontrada.',
              loader: (repo, tenant) => repo.tags(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'groups',
            builder: (_, _) => CrmListPage(
              title: 'Grupos',
              emptyMessage: 'Nenhum grupo encontrado.',
              loader: (repo, tenant) => repo.groups(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'regions',
            builder: (_, _) => CrmListPage(
              title: 'Regiões',
              emptyMessage: 'Nenhuma região encontrada.',
              loader: (repo, tenant) => repo.regions(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'neighborhoods',
            builder: (_, _) => CrmListPage(
              title: 'Bairros',
              emptyMessage: 'Nenhum bairro encontrado.',
              loader: (repo, tenant) => repo.neighborhoods(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'electoral-zones',
            builder: (_, _) => CrmListPage(
              title: 'Zonas eleitorais',
              emptyMessage: 'Nenhuma zona eleitoral encontrada.',
              loader: (repo, tenant) =>
                  repo.electoralZones(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'relationship-history',
            builder: (_, _) => CrmListPage(
              title: 'Histórico de relacionamento',
              emptyMessage: 'Nenhum histórico encontrado.',
              loader: (repo, tenant) =>
                  repo.relationshipHistory(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'interactions',
            builder: (_, _) => CrmListPage(
              title: 'Interações',
              emptyMessage: 'Nenhuma interação encontrada.',
              loader: (repo, tenant) => repo.interactions(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'visits',
            builder: (_, _) => CrmListPage(
              title: 'Visitas',
              emptyMessage: 'Nenhuma visita encontrada.',
              loader: (repo, tenant) => repo.visits(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'calls',
            builder: (_, _) => CrmListPage(
              title: 'Ligações',
              emptyMessage: 'Nenhuma ligação encontrada.',
              loader: (repo, tenant) => repo.calls(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'messages',
            builder: (_, _) => CrmListPage(
              title: 'Mensagens',
              emptyMessage: 'Nenhuma mensagem encontrada.',
              loader: (repo, tenant) => repo.messages(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'meetings',
            builder: (_, _) => CrmListPage(
              title: 'Reuniões',
              emptyMessage: 'Nenhuma reunião encontrada.',
              loader: (repo, tenant) => repo.meetings(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'linked-demands',
            builder: (_, _) => CrmListPage(
              title: 'Demandas vinculadas',
              emptyMessage: 'Nenhuma demanda vinculada.',
              loader: (repo, tenant) =>
                  repo.linkedDemands(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'linked-protocols',
            builder: (_, _) => CrmListPage(
              title: 'Protocolos vinculados',
              emptyMessage: 'Nenhum protocolo vinculado.',
              loader: (repo, tenant) =>
                  repo.linkedProtocols(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'campaigns',
            builder: (_, _) => CrmListPage(
              title: 'Campanhas',
              emptyMessage: 'Nenhuma campanha encontrada.',
              loader: (repo, tenant) => repo.campaigns(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'tasks',
            builder: (_, _) => CrmListPage(
              title: 'Tarefas',
              emptyMessage: 'Nenhuma tarefa encontrada.',
              loader: (repo, tenant) => repo.tasks(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'reminders',
            builder: (_, _) => CrmListPage(
              title: 'Lembretes',
              emptyMessage: 'Nenhum lembrete encontrado.',
              loader: (repo, tenant) => repo.reminders(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'support-level',
            builder: (_, _) => CrmListPage(
              title: 'Nível de apoio',
              emptyMessage: 'Nenhum nível de apoio encontrado.',
              loader: (repo, tenant) =>
                  repo.supportLevel(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'influence-potential',
            builder: (_, _) => CrmListPage(
              title: 'Potencial de influência',
              emptyMessage: 'Nenhum potencial de influência encontrado.',
              loader: (repo, tenant) =>
                  repo.influencePotential(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'relationships',
            builder: (_, _) => CrmListPage(
              title: 'Relacionamentos',
              emptyMessage: 'Nenhum relacionamento encontrado.',
              loader: (repo, tenant) =>
                  repo.relationships(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'import',
            builder: (_, _) => CrmListPage(
              title: 'Importação',
              emptyMessage: 'Nenhuma importação encontrada.',
              loader: (repo, tenant) => repo.importData(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'export',
            builder: (_, _) => CrmListPage(
              title: 'Exportação',
              emptyMessage: 'Nenhuma exportação encontrada.',
              loader: (repo, tenant) => repo.exportData(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (_, _) => const CrmSearchPage(),
          ),
          GoRoute(
            path: 'filters',
            builder: (_, _) => CrmListPage(
              title: 'Filtros',
              emptyMessage: 'Nenhum filtro disponível.',
              loader: (repo, tenant) => repo.filters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'indicators',
            builder: (_, _) => CrmListPage(
              title: 'Indicadores',
              emptyMessage: 'Nenhum indicador encontrado.',
              loader: (repo, tenant) => repo.indicators(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => CrmListPage(
              title: 'Relatórios',
              emptyMessage: 'Nenhum relatório encontrado.',
              loader: (repo, tenant) => repo.reports(tenantSlug: tenant),
            ),
          ),
        ],
      ),

      // Fase 17 — Gestão Eleitoral — staff only.
      GoRoute(
        path: '/home/elections',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ElectionsHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => ElectionsListPage(
              title: 'Painel eleitoral',
              emptyMessage: 'Nenhum indicador no painel.',
              loader: (repo, tenant) => repo.dashboard(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'pre-campaign',
            builder: (_, _) => ElectionsListPage(
              title: 'Pré-campanha',
              emptyMessage: 'Nenhum item de pré-campanha encontrado.',
              loader: (repo, tenant) => repo.preCampaign(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'campaigns',
            builder: (_, _) => ElectionsListPage(
              title: 'Campanhas',
              emptyMessage: 'Nenhuma campanha encontrada.',
              loader: (repo, tenant) => repo.campaigns(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'candidates',
            builder: (_, _) => ElectionsListPage(
              title: 'Candidatos',
              emptyMessage: 'Nenhum candidato encontrado.',
              loader: (repo, tenant) => repo.candidates(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'coordination',
            builder: (_, _) => ElectionsListPage(
              title: 'Coordenação',
              emptyMessage: 'Nenhum item de coordenação encontrado.',
              loader: (repo, tenant) => repo.coordination(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'teams',
            builder: (_, _) => ElectionsListPage(
              title: 'Equipes',
              emptyMessage: 'Nenhuma equipe encontrada.',
              loader: (repo, tenant) => repo.teams(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'canvassers',
            builder: (_, _) => ElectionsListPage(
              title: 'Cabos eleitorais',
              emptyMessage: 'Nenhum cabo eleitoral encontrado.',
              loader: (repo, tenant) => repo.canvassers(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'volunteers',
            builder: (_, _) => ElectionsListPage(
              title: 'Voluntários',
              emptyMessage: 'Nenhum voluntário encontrado.',
              loader: (repo, tenant) => repo.volunteers(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'leaders',
            builder: (_, _) => ElectionsListPage(
              title: 'Lideranças',
              emptyMessage: 'Nenhuma liderança encontrada.',
              loader: (repo, tenant) => repo.leaders(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'supporters',
            builder: (_, _) => ElectionsListPage(
              title: 'Apoiadores',
              emptyMessage: 'Nenhum apoiador encontrado.',
              loader: (repo, tenant) => repo.supporters(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'goals',
            builder: (_, _) => ElectionsListPage(
              title: 'Metas eleitorais',
              emptyMessage: 'Nenhuma meta encontrada.',
              loader: (repo, tenant) => repo.goals(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'regions',
            builder: (_, _) => ElectionsListPage(
              title: 'Regiões',
              emptyMessage: 'Nenhuma região encontrada.',
              loader: (repo, tenant) => repo.regions(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'neighborhoods',
            builder: (_, _) => ElectionsListPage(
              title: 'Bairros',
              emptyMessage: 'Nenhum bairro encontrado.',
              loader: (repo, tenant) => repo.neighborhoods(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'electoral-zones',
            builder: (_, _) => ElectionsListPage(
              title: 'Zonas eleitorais',
              emptyMessage: 'Nenhuma zona eleitoral encontrada.',
              loader: (repo, tenant) =>
                  repo.electoralZones(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'electoral-sections',
            builder: (_, _) => ElectionsListPage(
              title: 'Seções eleitorais',
              emptyMessage: 'Nenhuma seção eleitoral encontrada.',
              loader: (repo, tenant) =>
                  repo.electoralSections(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'polling-stations',
            builder: (_, _) => ElectionsListPage(
              title: 'Colégios eleitorais',
              emptyMessage: 'Nenhum colégio eleitoral encontrado.',
              loader: (repo, tenant) =>
                  repo.pollingStations(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'map',
            builder: (_, _) => ElectionsListPage(
              title: 'Mapa eleitoral',
              emptyMessage: 'Nenhum dado no mapa.',
              loader: (repo, tenant) => repo.map(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'campaign-agenda',
            builder: (_, _) => ElectionsListPage(
              title: 'Agenda de campanha',
              emptyMessage: 'Nenhum compromisso na agenda.',
              loader: (repo, tenant) =>
                  repo.campaignAgenda(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'events',
            builder: (_, _) => ElectionsListPage(
              title: 'Eventos',
              emptyMessage: 'Nenhum evento encontrado.',
              loader: (repo, tenant) => repo.events(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'walks',
            builder: (_, _) => ElectionsListPage(
              title: 'Caminhadas',
              emptyMessage: 'Nenhuma caminhada encontrada.',
              loader: (repo, tenant) => repo.walks(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'meetings',
            builder: (_, _) => ElectionsListPage(
              title: 'Reuniões',
              emptyMessage: 'Nenhuma reunião encontrada.',
              loader: (repo, tenant) => repo.meetings(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'visits',
            builder: (_, _) => ElectionsListPage(
              title: 'Visitas',
              emptyMessage: 'Nenhuma visita encontrada.',
              loader: (repo, tenant) => repo.visits(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'rallies',
            builder: (_, _) => ElectionsListPage(
              title: 'Comícios',
              emptyMessage: 'Nenhum comício encontrado.',
              loader: (repo, tenant) => repo.rallies(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'mobilizations',
            builder: (_, _) => ElectionsListPage(
              title: 'Mobilizações',
              emptyMessage: 'Nenhuma mobilização encontrada.',
              loader: (repo, tenant) =>
                  repo.mobilizations(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'campaign-materials',
            builder: (_, _) => ElectionsListPage(
              title: 'Materiais de campanha',
              emptyMessage: 'Nenhum material encontrado.',
              loader: (repo, tenant) =>
                  repo.campaignMaterials(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'inventory',
            builder: (_, _) => ElectionsListPage(
              title: 'Estoque',
              emptyMessage: 'Nenhum item no estoque.',
              loader: (repo, tenant) => repo.inventory(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'distribution',
            builder: (_, _) => ElectionsListPage(
              title: 'Distribuição',
              emptyMessage: 'Nenhuma distribuição encontrada.',
              loader: (repo, tenant) => repo.distribution(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'material-requests',
            builder: (_, _) => ElectionsListPage(
              title: 'Solicitações de material',
              emptyMessage: 'Nenhuma solicitação encontrada.',
              loader: (repo, tenant) =>
                  repo.materialRequests(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'polls',
            builder: (_, _) => ElectionsListPage(
              title: 'Pesquisas eleitorais',
              emptyMessage: 'Nenhuma pesquisa encontrada.',
              loader: (repo, tenant) => repo.polls(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'scenarios',
            builder: (_, _) => ElectionsListPage(
              title: 'Cenários',
              emptyMessage: 'Nenhum cenário encontrado.',
              loader: (repo, tenant) => repo.scenarios(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'vote-intention',
            builder: (_, _) => ElectionsListPage(
              title: 'Intenção de voto',
              emptyMessage: 'Nenhum dado de intenção de voto.',
              loader: (repo, tenant) =>
                  repo.voteIntention(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'rejection',
            builder: (_, _) => ElectionsListPage(
              title: 'Rejeição',
              emptyMessage: 'Nenhum dado de rejeição.',
              loader: (repo, tenant) => repo.rejection(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'comparatives',
            builder: (_, _) => ElectionsListPage(
              title: 'Comparativos',
              emptyMessage: 'Nenhum comparativo encontrado.',
              loader: (repo, tenant) => repo.comparatives(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'projections',
            builder: (_, _) => ElectionsListPage(
              title: 'Projeções',
              emptyMessage: 'Nenhuma projeção encontrada.',
              loader: (repo, tenant) => repo.projections(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'regional-performance',
            builder: (_, _) => ElectionsListPage(
              title: 'Desempenho por região',
              emptyMessage: 'Nenhum desempenho regional encontrado.',
              loader: (repo, tenant) =>
                  repo.regionalPerformance(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'accountability',
            builder: (_, _) => ElectionsListPage(
              title: 'Prestação de contas',
              emptyMessage: 'Nenhuma prestação de contas encontrada.',
              loader: (repo, tenant) =>
                  repo.accountability(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'revenues',
            builder: (_, _) => ElectionsListPage(
              title: 'Receitas',
              emptyMessage: 'Nenhuma receita encontrada.',
              loader: (repo, tenant) => repo.revenues(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'expenses',
            builder: (_, _) => ElectionsListPage(
              title: 'Despesas',
              emptyMessage: 'Nenhuma despesa encontrada.',
              loader: (repo, tenant) => repo.expenses(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'donations',
            builder: (_, _) => ElectionsListPage(
              title: 'Doações',
              emptyMessage: 'Nenhuma doação encontrada.',
              loader: (repo, tenant) => repo.donations(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'suppliers',
            builder: (_, _) => ElectionsListPage(
              title: 'Fornecedores',
              emptyMessage: 'Nenhum fornecedor encontrado.',
              loader: (repo, tenant) => repo.suppliers(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'receipts',
            builder: (_, _) => ElectionsListPage(
              title: 'Comprovantes',
              emptyMessage: 'Nenhum comprovante encontrado.',
              loader: (repo, tenant) => repo.receipts(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => ElectionsListPage(
              title: 'Relatórios',
              emptyMessage: 'Nenhum relatório encontrado.',
              loader: (repo, tenant) => repo.reports(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'exports',
            builder: (_, _) => ElectionsListPage(
              title: 'Exportações',
              emptyMessage: 'Nenhuma exportação encontrada.',
              loader: (repo, tenant) => repo.exports(tenantSlug: tenant),
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (_, _) => const ElectionsSearchPage(),
          ),
          GoRoute(
            path: 'filters',
            builder: (_, _) => ElectionsListPage(
              title: 'Filtros',
              emptyMessage: 'Nenhum filtro disponível.',
              loader: (repo, tenant) => repo.filters(tenantSlug: tenant),
            ),
          ),
        ],
      ),

      // Painel Estratégico (Sprint 10.7) — staff only.
      GoRoute(
        path: '/home/strategy',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const StrategyHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => const StrategyDashboardPage(),
          ),
          GoRoute(path: 'kpis', builder: (_, _) => const StrategyKpisPage()),
          GoRoute(path: 'map', builder: (_, _) => const StrategyMapPage()),
          GoRoute(
            path: 'heatmap',
            builder: (_, _) => const StrategyHeatmapPage(),
          ),
          GoRoute(
            path: 'trends',
            builder: (_, _) => const StrategyTrendsPage(),
          ),
          GoRoute(path: 'goals', builder: (_, _) => const StrategyGoalsPage()),
          GoRoute(
            path: 'alerts',
            builder: (_, _) => const StrategyAlertsPage(),
          ),
          GoRoute(
            path: 'compare',
            builder: (_, _) => StrategyPendingPage(
              title: 'Comparativos',
              path: AuthMode.staff.strategyComparePath,
              probe: (repo) => repo.compare(),
            ),
          ),
          GoRoute(
            path: 'regions',
            builder: (_, _) => const StrategyRegionsPage(),
          ),
          GoRoute(
            path: 'neighborhoods',
            builder: (_, _) => const StrategyNeighborhoodsPage(),
          ),
          GoRoute(
            path: 'forecasts',
            builder: (_, _) => const StrategyForecastsPage(),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => const StrategyReportsPage(),
          ),
          GoRoute(
            path: 'indicators',
            builder: (_, _) => StrategyPendingPage(
              title: 'Indicadores',
              path: AuthMode.staff.strategyIndicatorsPath,
              probe: (repo) => repo.indicators(),
            ),
          ),
          GoRoute(
            path: 'predictions',
            builder: (_, _) => StrategyPendingPage(
              title: 'Predições',
              path: AuthMode.staff.strategyPredictionsPath,
              probe: (repo) => repo.predictions(),
            ),
          ),
        ],
      ),

      // Central de Automação (Sprint 10.6) — staff only.
      GoRoute(
        path: '/home/automation',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AutomationHubPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, _) => const AutomationDashboardPage(),
          ),
          GoRoute(
            path: 'list',
            builder: (_, _) => const AutomationAutomationsPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => AutomationPendingPage(
                  title: 'Detalhe da automação',
                  path: AuthMode.staff.automationPath(
                    state.pathParameters['id']!,
                  ),
                  probe: (repo) => repo.assertPending(
                    AuthMode.staff.automationPath(state.pathParameters['id']!),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'executions',
            builder: (_, _) => const AutomationExecutionsPage(),
          ),
          GoRoute(
            path: 'approvals',
            builder: (_, _) => AutomationPendingPage(
              title: 'Aprovações',
              path: AuthMode.staff.automationsApprovalsPath,
              probe: (repo) => repo.approvals(),
            ),
          ),
          GoRoute(
            path: 'alerts',
            builder: (_, _) => const AutomationAlertsPage(),
          ),
          GoRoute(
            path: 'agents',
            builder: (_, _) => const AutomationAgentsPage(),
          ),
          GoRoute(
            path: 'schedule',
            builder: (_, _) => AutomationPendingPage(
              title: 'Agenda de execuções',
              path: AuthMode.staff.automationsSchedulePath,
              probe: (repo) => repo.schedule(),
            ),
          ),
          GoRoute(
            path: 'history',
            builder: (_, _) => const AutomationHistoryPage(),
          ),
          GoRoute(path: 'logs', builder: (_, _) => const AutomationLogsPage()),
          GoRoute(
            path: 'metrics',
            builder: (_, _) => const AutomationMetricsPage(),
          ),
          GoRoute(
            path: 'autonomy',
            builder: (_, _) => const AutomationAutonomyPage(),
          ),
          GoRoute(
            path: 'editor',
            builder: (_, _) => const AutomationEditorPage(),
          ),
        ],
      ),

      // Assistente Inteligente (Sprint 10.5) — hub em /home/chat (rota legada).
      GoRoute(
        path: '/home/chat',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ChatPage(),
        routes: [
          GoRoute(
            path: 'gabinete',
            builder: (_, _) => const SmartAssistantGabineteChatPage(),
          ),
          GoRoute(
            path: 'briefings',
            builder: (_, _) => const SmartAssistantBriefingsPage(),
          ),
          GoRoute(
            path: 'summary',
            builder: (_, _) => const SmartAssistantDaySummaryPage(),
            routes: [
              GoRoute(
                path: 'daily',
                builder: (_, _) => const SmartAssistantDaySummaryPage(),
              ),
              GoRoute(
                path: 'weekly',
                builder: (_, _) => SmartAssistantPendingPage(
                  title: 'Resumo semanal',
                  path: AuthMode.staff.mandateSummaryWeeklyPath,
                  probe: (repo) => repo.weeklySummary(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'suggestions',
            builder: (_, _) => SmartAssistantPendingPage(
              title: 'Sugestões',
              path: AuthMode.staff.mandateSuggestionsPath,
              probe: (repo) => repo.suggestions(),
            ),
          ),
          GoRoute(
            path: 'priorities',
            builder: (_, _) => SmartAssistantPendingPage(
              title: 'Prioridades',
              path: AuthMode.staff.mandatePrioritiesPath,
              probe: (repo) => repo.priorities(),
            ),
          ),
          GoRoute(
            path: 'insights',
            builder: (_, _) => const SmartAssistantInsightsPage(),
          ),
          GoRoute(
            path: 'questions',
            builder: (_, _) => SmartAssistantPendingPage(
              title: 'Perguntas ao gabinete',
              path: AuthMode.staff.aiQuestionsPath,
              probe: (repo) => repo.questions(),
            ),
          ),
          GoRoute(
            path: 'history',
            builder: (_, _) => const SmartAssistantHistoryPage(),
          ),
          GoRoute(
            path: 'favorites',
            builder: (_, _) => SmartAssistantPendingPage(
              title: 'Favoritos',
              path: AuthMode.staff.aiFavoritesPath,
              probe: (repo) => repo.favorites(),
            ),
          ),
          GoRoute(
            path: 'share',
            builder: (_, _) => SmartAssistantPendingPage(
              title: 'Compartilhar',
              path: AuthMode.staff.aiSharePath,
              probe: (repo) => repo.share(),
            ),
          ),
        ],
      ),

      // Central de Comunicação (Sprint 10.4) — staff only, PoliGestor.
      GoRoute(
        path: '/home/communication',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const CommunicationHubPage(),
        routes: [
          GoRoute(
            path: 'templates/:id',
            builder: (context, state) => CommunicationTemplateDetailPage(
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'campaigns/:id',
            builder: (context, state) => CommunicationCampaignDetailPage(
              id: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // Equipe Virtual (Sprint 10.1) — acesso via Mais / deep link.
      GoRoute(
        path: '/home/virtual-team',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const VirtualTeamDashboardPage(),
        routes: [
          GoRoute(
            path: 'agents',
            builder: (_, _) => const VirtualTeamAgentsPage(),
            routes: [
              GoRoute(
                path: ':slug',
                builder: (context, state) => VirtualTeamAgentDetailPage(
                  slug: state.pathParameters['slug']!,
                ),
                routes: [
                  GoRoute(
                    path: 'tasks',
                    builder: (context, state) => VirtualTeamTasksPage(
                      agentSlug: state.pathParameters['slug'],
                    ),
                  ),
                  GoRoute(
                    path: 'executions',
                    builder: (context, state) => VirtualTeamExecutionsPage(
                      agentSlug: state.pathParameters['slug'],
                    ),
                  ),
                  GoRoute(
                    path: 'logs',
                    builder: (context, state) => VirtualTeamLogsPage(
                      agentSlug: state.pathParameters['slug'],
                    ),
                  ),
                  GoRoute(
                    path: 'timeline',
                    builder: (context, state) => VirtualTeamTimelinePage(
                      agentSlug: state.pathParameters['slug'],
                    ),
                  ),
                  GoRoute(
                    path: 'metrics',
                    builder: (context, state) => VirtualTeamMetricsPage(
                      agentSlug: state.pathParameters['slug'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'tasks',
            builder: (_, _) => const VirtualTeamTasksPage(),
          ),
          GoRoute(
            path: 'executions',
            builder: (_, _) => const VirtualTeamExecutionsPage(),
          ),
          GoRoute(
            path: 'handoffs',
            builder: (_, _) => const VirtualTeamHandoffsPage(),
          ),
          GoRoute(
            path: 'events',
            builder: (_, _) => const VirtualTeamEventsPage(),
          ),
          GoRoute(
            path: 'memory',
            builder: (_, _) => const VirtualTeamMemoryPage(),
          ),
          GoRoute(
            path: 'learning',
            builder: (_, _) => const VirtualTeamLearningPage(),
          ),
          GoRoute(
            path: 'queue',
            builder: (_, _) => const VirtualTeamQueuePage(),
          ),
          GoRoute(
            path: 'timeline',
            builder: (_, _) => const VirtualTeamTimelinePage(),
          ),
          GoRoute(
            path: 'alerts',
            builder: (_, _) => const VirtualTeamAlertsPage(),
          ),
          GoRoute(
            path: 'metrics',
            builder: (_, _) => const VirtualTeamMetricsPage(),
          ),
          GoRoute(
            path: 'audit',
            builder: (_, _) => const VirtualTeamAuditPage(),
          ),
          GoRoute(path: 'logs', builder: (_, _) => const VirtualTeamLogsPage()),
          GoRoute(
            path: 'search',
            builder: (_, _) => const VirtualTeamSearchPage(),
          ),
        ],
      ),

      // Citizen shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CitizenShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/citizen/home',
                builder: (_, _) => const CitizenHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/citizen/requests',
                builder: (context, state) => CitizenRequestsPage(
                  initialStatusFilter: state.uri.queryParameters['status'],
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) {
                      final extra = state.extra;
                      String? category;
                      if (extra is Map && extra['category'] != null) {
                        category = extra['category'].toString();
                      }
                      return NewRequestPage(initialCategory: category);
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    // Fora do IndexedStack do shell — evita body vazio.
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        RequestDetailPage(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/citizen/notifications',
                builder: (_, _) => const CitizenNotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/citizen/profile',
                builder: (_, _) => const CitizenProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/citizen/chat',
        builder: (context, state) {
          final draft = state.extra is String ? state.extra as String : null;
          return AssistantChatPage(initialDraft: draft);
        },
      ),
      GoRoute(
        path: '/citizen/agenda',
        builder: (context, state) =>
            AgendaPage(focusId: state.uri.queryParameters['focus']),
      ),
      GoRoute(
        path: '/citizen/appointments/detail',
        builder: (context, state) {
          final extra = state.extra;
          final map = extra is Map
              ? Map<String, dynamic>.from(extra)
              : const {};
          return CitizenAppointmentDetailPage(
            title: (map['title'] ?? 'Compromisso').toString(),
            when: map['when']?.toString(),
            location: map['location']?.toString(),
            status: map['status']?.toString(),
            description: map['description']?.toString(),
          );
        },
      ),
      GoRoute(
        path: '/citizen/news',
        builder: (_, _) => const CitizenNewsListPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                CitizenNewsDetailPage(newsId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/citizen/neighborhood',
        builder: (context, state) {
          final extra = state.extra;
          final map = extra is Map
              ? Map<String, dynamic>.from(extra)
              : const {};
          return CitizenNeighborhoodPage(
            neighborhoodLabel: (map['neighborhoodLabel'] ?? 'Sua região')
                .toString(),
            unreadNotifications: (map['unread'] is int)
                ? map['unread'] as int
                : int.tryParse('${map['unread'] ?? 0}') ?? 0,
          );
        },
      ),
    ],
  );
}
