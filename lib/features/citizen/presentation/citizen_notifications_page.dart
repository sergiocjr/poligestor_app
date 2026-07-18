import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/ui_kit.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dateFmt = DateFormat('dd/MM HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          if (auth.apiDegraded)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ApiDegradedBanner(),
            ),
          Expanded(
            child: FutureBuilder<List<AppNotification>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingView();
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  );
                }
                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return const Center(child: Text('Sem notificações.'));
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      return ListTile(
                        leading: Icon(
                          n.isUnread
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          color: n.isUnread
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight:
                                n.isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text([
                          if (n.body != null) n.body!,
                          if (n.createdAt != null)
                            dateFmt.format(n.createdAt!.toLocal()),
                        ].join('\n')),
                        isThreeLine: n.body != null,
                        onTap: () async {
                          if (!n.isUnread) return;
                          try {
                            await context
                                .read<NotificationsRepository>()
                                .markRead(mode: auth.mode, id: n.id);
                            await _reload();
                          } catch (_) {}
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
