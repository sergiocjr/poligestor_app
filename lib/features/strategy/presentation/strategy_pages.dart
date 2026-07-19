import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_mode.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/strategy_models.dart';
import '../data/strategy_repository.dart';

/// Hub — Painel Estratégico (Sprint 10.7).
class StrategyHubPage extends StatelessWidget {
  const StrategyHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel executivo',
      'Indicadores estratégicos ativos',
      Icons.dashboard_outlined,
      '/home/strategy/dashboard',
      true,
    ),
    _Entry(
      'Indicadores',
      'Indicadores e categorias',
      Icons.speed_outlined,
      '/home/strategy/kpis',
      true,
    ),
    _Entry(
      'Mapa',
      'Território (mandato ativo)',
      Icons.map_outlined,
      '/home/strategy/map',
      true,
    ),
    _Entry(
      'Mapa de calor',
      'Concentração geográfica',
      Icons.bubble_chart_outlined,
      '/home/strategy/heatmap',
      true,
    ),
    _Entry(
      'Tendências',
      'Séries e detecções',
      Icons.trending_up,
      '/home/strategy/trends',
      true,
    ),
    _Entry(
      'Metas',
      'Objetivos estratégicos',
      Icons.flag_outlined,
      '/home/strategy/goals',
      false,
    ),
    _Entry(
      'Alertas',
      'Análises e avisos',
      Icons.notification_important_outlined,
      '/home/strategy/alerts',
      true,
    ),
    _Entry(
      'Comparativos',
      'Períodos e regiões',
      Icons.compare_arrows,
      '/home/strategy/compare',
      false,
    ),
    _Entry(
      'Regiões',
      'Mapa de calor e achados',
      Icons.public_outlined,
      '/home/strategy/regions',
      true,
    ),
    _Entry(
      'Bairros',
      'Criticidade e tendência',
      Icons.location_city_outlined,
      '/home/strategy/neighborhoods',
      true,
    ),
    _Entry(
      'Previsões',
      'Carga e SLA',
      Icons.insights_outlined,
      '/home/strategy/forecasts',
      true,
    ),
    _Entry(
      'Relatórios',
      'Exportações estratégicas',
      Icons.description_outlined,
      '/home/strategy/reports',
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel Estratégico')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisExtent: 100,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _entries.length,
            itemBuilder: (context, i) {
              final e = _entries[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push(e.route),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(child: Icon(e.icon)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                e.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                e.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(uiContractChip(available: e.live)),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: e.live ? Colors.green.shade50 : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
          if (!wide) return grid;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: grid,
            ),
          );
        },
      ),
    );
  }
}

class _Entry {
  const _Entry(this.title, this.subtitle, this.icon, this.route, this.live);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool live;
}

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _StrategyRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindStrategyRefresh(VoidCallback reload) {
    final r = context.watch<MandateRefreshController>();
    if (!identical(_refresh, r)) {
      _refresh = r;
      _gen = r.generation;
    } else if (r.generation != _gen) {
      _gen = r.generation;
      reload();
    }
  }
}

class StrategyPendingPage extends StatefulWidget {
  const StrategyPendingPage({
    super.key,
    required this.title,
    required this.path,
    required this.probe,
  });

  final String title;
  final String path;
  final Future<void> Function(StrategyRepository repo) probe;

  @override
  State<StrategyPendingPage> createState() => _StrategyPendingPageState();
}

class _StrategyPendingPageState extends State<StrategyPendingPage> {
  Future<void>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= widget.probe(context.read<StrategyRepository>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final err = snap.error;
          if (err is EndpointUnavailableException) {
            return EndpointPendingState(
              path: err.path,
              message:
                  '${widget.title} preparado. Aguardando contrato ativo estável na VPS.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = widget.probe(context.read<StrategyRepository>());
              }),
            );
          }
          return EndpointPendingState(path: widget.path);
        },
      ),
    );
  }
}

Widget _cacheBanner(
  BuildContext context, {
  required bool fromCache,
  String? age,
}) {
  if (!fromCache) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      'Dados salvos ${age ?? ''}',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}

Widget _kpiGrid(BuildContext context, StrategyKpiSummary d) {
  final items = <(String, String, IconData)>[
    ('Abertos', '${d.protocolsOpen}', Icons.inbox_outlined),
    ('Criados', '${d.protocolsCreated}', Icons.add_circle_outline),
    ('Resolvidos', '${d.protocolsResolved}', Icons.check_circle_outline),
    ('Atrasados', '${d.protocolsOverdue}', Icons.schedule),
    ('Risco de prazo', '${d.slaAtRisk}', Icons.warning_amber_outlined),
    ('Prazo violado', '${d.slaBreached}', Icons.error_outline),
    ('NPS', '${d.nps}', Icons.thumb_up_outlined),
    ('Satisfação', d.satisfaction.toStringAsFixed(1), Icons.star_outline),
    ('Crescimento', '${d.growthPercent}%', Icons.trending_up),
    ('Campanhas', '${d.campaigns}', Icons.campaign_outlined),
    ('Nota média', d.avgRating.toStringAsFixed(1), Icons.grade_outlined),
    (
      'Resolução h',
      d.avgResolutionHours.toStringAsFixed(1),
      Icons.timer_outlined,
    ),
  ];
  return LayoutBuilder(
    builder: (context, c) {
      final cols = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 600 ? 3 : 2);
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.35,
        children: [
          for (final (label, value, icon) in items)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 20),
                    const Spacer(),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class StrategyDashboardPage extends StatefulWidget {
  const StrategyDashboardPage({super.key});

  @override
  State<StrategyDashboardPage> createState() => _StrategyDashboardPageState();
}

class _StrategyDashboardPageState extends State<StrategyDashboardPage>
    with _StrategyRefresh {
  Future<StrategyKpiSummary>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindStrategyRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<StrategyKpiSummary> _load() => context
      .read<StrategyRepository>()
      .dashboard(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel executivo'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<StrategyKpiSummary>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final d = snap.data!;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                _cacheBanner(
                  context,
                  fromCache: d.fromCache,
                  age: d.cacheAgeLabel,
                ),
                Text(
                  'Fonte ativa: indicadores estratégicos (painel dedicado usa reserva se indisponível)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                _kpiGrid(context, d),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => context.push('/home/mandate'),
                      child: const Text('Mandato'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => context.push('/home/intelligence'),
                      child: const Text('Inteligência'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => context.push('/home/strategy/forecasts'),
                      child: const Text('Previsões'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StrategyKpisPage extends StatefulWidget {
  const StrategyKpisPage({super.key});

  @override
  State<StrategyKpisPage> createState() => _StrategyKpisPageState();
}

class _StrategyKpisPageState extends State<StrategyKpisPage>
    with _StrategyRefresh {
  Future<StrategyKpiSummary>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindStrategyRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<StrategyKpiSummary> _load() =>
      context.read<StrategyRepository>().kpis(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KPIs')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<StrategyKpiSummary>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final d = snap.data!;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                _cacheBanner(
                  context,
                  fromCache: d.fromCache,
                  age: d.cacheAgeLabel,
                ),
                _kpiGrid(context, d),
                const SizedBox(height: 16),
                Text(
                  'Por categoria',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...d.byCategory.entries
                    .take(12)
                    .map(
                      (e) => ListTile(
                        dense: true,
                        title: Text(e.key),
                        trailing: Text('${e.value}'),
                      ),
                    ),
                const SizedBox(height: 8),
                Text(
                  'Por status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...d.byStatus.entries.map(
                  (e) => ListTile(
                    dense: true,
                    title: Text(e.key),
                    trailing: Text('${e.value}'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StrategyHeatmapPage extends StatefulWidget {
  const StrategyHeatmapPage({super.key});

  @override
  State<StrategyHeatmapPage> createState() => _StrategyHeatmapPageState();
}

class _StrategyHeatmapPageState extends State<StrategyHeatmapPage>
    with _StrategyRefresh {
  Future<StrategyHeatmapData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindStrategyRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<StrategyHeatmapData> _load() => context
      .read<StrategyRepository>()
      .heatmap(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de calor'),
        actions: [
          TextButton(
            onPressed: () => context.push('/home/mandate/map'),
            child: const Text('Mapa mandato'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<StrategyHeatmapData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final data = snap.data!;
            final points = data.points.isNotEmpty ? data.points : data.clusters;
            if (points.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Sem pontos no mapa de calor.'),
                ],
              );
            }
            final maxTotal = points
                .map((p) => p.total)
                .fold<int>(1, (a, b) => a > b ? a : b);
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: points.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _cacheBanner(
                    context,
                    fromCache: data.fromCache,
                    age: data.cacheAgeLabel,
                  );
                }
                final p = points[i - 1];
                final intensity = (p.total / maxTotal).clamp(0.15, 1.0);
                return Card(
                  color: Color.lerp(
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(context).colorScheme.errorContainer,
                    intensity,
                  ),
                  child: ListTile(
                    title: Text(
                      p.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Abertos ${p.open} · Resolvidos ${p.resolved}'
                      '${p.lat != null ? ' · ${p.lat!.toStringAsFixed(3)}, ${p.lng!.toStringAsFixed(3)}' : ''}',
                    ),
                    trailing: Text('${p.total}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class StrategyTrendsPage extends StatefulWidget {
  const StrategyTrendsPage({super.key});

  @override
  State<StrategyTrendsPage> createState() => _StrategyTrendsPageState();
}

class _StrategyTrendsPageState extends State<StrategyTrendsPage>
    with _StrategyRefresh {
  Future<StrategyTrendsData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindStrategyRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<StrategyTrendsData> _load() =>
      context.read<StrategyRepository>().trends(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tendências'),
        actions: [
          TextButton(
            onPressed: () => context.push('/home/intelligence/trends'),
            child: const Text('Inteligência'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<StrategyTrendsData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final d = snap.data!;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                _cacheBanner(
                  context,
                  fromCache: d.fromCache,
                  age: d.cacheAgeLabel,
                ),
                Card(
                  child: ListTile(
                    title: const Text('Totais da série'),
                    subtitle: Text(
                      'Criados ${d.seriesTotalsCreated} · Resolvidos ${d.seriesTotalsResolved}'
                      '${d.seasonalityHint != null ? '\n${d.seasonalityHint}' : ''}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Detecções',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...d.detections.map(
                  (t) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.trending_up),
                      title: Text(t.label),
                      subtitle: Text(
                        [t.type, t.value].whereType<String>().join(' · '),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Temas emergentes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...d.emergingTopics.map(
                  (t) => ListTile(
                    title: Text(t.label),
                    trailing: Text(t.value ?? ''),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StrategyAlertsPage extends StatefulWidget {
  const StrategyAlertsPage({super.key});

  @override
  State<StrategyAlertsPage> createState() => _StrategyAlertsPageState();
}

class _StrategyAlertsPageState extends State<StrategyAlertsPage>
    with _StrategyRefresh {
  Future<List<StrategyAlert>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindStrategyRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<StrategyAlert>> _load() =>
      context.read<StrategyRepository>().alerts(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas estratégicos')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<StrategyAlert>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final items = snap.data ?? const [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Nenhum alerta estratégico.'),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = items[i];
                final critical =
                    a.severity == 'high' || a.severity == 'critical';
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.notification_important_outlined,
                      color: critical
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                    title: Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${uiSeverityLabel(a.severity)} · ${uiStatusLabel(a.status)}\n${a.body}',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class StrategyRegionsPage extends StatefulWidget {
  const StrategyRegionsPage({super.key});

  @override
  State<StrategyRegionsPage> createState() => _StrategyRegionsPageState();
}

class _StrategyRegionsPageState extends State<StrategyRegionsPage>
    with _StrategyRefresh {
  Future<StrategyRegionsData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindStrategyRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<StrategyRegionsData> _load() => context
      .read<StrategyRepository>()
      .regions(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Regiões')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<StrategyRegionsData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final d = snap.data!;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                _cacheBanner(
                  context,
                  fromCache: d.fromCache,
                  age: d.cacheAgeLabel,
                ),
                Text(
                  'Mapa de calor regional',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...d.heatmap.map(
                  (p) => Card(
                    child: ListTile(
                      title: Text(p.label),
                      subtitle: Text(
                        'Abertos ${p.open} · Resolvidos ${p.resolved}',
                      ),
                      trailing: Text('${p.total}'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Achados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...d.findings.map(
                  (f) => Card(
                    child: ListTile(
                      title: Text(f.title),
                      subtitle: Text(
                        f.summary,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StrategyNeighborhoodsPage extends StatefulWidget {
  const StrategyNeighborhoodsPage({super.key});

  @override
  State<StrategyNeighborhoodsPage> createState() =>
      _StrategyNeighborhoodsPageState();
}

class _StrategyNeighborhoodsPageState extends State<StrategyNeighborhoodsPage>
    with _StrategyRefresh {
  Future<List<StrategyNeighborhood>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindStrategyRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<StrategyNeighborhood>> _load() => context
      .read<StrategyRepository>()
      .neighborhoods(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bairros'),
        actions: [
          TextButton(
            onPressed: () => context.push('/home/mandate/neighborhoods'),
            child: const Text('Mandato'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<StrategyNeighborhood>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final items = snap.data ?? const [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Nenhum bairro na série estratégica.'),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = items[i];
                return Card(
                  child: ListTile(
                    title: Text(
                      n.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [
                            n.district,
                            n.city,
                            n.priority,
                            n.trend,
                            if (n.growthPercent != null)
                              'cresc. ${n.growthPercent!.toStringAsFixed(0)}%',
                          ]
                          .whereType<String>()
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${n.quantity}'),
                        Text(
                          'crit. ${n.criticality}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class StrategyForecastsPage extends StatefulWidget {
  const StrategyForecastsPage({super.key});

  @override
  State<StrategyForecastsPage> createState() => _StrategyForecastsPageState();
}

class _StrategyForecastsPageState extends State<StrategyForecastsPage>
    with _StrategyRefresh {
  Future<StrategyForecastsData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindStrategyRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<StrategyForecastsData> _load() => context
      .read<StrategyRepository>()
      .forecasts(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previsões')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<StrategyForecastsData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final d = snap.data!;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                _cacheBanner(
                  context,
                  fromCache: d.fromCache,
                  age: d.cacheAgeLabel,
                ),
                Card(
                  child: ListTile(
                    title: Text('Modelo ${d.model} · ${d.horizonDays}d'),
                    subtitle: Text(
                      'Abertos agora ${d.currentOpen} · Previstos ${d.predictedOpen.toStringAsFixed(0)}\n'
                      'Prazo (SLA): ${d.slaOutlook}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...d.protocols
                    .take(14)
                    .map(
                      (p) => ListTile(
                        dense: true,
                        title: Text(p.date),
                        subtitle: Text(
                          'Criados ${p.predictedCreated.toStringAsFixed(0)} · '
                          'Resolvidos ${p.predictedResolved.toStringAsFixed(0)} · '
                          'Δ ${p.netBacklogDelta.toStringAsFixed(0)}',
                        ),
                      ),
                    ),
                ...d.findings.map(
                  (f) => Card(
                    child: ListTile(
                      title: Text(f.title),
                      subtitle: Text(f.summary),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StrategyReportsPage extends StatefulWidget {
  const StrategyReportsPage({super.key});

  @override
  State<StrategyReportsPage> createState() => _StrategyReportsPageState();
}

class _StrategyReportsPageState extends State<StrategyReportsPage> {
  Future<List<StrategyReportItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<StrategyRepository>().reports(
      tenantSlug: _tenantOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios estratégicos'),
        actions: [
          TextButton(
            onPressed: () => context.push('/home/mandate/reports'),
            child: const Text('Mandato'),
          ),
        ],
      ),
      body: FutureBuilder<List<StrategyReportItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<StrategyRepository>().reports(
                  tenantSlug: _tenantOf(context),
                );
              }),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(
              message: 'Nenhum relatório estratégico publicado ainda.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = items[i];
              return Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text(uiStatusLabel(r.status)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StrategyGoalsPage extends StatefulWidget {
  const StrategyGoalsPage({super.key});

  @override
  State<StrategyGoalsPage> createState() => _StrategyGoalsPageState();
}

class _StrategyGoalsPageState extends State<StrategyGoalsPage> {
  Future<List<StrategyGoal>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<StrategyRepository>().goals(
      tenantSlug: _tenantOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      body: FutureBuilder<List<StrategyGoal>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.error is EndpointUnavailableException) {
            final err = snap.error! as EndpointUnavailableException;
            return EndpointPendingState(
              path: err.path,
              message:
                  'Metas estratégicas preparadas. Contrato /v1/strategy/goals ainda instável (404/500).',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<StrategyRepository>().goals(
                  tenantSlug: _tenantOf(context),
                );
              }),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Nenhuma meta publicada.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final g = items[i];
              return Card(
                child: ListTile(
                  title: Text(g.title),
                  subtitle: Text(
                    [
                      if (g.current != null) 'atual ${g.current}',
                      if (g.target != null) 'meta ${g.target}',
                      g.unit,
                      g.status,
                    ].whereType<String>().join(' · '),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Mapa: tenta contrato strategy/map; se pending, reusa mapa do mandato.
class StrategyMapPage extends StatefulWidget {
  const StrategyMapPage({super.key});

  @override
  State<StrategyMapPage> createState() => _StrategyMapPageState();
}

class _StrategyMapPageState extends State<StrategyMapPage> {
  Future<_MapProbe>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _probe();
  }

  Future<_MapProbe> _probe() async {
    final repo = context.read<StrategyRepository>();
    try {
      await repo.strategyMapContract();
      return const _MapProbe(dedicatedLive: true);
    } on EndpointUnavailableException {
      return const _MapProbe(dedicatedLive: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa estratégico')),
      body: FutureBuilder<_MapProbe>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() => _future = _probe()),
            );
          }
          final dedicated = snap.data?.dedicatedLive ?? false;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!dedicated)
                EndpointPendingState(
                  path: AuthMode.staff.strategyMapPath,
                  message:
                      'Mapa estratégico dedicado pendente. Reutilize o mapa territorial do mandato.',
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.push('/home/mandate/map'),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Abrir mapa do mandato (ativo)'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => context.push('/home/strategy/heatmap'),
                icon: const Icon(Icons.bubble_chart_outlined),
                label: const Text('Ver heatmap estratégico'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapProbe {
  const _MapProbe({required this.dedicatedLive});
  final bool dedicatedLive;
}
