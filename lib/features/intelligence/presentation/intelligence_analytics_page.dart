import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/intelligence_models.dart';
import '../data/intelligence_repository.dart';
import 'widgets/intelligence_widgets.dart';

enum AnalyticsFocus { neighborhoods, subjects, team, productivity }

class IntelligenceAnalyticsPage extends StatefulWidget {
  const IntelligenceAnalyticsPage({super.key, required this.focus});

  final AnalyticsFocus focus;

  @override
  State<IntelligenceAnalyticsPage> createState() =>
      _IntelligenceAnalyticsPageState();
}

class _IntelligenceAnalyticsPageState extends State<IntelligenceAnalyticsPage> {
  Future<IntelligenceAnalyticsData>? _future;
  String _period = '7d';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<IntelligenceAnalyticsData> _load() =>
      context.read<IntelligenceRepository>().analytics(
            filter: IntelligenceFilter(period: _period),
          );

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  String get _title => switch (widget.focus) {
        AnalyticsFocus.neighborhoods => 'Análise de bairros',
        AnalyticsFocus.subjects => 'Análise de assuntos',
        AnalyticsFocus.team => 'Análise de equipe',
        AnalyticsFocus.productivity => 'Produtividade',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Column(
        children: [
          IntelPeriodFilterBar(
            value: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load();
            }),
          ),
          Expanded(
            child: FutureBuilder<IntelligenceAnalyticsData>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SkeletonBox(height: 140, radius: 16),
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
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    children: [
                      if (data.fromCache && data.cacheAgeLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: IntelStaleNotice(ageLabel: data.cacheAgeLabel!),
                        ),
                      ...switch (widget.focus) {
                        AnalyticsFocus.neighborhoods =>
                          _neighborhoods(context, data),
                        AnalyticsFocus.subjects => _subjects(context, data),
                        AnalyticsFocus.team => _team(context, data),
                        AnalyticsFocus.productivity =>
                          _productivity(context, data),
                      },
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

  List<Widget> _neighborhoods(
    BuildContext context,
    IntelligenceAnalyticsData data,
  ) {
    final summary = data.neighborhoodSummary;
    return [
      SoftNotice(
        message:
            'Mais ativo: ${summary['hottest'] ?? '—'} · '
            'Melhorando: ${summary['improving'] ?? '—'} · '
            'Atenção: ${summary['worsening'] ?? '—'}',
      ),
      const SizedBox(height: 8),
      if (data.neighborhoods.isEmpty)
        const AppEmptyState(message: 'Sem dados de bairros.')
      else
        ...data.neighborhoods.map(
          (n) => Card(
            child: ListTile(
              title: Text(n.district),
              subtitle: Text(
                '${n.total} no período · ${n.open} abertas · ${n.resolved} resolvidas'
                '${n.growthPct == null ? '' : ' · variação ${n.growthPct!.toStringAsFixed(0)}%'}'
                '${n.topSubjects.isEmpty ? '' : '\n${n.topSubjects.take(2).map((t) => t.name).join(', ')}'}',
              ),
              isThreeLine: n.topSubjects.isNotEmpty,
            ),
          ),
        ),
    ];
  }

  List<Widget> _subjects(BuildContext context, IntelligenceAnalyticsData data) {
    final summary = data.subjectSummary;
    return [
      SoftNotice(
        message:
            'Líder: ${summary['leading'] ?? '—'} '
            '(${summary['leading_share_pct'] ?? '—'}%) · '
            'Subindo: ${summary['rising'] ?? '—'} · '
            'Caindo: ${summary['falling'] ?? '—'}',
      ),
      const SizedBox(height: 8),
      if (data.subjects.isEmpty)
        const AppEmptyState(message: 'Sem dados de assuntos.')
      else
        ...data.subjects.map(
          (s) => Card(
            child: ListTile(
              title: Text(s.label),
              subtitle: Text(
                '${s.total} solicitações · ${s.trendLabel}'
                '${s.growthPct == null ? '' : ' · ${s.growthPct!.toStringAsFixed(0)}%'}',
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _team(BuildContext context, IntelligenceAnalyticsData data) {
    final summary = data.teamSummary;
    return [
      SoftNotice(
        message:
            'Equipe: ${summary['team_size'] ?? '—'} · '
            'Destaque: ${summary['top_performer'] ?? '—'} · '
            'Nota média: ${summary['avg_rating'] ?? '—'}',
      ),
      const SizedBox(height: 8),
      if (data.team.isEmpty)
        const AppEmptyState(message: 'Sem dados de equipe.')
      else
        ...data.team.map(
          (m) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${m.rank}')),
              title: Text(m.name),
              subtitle: Text(
                'Atendidos ${m.attended} · Em andamento ${m.inProgress} · '
                'Concluídos ${m.completed} · Em atraso ${m.overdue}',
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _productivity(
    BuildContext context,
    IntelligenceAnalyticsData data,
  ) {
    final summary = data.teamSummary;
    return [
      SoftNotice(
        message:
            'Resolvidos: ${summary['resolved_total'] ?? '—'} · '
            'Abertos: ${summary['open_total'] ?? '—'} · '
            'Nota média: ${summary['avg_rating'] ?? '—'}',
      ),
      const SizedBox(height: 8),
      if (data.team.isEmpty)
        const AppEmptyState(message: 'Sem indicadores de produtividade.')
      else
        ...data.team.map(
          (m) => Card(
            child: ListTile(
              title: Text(m.name),
              subtitle: Text(
                'Pontuação ${m.score.toStringAsFixed(1)} · '
                'Tempo médio ${m.avgHours.toStringAsFixed(1)} h · '
                'Avaliação ${m.avgRating.toStringAsFixed(1)}',
              ),
            ),
          ),
        ),
    ];
  }
}
