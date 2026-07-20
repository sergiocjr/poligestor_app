import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_mode.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/works_models.dart';
import '../data/works_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _WorksRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindWorksRefresh(VoidCallback reload) {
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

/// Hub — Painel Obras (Sprint 10.9).
class WorksHubPage extends StatelessWidget {
  const WorksHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel',
      'Indicadores de obras',
      Icons.dashboard_outlined,
      '/home/works/dashboard',
      false,
    ),
    _Entry(
      'Obras',
      'Lista e trâmite',
      Icons.construction_outlined,
      '/home/works/list',
      false,
    ),
    _Entry(
      'Demandas',
      'Solicitações de obras',
      Icons.inbox_outlined,
      '/home/works/demands',
      false,
    ),
    _Entry(
      'Fiscalizações',
      'Visitas e laudos',
      Icons.fact_check_outlined,
      '/home/works/inspections',
      false,
    ),
    _Entry(
      'Cronograma',
      'Marcos e prazos',
      Icons.calendar_month_outlined,
      '/home/works/schedule',
      false,
    ),
    _Entry(
      'Mapa',
      'Território (mandato ativo)',
      Icons.map_outlined,
      '/home/works/map',
      true,
    ),
    _Entry(
      'Linha do Tempo',
      'Eventos da obra',
      Icons.timeline,
      '/home/works/timeline',
      false,
    ),
    _Entry(
      'Fotos',
      'Registro fotográfico',
      Icons.photo_library_outlined,
      '/home/works/photos',
      false,
    ),
    _Entry(
      'Anexos',
      'Documentos',
      Icons.attach_file,
      '/home/works/attachments',
      false,
    ),
    _Entry(
      'Lista de verificação',
      'Itens de verificação',
      Icons.checklist_outlined,
      '/home/works/checklist',
      false,
    ),
    _Entry(
      'Indicadores',
      'Métricas de execução',
      Icons.analytics_outlined,
      '/home/works/indicators',
      false,
    ),
    _Entry(
      'Relatórios',
      'Exportações',
      Icons.description_outlined,
      '/home/works/reports',
      false,
    ),
    _Entry(
      'Pesquisa',
      'Busca de obras',
      Icons.search,
      '/home/works/search',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel Obras')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // A10 (~720) permanece 1 coluna; 2+ colunas só em tablet.
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisExtent: cross == 1 ? 104 : 112,
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
                          label: Text(uiContractChip(available: e.live)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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

class WorksPendingPage extends StatefulWidget {
  const WorksPendingPage({
    super.key,
    required this.title,
    required this.path,
    required this.probe,
  });

  final String title;
  final String path;
  final Future<void> Function(WorksRepository repo) probe;

  @override
  State<WorksPendingPage> createState() => _WorksPendingPageState();
}

class _WorksPendingPageState extends State<WorksPendingPage> {
  Future<void>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= widget.probe(context.read<WorksRepository>());
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
                  '${widget.title} preparado. Aguardando contrato ativo na VPS.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = widget.probe(context.read<WorksRepository>());
              }),
            );
          }
          return EndpointPendingState(path: widget.path);
        },
      ),
    );
  }
}

typedef WorksListLoader =
    Future<List<WorksItem>> Function(WorksRepository repo, String tenant);

class WorksListPage extends StatefulWidget {
  const WorksListPage({
    super.key,
    required this.title,
    required this.loader,
    required this.detailRoutePrefix,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final WorksListLoader loader;
  final String detailRoutePrefix;
  final String emptyMessage;

  @override
  State<WorksListPage> createState() => _WorksListPageState();
}

class _WorksListPageState extends State<WorksListPage> with _WorksRefresh {
  Future<List<WorksItem>>? _future;
  String _query = '';
  String? _statusFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindWorksRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<WorksItem>> _load() =>
      widget.loader(context.read<WorksRepository>(), _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
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
        child: FutureBuilder<List<WorksItem>>(
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
                    '${widget.title} preparado. Aguardando contrato ativo na VPS.',
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            var items = snap.data ?? const <WorksItem>[];
            final statuses =
                items.map((e) => e.status).whereType<String>().toSet().toList()
                  ..sort();
            if (_statusFilter != null) {
              items = items.where((e) => e.status == _statusFilter).toList();
            }
            if (_query.trim().isNotEmpty) {
              final q = _query.trim().toLowerCase();
              items = items
                  .where(
                    (e) =>
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.district ?? ''}'
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
                if (statuses.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: _statusFilter == null,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                      for (final s in statuses)
                        FilterChip(
                          label: Text(uiStatusLabel(s)),
                          selected: _statusFilter == s,
                          onSelected: (_) => setState(() => _statusFilter = s),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: AppEmptyState(message: widget.emptyMessage),
                  )
                else
                  ...items.map((item) {
                    return Padding(
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
                              if (item.district != null) item.district!,
                              if (item.dueAt != null)
                                fmt.format(item.dueAt!.toLocal()),
                              if (item.progressPct != null)
                                '${item.progressPct!.toStringAsFixed(0)}%',
                            ].join(' · '),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: item.id.isEmpty
                              ? null
                              : () => context.push(
                                  '${widget.detailRoutePrefix}/${item.id}',
                                ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WorksDashboardPage extends StatefulWidget {
  const WorksDashboardPage({super.key});

  @override
  State<WorksDashboardPage> createState() => _WorksDashboardPageState();
}

class _WorksDashboardPageState extends State<WorksDashboardPage>
    with _WorksRefresh {
  Future<WorksDashboard>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindWorksRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<WorksDashboard> _load() =>
      context.read<WorksRepository>().dashboard(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel de obras')),
      body: FutureBuilder<WorksDashboard>(
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
                  'Painel de obras preparado. Aguardando /v1/works/dashboard.',
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
            ('Obras abertas', '${d.worksOpen}', Icons.construction_outlined),
            ('Em execução', '${d.worksInProgress}', Icons.play_circle_outline),
            ('Concluídas', '${d.worksCompleted}', Icons.check_circle_outline),
            ('Demandas', '${d.demandsOpen}', Icons.inbox_outlined),
            (
              'Fiscalizações',
              '${d.inspectionsPending}',
              Icons.fact_check_outlined,
            ),
            (
              'Cronograma',
              '${d.scheduleUpcoming}',
              Icons.calendar_month_outlined,
            ),
            ('Lista de verificação', '${d.checklistOpen}', Icons.checklist_outlined),
            ('Fotos', '${d.photosCount}', Icons.photo_library_outlined),
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
                  final cols = box.maxWidth >= 600 ? 4 : 2;
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

class WorksDetailPage extends StatefulWidget {
  const WorksDetailPage({super.key, required this.id});

  final String id;

  @override
  State<WorksDetailPage> createState() => _WorksDetailPageState();
}

class _WorksDetailPageState extends State<WorksDetailPage> {
  Future<WorksItem>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<WorksRepository>().projectDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da obra')),
      body: FutureBuilder<WorksItem>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.error is EndpointUnavailableException) {
            final err = snap.error! as EndpointUnavailableException;
            return EndpointPendingState(
              path: err.path,
              message: 'Detalhe preparado. Aguardando contrato ativo.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<WorksRepository>().projectDetail(
                  widget.id,
                );
              }),
            );
          }
          final item = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (item.code != null) Text('Código: ${item.code}'),
              if (item.status != null)
                Text('Situação: ${uiStatusLabel(item.status)}'),
              if (item.kind != null) Text('Tipo: ${item.kind}'),
              if (item.district != null) Text('Bairro: ${item.district}'),
              if (item.progressPct != null)
                Text('Progresso: ${item.progressPct!.toStringAsFixed(0)}%'),
              if (item.startedAt != null)
                Text('Início: ${fmt.format(item.startedAt!.toLocal())}'),
              if (item.dueAt != null)
                Text('Prazo: ${fmt.format(item.dueAt!.toLocal())}'),
              const SizedBox(height: 12),
              Text(
                item.summary?.isNotEmpty == true
                    ? item.summary!
                    : 'Sem resumo.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/works/timeline'),
                    child: const Text('Linha do tempo'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/works/photos'),
                    child: const Text('Fotos'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/works/attachments'),
                    child: const Text('Anexos'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/works/checklist'),
                    child: const Text('Lista de verificação'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/works/map'),
                    child: const Text('Mapa'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Mapa: tenta `/v1/works/map`; se pendente, reusa mapa do mandato LIVE.
class WorksMapPage extends StatefulWidget {
  const WorksMapPage({super.key});

  @override
  State<WorksMapPage> createState() => _WorksMapPageState();
}

class _WorksMapPageState extends State<WorksMapPage> {
  Future<_MapProbe>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _probe();
  }

  Future<_MapProbe> _probe() async {
    final repo = context.read<WorksRepository>();
    try {
      await repo.worksMapContract();
      return const _MapProbe(dedicatedLive: true);
    } on EndpointUnavailableException {
      return const _MapProbe(dedicatedLive: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de obras')),
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
                  path: AuthMode.staff.worksMapPath,
                  message:
                      'Mapa dedicado de obras pendente. Use o mapa territorial do mandato.',
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.push('/home/mandate/map'),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Abrir mapa do mandato (ativo)'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => context.push('/home/works/list'),
                icon: const Icon(Icons.construction_outlined),
                label: const Text('Ver lista de obras'),
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

class WorksSearchPage extends StatefulWidget {
  const WorksSearchPage({super.key});

  @override
  State<WorksSearchPage> createState() => _WorksSearchPageState();
}

class _WorksSearchPageState extends State<WorksSearchPage> {
  Future<void>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<WorksRepository>().search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa de obras')),
      body: FutureBuilder<void>(
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
                  'Pesquisa dedicada preparada. Aguardando /v1/works/search.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<WorksRepository>().search();
              }),
            );
          }
          return EndpointPendingState(path: AuthMode.staff.worksSearchPath);
        },
      ),
    );
  }
}
