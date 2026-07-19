import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../notifications/domain/push_notification_service.dart';

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
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('Chat IA'),
            onTap: () => context.push('/home/chat'),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Inteligência'),
            onTap: () => context.go('/home/intelligence'),
          ),
          const Divider(),
          const _SoonTile(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
          ),
          const _SoonTile(
            icon: Icons.folder_outlined,
            title: 'Documentos',
          ),
          const _SoonTile(
            icon: Icons.badge_outlined,
            title: 'Carteira Digital',
          ),
          const _SoonTile(
            icon: Icons.qr_code_scanner,
            title: 'Scanner QR',
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Mapa do mandato'),
            onTap: () => context.push('/home/mandate/map'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Sair',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              try {
                await context.read<PushNotificationService>().onLogout();
              } catch (_) {}
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _SoonTile extends StatelessWidget {
  const _SoonTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: false,
      leading: Icon(icon),
      title: Text(title),
      subtitle: const Text('Em breve'),
    );
  }
}
