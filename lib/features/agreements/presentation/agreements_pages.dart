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
import '../data/agreements_models.dart';
import '../data/agreements_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _AgreementsRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindAgreementsRefresh(VoidCallback reload) {
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

/// Hub — Painel de Convênios (Sprint 11.0).
class AgreementsHubPage extends StatelessWidget {
  const AgreementsHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel',
      'Indicadores de convênios',
      Icons.dashboard_outlined,
      '/home/agreements/dashboard',
      true,
    ),
    _Entry(
      'Convênios',
      'Lista e trâmite',
      Icons.handshake_outlined,
      '/home/agreements/list',
      true,
    ),
    _Entry(
      'Recursos',
      'Fontes e valores',
      Icons.account_balance_wallet_outlined,
      '/home/agreements/resources',
      false,
    ),
    _Entry(
      'Projetos',
      'Projetos vinculados',
      Icons.folder_outlined,
      '/home/agreements/projects',
      true,
    ),
    _Entry(
      'Execução',
      'Acompanhamento da execução',
      Icons.play_circle_outline,
      '/home/agreements/execution',
      true,
    ),
    _Entry(
      'Prestação de Contas',
      'Relatórios e prestações',
      Icons.receipt_long_outlined,
      '/home/agreements/accountability',
      true,
    ),
    _Entry(
      'Cronograma',
      'Marcos e prazos',
      Icons.calendar_month_outlined,
      '/home/agreements/schedule',
      false,
    ),
    _Entry(
      'Linha do Tempo',
      'Eventos do convênio',
      Icons.timeline,
      '/home/agreements/timeline',
      true,
    ),
    _Entry(
      'Documentos',
      'Documentação oficial',
      Icons.description_outlined,
      '/home/agreements/documents',
      true,
    ),
    _Entry(
      'Anexos',
      'Arquivos anexos',
      Icons.attach_file,
      '/home/agreements/attachments',
      false,
    ),
    _Entry(
      'Indicadores',
      'Métricas de desempenho',
      Icons.analytics_outlined,
      '/home/agreements/indicators',
      false,
    ),
    _Entry(
      'Relatórios',
      'Exportações',
      Icons.summarize_outlined,
      '/home/agreements/reports',
      true,
    ),
    _Entry(
      'Pesquisa',
      'Busca de convênios',
      Icons.search,
      '/home/agreements/search',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel de Convênios')),
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
                          label: Text(uiContractChip(available: e.live)),
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
  const _Entry(this.title, this.subtitle, this.icon, this.route, this.live);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool live;
}

typedef AgreementsListLoader =
    Future<List<AgreementsItem>> Function(
      AgreementsRepository repo,
      String tenant,
    );

class AgreementsListPage extends StatefulWidget {
  const AgreementsListPage({
    super.key,
    required this.title,
    required this.loader,
    required this.detailRoutePrefix,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final AgreementsListLoader loader;
  final String detailRoutePrefix;
  final String emptyMessage;

  @override
  State<AgreementsListPage> createState() => _AgreementsListPageState();
}

class _AgreementsListPageState extends State<AgreementsListPage>
    with _AgreementsRefresh {
  Future<List<AgreementsItem>>? _future;
  String _query = '';
  String? _statusFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAgreementsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<AgreementsItem>> _load() =>
      widget.loader(context.read<AgreementsRepository>(), _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
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
        child: FutureBuilder<List<AgreementsItem>>(
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
            var items = snap.data ?? const <AgreementsItem>[];
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
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.partner ?? ''}'
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
                              if (item.partner != null) item.partner!,
                              if (item.amount != null)
                                money.format(item.amount),
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

class AgreementsDashboardPage extends StatefulWidget {
  const AgreementsDashboardPage({super.key});

  @override
  State<AgreementsDashboardPage> createState() =>
      _AgreementsDashboardPageState();
}

class _AgreementsDashboardPageState extends State<AgreementsDashboardPage>
    with _AgreementsRefresh {
  Future<AgreementsDashboard>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAgreementsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<AgreementsDashboard> _load() => context
      .read<AgreementsRepository>()
      .dashboard(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel de convênios')),
      body: FutureBuilder<AgreementsDashboard>(
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
                  'Painel de convênios preparado. Aguardando /v1/grants/dashboard.',
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
            (
              'Convênios abertos',
              '${d.agreementsOpen}',
              Icons.handshake_outlined,
            ),
            (
              'Em execução',
              '${d.agreementsInProgress}',
              Icons.play_circle_outline,
            ),
            (
              'Concluídos',
              '${d.agreementsCompleted}',
              Icons.check_circle_outline,
            ),
            (
              'Recursos',
              '${d.resourcesActive}',
              Icons.account_balance_wallet_outlined,
            ),
            ('Projetos', '${d.projectsOpen}', Icons.folder_outlined),
            (
              'Execução pendente',
              '${d.executionPending}',
              Icons.pending_actions_outlined,
            ),
            (
              'Prestação de contas',
              '${d.accountabilityOpen}',
              Icons.receipt_long_outlined,
            ),
            (
              'Cronograma',
              '${d.scheduleUpcoming}',
              Icons.calendar_month_outlined,
            ),
            ('Documentos', '${d.documentsCount}', Icons.description_outlined),
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

class AgreementsDetailPage extends StatefulWidget {
  const AgreementsDetailPage({super.key, required this.id});

  final String id;

  @override
  State<AgreementsDetailPage> createState() => _AgreementsDetailPageState();
}

class _AgreementsDetailPageState extends State<AgreementsDetailPage> {
  Future<AgreementsItem>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AgreementsRepository>().agreementDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do convênio')),
      body: FutureBuilder<AgreementsItem>(
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
                _future = context.read<AgreementsRepository>().agreementDetail(
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
              if (item.partner != null) Text('Parceiro: ${item.partner}'),
              if (item.amount != null)
                Text('Valor: ${money.format(item.amount)}'),
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
                    onPressed: () => context.push('/home/agreements/timeline'),
                    child: const Text('Linha do tempo'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/agreements/documents'),
                    child: const Text('Documentos'),
                  ),
                  FilledButton.tonal(
                    onPressed: () =>
                        context.push('/home/agreements/attachments'),
                    child: const Text('Anexos'),
                  ),
                  FilledButton.tonal(
                    onPressed: () =>
                        context.push('/home/agreements/accountability'),
                    child: const Text('Prestação de contas'),
                  ),
                  FilledButton.tonal(
                    onPressed: () =>
                        context.push('/home/agreements/indicators'),
                    child: const Text('Indicadores'),
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

class AgreementsSearchPage extends StatefulWidget {
  const AgreementsSearchPage({super.key});

  @override
  State<AgreementsSearchPage> createState() => _AgreementsSearchPageState();
}

class _AgreementsSearchPageState extends State<AgreementsSearchPage> {
  Future<void>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AgreementsRepository>().search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa de convênios')),
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
                  'Pesquisa dedicada preparada. Aguardando /v1/grants/search.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<AgreementsRepository>().search();
              }),
            );
          }
          return EndpointPendingState(
            path: AuthMode.staff.agreementsSearchPath,
          );
        },
      ),
    );
  }
}
