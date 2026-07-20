import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';
import '../domain/mandate_refresh_controller.dart';
import 'widgets/mandate_widgets.dart';

/// Hub do mandato: visão executiva + atalhos + pontos de atenção + resumo IA.
class MandateOverviewPage extends StatefulWidget {
  const MandateOverviewPage({super.key});

  @override
  State<MandateOverviewPage> createState() => _MandateOverviewPageState();
}

class _MandateOverviewPageState extends State<MandateOverviewPage> {
  Future<MandateExecutive>? _future;
  String _period = '7d';
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

  Future<MandateExecutive> _load() async {
    final repo = context.read<MandateRepository>();
    final exec = await repo.executive(filter: MandateFilter(period: _period));
    // Briefing pode vir embutido; se não, busca endpoint dedicado.
    if (exec.briefing == null || exec.briefing!.bullets.isEmpty) {
      try {
        final briefing = await repo.briefing(
          filter: MandateFilter(period: _period),
        );
        return MandateExecutive(
          daySummary: exec.daySummary,
          monthTotals: exec.monthTotals,
          weeklySeries: exec.weeklySeries,
          monthlySeries: exec.monthlySeries,
          situationByTheme: exec.situationByTheme,
          attention: exec.attention,
          period: exec.period,
          generatedAt: exec.generatedAt,
          briefing: briefing,
          fromCache: exec.fromCache,
          cacheAgeLabel: exec.cacheAgeLabel,
        );
      } catch (_) {
        return exec;
      }
    }
    return exec;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandato'),
        actions: [
          IconButton(
            tooltip: 'Pesquisar',
            onPressed: () => context.push('/home/mandate/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Painel',
            onPressed: () => context.push('/home/mandate/tv'),
            icon: const Icon(Icons.tv_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          MandatePeriodFilterBar(
            value: _period,
            onChanged: (v) {
              setState(() {
                _period = v;
                _future = _load();
              });
            },
          ),
          Expanded(
            child: FutureBuilder<MandateExecutive>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SkeletonBox(height: 88, radius: 16),
                      SizedBox(height: 12),
                      SkeletonBox(height: 88, radius: 16),
                      SizedBox(height: 12),
                      SkeletonBox(height: 120, radius: 16),
                    ],
                  );
                }
                if (snap.hasError && !snap.hasData) {
                  final err = snap.error;
                  if (err is ApiException && err.isForbidden) {
                    return const AppEmptyState(
                      message:
                          'Seu usuário não tem permissão para ver o Mandato.',
                      icon: Icons.lock_outline_rounded,
                    );
                  }
                  return AppErrorState(
                    message: UserMessages.fromError(snap.error),
                    error: snap.error,
                    onRetry: _refresh,
                  );
                }
                final data = snap.data!;
                final d = data.daySummary;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    children: [
                      if (data.fromCache && data.cacheAgeLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SoftNotice(
                            message:
                                'Dados salvos (${data.cacheAgeLabel}). Puxe para atualizar.',
                          ),
                        ),
                      const MandateSectionSeeAll(title: 'Situação agora'),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.35,
                        children: [
                          MandateIndicatorCard(
                            label: 'Abertas',
                            value: '${d.open}',
                            icon: Icons.inbox_outlined,
                            onTap: () => context.go('/home/protocols'),
                          ),
                          MandateIndicatorCard(
                            label: 'Novas hoje',
                            value: '${d.newToday}',
                            icon: Icons.fiber_new_rounded,
                            onTap: () => context.go('/home/protocols'),
                          ),
                          MandateIndicatorCard(
                            label: 'Resolvidas hoje',
                            value: '${d.resolvedToday}',
                            icon: Icons.check_circle_outline,
                            onTap: () => context.go('/home/protocols'),
                          ),
                          MandateIndicatorCard(
                            label: 'Em atraso',
                            value: '${d.overdue}',
                            icon: Icons.schedule_rounded,
                            emphasis: d.overdue > 0,
                            onTap: () => context.go('/home/protocols'),
                          ),
                          MandateIndicatorCard(
                            label: 'Aguardando cidadão',
                            value: '${d.waitingCitizen}',
                            icon: Icons.person_outline,
                            onTap: () => context.go('/home/protocols'),
                          ),
                          MandateIndicatorCard(
                            label: 'Tempo médio',
                            value:
                                '${d.avgResolutionHours.toStringAsFixed(1)} h',
                            hint: 'Prazo de atendimento',
                            icon: Icons.timer_outlined,
                          ),
                        ],
                      ),
                      const MandateSectionSeeAll(title: 'Pontos de atenção'),
                      if (data.attention.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Nenhum ponto crítico no momento.'),
                        )
                      else
                        ...data.attention.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MandateAttentionTile(
                              title: a.title,
                              explanation: a.explanation,
                              actionLabel: a.actionLabel,
                              onAction: a.routeHint == null
                                  ? null
                                  : () => context.push(a.routeHint!),
                            ),
                          ),
                        ),
                      if (data.briefing != null &&
                          data.briefing!.bullets.isNotEmpty) ...[
                        const MandateSectionSeeAll(title: 'Resumo do dia'),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final b in data.briefing!.bullets)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('•  '),
                                        Expanded(child: Text(b)),
                                      ],
                                    ),
                                  ),
                                if (data.briefing!.source != null)
                                  Text(
                                    'Fonte: ${data.briefing!.source}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      MandateSectionSeeAll(
                        title: 'Assuntos com mais abertas',
                        onSeeAll: () => context.push('/home/mandate/subjects'),
                      ),
                      ...data.situationByTheme
                          .where((t) => t.open > 0)
                          .take(5)
                          .map(
                            (t) => MandateRankingTile(
                              rank: data.situationByTheme.indexOf(t) + 1,
                              title: t.label,
                              subtitle: '${t.open} abertas',
                              onTap: () =>
                                  context.push('/home/mandate/subjects'),
                            ),
                          ),
                      const SizedBox(height: 8),
                      const MandateSectionSeeAll(title: 'Áreas do mandato'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in _hubLinks)
                            ActionChip(
                              avatar: Icon(item.$3, size: 18),
                              label: Text(item.$1),
                              onPressed: () => context.push(item.$2),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _hubLinks = <(String, String, IconData)>[
    ('Inteligência', '/home/intelligence', Icons.auto_awesome_outlined),
    ('Agenda', '/home/mandate/agenda', Icons.event_outlined),
    ('Bairros', '/home/mandate/neighborhoods', Icons.location_city_outlined),
    ('Assuntos', '/home/mandate/subjects', Icons.category_outlined),
    ('Equipe', '/home/mandate/team', Icons.groups_outlined),
    ('Mapa', '/home/mandate/map', Icons.map_outlined),
    ('Relatórios', '/home/mandate/reports', Icons.summarize_outlined),
    ('Pesquisa', '/home/mandate/search', Icons.search_rounded),
    ('Painel', '/home/mandate/tv', Icons.tv_rounded),
  ];
}
