import 'package:flutter/foundation.dart';
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
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Segurança e Privacidade'),
            subtitle: const Text(
              'Autenticação, privacidade, dados e alertas',
            ),
            onTap: () => context.push('/home/security'),
          ),
          ListTile(
            leading: const Icon(Icons.hub_outlined),
            title: const Text('Central de Integrações'),
            subtitle: const Text(
              'Gov.br, calendários, canais, webhooks e sincronizações',
            ),
            onTap: () => context.push('/home/integrations'),
          ),
          ListTile(
            leading: const Icon(Icons.newspaper_outlined),
            title: const Text('Notícias regionais'),
            subtitle: const Text(
              'Feed, menções, favoritos e alertas',
            ),
            onTap: () => context.push('/home/news'),
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
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('IA Avançada'),
            subtitle: const Text(
              'Agentes especializados, resumos, prompts e avaliação',
            ),
            onTap: () => context.push('/home/advanced-ai'),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Administração do Sistema'),
            subtitle: const Text(
              'Empresas, usuários, permissões, auditoria e configurações',
            ),
            onTap: () => context.push('/home/system-admin'),
          ),
          if (kIsWeb)
            ListTile(
              leading: const Icon(Icons.public_outlined),
              title: const Text('Portal administrativo'),
              subtitle: const Text(
                'Gestão da plataforma, cobrança, operação e suporte',
              ),
              onTap: () => context.push('/platform'),
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
            leading: const Icon(Icons.handshake_outlined),
            title: const Text('Painel de Convênios'),
            subtitle: const Text(
              'Convênios, recursos, execução e prestação de contas',
            ),
            onTap: () => context.push('/home/agreements'),
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('Painel de Eventos'),
            subtitle: const Text(
              'Agenda, calendário, audiências, reuniões e presença',
            ),
            onTap: () => context.push('/home/events'),
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote_outlined),
            title: const Text('Gestão Eleitoral'),
            subtitle: const Text(
              'Campanhas, candidatos, zonas, pesquisas e prestação de contas',
            ),
            onTap: () => context.push('/home/elections'),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('CRM Político'),
            subtitle: const Text(
              'Líderes, apoiadores, eleitores, visitas e relacionamento',
            ),
            onTap: () => context.push('/home/crm'),
          ),
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: const Text('Comunicação Institucional'),
            subtitle: const Text(
              'Notícias, comunicados, campanhas, mídia e canais',
            ),
            onTap: () => context.push('/home/institutional-communication'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Gestão Financeira'),
            subtitle: const Text(
              'Painel, orçamento, fluxo de caixa e prestação de contas',
            ),
            onTap: () => context.push('/home/finance'),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Gestão Documental'),
            subtitle: const Text(
              'Documentos, PDF, assinaturas, aprovações e anexos',
            ),
            onTap: () => context.push('/home/documents'),
          ),
          ListTile(
            leading: const Icon(Icons.travel_explore_outlined),
            title: const Text('Inteligência Territorial'),
            subtitle: const Text(
              'Painel BI, mapas, bairros, tendências e projeções',
            ),
            onTap: () => context.push('/home/territorial-intelligence'),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Recursos adicionais',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _SoonTile(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            onTap: () => _showDemoSheet(context, 'Notificações',
                'Central de alertas com exemplos de menções, prazos e atualizações.'),
          ),
          _SoonTile(
            icon: Icons.badge_outlined,
            title: 'Carteira Digital',
            onTap: () => _showDemoSheet(context, 'Carteira Digital',
                'Documentos digitais de exemplo: identificação, credencial e comprovantes.'),
          ),
          _SoonTile(
            icon: Icons.qr_code_scanner,
            title: 'Scanner QR',
            onTap: () => _showDemoSheet(context, 'Scanner QR',
                'Simulação de leitura de QR Code para check-in em eventos.'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Concentração por bairro'),
            subtitle: const Text('Mapa do mandato'),
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
  const _SoonTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: const Text('Ver demonstração'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

void _showDemoSheet(BuildContext context, String title, String body) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(body),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    ),
  );
}
