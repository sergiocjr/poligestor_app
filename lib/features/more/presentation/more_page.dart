import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../account/data/account_repository.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../notifications/domain/push_notification_service.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final tenant = context.watch<TenantController>();
    final session = auth.session;

    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        children: [
          if (session != null)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                session.user.name.isEmpty
                    ? session.user.email
                    : session.user.name,
              ),
              subtitle: Text(
                '${session.mode.label} · ${tenant.displayName}\n${session.user.email}',
              ),
              isThreeLine: true,
              onTap: () => context.push('/account/profile'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Meu perfil'),
            onTap: () => context.push('/account/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: const Text('Sessões'),
            subtitle: const Text('Dispositivos ativos'),
            onTap: () => context.push('/account/sessions'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Trocar organização'),
            onTap: () async {
              final push = context.read<PushNotificationService>();
              final account = context.read<AccountRepository>();
              final tenantCtrl = context.read<TenantController>();
              try {
                await push.onLogout();
              } catch (_) {}
              try {
                await account.logoutRemote(mode: auth.mode);
              } catch (_) {}
              await tenantCtrl.clearOrganization();
              await auth.logout();
              if (context.mounted) context.go('/org');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('Assistente Inteligente'),
            subtitle: const Text('Central de IA, chat, resumos e análises'),
            onTap: () => context.push('/home/chat'),
          ),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Equipe Virtual'),
            subtitle: const Text('Agentes, tarefas e operação'),
            onTap: () => context.push('/home/virtual-team'),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('Central de Automação'),
            subtitle: const Text('Automações, aprovações e execução'),
            onTap: () => context.push('/home/automation'),
          ),
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: const Text('Painel Estratégico'),
            subtitle: const Text(
              'Indicadores, mapa de calor, tendências e previsões',
            ),
            onTap: () => context.push('/home/strategy'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text('Painel Parlamentar'),
            subtitle: const Text(
              'Projetos de lei, sessões, votações e demandas',
            ),
            onTap: () => context.push('/home/parliament'),
          ),
          ListTile(
            leading: const Icon(Icons.construction_outlined),
            title: const Text('Painel Obras'),
            subtitle: const Text(
              'Obras, demandas, fiscalizações, mapa e cronograma',
            ),
            onTap: () => context.push('/home/works'),
          ),
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: const Text('Central de Comunicação'),
            subtitle: const Text('Canais, modelos e campanhas'),
            onTap: () => context.push('/home/communication'),
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
          const _SoonTile(icon: Icons.folder_outlined, title: 'Documentos'),
          const _SoonTile(
            icon: Icons.badge_outlined,
            title: 'Carteira Digital',
          ),
          const _SoonTile(icon: Icons.qr_code_scanner, title: 'Scanner QR'),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Mapa do mandato'),
            onTap: () => context.push('/home/mandate/map'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Sair',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              final push = context.read<PushNotificationService>();
              final account = context.read<AccountRepository>();
              try {
                await push.onLogout();
              } catch (_) {}
              try {
                await account.logoutRemote(mode: auth.mode);
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
