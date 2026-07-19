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

class VirtualTeamAgentDetailPage extends StatefulWidget {
  const VirtualTeamAgentDetailPage({super.key, required this.slug});

  final String slug;

  @override
  State<VirtualTeamAgentDetailPage> createState() =>
      _VirtualTeamAgentDetailPageState();
}

class _AgentBundle {
  const _AgentBundle({
    required this.agent,
    required this.metrics,
    required this.tasks,
    required this.executions,
    required this.logs,
    required this.timeline,
  });

  final VtAgent agent;
  final VtDashboard metrics;
  final List<VtTask> tasks;
  final List<VtExecution> executions;
  final List<VtLogEntry> logs;
  final List<VtTimelineItem> timeline;
}

class _VirtualTeamAgentDetailPageState
    extends State<VirtualTeamAgentDetailPage> {
  Future<_AgentBundle>? _future;
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

  Future<_AgentBundle> _load() async {
    final repo = context.read<VirtualTeamRepository>();
    final slug = widget.slug;
    final results = await Future.wait([
      repo.agent(slug),
      repo.metrics(agentSlug: slug),
      repo.tasks(agentSlug: slug),
      repo.executions(agentSlug: slug),
      repo.logs(agentSlug: slug),
      repo.timeline(agentSlug: slug),
    ]);
    return _AgentBundle(
      agent: results[0] as VtAgent,
      metrics: results[1] as VtDashboard,
      tasks: (results[2] as VtPagedList<VtTask>).items,
      executions: (results[3] as VtPagedList<VtExecution>).items,
      logs: (results[4] as VtPagedList<VtLogEntry>).items,
      timeline: (results[5] as VtPagedList<VtTimelineItem>).items,
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
        title: Text(widget.slug),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<_AgentBundle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && !snap.hasData) {
            final err = snap.error;
            if (err is ApiException && err.statusCode == 404) {
              return const AppEmptyState(
                message: 'Agente não encontrado.',
                icon: Icons.person_off_outlined,
              );
            }
            return AppErrorState(
              error: err,
              message: UserMessages.fromError(err),
              onRetry: _refresh,
            );
          }
          final b = snap.data!;
          final a = b.agent;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        a.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    VtStatusChip(
                      label: a.isOnline ? 'Online' : 'Offline',
                      online: a.isOnline,
                    ),
                  ],
                ),
                Text(a.specialty.isEmpty ? a.slug : a.specialty),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(a.stateLabel)),
                    Chip(
                      label: Text(
                        a.isAvailable ? 'Disponível' : 'Indisponível',
                      ),
                    ),
                    if (a.model != null) Chip(label: Text(a.model!)),
                  ],
                ),
                if (a.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(a.description),
                ],
                if (a.objective.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Objetivo',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(a.objective),
                ],
                const SizedBox(height: 16),
                Text(
                  'Métricas do agente',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                VtKpiGrid(dashboard: b.metrics),
                const SizedBox(height: 12),
                Text(
                  'Sub-rotas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Card(
                  child: Column(
                    children: [
                      VtNavTile(
                        icon: Icons.task_alt_outlined,
                        title: 'Tarefas (${b.tasks.length})',
                        subtitle: 'Filtradas por este agente',
                        onTap: () => context.push(
                          '/home/virtual-team/agents/${widget.slug}/tasks',
                        ),
                      ),
                      VtNavTile(
                        icon: Icons.play_circle_outline,
                        title: 'Execuções (${b.executions.length})',
                        subtitle: 'Runs deste agente',
                        onTap: () => context.push(
                          '/home/virtual-team/agents/${widget.slug}/executions',
                        ),
                      ),
                      VtNavTile(
                        icon: Icons.article_outlined,
                        title: 'Logs (${b.logs.length})',
                        subtitle: 'Trilha do agente',
                        onTap: () => context.push(
                          '/home/virtual-team/agents/${widget.slug}/logs',
                        ),
                      ),
                      VtNavTile(
                        icon: Icons.timeline_outlined,
                        title: 'Timeline (${b.timeline.length})',
                        subtitle: 'Linha do tempo do agente',
                        onTap: () => context.push(
                          '/home/virtual-team/agents/${widget.slug}/timeline',
                        ),
                      ),
                      VtNavTile(
                        icon: Icons.insights_outlined,
                        title: 'Métricas',
                        subtitle: 'KPIs do agente',
                        onTap: () => context.push(
                          '/home/virtual-team/agents/${widget.slug}/metrics',
                        ),
                      ),
                    ],
                  ),
                ),
                if (b.timeline.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Últimos eventos',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  for (final t in b.timeline.take(5))
                    ListTile(
                      dense: true,
                      title: Text(t.title),
                      subtitle: Text(
                        t.body ?? t.kind,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        vtFormatWhen(t.createdAt),
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
