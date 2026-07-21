import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/territorial_intelligence_contracts.dart';
import '../data/territorial_intelligence_models.dart';
import '../data/territorial_intelligence_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _TiRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindTiRefresh(VoidCallback reload) {
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

/// Hub — Inteligência Territorial (Fase 12).
class TerritorialIntelligenceHubPage extends StatelessWidget {
  const TerritorialIntelligenceHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel BI',
      'Visão executiva territorial',
      Icons.dashboard_outlined,
      'dashboard',
      '/home/territorial-intelligence/dashboard',
    ),
    _Entry(
      'Painel Analítico',
      'Visão analítica do território',
      Icons.analytics_outlined,
      'bi',
      '/home/territorial-intelligence/bi',
    ),
    _Entry(
      'Indicadores-chave',
      'KPIs do território',
      Icons.speed_outlined,
      'kpis',
      '/home/territorial-intelligence/kpis',
    ),
    _Entry(
      'Indicadores',
      'Métricas detalhadas',
      Icons.insights_outlined,
      'indicators',
      '/home/territorial-intelligence/indicators',
    ),
    _Entry(
      'Gráficos',
      'Séries e visualizações',
      Icons.bar_chart_outlined,
      'charts',
      '/home/territorial-intelligence/charts',
    ),
    _Entry(
      'Mapas de calor',
      'Concentração geográfica',
      Icons.bubble_chart_outlined,
      'heatmap',
      '/home/territorial-intelligence/heatmap',
    ),
    _Entry(
      'Mapa territorial',
      'Território e localidades',
      Icons.map_outlined,
      'map',
      '/home/territorial-intelligence/map',
    ),
    _Entry(
      'Bairros',
      'Análise por bairro',
      Icons.location_city_outlined,
      'neighborhoods',
      '/home/territorial-intelligence/neighborhoods',
    ),
    _Entry(
      'Regiões',
      'Análise regional',
      Icons.public_outlined,
      'regions',
      '/home/territorial-intelligence/regions',
    ),
    _Entry(
      'Zonas eleitorais',
      'Recorte eleitoral',
      Icons.how_to_vote_outlined,
      'electoral-zones',
      '/home/territorial-intelligence/electoral-zones',
    ),
    _Entry(
      'Lideranças',
      'Lideranças territoriais',
      Icons.groups_outlined,
      'leaderships',
      '/home/territorial-intelligence/leaderships',
    ),
    _Entry(
      'Demandas',
      'Demandas do território',
      Icons.inbox_outlined,
      'demands',
      '/home/territorial-intelligence/demands',
    ),
    _Entry(
      'Obras',
      'Obras no território',
      Icons.construction_outlined,
      'works',
      '/home/territorial-intelligence/works',
    ),
    _Entry(
      'Protocolos',
      'Protocolos territoriais',
      Icons.assignment_outlined,
      'protocols',
      '/home/territorial-intelligence/protocols',
    ),
    _Entry(
      'Atendimentos',
      'Atendimentos no território',
      Icons.support_agent_outlined,
      'attendances',
      '/home/territorial-intelligence/attendances',
    ),
    _Entry(
      'Comparativos',
      'Comparação de períodos',
      Icons.compare_arrows,
      'comparatives',
      '/home/territorial-intelligence/comparatives',
    ),
    _Entry(
      'Evolução',
      'Evolução temporal',
      Icons.show_chart,
      'evolution',
      '/home/territorial-intelligence/evolution',
    ),
    _Entry(
      'Tendências',
      'Tendências detectadas',
      Icons.trending_up,
      'trends',
      '/home/territorial-intelligence/trends',
    ),
    _Entry(
      'Projeções',
      'Projeções e cenários',
      Icons.timeline,
      'projections',
      '/home/territorial-intelligence/projections',
    ),
    _Entry(
      'Filtros',
      'Filtros territoriais',
      Icons.filter_list,
      'filters',
      '/home/territorial-intelligence/filters',
    ),
    _Entry(
      'Exportações',
      'Exportar relatórios',
      Icons.file_download_outlined,
      'exports',
      '/home/territorial-intelligence/exports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Inteligência Territorial')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              SoftNotice(
                message:
                    'Consome somente /v1/intelligence/*. Chip Ativo = contrato '
                    'Ativo = contrato publicado; Demonstração = conteúdo ilustrativo até sincronizar.',
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisExtent: cross == 1 ? 104 : 112,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  final live = territorialIntelligencePathLive(e.slug);
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push(e.route),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: live
                                  ? scheme.primary.withValues(alpha: 0.12)
                                  : scheme.surfaceContainerHighest,
                              child: Icon(
                                e.icon,
                                color: live
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    e.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    e.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                uiContractChip(available: live),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
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
  const _Entry(
    this.title,
    this.subtitle,
    this.icon,
    this.slug,
    this.route,
  );
  final String title;
  final String subtitle;
  final IconData icon;
  final String slug;
  final String route;
}

typedef TiListLoader =
    Future<List<TerritorialItem>> Function(
      TerritorialIntelligenceRepository repo,
      String tenant,
    );

class TerritorialIntelligenceListPage extends StatefulWidget {
  const TerritorialIntelligenceListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final TiListLoader loader;
  final String emptyMessage;

  @override
  State<TerritorialIntelligenceListPage> createState() =>
      _TerritorialIntelligenceListPageState();
}

class _TerritorialIntelligenceListPageState
    extends State<TerritorialIntelligenceListPage>
    with _TiRefresh {
  Future<List<TerritorialItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindTiRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<TerritorialItem>> _load() => widget.loader(
    context.read<TerritorialIntelligenceRepository>(),
    _tenantOf(context),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<TerritorialItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  SkeletonBox(height: 72, radius: 16),
                  SizedBox(height: 10),
                  SkeletonBox(height: 72, radius: 16),
                  SizedBox(height: 10),
                  SkeletonBox(height: 72, radius: 16),
                ],
              );
            }
            if (snap.error is EndpointUnavailableException) {
              final err = snap.error! as EndpointUnavailableException;
              return EndpointPendingState(
                path: err.path,
                message:
                    '${widget.title} preparado. Aguardando contrato ativo em /v1/intelligence.',
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            var items = snap.data ?? const <TerritorialItem>[];
            if (_query.trim().isNotEmpty) {
              final q = _query.trim().toLowerCase();
              items = items
                  .where(
                    (e) =>
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.region ?? ''} ${e.neighborhood ?? ''}'
                            .toLowerCase()
                            .contains(q),
                  )
                  .toList();
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(12),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Filtrar nesta lista',
                    prefixIcon: Icon(Icons.filter_list),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: AppEmptyState(message: widget.emptyMessage),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              if (item.code != null) item.code!,
                              if (item.status != null)
                                uiStatusLabel(item.status),
                              if (item.region != null) item.region!,
                              if (item.neighborhood != null)
                                item.neighborhood!,
                              if (item.value != null)
                                item.value!.toStringAsFixed(0),
                              if (item.summary != null) item.summary!,
                            ].join(' · '),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            'Informativo',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: scheme.outline),
                          ),
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

class TerritorialIntelligenceDashboardPage extends StatefulWidget {
  const TerritorialIntelligenceDashboardPage({super.key});

  @override
  State<TerritorialIntelligenceDashboardPage> createState() =>
      _TerritorialIntelligenceDashboardPageState();
}

class _TerritorialIntelligenceDashboardPageState
    extends State<TerritorialIntelligenceDashboardPage>
    with _TiRefresh {
  Future<TerritorialDashboard>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindTiRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<TerritorialDashboard> _load() => context
      .read<TerritorialIntelligenceRepository>()
      .dashboard(tenantSlug: _tenantOf(context));

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel BI'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<TerritorialDashboard>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done && !snap.hasData) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  SkeletonBox(height: 88, radius: 16),
                  SizedBox(height: 12),
                  SkeletonBox(height: 88, radius: 16),
                ],
              );
            }
            if (snap.error is EndpointUnavailableException) {
              final err = snap.error! as EndpointUnavailableException;
              return EndpointPendingState(
                path: err.path,
                message:
                    'Painel BI preparado. Aguardando /v1/intelligence/dashboard.',
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: _reload,
              );
            }
            final d = snap.data!;
            final items = <(String, String, IconData, String?)>[
              (
                'Indicadores-chave',
                '${d.kpisTotal}',
                Icons.speed_outlined,
                '/home/territorial-intelligence/kpis',
              ),
              (
                'Demandas abertas',
                '${d.demandsOpen}',
                Icons.inbox_outlined,
                '/home/territorial-intelligence/demands',
              ),
              (
                'Obras ativas',
                '${d.worksActive}',
                Icons.construction_outlined,
                '/home/territorial-intelligence/works',
              ),
              (
                'Protocolos abertos',
                '${d.protocolsOpen}',
                Icons.assignment_outlined,
                '/home/territorial-intelligence/protocols',
              ),
              (
                'Atendimentos',
                '${d.attendancesPeriod}',
                Icons.support_agent_outlined,
                '/home/territorial-intelligence/attendances',
              ),
              (
                'Bairros',
                '${d.neighborhoods}',
                Icons.location_city_outlined,
                '/home/territorial-intelligence/neighborhoods',
              ),
              (
                'Regiões',
                '${d.regions}',
                Icons.public_outlined,
                '/home/territorial-intelligence/regions',
              ),
              (
                'Lideranças',
                '${d.leaderships}',
                Icons.groups_outlined,
                '/home/territorial-intelligence/leaderships',
              ),
            ];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                if (d.fromCache)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SoftNotice(
                      message:
                          'Dados salvos ${d.cacheAgeLabel ?? ''}. Puxe para atualizar.',
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, box) {
                    final cols = box.maxWidth >= 600 ? 3 : 2;
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: box.maxWidth < 380 ? 1.2 : 1.35,
                      children: [
                        for (final (label, value, icon, route) in items)
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: route == null
                                  ? null
                                  : () => context.push(route),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(icon, size: 20, color: scheme.primary),
                                        const Spacer(),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: scheme.primary,
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        value,
                                        maxLines: 1,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      label,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
