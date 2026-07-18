import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final session = auth.session;

    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        children: [
          if (session != null)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(session.user.name.isEmpty
                  ? session.user.email
                  : session.user.name),
              subtitle: Text(
                '${session.mode.label} · ${session.tenantSlug}\n${session.user.email}',
              ),
              isThreeLine: true,
            ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notificações'),
            subtitle: Text('Sprint 2'),
          ),
          const ListTile(
            leading: Icon(Icons.folder_outlined),
            title: Text('Documentos'),
            subtitle: Text('Sprint 3'),
          ),
          const ListTile(
            leading: Icon(Icons.badge_outlined),
            title: Text('Carteira Digital'),
            subtitle: Text('Sprint 4'),
          ),
          const ListTile(
            leading: Icon(Icons.qr_code_scanner),
            title: Text('Scanner QR'),
            subtitle: Text('Sprint 4'),
          ),
          const ListTile(
            leading: Icon(Icons.map_outlined),
            title: Text('Mapa'),
            subtitle: Text('Sprint 4'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('API'),
            subtitle: Text(AppConfig.apiBaseUrl),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Sair',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
