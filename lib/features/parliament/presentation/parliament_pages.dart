import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/parliament_models.dart';
import '../data/parliament_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _ParlRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindParlRefresh(VoidCallback reload) {
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

/// Hub — Painel Parlamentar (Sprint 10.8).
class ParliamentHubPage extends StatelessWidget {
  const ParliamentHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel',
      'Indicadores legislativos',
      Icons.dashboard_outlined,
      '/home/parliament/dashboard',
      true,
    ),
    _Entry(
      'Projetos de Lei',
      'Proposições e trâmite',
      Icons.gavel_outlined,
      '/home/parliament/bills',
      true,
    ),
    _Entry(
      'Projetos',
      'Catálogo de projetos',
      Icons.folder_outlined,
      '/home/parliament/projects',
      true,
    ),
    _Entry(
      'Indicações',
      'Indicações parlamentares',
      Icons.campaign_outlined,
      '/home/parliament/indications',
      true,
    ),
    _Entry(
      'Requerimentos',
      'Pedidos formais',
      Icons.request_page_outlined,
      '/home/parliament/requests',
      true,
    ),
    _Entry(
      'Moções',
      'Moções em trâmite',
      Icons.record_voice_over_outlined,
      '/home/parliament/motions',
      true,
    ),
    _Entry(
      'Emendas',
      'Emendas e execução',
      Icons.edit_note_outlined,
      '/home/parliament/amendments',
      true,
    ),
    _Entry(
      'Agenda',
      'Próximos itens',
      Icons.event_outlined,
      '/home/parliament/agenda',
      true,
    ),
    _Entry(
      'Sessões',
      'Sessões plenárias',
      Icons.groups_outlined,
      '/home/parliament/sessions',
      true,
    ),
    _Entry(
      'Votações',
      'Votações abertas',
      Icons.how_to_vote_outlined,
      '/home/parliament/votes',
      true,
    ),
    _Entry(
      'Promessas',
      'Compromissos públicos',
      Icons.handshake_outlined,
      '/home/parliament/promises',
      false,
    ),
    _Entry(
      'Base de Apoio',
      'Rede de apoio',
      Icons.diversity_3_outlined,
      '/home/parliament/support-base',
      true,
    ),
    _Entry(
      'Demandas',
      'Demandas em aberto',
      Icons.inbox_outlined,
      '/home/parliament/demands',
      true,
    ),
    _Entry(
      'Pesquisa',
      'Busca legislativa',
      Icons.search,
      '/home/parliament/search',
      true,
    ),
    _Entry(
      'Linha do Tempo',
      'Eventos legislativos',
      Icons.timeline,
      '/home/parliament/timeline',
      false,
    ),
    _Entry(
      'Histórico',
      'Auditoria parlamentar',
      Icons.history,
      '/home/parliament/history',
      false,
    ),
    _Entry(
      'Anexos',
      'Documentos anexos',
      Icons.attach_file,
      '/home/parliament/attachments',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel Parlamentar')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisExtent: 124,
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

class ParliamentPendingPage extends StatefulWidget {
  const ParliamentPendingPage({
    super.key,
    required this.title,
    required this.path,
    required this.probe,
  });

  final String title;
  final String path;
  final Future<void> Function(ParliamentRepository repo) probe;

  @override
  State<ParliamentPendingPage> createState() => _ParliamentPendingPageState();
}

class _ParliamentPendingPageState extends State<ParliamentPendingPage> {
  Future<void>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= widget.probe(context.read<ParliamentRepository>());
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
                _future = widget.probe(context.read<ParliamentRepository>());
              }),
            );
          }
          return EndpointPendingState(path: widget.path);
        },
      ),
    );
  }
}

class ParliamentDashboardPage extends StatefulWidget {
  const ParliamentDashboardPage({super.key});

  @override
  State<ParliamentDashboardPage> createState() =>
      _ParliamentDashboardPageState();
}

class _ParliamentDashboardPageState extends State<ParliamentDashboardPage>
    with _ParlRefresh {
  Future<ParliamentDashboard>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindParlRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<ParliamentDashboard> _load() => context
      .read<ParliamentRepository>()
      .dashboard(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel parlamentar'),
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
        child: FutureBuilder<ParliamentDashboard>(
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
            final c = d.counts;
            final items = <(String, String, IconData, String)>[
              (
                'Projetos de Lei',
                '${c.bills}',
                Icons.gavel_outlined,
                '/home/parliament/bills',
              ),
              (
                'Indicações',
                '${c.indications}',
                Icons.campaign_outlined,
                '/home/parliament/indications',
              ),
              (
                'Requerimentos',
                '${c.requests}',
                Icons.request_page_outlined,
                '/home/parliament/requests',
              ),
              (
                'Moções',
                '${c.motions}',
                Icons.record_voice_over_outlined,
                '/home/parliament/motions',
              ),
              (
                'Emendas',
                '${c.amendments}',
                Icons.edit_note_outlined,
                '/home/parliament/amendments',
              ),
              (
                'Sessões',
                '${c.sessions}',
                Icons.groups_outlined,
                '/home/parliament/sessions',
              ),
              (
                'Votações abertas',
                '${c.votesOpen}',
                Icons.how_to_vote_outlined,
                '/home/parliament/votes',
              ),
              (
                'Agenda',
                '${c.agendaUpcoming}',
                Icons.event_outlined,
                '/home/parliament/agenda',
              ),
              (
                'Promessas',
                '${c.promises}',
                Icons.handshake_outlined,
                '/home/parliament/promises',
              ),
              (
                'Base de apoio',
                '${c.supportBase}',
                Icons.diversity_3_outlined,
                '/home/parliament/support-base',
              ),
              (
                'Demandas abertas',
                '${c.demandsOpen}',
                Icons.inbox_outlined,
                '/home/parliament/demands',
              ),
              (
                'Comissões',
                '${c.commissions}',
                Icons.account_balance_outlined,
                '/home/parliament/dashboard',
              ),
            ];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                if (d.fromCache)
                  Text(
                    'Dados salvos ${d.cacheAgeLabel ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  'Fonte ativa: /v1/parliament/dashboard',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, box) {
                    final cols = box.maxWidth >= 900
                        ? 4
                        : (box.maxWidth >= 600 ? 3 : 2);
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.35,
                      children: [
                        for (final (label, value, icon, route) in items)
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.push(route),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(icon, size: 20),
                                    const Spacer(),
                                    Text(
                                      value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    Text(
                                      label,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
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

typedef ParliamentListLoader =
    Future<List<ParliamentItem>> Function(
      ParliamentRepository repo,
      String tenant,
    );

class ParliamentListPage extends StatefulWidget {
  const ParliamentListPage({
    super.key,
    required this.title,
    required this.loader,
    required this.detailRoutePrefix,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final ParliamentListLoader loader;
  final String detailRoutePrefix;
  final String emptyMessage;

  @override
  State<ParliamentListPage> createState() => _ParliamentListPageState();
}

class _ParliamentListPageState extends State<ParliamentListPage>
    with _ParlRefresh {
  Future<List<ParliamentItem>>? _future;
  String _query = '';
  String? _statusFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindParlRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<ParliamentItem>> _load() =>
      widget.loader(context.read<ParliamentRepository>(), _tenantOf(context));

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
        child: FutureBuilder<List<ParliamentItem>>(
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
            var items = snap.data ?? const <ParliamentItem>[];
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
                    (e) => '${e.number ?? ''} ${e.title} ${e.summary ?? ''}'
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
                              if (item.number != null) item.number!,
                              if (item.status != null)
                                uiStatusLabel(item.status),
                              if (item.kind != null) item.kind!,
                              if (item.filedAt != null)
                                fmt.format(item.filedAt!.toLocal()),
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

class ParliamentDetailPage extends StatefulWidget {
  const ParliamentDetailPage({
    super.key,
    required this.title,
    required this.id,
    required this.loader,
  });

  final String title;
  final String id;
  final Future<ParliamentItem> Function(ParliamentRepository repo) loader;

  @override
  State<ParliamentDetailPage> createState() => _ParliamentDetailPageState();
}

class _ParliamentDetailPageState extends State<ParliamentDetailPage> {
  Future<ParliamentItem>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= widget.loader(context.read<ParliamentRepository>());
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<ParliamentItem>(
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
                _future = widget.loader(context.read<ParliamentRepository>());
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
              if (item.number != null) Text('Número: ${item.number}'),
              if (item.status != null)
                Text('Situação: ${uiStatusLabel(item.status)}'),
              if (item.kind != null) Text('Tipo: ${item.kind}'),
              if (item.authors.isNotEmpty)
                Text('Autores: ${item.authors.join(', ')}'),
              if (item.filedAt != null)
                Text('Protocolado: ${fmt.format(item.filedAt!.toLocal())}'),
              if (item.createdAt != null)
                Text('Criado: ${fmt.format(item.createdAt!.toLocal())}'),
              const SizedBox(height: 16),
              Text('Resumo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                item.summary?.isNotEmpty == true
                    ? item.summary!
                    : 'Sem resumo.',
              ),
              const SizedBox(height: 16),
              Text(
                'Linha do tempo e anexos dedicados aguardam contratos específicos.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/parliament/timeline'),
                    child: const Text('Linha do tempo'),
                  ),
                  FilledButton.tonal(
                    onPressed: () =>
                        context.push('/home/parliament/attachments'),
                    child: const Text('Anexos'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/parliament/history'),
                    child: const Text('Histórico'),
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

class ParliamentSearchPage extends StatefulWidget {
  const ParliamentSearchPage({super.key});

  @override
  State<ParliamentSearchPage> createState() => _ParliamentSearchPageState();
}

class _ParliamentSearchPageState extends State<ParliamentSearchPage> {
  final _controller = TextEditingController();
  Future<List<ParliamentItem>>? _future;
  String? _serverPendingPath;

  Future<void> _run() async {
    final repo = context.read<ParliamentRepository>();
    final tenant = _tenantOf(context);
    setState(() {
      _serverPendingPath = null;
      _future = () async {
        try {
          await repo.search();
        } on EndpointUnavailableException catch (e) {
          _serverPendingPath = e.path;
        }
        return repo.localSearch(tenantSlug: tenant, query: _controller.text);
      }();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa parlamentar')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar proposições e demandas',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _run,
                ),
              ),
              onSubmitted: (_) => _run(),
            ),
            const SizedBox(height: 8),
            if (_serverPendingPath != null)
              Text(
                'Busca local nas listas ativas. Exemplos marcados como dados de demonstração.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _future == null
                  ? const AppEmptyState(
                      message: 'Digite um termo para pesquisar.',
                    )
                  : FutureBuilder<List<ParliamentItem>>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snap.hasError) {
                          return AppErrorState(
                            error: snap.error,
                            onRetry: _run,
                          );
                        }
                        final items = snap.data ?? const [];
                        if (items.isEmpty) {
                          return const AppEmptyState(
                            message: 'Nenhum resultado encontrado.',
                          );
                        }
                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final item = items[i];
                            return Card(
                              child: ListTile(
                                title: Text(item.title),
                                subtitle: Text(
                                  [
                                    if (item.number != null) item.number!,
                                    if (item.status != null)
                                      uiStatusLabel(item.status),
                                  ].join(' · '),
                                ),
                                onTap: item.id.isEmpty
                                    ? null
                                    : () => context.push(
                                        '/home/parliament/bills/${item.id}',
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
