import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../notifications/domain/notifications_controller.dart';

class CitizenShell extends StatelessWidget {
  const CitizenShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationsController>().unreadCount;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 400;
    final scheme = Theme.of(context).colorScheme;
    final overlay =
        Theme.of(context).appBarTheme.systemOverlayStyle ??
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        );

    final items =
        <({IconData icon, IconData selected, String label, Widget? badge})>[
          (
            icon: Icons.home_outlined,
            selected: Icons.home_rounded,
            label: 'Início',
            badge: null,
          ),
          (
            icon: Icons.assignment_outlined,
            selected: Icons.assignment_rounded,
            label: 'Pedidos',
            badge: null,
          ),
          (
            icon: Icons.notifications_outlined,
            selected: Icons.notifications_rounded,
            label: 'Avisos',
            badge: unread > 0
                ? Badge(
                    label: Text(unread > 99 ? '99+' : '$unread'),
                    child: Icon(
                      navigationShell.currentIndex == 2
                          ? Icons.notifications_rounded
                          : Icons.notifications_outlined,
                    ),
                  )
                : null,
          ),
          (
            icon: Icons.person_outline_rounded,
            selected: Icons.person_rounded,
            label: 'Perfil',
            badge: null,
          ),
        ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        // Início do cidadão não usa AppBar — SafeArea só no conteúdo da página.
        body: navigationShell,
        bottomNavigationBar: Material(
          color: Colors.white,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: compact ? 56 : 62,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: InkWell(
                          onTap: () => _onTap(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (items[i].badge != null)
                                  IconTheme(
                                    data: IconThemeData(
                                      size: compact ? 22 : 24,
                                      color: navigationShell.currentIndex == i
                                          ? scheme.primary
                                          : scheme.onSurfaceVariant,
                                    ),
                                    child: items[i].badge!,
                                  )
                                else
                                  Icon(
                                    navigationShell.currentIndex == i
                                        ? items[i].selected
                                        : items[i].icon,
                                    size: compact ? 22 : 24,
                                    color: navigationShell.currentIndex == i
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant,
                                  ),
                                const SizedBox(height: 3),
                                Text(
                                  items[i].label,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: compact ? 10 : 11,
                                    height: 1.0,
                                    fontWeight:
                                        navigationShell.currentIndex == i
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: navigationShell.currentIndex == i
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
