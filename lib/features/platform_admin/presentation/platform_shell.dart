import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/widgets/app_states.dart';
import 'platform_pages.dart';

/// Shell do Portal Administrativo Web — NavigationRail (≥900) ou gaveta (<900).
class PlatformShell extends StatelessWidget {
  const PlatformShell({super.key, required this.child});

  final Widget child;

  static const _groups = <_NavGroup>[
    _NavGroup('Visão geral', Icons.dashboard_outlined, '/platform'),
    _NavGroup('Organização', Icons.business_outlined, '/platform/companies'),
    _NavGroup('Cobrança', Icons.payments_outlined, '/platform/plans'),
    _NavGroup('Operação', Icons.monitor_heart_outlined, '/platform/metrics'),
    _NavGroup('Suporte', Icons.support_agent_outlined, '/platform/support'),
    _NavGroup('Relatórios', Icons.summarize_outlined, '/platform/reports'),
  ];

  int _selectedIndex(String loc) {
    for (var i = _groups.length - 1; i >= 0; i--) {
      final g = _groups[i];
      if (loc == g.route || loc.startsWith('${g.route}/')) return i;
    }
    if (loc.startsWith('/platform/')) {
      for (var i = 0; i < _groups.length; i++) {
        final prefix = _groups[i].route.replaceFirst('/platform', '');
        if (prefix.isNotEmpty && loc.contains(prefix.substring(1))) {
          return i;
        }
      }
    }
    return 0;
  }

  String _pageTitle(String loc) {
    if (loc == '/platform' || loc == '/platform/') {
      return 'Visão geral';
    }
    final slug = loc.split('/').last;
    return platformSlugTitles[slug] ?? 'Portal administrativo';
  }

  void _goGroup(BuildContext context, int index) {
    context.go(_groups[index].route);
    if (Scaffold.maybeOf(context)?.hasDrawer == true) {
      Navigator.of(context).pop();
    }
  }

  Widget _rail(BuildContext context, int selected) {
    final scheme = Theme.of(context).colorScheme;
    return NavigationRail(
      extended: MediaQuery.sizeOf(context).width >= 1100,
      selectedIndex: selected,
      onDestinationSelected: (i) => _goGroup(context, i),
      labelType: NavigationRailLabelType.none,
      leading: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Icon(Icons.admin_panel_settings_outlined, color: scheme.primary),
      ),
      destinations: [
        for (final g in _groups)
          NavigationRailDestination(
            icon: Icon(g.icon),
            label: Text(g.label),
          ),
      ],
    );
  }

  Widget _drawer(BuildContext context, int selected) {
    return NavigationDrawer(
      selectedIndex: selected,
      onDestinationSelected: (i) => _goGroup(context, i),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 8),
          child: Text(
            'Portal administrativo',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        for (var i = 0; i < _groups.length; i++)
          NavigationDrawerDestination(
            icon: Icon(_groups[i].icon),
            label: Text(_groups[i].label),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final selected = _selectedIndex(loc);
    final auth = context.watch<AuthController>();
    final session = auth.session;
    final userName = session?.user.name.isNotEmpty == true
        ? session!.user.name
        : (session?.user.email ?? 'Operador');
    final role = session?.user.role;
    final roleLabel = role != null && role.isNotEmpty
        ? 'Perfil: $role'
        : 'Sem perfil';
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final title = _pageTitle(loc);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          userName,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          roleLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final notice = SoftNotice(
      message: role == null || role.isEmpty
          ? 'Acesso conforme o perfil do operador. Sem perfil associado — '
              'visualização limitada ao hub. Contratos de permissões em '
              '/v1/platform/permissions.'
          : 'Acesso conforme o perfil do operador. Contratos de permissões '
              'em /v1/platform/permissions.',
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        notice,
        const SizedBox(height: 8),
        Expanded(child: child),
      ],
    );

    if (wide) {
      return Scaffold(
        appBar: AppBar(
          title: header,
          actions: [
            IconButton(
              tooltip: 'Voltar ao gabinete',
              icon: const Icon(Icons.home_outlined),
              onPressed: () => context.go('/home/dashboard'),
            ),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _rail(context, selected),
            const VerticalDivider(width: 1),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: header,
        actions: [
          IconButton(
            tooltip: 'Voltar ao gabinete',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home/dashboard'),
          ),
        ],
      ),
      drawer: _drawer(context, selected),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: content,
        ),
      ),
    );
  }
}

class _NavGroup {
  const _NavGroup(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
