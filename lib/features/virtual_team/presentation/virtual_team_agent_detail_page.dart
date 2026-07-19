import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
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

class _VirtualTeamAgentDetailPageState
    extends State<VirtualTeamAgentDetailPage> {
  Future<VtAgent>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??=
        context.read<VirtualTeamRepository>().agent(widget.slug);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = context.read<VirtualTeamRepository>().agent(widget.slug);
    });
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
      body: FutureBuilder<VtAgent>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && !snap.hasData) {
            final err = snap.error;
            if (err is ApiException && err.statusCode == 404) {
              return const AppEmptyState(
                message: 'Agente não encontrado. Use o slug correto.',
                icon: Icons.person_off_outlined,
              );
            }
            return AppErrorState(
              error: err,
              message: UserMessages.fromError(err),
              onRetry: _refresh,
            );
          }
          final a = snap.data!;
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
                const SizedBox(height: 4),
                Text(a.specialty.isEmpty ? a.slug : a.specialty),
                const SizedBox(height: 12),
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
                  const SizedBox(height: 16),
                  Text(
                    'Objetivo',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(a.objective),
                ],
                if (a.responsibilities.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Responsabilidades',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  for (final r in a.responsibilities)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline, size: 18),
                      title: Text(r),
                    ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Estatísticas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Concluídas: ${a.stats.tasksCompleted}'),
                        Text('Falhas: ${a.stats.tasksFailed}'),
                        Text('Delegações: ${a.stats.delegations}'),
                        if (a.stats.avgDurationMs != null)
                          Text('Duração média: ${a.stats.avgDurationMs} ms'),
                        if (a.queue.isNotEmpty) Text('Fila: ${a.queue}'),
                        if (a.maxConcurrent != null)
                          Text('Máx. concorrência: ${a.maxConcurrent}'),
                        if (a.lastRunAt != null)
                          Text('Última execução: ${a.lastRunAt}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sub-rotas por agente (tasks/executions/…) ainda não '
                  'existem no backend — use as telas globais do módulo.',
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
