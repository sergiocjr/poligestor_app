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

class VirtualTeamDashboardPage extends StatefulWidget {
  const VirtualTeamDashboardPage({super.key});

  @override
  State<VirtualTeamDashboardPage> createState() =>
      _VirtualTeamDashboardPageState();
}

class _VirtualTeamDashboardPageState extends State<VirtualTeamDashboardPage> {
  Future<VtDashboard>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

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

  Future<VtDashboard> _load() =>
      context.read<VirtualTeamRepository>().dashboard();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipe Virtual'),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            onPressed: () => context.push('/home/virtual-team/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtDashboard>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 160, radius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 200, radius: 16),
              ],
            );
          }
          if (snap.hasError && !snap.hasData) {
            final err = snap.error;
            if (err is ApiException && err.isForbidden) {
              return const AppEmptyState(
                message: 'Sem permissão para Equipe Virtual.',
                icon: Icons.lock_outline,
              );
            }
            return AppErrorState(
              error: err,
              message: UserMessages.fromError(err),
              onRetry: _refresh,
            );
          }
          final dash = snap.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (dash.fromCache)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Cache ${dash.cacheAgeLabel ?? ''}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                VtKpiGrid(dashboard: dash),
                const SizedBox(height: 8),
                Text(
                  'Operação',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Card(
                  child: Column(
                    children: [
                      VtNavTile(
                        icon: Icons.groups_outlined,
                        title: 'Agentes',
                        subtitle: 'Catálogo e status operacional',
                        onTap: () =>
                            context.push('/home/virtual-team/agents'),
                      ),
                      VtNavTile(
                        icon: Icons.task_alt_outlined,
                        title: 'Tarefas',
                        subtitle: 'Fila e status de tarefas',
                        onTap: () =>
                            context.push('/home/virtual-team/tasks'),
                      ),
                      VtNavTile(
                        icon: Icons.play_circle_outline,
                        title: 'Execuções',
                        subtitle: 'Runs e resultados',
                        onTap: () =>
                            context.push('/home/virtual-team/executions'),
                      ),
                      VtNavTile(
                        icon: Icons.swap_horiz_outlined,
                        title: 'Hand-offs',
                        subtitle: 'Transferências entre agentes',
                        onTap: () =>
                            context.push('/home/virtual-team/handoffs'),
                      ),
                      VtNavTile(
                        icon: Icons.queue_outlined,
                        title: 'Fila',
                        subtitle: 'Itens aguardando processamento',
                        onTap: () =>
                            context.push('/home/virtual-team/queue'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Memória & aprendizado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Card(
                  child: Column(
                    children: [
                      VtNavTile(
                        icon: Icons.memory_outlined,
                        title: 'Memória',
                        subtitle: 'Contexto persistido',
                        onTap: () =>
                            context.push('/home/virtual-team/memory'),
                      ),
                      VtNavTile(
                        icon: Icons.school_outlined,
                        title: 'Aprendizado',
                        subtitle: 'Lições e padrões',
                        onTap: () =>
                            context.push('/home/virtual-team/learning'),
                      ),
                      VtNavTile(
                        icon: Icons.timeline_outlined,
                        title: 'Eventos',
                        subtitle: 'Linha do tempo operacional',
                        onTap: () =>
                            context.push('/home/virtual-team/events'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Governança',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Card(
                  child: Column(
                    children: [
                      VtNavTile(
                        icon: Icons.fact_check_outlined,
                        title: 'Auditoria',
                        subtitle: 'Trilha de auditoria',
                        onTap: () =>
                            context.push('/home/virtual-team/audit'),
                      ),
                      VtNavTile(
                        icon: Icons.article_outlined,
                        title: 'Logs',
                        subtitle: 'Registros técnicos',
                        onTap: () =>
                            context.push('/home/virtual-team/logs'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Concluídas 24h: ${dash.tasksCompleted24h} · '
                  'Falhas 24h: ${dash.tasksFailed24h} · '
                  'Delegações: ${dash.delegations24h}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
