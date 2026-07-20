import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell staff (Gabinete) com barra inferior adaptada a telas estreitas (A10).
///
/// Usa barra própria (não [NavigationBar] Material) para forçar rótulos em
/// **uma linha** e eliminar overflow em ~360 dp de largura.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_ShellDest>[
    _ShellDest(
      Icons.dashboard_outlined,
      Icons.dashboard,
      'Gabinete',
    ),
    _ShellDest(
      Icons.assignment_outlined,
      Icons.assignment,
      'Protocolos',
    ),
    _ShellDest(
      Icons.event_outlined,
      Icons.event,
      'Agenda',
    ),
    _ShellDest(
      Icons.account_balance_outlined,
      Icons.account_balance,
      'Mandato',
    ),
    _ShellDest(
      Icons.more_horiz,
      Icons.more_horiz,
      'Mais',
    ),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 400;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: navigationShell,
      ),
      bottomNavigationBar: Material(
        elevation: 3,
        color: scheme.surfaceContainer,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: compact ? 58 : 64,
            child: Row(
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  Expanded(
                    child: _ShellNavItem(
                      dest: _destinations[i],
                      selected: navigationShell.currentIndex == i,
                      compact: compact,
                      onTap: () => _onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellDest {
  const _ShellDest(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _ShellNavItem extends StatelessWidget {
  const _ShellNavItem({
    required this.dest,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final _ShellDest dest;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? dest.selectedIcon : dest.icon,
              size: compact ? 22 : 24,
              color: color,
            ),
            SizedBox(height: compact ? 2 : 4),
            Text(
              dest.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                height: 1.0,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
