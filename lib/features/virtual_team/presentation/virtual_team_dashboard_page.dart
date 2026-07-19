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

class _DashBundle {
  const _DashBundle({
    required this.root,
    required this.alerts,
  });

  final VtTeamRoot root;
  final List<VtAlert> alerts;
}

class VirtualTeamDashboardPage extends StatefulWidget {
  const VirtualTeamDashboardPage({super.key});

  @override
  State<VirtualTeamDashboardPage> createState() =>
      _VirtualTeamDashboardPageState();
}

class _VirtualTeamDashboardPageState extends State<VirtualTeamDashboardPage> {
  Future<_DashBundle>? _future;
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

  Future<_DashBundle> _load() async {
    final repo = context.read<VirtualTeamRepository>();
    final results = await Future.wait([
      repo.root(),
      repo.alerts(),
    ]);
    return _DashBundle(
      root: results[0] as VtTeamRoot,
      alerts: (results[1] as VtPagedList<VtAlert>).items,
    );
  }

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
      body: FutureBuilder<_DashBundle>(
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
          final data = snap.data!;
          final root = data.root;
          final dash = root.dashboard;
          final openAlerts =
              data.alerts.where((a) => a.status == 'open').toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (root.fromCache)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Cache ${root.cacheAgeLabel ?? ''}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                if (root.sprint != null)
                  Text(
                    'Sprint ${root.sprint}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                const SizedBox(height: 4),
                VtKpiGrid(dashboard: dash),
                if (openAlerts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Alertas abertos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  for (final a in openAlerts.take(3))
                    Card(
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer
                          .withValues(alpha: 0.28),
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber_rounded),
                        title: Text(a.title),
                        subtitle: Text(a.body, maxLines: 2),
                        onTap: () =>
                            context.push('/home/virtual-team/alerts'),
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Operação',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Card(
                  child: Column(
                    children: [
                      VtNavTile(
                        icon: Icons.groups_outlined,
                        title: 'Agentes',
                        subtitle: '${root.agentsState.length} no plantão',
                        onTap: () =>
                            context.push('/home/virtual-team/agents'),
                      ),
                      VtNavTile(
                        icon: Icons.task_alt_outlined,
                        title: 'Tarefas',
                        subtitle: 'Fila e status',
                        onTap: () =>
                            context.push('/home/virtual-team/tasks'),
                      ),
                      VtNavTile(
                        icon: Icons.play_circle_outline,
                        title: 'Execuções',
                        subtitle: 'Runs e duração',
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
                        icon: Icons.timeline_outlined,
                        title: 'Timeline',
                        subtitle: 'Linha do tempo unificada',
                        onTap: () =>
                            context.push('/home/virtual-team/timeline'),
                      ),
                      VtNavTile(
                        icon: Icons.queue_outlined,
                        title: 'Fila',
                        subtitle: 'Itens aguardando',
                        onTap: () =>
                            context.push('/home/virtual-team/queue'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Inteligência operacional',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Card(
                  child: Column(
                    children: [
                      VtNavTile(
                        icon: Icons.insights_outlined,
                        title: 'Métricas',
                        subtitle: 'KPIs detalhados',
                        onTap: () =>
                            context.push('/home/virtual-team/metrics'),
                      ),
                      VtNavTile(
                        icon: Icons.warning_amber_rounded,
                        title: 'Alertas',
                        subtitle: '${openAlerts.length} abertos',
                        onTap: () =>
                            context.push('/home/virtual-team/alerts'),
                      ),
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
                        icon: Icons.event_note_outlined,
                        title: 'Eventos',
                        subtitle: 'Eventos brutos da operação',
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
                        subtitle: 'Decisões e aprovações',
                        onTap: () =>
                            context.push('/home/virtual-team/audit'),
                      ),
                      VtNavTile(
                        icon: Icons.article_outlined,
                        title: 'Logs',
                        subtitle: 'Trilha técnica',
                        onTap: () =>
                            context.push('/home/virtual-team/logs'),
                      ),
                    ],
                  ),
                ),
                if (root.recentHandoffs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Hand-offs recentes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  for (final h in root.recentHandoffs.take(5))
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.swap_horiz, size: 18),
                      title: Text('${h.fromAgent} → ${h.toAgent}'),
                      subtitle: Text(h.reason, maxLines: 1),
                      trailing: Text(
                        vtFormatWhen(h.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
