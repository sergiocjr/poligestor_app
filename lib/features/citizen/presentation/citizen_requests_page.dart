import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/ui_kit.dart';
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
    final auth = context.watch<AuthController>();
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas solicitações'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/citizen/requests/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (auth.apiDegraded)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ApiDegradedBanner(),
            ),
          Expanded(
            child: FutureBuilder<List<ProtocolSummary>>(
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
                  return const Center(
                    child: Text('Você ainda não tem solicitações.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = items[index];
                      return ListTile(
                        title: Text(p.title),
                        subtitle: Text([
                          if (p.number != null) '#${p.number}',
                          ProtocolStatusLabel.pt(p.status),
                          if (p.createdAt != null)
                            dateFmt.format(p.createdAt!.toLocal()),
                        ].join(' · ')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push('/citizen/requests/${p.id}'),
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
