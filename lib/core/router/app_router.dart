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

      if (isSplash || isLoginFlow || isOrg) {
        return auth.mode == AuthMode.portal
            ? '/citizen/home'
            : '/home/protocols';
      }

      if (auth.mode == AuthMode.portal && isStaffPath) {
        return '/citizen/home';
      }
      if (auth.mode == AuthMode.staff && isCitizenPath) {
        return '/home/protocols';
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
              isAgreementsPath) &&
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
              GoRoute(
                path: '/home/intelligence',
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
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home/more', builder: (_, _) => const MorePage()),
            ],
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
