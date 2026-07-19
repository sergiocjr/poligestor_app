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
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notificações'),
          ),
          const ListTile(
            leading: Icon(Icons.folder_outlined),
            title: Text('Documentos'),
          ),
          const ListTile(
            leading: Icon(Icons.badge_outlined),
            title: Text('Carteira Digital'),
          ),
          const ListTile(
            leading: Icon(Icons.qr_code_scanner),
            title: Text('Scanner QR'),
          ),
          const ListTile(
            leading: Icon(Icons.map_outlined),
            title: Text('Mapa'),
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
