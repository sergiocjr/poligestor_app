import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/intelligence_models.dart';
import '../data/intelligence_repository.dart';
import 'widgets/intelligence_widgets.dart';

/// Dashboard inteligente — hub do módulo Inteligência.
class IntelligenceDashboardPage extends StatefulWidget {
  const IntelligenceDashboardPage({super.key});

  @override
  State<IntelligenceDashboardPage> createState() =>
      _IntelligenceDashboardPageState();
}

class _DashboardBundle {
  const _DashboardBundle({
    required this.briefing,
    required this.insights,
    required this.trends,
    required this.analytics,
  });

  final IntelligenceBriefingView briefing;
  final IntelligenceInsightsData insights;
  final IntelligenceTrendsData trends;
  final IntelligenceAnalyticsData analytics;
}

class _IntelligenceDashboardPageState extends State<IntelligenceDashboardPage> {
  Future<_DashboardBundle>? _future;
  String _period = '7d';
  DateTimeRange? _customRange;
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
      // Resume/realtime: sem generate=1 (evita job IA a cada bump).
      _future = _load(generateInsights: false);
    }
    _future ??= _load(generateInsights: true);
  }

  IntelligenceFilter get _filter {
    if (_period == 'custom' && _customRange != null) {
      return IntelligenceFilter(
        from: _customRange!.start.toIso8601String().split('T').first,
        to: _customRange!.end.toIso8601String().split('T').first,
      );
    }
    return IntelligenceFilter(period: _period == 'custom' ? '7d' : _period);
  }

  Future<_DashboardBundle> _load({bool generateInsights = false}) async {
    final repo = context.read<IntelligenceRepository>();
    final filter = _filter;
    final results = await Future.wait([
      repo.briefing(filter: filter),
      repo.insights(filter: filter, generate: generateInsights),
      repo.trends(filter: filter),
      repo.analytics(filter: filter),
    ]);
    return _DashboardBundle(
      briefing: results[0] as IntelligenceBriefingView,
      insights: results[1] as IntelligenceInsightsData,
      trends: results[2] as IntelligenceTrendsData,
      analytics: results[3] as IntelligenceAnalyticsData,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load(generateInsights: true));
    await _future;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange:
          _customRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customRange = picked;
      _period = 'custom';
      _future = _load(generateInsights: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inteligência'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          IntelPeriodFilterBar(
            value: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load(generateInsights: false);
            }),
            onCustomRange: _pickRange,
          ),
          Expanded(
            child: FutureBuilder<_DashboardBundle>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SkeletonBox(height: 100, radius: 16),
                      SizedBox(height: 12),
                      SkeletonBox(height: 120, radius: 16),
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
                          'Seu usuário não tem permissão para a Inteligência.',
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
                final snapShot = data.analytics.snapshot;
                final stale = [
                  if (data.briefing.fromCache &&
                      data.briefing.cacheAgeLabel != null)
                    data.briefing.cacheAgeLabel!,
                  if (data.insights.fromCache &&
                      data.insights.cacheAgeLabel != null)
                    data.insights.cacheAgeLabel!,
                  if (data.trends.fromCache &&
                      data.trends.cacheAgeLabel != null)
                    data.trends.cacheAgeLabel!,
                ];
                final opportunities = data.insights.items
                    .where((e) => e.isOpportunity)
                    .toList();
                final alerts = data.insights.items
                    .where((e) => e.priority == 'attention')
                    .toList();

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    children: [
                      if (stale.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: IntelStaleNotice(ageLabel: stale.first),
                        ),
                      const IntelSectionTitle(title: 'Prioridades agora'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _KpiChip(label: 'Abertas', value: '${snapShot.open}'),
                          _KpiChip(
                            label: 'Em atraso',
                            value: '${snapShot.overdue}',
                            emphasize: snapShot.overdue > 0,
                          ),
                          _KpiChip(
                            label: 'Aguardando',
                            value: '${snapShot.waitingCitizen}',
                          ),
                          _KpiChip(
                            label: 'Ritmo',
                            value: data.trends.signals.momentumLabel,
                          ),
                        ],
                      ),
                      IntelSectionTitle(
                        title: 'Resumo do dia',
                        onSeeAll: () =>
                            context.push('/home/intelligence/briefing'),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data.briefing.briefing.bullets.isEmpty)
                                const Text('Sem resumo disponível no momento.')
                              else
                                for (final b
                                    in data.briefing.briefing.bullets.take(4))
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('• $b'),
                                  ),
                            ],
                          ),
                        ),
                      ),
                      IntelSectionTitle(
                        title: 'Alertas',
                        onSeeAll: () =>
                            context.push('/home/intelligence/insights'),
                      ),
                      if (alerts.isEmpty)
                        const SoftNotice(message: 'Nenhum alerta prioritário.')
                      else
                        ...alerts
                            .take(3)
                            .map(
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InsightCard(
                                  insight: i,
                                  onAction: i.routeHint == null
                                      ? null
                                      : () => context.push(i.routeHint!),
                                ),
                              ),
                            ),
                      IntelSectionTitle(
                        title: 'Insights',
                        onSeeAll: () =>
                            context.push('/home/intelligence/insights'),
                      ),
                      ...data.insights.items
                          .take(3)
                          .map(
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InsightCard(
                                insight: i,
                                onAction: i.routeHint == null
                                    ? null
                                    : () => context.push(i.routeHint!),
                              ),
                            ),
                          ),
                      IntelSectionTitle(
                        title: 'Tendências',
                        onSeeAll: () =>
                            context.push('/home/intelligence/trends'),
                      ),
                      TrendSeriesCard(
                        title: 'Últimos dias',
                        points: data.trends.daily,
                      ),
                      IntelSectionTitle(
                        title: 'Oportunidades',
                        onSeeAll: () =>
                            context.push('/home/intelligence/opportunities'),
                      ),
                      if (opportunities.isEmpty)
                        const SoftNotice(
                          message: 'Nenhuma oportunidade destacada agora.',
                        )
                      else
                        ...opportunities
                            .take(3)
                            .map(
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InsightCard(insight: i),
                              ),
                            ),
                      const IntelSectionTitle(title: 'Áreas'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in _links)
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

  static const _links = <(String, String, IconData)>[
    ('Briefing', '/home/intelligence/briefing', Icons.wb_sunny_outlined),
    ('Insights', '/home/intelligence/insights', Icons.lightbulb_outline),
    ('Tendências', '/home/intelligence/trends', Icons.show_chart_rounded),
    (
      'Bairros',
      '/home/intelligence/analytics/neighborhoods',
      Icons.location_city_outlined,
    ),
    (
      'Assuntos',
      '/home/intelligence/analytics/subjects',
      Icons.category_outlined,
    ),
    ('Equipe', '/home/intelligence/analytics/team', Icons.groups_outlined),
    (
      'Produtividade',
      '/home/intelligence/analytics/productivity',
      Icons.speed_outlined,
    ),
    ('Oportunidades', '/home/intelligence/opportunities', Icons.flag_outlined),
    ('Resumos', '/home/intelligence/summaries', Icons.menu_book_outlined),
  ];
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: emphasize
            ? scheme.errorContainer.withValues(alpha: 0.45)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
