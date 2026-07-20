import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sessão revogada.')));
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(UserMessages.fromError(e))));
    }
  }

  Future<void> _revokeAll() async {
    final auth = context.read<AuthController>();
    try {
      await context.read<AccountRepository>().revokeAllSessions(
        mode: auth.mode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sessões revogadas.')));
      await auth.logout();
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Indisponível'),
          content: EndpointPendingState(path: e.path),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(UserMessages.fromError(e))));
    }
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/'
        '${l.month.toString().padLeft(2, '0')} '
        '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessões'),
        actions: [
          IconButton(
            tooltip: 'Sair de todos os dispositivos',
            onPressed: _revokeAll,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<AuthSessionInfo>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && !snap.hasData) {
            final err = snap.error;
            if (err is EndpointUnavailableException) {
              return EndpointPendingState(path: err.path);
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
                  child: ListTile(
                    leading: const Icon(Icons.devices_outlined),
                    title: Text(s.deviceName),
                    subtitle: Text(
                      [
                        if (s.platform != null) s.platform!,
                        if (s.ip != null) 'IP ${s.ip}',
                        if (s.location != null) s.location!,
                        'Último acesso: ${_fmt(s.lastUsedAt)}',
                        if (s.hasRefresh) 'Atualização ativa',
                      ].join('\n'),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Revogar',
                      onPressed: () => _revoke(s),
                      icon: const Icon(Icons.block),
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
