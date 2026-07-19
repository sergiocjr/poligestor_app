import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/virtual_team_models.dart';
import '../data/virtual_team_repository.dart';
import 'widgets/virtual_team_widgets.dart';

class VirtualTeamAgentsPage extends StatefulWidget {
  const VirtualTeamAgentsPage({super.key});

  @override
  State<VirtualTeamAgentsPage> createState() => _VirtualTeamAgentsPageState();
}

class _VirtualTeamAgentsPageState extends State<VirtualTeamAgentsPage> {
  Future<List<VtAgent>>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;
  String _query = '';

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

  Future<List<VtAgent>> _load() =>
      context.read<VirtualTeamRepository>().agents();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agentes'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Filtrar por nome ou especialidade',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VtAgent>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError && !snap.hasData) {
                  final err = snap.error;
                  if (err is ApiException && err.isForbidden) {
                    return const AppEmptyState(
                      message: 'Sem permissão para listar agentes.',
                      icon: Icons.lock_outline,
                    );
                  }
                  return AppErrorState(
                    error: err,
                    message: UserMessages.fromError(err),
                    onRetry: _refresh,
                  );
                }
                final all = snap.data ?? const <VtAgent>[];
                final agents = _query.isEmpty
                    ? all
                    : all
                        .where(
                          (a) =>
                              a.name.toLowerCase().contains(_query) ||
                              a.specialty.toLowerCase().contains(_query) ||
                              a.slug.toLowerCase().contains(_query),
                        )
                        .toList();
                if (agents.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhum agente encontrado.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    itemCount: agents.length,
                    itemBuilder: (context, i) {
                      final agent = agents[i];
                      return VtAgentCard(
                        agent: agent,
                        onTap: () => context.push(
                          '/home/virtual-team/agents/${agent.slug}',
                        ),
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
