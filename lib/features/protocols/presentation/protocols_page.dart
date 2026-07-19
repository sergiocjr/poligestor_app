import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/protocol_models.dart';
import '../data/protocols_repository.dart';

class ProtocolsPage extends StatefulWidget {
  const ProtocolsPage({super.key});

  @override
  State<ProtocolsPage> createState() => _ProtocolsPageState();
}

class _ProtocolsPageState extends State<ProtocolsPage> {
  Future<List<ProtocolSummary>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<ProtocolSummary>> _load() {
    final auth = context.read<AuthController>();
    final repo = context.read<ProtocolsRepository>();
    return repo.list(mode: auth.mode);
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocolos'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ProtocolSummary>>(
        future: _future!,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView(message: 'Carregando protocolos...');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum protocolo encontrado.'));
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(
                    [
                      if (item.number != null) '#${item.number}',
                      item.displayStatus,
                      if (item.createdAt != null)
                        dateFmt.format(item.createdAt!.toLocal()),
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/home/protocols/${item.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
