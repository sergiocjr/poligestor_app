import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/demo/demo_experience_pane.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/pg_design_system.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../data/account_repository.dart';

/// Sessões ativas — consome `GET /v1/auth/sessions` (staff LIVE).
class AccountSessionsPage extends StatefulWidget {
  const AccountSessionsPage({super.key});

  @override
  State<AccountSessionsPage> createState() => _AccountSessionsPageState();
}

class _AccountSessionsPageState extends State<AccountSessionsPage> {
  Future<List<AuthSessionInfo>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<AuthSessionInfo>> _load() {
    final auth = context.read<AuthController>();
    return context.read<AccountRepository>().sessions(mode: auth.mode);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _revoke(AuthSessionInfo s) async {
    final auth = context.read<AuthController>();
    try {
      await context.read<AccountRepository>().revokeSession(
        mode: auth.mode,
        sessionId: s.sessionId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão revogada.')),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserMessages.fromError(e))),
      );
    }
  }

  Future<void> _revokeAll() async {
    final auth = context.read<AuthController>();
    try {
      await context.read<AccountRepository>().revokeAllSessions(
        mode: auth.mode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessões revogadas.')),
      );
      await auth.logout();
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      await pgShowStandardBottomSheet<void>(
        context: context,
        title: 'Indisponível',
        child: DemoExperiencePane(path: e.path),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserMessages.fromError(e))),
      );
    }
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/'
        '${l.month.toString().padLeft(2, '0')}/${l.year} '
        '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PgStandardAppBar(
        title: 'Sessões',
        onRefresh: _refresh,
        actions: [
          IconButton(
            tooltip: 'Sair de todos os dispositivos',
            onPressed: _revokeAll,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<AuthSessionInfo>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 88, radius: 16),
                SizedBox(height: 10),
                SkeletonBox(height: 88, radius: 16),
              ],
            );
          }
          if (snap.hasError && !snap.hasData) {
            final err = snap.error;
            if (err is EndpointUnavailableException) {
              return DemoExperiencePane(path: err.path);
            }
            return AppErrorState(
              error: err,
              message: UserMessages.fromError(err),
              onRetry: _refresh,
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Nenhuma sessão encontrada.');
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final s = items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.devices_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.deviceName,
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (s.isCurrent)
                              const PgStatusChip(
                                label: 'Atual',
                                tone: PgStatusTone.success,
                                compact: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _SessionRow(
                          label: 'Sistema',
                          value: s.platform ?? '—',
                        ),
                        _SessionRow(
                          label: 'IP',
                          value: s.ip ?? '—',
                        ),
                        _SessionRow(
                          label: 'Último acesso',
                          value: _fmt(s.lastUsedAt ?? s.createdAt),
                        ),
                        if (s.location != null && s.location!.isNotEmpty)
                          _SessionRow(label: 'Local', value: s.location!),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _revoke(s),
                            icon: const Icon(Icons.block),
                            label: const Text('Revogar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 3,
              softWrap: true,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
