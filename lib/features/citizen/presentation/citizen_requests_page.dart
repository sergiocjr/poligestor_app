import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../protocols/data/protocol_models.dart';
import '../../protocols/data/protocols_repository.dart';

class CitizenRequestsPage extends StatefulWidget {
  const CitizenRequestsPage({super.key});

  @override
  State<CitizenRequestsPage> createState() => _CitizenRequestsPageState();
}

class _CitizenRequestsPageState extends State<CitizenRequestsPage> {
  Future<List<ProtocolSummary>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<ProtocolSummary>> _load() {
    final auth = context.read<AuthController>();
    return context.read<ProtocolsRepository>().list(mode: auth.mode);
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas solicitações'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/citizen/requests/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova'),
      ),
      body: FutureBuilder<List<ProtocolSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: const [
                SkeletonBox(height: 72, radius: 18),
                SizedBox(height: 12),
                SkeletonBox(height: 72, radius: 18),
                SizedBox(height: 12),
                SkeletonBox(height: 72, radius: 18),
              ],
            );
          }
          if (snapshot.hasError) {
            return AppErrorState(
              error: snapshot.error,
              onRetry: _reload,
            );
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return AppEmptyState(
              message: UserMessages.emptyRequests,
              actionLabel: 'Criar solicitação',
              onAction: () => context.push('/citizen/requests/new'),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = items[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      p.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text([
                      if (p.number != null) '#${p.number}',
                      ProtocolStatusLabel.pt(p.status),
                      if (p.createdAt != null)
                        dateFmt.format(p.createdAt!.toLocal()),
                    ].join(' · ')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/citizen/requests/${p.id}'),
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
