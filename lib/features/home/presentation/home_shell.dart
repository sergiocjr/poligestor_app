import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Shell staff (Gabinete) — tela cheia sob a status bar; AppBar cuida do inset.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_ShellDest>[
    _ShellDest(Icons.dashboard_outlined, Icons.dashboard, 'Gabinete'),
    _ShellDest(Icons.assignment_outlined, Icons.assignment, 'Protocolos'),
    _ShellDest(Icons.event_outlined, Icons.event, 'Agenda'),
    _ShellDest(Icons.account_balance_outlined, Icons.account_balance, 'Mandato'),
    _ShellDest(Icons.more_horiz, Icons.more_horiz, 'Mais'),
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
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final barHeight = (compact ? 56.0 : 62.0) * textScale.clamp(1.0, 1.35);
    final scheme = Theme.of(context).colorScheme;
    final overlay =
        Theme.of(context).appBarTheme.systemOverlayStyle ??
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        // Sem SafeArea no body: o AppBar das páginas ocupa a área sob a status bar.
        body: navigationShell,
        bottomNavigationBar: Material(
          elevation: 0,
          color: Colors.white,
          shadowColor: Colors.black26,
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
                height: barHeight,
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
      child: Semantics(
        button: true,
        selected: selected,
        label: dest.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? dest.selectedIcon : dest.icon,
                size: compact ? 22 : 24,
                color: color,
              ),
              const SizedBox(height: 3),
              Text(
                dest.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
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
      ),
    );
  }
}
