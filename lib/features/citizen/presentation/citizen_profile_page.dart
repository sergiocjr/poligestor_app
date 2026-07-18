import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config.dart';
import '../../../shared/widgets/ui_kit.dart';

class CitizenProfilePage extends StatelessWidget {
  const CitizenProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final session = auth.session;
    final user = session?.user;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (auth.apiDegraded) ...[
            const ApiDegradedBanner(),
            const SizedBox(height: 12),
          ],
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: scheme.primary.withValues(alpha: 0.15),
              child: Icon(Icons.person, size: 42, color: scheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? 'Cidadão',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.domain),
            title: const Text('Organização'),
            subtitle: Text(user?.tenantName ?? session?.tenantSlug ?? '—'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_city_outlined),
            title: const Text('Meu bairro'),
            subtitle: Text(user?.neighborhoodLabel ?? '—'),
          ),
          if (user?.document != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Documento'),
              subtitle: Text(user!.document!),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('API'),
            subtitle: Text(AppConfig.apiBaseUrl),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
