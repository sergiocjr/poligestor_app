import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../notifications/domain/push_notification_service.dart';
import '../data/account_repository.dart';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  Future<List<LinkedAccount>>? _linkedFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _linkedFuture ??= _loadLinked();
  }

  Future<List<LinkedAccount>> _loadLinked() {
    final auth = context.read<AuthController>();
    return context.read<AccountRepository>().linkedAccounts(mode: auth.mode);
  }

  Future<void> _logout() async {
    final push = context.read<PushNotificationService>();
    final auth = context.read<AuthController>();
    final account = context.read<AccountRepository>();
    try {
      await push.onLogout();
    } catch (_) {}
    try {
      await account.logoutRemote(mode: auth.mode);
    } catch (_) {}
    await auth.logout();
    if (mounted) context.go('/login');
  }

  Future<void> _switchOrg() async {
    final tenant = context.read<TenantController>();
    await tenant.clearOrganization();
    await _logout();
    if (mounted) context.go('/org');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final tenant = context.watch<TenantController>();
    final session = auth.session;
    final user = session?.user;

    if (user == null) {
      return const Scaffold(
        body: AppEmptyState(message: 'Faça login para ver o perfil.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                child: Text(
                  user.firstName.isEmpty
                      ? '?'
                      : user.firstName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(user.email),
                    Text(
                      tenant.displayName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('CPF'),
                  subtitle: Text(user.maskedDocument ?? 'Não informado'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Telefone'),
                  subtitle: Text(
                    user.raw?['phone']?.toString() ?? 'Não informado',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: const Text('Perfil'),
                  subtitle: Text(user.role ?? session!.mode.label),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Contas vinculadas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          FutureBuilder<List<LinkedAccount>>(
            future: _linkedFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done &&
                  !snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                final err = snap.error;
                if (err is EndpointUnavailableException) {
                  return EndpointPendingState(path: err.path);
                }
                return AppErrorState(
                  error: err,
                  message: UserMessages.fromError(err),
                );
              }
              final items = snap.data ?? const [];
              if (items.isEmpty) {
                return const ListTile(
                  title: Text('Nenhuma conta vinculada retornada pela API.'),
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (final a in items)
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: Text(a.label),
                        subtitle: Text(a.email ?? a.provider),
                        trailing: Text(a.linked ? 'Vinculada' : '—'),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: const Text('Sessões'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/account/sessions'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Alterar senha'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/login/forgot'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Trocar organização'),
            onTap: _switchOrg,
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _logout,
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
