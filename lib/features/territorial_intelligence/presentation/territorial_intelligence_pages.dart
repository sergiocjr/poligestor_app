import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
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
      '/home/territorial-intelligence/dashboard',
    ),
    _Entry(
      'Painel Analítico',
      'Visão analítica do território',
      Icons.analytics_outlined,
      '/home/territorial-intelligence/bi',
    ),
    _Entry(
      'Indicadores-chave',
      'KPIs do território',
      Icons.speed_outlined,
      '/home/territorial-intelligence/kpis',
    ),
    _Entry(
      'Indicadores',
      'Métricas detalhadas',
      Icons.insights_outlined,
      '/home/territorial-intelligence/indicators',
    ),
    _Entry(
      'Gráficos',
      'Séries e visualizações',
      Icons.bar_chart_outlined,
      '/home/territorial-intelligence/charts',
    ),
    _Entry(
      'Mapas de calor',
      'Concentração geográfica',
      Icons.bubble_chart_outlined,
      '/home/territorial-intelligence/heatmap',
    ),
    _Entry(
      'Mapa territorial',
      'Território e localidades',
      Icons.map_outlined,
      '/home/territorial-intelligence/map',
    ),
    _Entry(
      'Bairros',
      'Análise por bairro',
      Icons.location_city_outlined,
      '/home/territorial-intelligence/neighborhoods',
    ),
    _Entry(
      'Regiões',
      'Análise regional',
      Icons.public_outlined,
      '/home/territorial-intelligence/regions',
    ),
    _Entry(
      'Zonas eleitorais',
      'Recorte eleitoral',
      Icons.how_to_vote_outlined,
      '/home/territorial-intelligence/electoral-zones',
    ),
    _Entry(
      'Lideranças',
      'Lideranças territoriais',
      Icons.groups_outlined,
      '/home/territorial-intelligence/leaderships',
    ),
    _Entry(
      'Demandas',
      'Demandas do território',
      Icons.inbox_outlined,
      '/home/territorial-intelligence/demands',
    ),
    _Entry(
      'Obras',
      'Obras no território',
      Icons.construction_outlined,
      '/home/territorial-intelligence/works',
    ),
    _Entry(
      'Protocolos',
      'Protocolos territoriais',
      Icons.assignment_outlined,
      '/home/territorial-intelligence/protocols',
    ),
    _Entry(
      'Atendimentos',
      'Atendimentos no território',
      Icons.support_agent_outlined,
      '/home/territorial-intelligence/attendances',
    ),
    _Entry(
      'Comparativos',
      'Comparação de períodos',
      Icons.compare_arrows,
      '/home/territorial-intelligence/comparatives',
    ),
    _Entry(
      'Evolução',
      'Evolução temporal',
      Icons.show_chart,
      '/home/territorial-intelligence/evolution',
    ),
    _Entry(
      'Tendências',
      'Tendências detectadas',
      Icons.trending_up,
      '/home/territorial-intelligence/trends',
    ),
    _Entry(
      'Projeções',
      'Projeções e cenários',
      Icons.timeline,
      '/home/territorial-intelligence/projections',
    ),
    _Entry(
      'Filtros',
      'Filtros territoriais',
      Icons.filter_list,
      '/home/territorial-intelligence/filters',
    ),
    _Entry(
      'Exportações',
      'Exportar relatórios',
      Icons.file_download_outlined,
      '/home/territorial-intelligence/exports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inteligência Territorial')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisExtent: cross == 1 ? 96 : 112,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(uiContractChip(available: false)),
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
  const _Entry(this.title, this.subtitle, this.icon, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
        child: FutureBuilder<List<TerritorialItem>>(
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
              physics: const AlwaysScrollableScrollPhysics(),
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
                            ].join(' · '),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel BI territorial')),
      body: FutureBuilder<TerritorialDashboard>(
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
                  'Painel BI preparado. Aguardando /v1/intelligence/dashboard.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final d = snap.data!;
          final items = <(String, String, IconData)>[
            ('Indicadores-chave', '${d.kpisTotal}', Icons.speed_outlined),
            ('Demandas abertas', '${d.demandsOpen}', Icons.inbox_outlined),
            ('Obras ativas', '${d.worksActive}', Icons.construction_outlined),
            (
              'Protocolos abertos',
              '${d.protocolsOpen}',
              Icons.assignment_outlined,
            ),
            (
              'Atendimentos',
              '${d.attendancesPeriod}',
              Icons.support_agent_outlined,
            ),
            ('Bairros', '${d.neighborhoods}', Icons.location_city_outlined),
            ('Regiões', '${d.regions}', Icons.public_outlined),
            ('Lideranças', '${d.leaderships}', Icons.groups_outlined),
          ];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (d.fromCache)
                Text(
                  'Dados salvos ${d.cacheAgeLabel ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              LayoutBuilder(
                builder: (context, box) {
                  final cols = box.maxWidth >= 600 ? 3 : 2;
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
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  label,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
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
    );
  }
}
