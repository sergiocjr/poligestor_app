import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../notifications/data/notifications_repository.dart';

class CitizenNotificationsPage extends StatefulWidget {
  const CitizenNotificationsPage({super.key});

  @override
  State<CitizenNotificationsPage> createState() =>
      _CitizenNotificationsPageState();
}

class _CitizenNotificationsPageState extends State<CitizenNotificationsPage> {
  Future<List<AppNotification>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<AppNotification>> _load() {
    final auth = context.read<AuthController>();
    return context.read<NotificationsRepository>().list(mode: auth.mode);
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  IconData _icon(IconDataForNotification kind) => switch (kind) {
        IconDataForNotification.chat => Icons.mark_chat_unread_rounded,
        IconDataForNotification.status => Icons.sync_alt_rounded,
        IconDataForNotification.help => Icons.help_outline_rounded,
        IconDataForNotification.done => Icons.check_circle_outline_rounded,
        IconDataForNotification.star => Icons.star_outline_rounded,
        IconDataForNotification.bell => Icons.notifications_none_rounded,
      };

  Future<void> _open(AppNotification n) async {
    final auth = context.read<AuthController>();
    if (n.isUnread) {
      try {
        await context
            .read<NotificationsRepository>()
            .markRead(mode: auth.mode, id: n.id);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UserMessages.syncFailed)),
        );
      }
    }

    final protocolId = n.protocolId;
    if (protocolId != null && protocolId.isNotEmpty && mounted) {
      await context.push('/citizen/requests/$protocolId');
      if (mounted) await _reload();
      return;
    }

    if (mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM HH:mm');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                SkeletonBox(height: 80, radius: 18),
                SizedBox(height: 12),
                SkeletonBox(height: 80, radius: 18),
              ],
            );
          }
          if (snapshot.hasError) {
            return AppErrorState(error: snapshot.error, onRetry: _reload);
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(
              message: UserMessages.emptyNotifications,
              icon: Icons.notifications_none_rounded,
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = items[index];
                return Card(
                  color: n.isUnread
                      ? scheme.primaryContainer.withValues(alpha: 0.28)
                      : null,
                  child: ListTile(
                    leading: Icon(
                      n.isUnread
                          ? Icons.notifications_active_rounded
                          : _icon(n.kindIcon),
                      color: n.isUnread ? scheme.primary : null,
                    ),
                    title: Text(
                      n.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            n.isUnread ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      [
                        n.kindLabel,
                        if (n.body != null) n.body!,
                        if (n.createdAt != null)
                          dateFmt.format(n.createdAt!.toLocal()),
                      ].join('\n'),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: n.protocolId != null
                        ? const Icon(Icons.chevron_right_rounded)
                        : null,
                    onTap: () => _open(n),
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
