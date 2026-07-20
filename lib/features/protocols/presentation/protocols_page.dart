import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/protocol_models.dart';
import '../data/protocols_repository.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';

class ProtocolsPage extends StatefulWidget {
  const ProtocolsPage({super.key});

  @override
  State<ProtocolsPage> createState() => _ProtocolsPageState();
}

class _ProtocolsPageState extends State<ProtocolsPage>
    with AutomaticKeepAliveClientMixin {
  Future<List<ProtocolSummary>>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refresh = context.watch<MandateRefreshController>();
    if (!identical(_refreshCtrl, refresh)) {
      _refreshCtrl = refresh;
      _lastGen = refresh.generation;
    } else if (refresh.generation != _lastGen) {
      _lastGen = refresh.generation;
      _future = _load();
    }
    _future ??= _load();
  }

  Future<List<ProtocolSummary>> _load() {
    final auth = context.read<AuthController>();
    return context.read<ProtocolsRepository>().list(mode: auth.mode);
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocolos'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<ProtocolSummary>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done &&
                !snapshot.hasData) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  SkeletonBox(height: 72, radius: 16),
                  SizedBox(height: 10),
                  SkeletonBox(height: 72, radius: 16),
                  SizedBox(height: 10),
                  SkeletonBox(height: 72, radius: 16),
                ],
              );
            }
            if (snapshot.hasError && !snapshot.hasData) {
              return AppErrorState(
                message: UserMessages.forProtocolError(snapshot.error),
                error: snapshot.error,
                onRetry: _reload,
              );
            }
            final items = snapshot.data ?? const <ProtocolSummary>[];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  AppEmptyState(
                    message: 'Nenhum protocolo encontrado.',
                    icon: Icons.assignment_outlined,
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.assignment_outlined,
                        color: scheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [
                        if (item.number != null) '#${item.number}',
                        item.displayStatus,
                        if (item.createdAt != null)
                          dateFmt.format(item.createdAt!.toLocal()),
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.primary,
                    ),
                    onTap: () => context.push('/home/protocols/${item.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
