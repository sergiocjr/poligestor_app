import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../notifications/data/push_payload.dart';
import '../../notifications/domain/notification_router.dart';
import '../../notifications/domain/notifications_controller.dart';
import '../../protocols/data/protocol_navigation.dart';

class CitizenNotificationsPage extends StatefulWidget {
  const CitizenNotificationsPage({super.key});

  @override
  State<CitizenNotificationsPage> createState() =>
      _CitizenNotificationsPageState();
}

class _CitizenNotificationsPageState extends State<CitizenNotificationsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ctrl = context.read<NotificationsController>();
    if (!ctrl.loadedOnce && !ctrl.loading) {
      // ignore: discarded_futures
      ctrl.refresh();
    }
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
    final payload = PushPayload(
      type: switch (n.kind) {
        NotificationKind.newReply => PushEventType.protocolMessage,
        NotificationKind.infoRequest =>
          PushEventType.protocolInformationRequested,
        NotificationKind.statusChange => PushEventType.protocolStatusChanged,
        NotificationKind.resolved => PushEventType.protocolResolved,
        NotificationKind.ratingAvailable =>
          PushEventType.protocolRatingAvailable,
        NotificationKind.generic => PushEventType.systemNotice,
      },
      protocolId: n.protocolId,
      protocolNumber: n.protocolNumber,
      link: n.link,
      title: n.title,
      body: n.body,
      notificationId: '${n.id}',
    );

    final route = const NotificationRouter().resolve(payload);
    final target = ProtocolNavigationTarget.resolve(
      protocolId: n.protocolId,
      protocolNumber: n.protocolNumber,
      link: n.link,
    );

    if (kDebugMode) {
      debugPrint(
        '[Avisos] open type=${n.kind.name} '
        'route=${route?.location} protocol=${target?.protocolId}',
      );
    }

    if (route == null ||
        (route.location.startsWith('/citizen/requests/') && target == null)) {
      if (!mounted) return;
      if (n.kind == NotificationKind.generic &&
          (n.protocolId == null && n.link == null)) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UserMessages.notificationWithoutProtocol)),
      );
      return;
    }

    bool openedOk = false;
    try {
      if (route.location == '/citizen/notifications') {
        openedOk = true;
      } else {
        final result = await context.push<bool>(route.location);
        openedOk = result == true;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserMessages.forProtocolError(e))),
      );
      return;
    }

    if (!mounted || !openedOk) return;

    final ctrl = context.read<NotificationsController>();
    if (n.isUnread) {
      final ok = await ctrl.markRead(n.id);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(UserMessages.notificationMarkReadFailed),
          ),
        );
      }
    }
    await ctrl.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NotificationsController>();
    final dateFmt = DateFormat('dd/MM HH:mm');
    final scheme = Theme.of(context).colorScheme;
    final items = ctrl.visibleItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        actions: [
          IconButton(
            onPressed: ctrl.loading ? null : () => ctrl.refresh(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                for (final f in NotificationFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(switch (f) {
                        NotificationFilter.all => 'Todas',
                        NotificationFilter.messages => 'Mensagens',
                        NotificationFilter.requests => 'Solicitações',
                        NotificationFilter.notices => 'Avisos',
                      }),
                      selected: ctrl.filter == f,
                      onSelected: (_) => ctrl.setFilter(f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildBody(ctrl, items, dateFmt, scheme)),
        ],
      ),
    );
  }

  Widget _buildBody(
    NotificationsController ctrl,
    List<AppNotification> items,
    DateFormat dateFmt,
    ColorScheme scheme,
  ) {
    if (ctrl.loading && !ctrl.loadedOnce) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SkeletonBox(height: 80, radius: 18),
          SizedBox(height: 12),
          SkeletonBox(height: 80, radius: 18),
        ],
      );
    }
    if (ctrl.error != null && items.isEmpty) {
      return AppErrorState(
        message: UserMessages.fromError(ctrl.error),
        error: ctrl.error,
        onRetry: ctrl.refresh,
      );
    }
    if (items.isEmpty) {
      return const AppEmptyState(
        message: UserMessages.emptyNotifications,
        icon: Icons.notifications_none_rounded,
      );
    }
    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final n = items[index];
          final canOpen = ProtocolNavigationTarget.resolve(
                protocolId: n.protocolId,
                protocolNumber: n.protocolNumber,
                link: n.link,
              ) !=
              null;
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
                  fontWeight: n.isUnread ? FontWeight.w800 : FontWeight.w600,
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
              trailing: canOpen ? const Icon(Icons.chevron_right_rounded) : null,
              onTap: () => _open(n),
            ),
          );
        },
      ),
    );
  }
}
