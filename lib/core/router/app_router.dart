import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_mode.dart';
import '../../features/agenda/presentation/agenda_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/chat/presentation/chat_page.dart';
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
import '../../features/more/presentation/more_page.dart';
import '../../features/protocols/presentation/protocol_detail_page.dart';
import '../../features/protocols/presentation/protocols_page.dart';

/// Navigator raiz — detalhes de solicitação sobem acima do CitizenShell
/// para não cair no IndexedStack da aba (tela branca com AppBar/nav).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final booting = auth.isBooting;
      final loggedIn = auth.isAuthenticated;
      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final isLogin = loc == '/login';

      if (booting) return isSplash ? null : '/splash';
      if (!loggedIn) return isLogin ? null : '/login';

      final isCitizenPath = loc.startsWith('/citizen');
      final isStaffPath = loc.startsWith('/home');
      final isMandatePath = loc.startsWith('/home/mandate');
      final isIntelPath = loc.startsWith('/home/intelligence');

      if (isSplash || isLogin) {
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
      // Mandato / Inteligência exclusivos de staff.
      if ((isMandatePath || isIntelPath) && auth.mode != AuthMode.staff) {
        return '/citizen/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),

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
                    builder: (context, state) => ProtocolDetailPage(
                      id: state.pathParameters['id']!,
                    ),
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
                  GoRoute(
                    path: 'tv',
                    builder: (_, _) => const MandateTvPage(),
                  ),
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
                    builder: (_, _) => const IntelligenceInsightsPage(
                      opportunitiesOnly: true,
                    ),
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
              GoRoute(
                path: '/home/more',
                builder: (_, _) => const MorePage(),
              ),
            ],
          ),
        ],
      ),

      // Chat IA fora do bottom bar (acesso via Mais).
      GoRoute(
        path: '/home/chat',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ChatPage(),
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
                    builder: (context, state) => RequestDetailPage(
                      id: state.pathParameters['id']!,
                    ),
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
        builder: (context, state) => AgendaPage(
          focusId: state.uri.queryParameters['focus'],
        ),
      ),
      GoRoute(
        path: '/citizen/appointments/detail',
        builder: (context, state) {
          final extra = state.extra;
          final map =
              extra is Map ? Map<String, dynamic>.from(extra) : const {};
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
            builder: (context, state) => CitizenNewsDetailPage(
              newsId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/citizen/neighborhood',
        builder: (context, state) {
          final extra = state.extra;
          final map =
              extra is Map ? Map<String, dynamic>.from(extra) : const {};
          return CitizenNeighborhoodPage(
            neighborhoodLabel:
                (map['neighborhoodLabel'] ?? 'Sua região').toString(),
            unreadNotifications: (map['unread'] is int)
                ? map['unread'] as int
                : int.tryParse('${map['unread'] ?? 0}') ?? 0,
          );
        },
      ),
    ],
  );
}
