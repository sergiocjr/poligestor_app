import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_mode.dart';
import '../../features/agenda/presentation/agenda_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../../features/citizen/presentation/citizen_chat_page.dart';
import '../../features/citizen/presentation/citizen_home_page.dart';
import '../../features/citizen/presentation/citizen_notifications_page.dart';
import '../../features/citizen/presentation/citizen_profile_page.dart';
import '../../features/citizen/presentation/citizen_requests_page.dart';
import '../../features/citizen/presentation/citizen_shell.dart';
import '../../features/citizen/presentation/new_request_page.dart';
import '../../features/citizen/presentation/request_detail_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/more/presentation/more_page.dart';
import '../../features/protocols/presentation/protocol_detail_page.dart';
import '../../features/protocols/presentation/protocols_page.dart';

GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
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
                path: '/home/chat',
                builder: (_, _) => const ChatPage(),
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
                builder: (_, _) => const CitizenRequestsPage(),
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
        builder: (_, _) => const CitizenChatPage(),
      ),
    ],
  );
}
