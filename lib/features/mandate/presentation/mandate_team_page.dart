import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';
import 'widgets/mandate_widgets.dart';

class MandateTeamPage extends StatefulWidget {
  const MandateTeamPage({super.key});

  @override
  State<MandateTeamPage> createState() => _MandateTeamPageState();
}

class _MandateTeamPageState extends State<MandateTeamPage> {
  Future<MandateTeamData>? _future;
  String _period = '7d';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<MandateTeamData> _load() => context.read<MandateRepository>().team(
        filter: MandateFilter(period: _period),
      );

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipe')),
      body: Column(
        children: [
          MandatePeriodFilterBar(
            value: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load();
            }),
          ),
          Expanded(
            child: FutureBuilder<MandateTeamData>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SkeletonBox(height: 100, radius: 16),
                  );
                }
                if (snap.hasError && !snap.hasData) {
                  return AppErrorState(
                    message: UserMessages.fromError(snap.error),
                    error: snap.error,
                    onRetry: _refresh,
                  );
                }
                final data = snap.data!;
                if (data.ranking.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhum integrante no ranking do período.',
                    icon: Icons.groups_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: data.ranking.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = data.ranking[i];
                      return MandateRankingTile(
                        rank: m.rank,
                        title: m.name,
                        subtitle:
                            'Atendidos ${m.attended} · Em andamento ${m.inProgress} · '
                            'Concluídos ${m.completed} · Em atraso ${m.overdue}\n'
                            'Tempo médio ${m.avgHours.toStringAsFixed(1)} h · '
                            'Avaliação ${m.avgRating.toStringAsFixed(1)}',
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (_) => Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Carga de trabalho (pontuação): ${m.score.toStringAsFixed(1)}'),
                                  Text('Atendidos no período: ${m.attended}'),
                                  Text('Em andamento: ${m.inProgress}'),
                                  Text('Concluídos: ${m.completed}'),
                                  Text('Em atraso: ${m.overdue}'),
                                  Text(
                                    'Tempo médio: ${m.avgHours.toStringAsFixed(1)} h',
                                  ),
                                  Text(
                                    'Avaliação média: ${m.avgRating.toStringAsFixed(1)}',
                                  ),
                                ],
                              ),
                            ),
                          );
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
