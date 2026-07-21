import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/pg_design_system.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../notifications/domain/push_notification_service.dart';
import '../data/account_repository.dart';
import '../../../core/auth/auth_state.dart';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  Future<_ProfileData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_ProfileData> _load() async {
    final auth = context.read<AuthController>();
    final account = context.read<AccountRepository>();
    var user = auth.session!.user;
    String? syncNote;
    try {
      final remote = await account.getProfile(mode: auth.mode);
      user = AuthUser.fromJson({...?user.raw, ...remote});
    } on EndpointUnavailableException {
      syncNote = 'Perfil local — API de perfil indisponível.';
    } catch (_) {
      syncNote = UserMessages.syncFailed;
    }
    List<LinkedAccount> linked = const [];
    try {
      linked = await account.linkedAccounts(mode: auth.mode);
    } on EndpointUnavailableException catch (e) {
      syncNote ??= 'Contas vinculadas indisponíveis (${e.path}).';
    } catch (_) {
      syncNote ??= 'Contas vinculadas não sincronizadas.';
    }
    return _ProfileData(user: user, linked: linked, syncNote: syncNote);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _endSession({required String nextRoute}) async {
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
    if (mounted) context.go(nextRoute);
  }

  Future<void> _logout() => _endSession(nextRoute: '/login');

  Future<void> _switchOrg() async {
    final tenant = context.read<TenantController>();
    await tenant.clearOrganization();
    await _endSession(nextRoute: '/org');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final tenant = context.watch<TenantController>();
    final session = auth.session;

    if (session == null) {
      return const Scaffold(
        body: AppEmptyState(message: 'Faça login para ver o perfil.'),
      );
    }

    return Scaffold(
      appBar: PgStandardAppBar(
        title: 'Meu perfil',
        onRefresh: _refresh,
      ),
      body: FutureBuilder<_ProfileData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 96, radius: 48),
                SizedBox(height: 16),
                SkeletonBox(height: 140, radius: 16),
              ],
            );
          }
          if (snap.hasError && !snap.hasData) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          final data = snap.data!;
          final user = data.user;
          final phone = user.phone?.trim();
          final doc = user.maskedDocument;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                if (data.syncNote != null) ...[
                  SoftNotice(message: data.syncNote!),
                  const SizedBox(height: 12),
                ],
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
                            maxLines: 3,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(user.email, maxLines: 2, softWrap: true),
                          Text(
                            tenant.displayName,
                            maxLines: 2,
                            softWrap: true,
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
                        subtitle: Text(
                          (doc != null && doc.isNotEmpty)
                              ? doc
                              : 'Não informado',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('Telefone'),
                        subtitle: Text(
                          (phone != null && phone.isNotEmpty)
                              ? phone
                              : 'Não informado',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.workspace_premium_outlined),
                        title: const Text('Perfil'),
                        subtitle: Text(user.role ?? session.mode.label),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Contas vinculadas',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (data.linked.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text('Nenhuma conta vinculada retornada.'),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final a in data.linked)
                          ListTile(
                            leading: const Icon(Icons.link),
                            title: Text(a.label, maxLines: 2, softWrap: true),
                            subtitle: Text(
                              a.email ?? a.provider,
                              maxLines: 2,
                              softWrap: true,
                            ),
                            trailing: PgStatusChip(
                              label: a.linked ? 'Vinculada' : '—',
                              tone: a.linked
                                  ? PgStatusTone.success
                                  : PgStatusTone.neutral,
                              compact: true,
                            ),
                          ),
                      ],
                    ),
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
        },
      ),
    );
  }
}

class _ProfileData {
  const _ProfileData({
    required this.user,
    required this.linked,
    this.syncNote,
  });

  final AuthUser user;
  final List<LinkedAccount> linked;
  final String? syncNote;
}
