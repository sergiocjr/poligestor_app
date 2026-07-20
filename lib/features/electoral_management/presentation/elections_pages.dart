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
import '../data/elections_contracts.dart';
import '../data/elections_models.dart';
import '../data/elections_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _ElectionsRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindElectionsRefresh(VoidCallback reload) {
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

/// Hub — Gestão Eleitoral (Fase 17).
class ElectionsHubPage extends StatelessWidget {
  const ElectionsHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel eleitoral',
      'Visão geral da gestão eleitoral',
      Icons.dashboard_outlined,
      'dashboard',
      '/home/elections/dashboard',
    ),
    _Entry(
      'Pré-campanha',
      'Preparação pré-campanha',
      Icons.flag_outlined,
      'pre-campaign',
      '/home/elections/pre-campaign',
    ),
    _Entry(
      'Campanhas',
      'Campanhas eleitorais',
      Icons.campaign_outlined,
      'campaigns',
      '/home/elections/campaigns',
    ),
    _Entry(
      'Candidatos',
      'Cadastro de candidatos',
      Icons.badge_outlined,
      'candidates',
      '/home/elections/candidates',
    ),
    _Entry(
      'Coordenação',
      'Coordenação de campanha',
      Icons.account_tree_outlined,
      'coordination',
      '/home/elections/coordination',
    ),
    _Entry(
      'Equipes',
      'Equipes de campanha',
      Icons.groups_outlined,
      'teams',
      '/home/elections/teams',
    ),
    _Entry(
      'Cabos eleitorais',
      'Rede de cabos eleitorais',
      Icons.handshake_outlined,
      'canvassers',
      '/home/elections/canvassers',
    ),
    _Entry(
      'Voluntários',
      'Equipe de voluntários',
      Icons.volunteer_activism_outlined,
      'volunteers',
      '/home/elections/volunteers',
    ),
    _Entry(
      'Lideranças',
      'Lideranças políticas',
      Icons.military_tech_outlined,
      'leaders',
      '/home/elections/leaders',
    ),
    _Entry(
      'Apoiadores',
      'Base de apoiadores',
      Icons.thumb_up_alt_outlined,
      'supporters',
      '/home/elections/supporters',
    ),
    _Entry(
      'Metas eleitorais',
      'Metas e objetivos',
      Icons.track_changes_outlined,
      'goals',
      '/home/elections/goals',
    ),
    _Entry(
      'Regiões',
      'Regiões de atuação',
      Icons.map_outlined,
      'regions',
      '/home/elections/regions',
    ),
    _Entry(
      'Bairros',
      'Bairros e localidades',
      Icons.location_city_outlined,
      'neighborhoods',
      '/home/elections/neighborhoods',
    ),
    _Entry(
      'Zonas eleitorais',
      'Zonas eleitorais',
      Icons.place_outlined,
      'electoral-zones',
      '/home/elections/electoral-zones',
    ),
    _Entry(
      'Seções eleitorais',
      'Seções de votação',
      Icons.pin_drop_outlined,
      'electoral-sections',
      '/home/elections/electoral-sections',
    ),
    _Entry(
      'Colégios eleitorais',
      'Locais de votação',
      Icons.apartment_outlined,
      'polling-stations',
      '/home/elections/polling-stations',
    ),
    _Entry(
      'Mapa eleitoral',
      'Mapa de cobertura',
      Icons.map_rounded,
      'map',
      '/home/elections/map',
    ),
    _Entry(
      'Agenda de campanha',
      'Agenda e compromissos',
      Icons.calendar_month_outlined,
      'campaign-agenda',
      '/home/elections/campaign-agenda',
    ),
    _Entry(
      'Eventos',
      'Eventos de campanha',
      Icons.event_outlined,
      'events',
      '/home/elections/events',
    ),
    _Entry(
      'Caminhadas',
      'Caminhadas e passeatas',
      Icons.directions_walk_outlined,
      'walks',
      '/home/elections/walks',
    ),
    _Entry(
      'Reuniões',
      'Reuniões agendadas',
      Icons.groups_2_outlined,
      'meetings',
      '/home/elections/meetings',
    ),
    _Entry(
      'Visitas',
      'Visitas e encontros',
      Icons.home_work_outlined,
      'visits',
      '/home/elections/visits',
    ),
    _Entry(
      'Comícios',
      'Comícios e atos públicos',
      Icons.stadium_outlined,
      'rallies',
      '/home/elections/rallies',
    ),
    _Entry(
      'Mobilizações',
      'Ações de mobilização',
      Icons.diversity_3_outlined,
      'mobilizations',
      '/home/elections/mobilizations',
    ),
    _Entry(
      'Materiais de campanha',
      'Materiais de divulgação',
      Icons.inventory_2_outlined,
      'campaign-materials',
      '/home/elections/campaign-materials',
    ),
    _Entry(
      'Estoque',
      'Controle de estoque',
      Icons.warehouse_outlined,
      'inventory',
      '/home/elections/inventory',
    ),
    _Entry(
      'Distribuição',
      'Distribuição de materiais',
      Icons.local_shipping_outlined,
      'distribution',
      '/home/elections/distribution',
    ),
    _Entry(
      'Solicitações de material',
      'Pedidos de material',
      Icons.request_page_outlined,
      'material-requests',
      '/home/elections/material-requests',
    ),
    _Entry(
      'Pesquisas eleitorais',
      'Pesquisas e enquetes',
      Icons.poll_outlined,
      'polls',
      '/home/elections/polls',
    ),
    _Entry(
      'Cenários',
      'Cenários eleitorais',
      Icons.schema_outlined,
      'scenarios',
      '/home/elections/scenarios',
    ),
    _Entry(
      'Intenção de voto',
      'Intenção de voto',
      Icons.how_to_vote_outlined,
      'vote-intention',
      '/home/elections/vote-intention',
    ),
    _Entry(
      'Rejeição',
      'Índices de rejeição',
      Icons.thumb_down_alt_outlined,
      'rejection',
      '/home/elections/rejection',
    ),
    _Entry(
      'Comparativos',
      'Comparativos eleitorais',
      Icons.compare_arrows_outlined,
      'comparatives',
      '/home/elections/comparatives',
    ),
    _Entry(
      'Projeções',
      'Projeções de resultado',
      Icons.trending_up_outlined,
      'projections',
      '/home/elections/projections',
    ),
    _Entry(
      'Desempenho por região',
      'Desempenho regional',
      Icons.area_chart_outlined,
      'regional-performance',
      '/home/elections/regional-performance',
    ),
    _Entry(
      'Prestação de contas',
      'Prestação de contas eleitoral',
      Icons.account_balance_outlined,
      'accountability',
      '/home/elections/accountability',
    ),
    _Entry(
      'Receitas',
      'Receitas de campanha',
      Icons.south_west_outlined,
      'revenues',
      '/home/elections/revenues',
    ),
    _Entry(
      'Despesas',
      'Despesas de campanha',
      Icons.north_east_outlined,
      'expenses',
      '/home/elections/expenses',
    ),
    _Entry(
      'Doações',
      'Doações recebidas',
      Icons.card_giftcard_outlined,
      'donations',
      '/home/elections/donations',
    ),
    _Entry(
      'Fornecedores',
      'Fornecedores de campanha',
      Icons.storefront_outlined,
      'suppliers',
      '/home/elections/suppliers',
    ),
    _Entry(
      'Comprovantes',
      'Comprovantes e documentos',
      Icons.receipt_long_outlined,
      'receipts',
      '/home/elections/receipts',
    ),
    _Entry(
      'Relatórios',
      'Relatórios eleitorais',
      Icons.summarize_outlined,
      'reports',
      '/home/elections/reports',
    ),
    _Entry(
      'Exportações',
      'Exportar dados',
      Icons.download_outlined,
      'exports',
      '/home/elections/exports',
    ),
    _Entry(
      'Pesquisa',
      'Buscar na gestão eleitoral',
      Icons.search_rounded,
      'search',
      '/home/elections/search',
    ),
    _Entry(
      'Filtros',
      'Filtros disponíveis',
      Icons.filter_list,
      'filters',
      '/home/elections/filters',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão Eleitoral')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final body = ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              SoftNotice(
                message:
                    'Namespace /v1/elections/* sincronizado. Chip Ativo = '
                    'HTTP 200; Em preparação = contrato ainda 404 na VPS.',
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
                  final live = electionsPathLive(e.slug);
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    e.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Chip(
                              label: Text(
                                uiContractChip(available: live),
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
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
          if (!wide) return body;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: body,
            ),
          );
        },
      ),
    );
  }
}

class _Entry {
  const _Entry(this.title, this.subtitle, this.icon, this.slug, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String slug;
  final String route;
}

typedef ElectionsListLoader =
    Future<List<ElectionsItem>> Function(
      ElectionsRepository repo,
      String tenant,
    );

class ElectionsListPage extends StatefulWidget {
  const ElectionsListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final ElectionsListLoader loader;
  final String emptyMessage;

  @override
  State<ElectionsListPage> createState() => _ElectionsListPageState();
}

class _ElectionsListPageState extends State<ElectionsListPage>
    with _ElectionsRefresh {
  Future<List<ElectionsItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindElectionsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<ElectionsItem>> _load() =>
      widget.loader(context.read<ElectionsRepository>(), _tenantOf(context));

  void _openItem(ElectionsItem item) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (item.code != null) Text('Código: ${item.code}'),
                if (item.region != null) Text('Região: ${item.region}'),
                if (item.kind != null) Text('Tipo: ${item.kind}'),
                if (item.supportLevel != null)
                  Text('Nível de apoio: ${item.supportLevel}'),
                if (item.status != null)
                  Text('Situação: ${uiStatusLabel(item.status)}'),
                if (item.date != null)
                  Text('Data: ${dateFmt.format(item.date!.toLocal())}'),
                if (item.summary != null) ...[
                  const SizedBox(height: 8),
                  Text(item.summary!),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
        child: FutureBuilder<List<ElectionsItem>>(
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
                ],
              );
            }
            if (snap.error is EndpointUnavailableException) {
              final err = snap.error! as EndpointUnavailableException;
              return EndpointPendingState(
                path: err.path,
                message:
                    '${widget.title} preparado. Aguardando contrato ativo '
                    'em /v1/elections.',
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            var items = snap.data ?? const <ElectionsItem>[];
            if (_query.trim().isNotEmpty) {
              final q = _query.trim().toLowerCase();
              items = items
                  .where(
                    (e) =>
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.region ?? ''}'
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
                    hintText: 'Filtrar nesta lista…',
                    prefixIcon: Icon(Icons.filter_list),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: AppEmptyState(
                      message: widget.emptyMessage,
                      icon: Icons.inbox_outlined,
                    ),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: scheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(
                              Icons.how_to_vote_outlined,
                              color: scheme.primary,
                            ),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              if (item.region != null) item.region!,
                              if (item.status != null)
                                uiStatusLabel(item.status),
                            ].where((s) => s.isNotEmpty).join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _openItem(item),
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

class ElectionsSearchPage extends StatefulWidget {
  const ElectionsSearchPage({super.key});

  @override
  State<ElectionsSearchPage> createState() => _ElectionsSearchPageState();
}

class _ElectionsSearchPageState extends State<ElectionsSearchPage>
    with _ElectionsRefresh {
  final _ctrl = TextEditingController();
  Future<List<ElectionsItem>>? _future;
  String _last = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindElectionsRefresh(() {
      if (_last.length >= 2) {
        setState(() => _future = _search(_last));
      }
    });
  }

  Future<List<ElectionsItem>> _search(String q) => context
      .read<ElectionsRepository>()
      .search(tenantSlug: _tenantOf(context), query: q);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Nome, região, código…',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                final q = v.trim();
                if (q.length < 2) {
                  setState(() {
                    _future = null;
                    _last = '';
                  });
                  return;
                }
                setState(() {
                  _last = q;
                  _future = _search(q);
                });
              },
            ),
          ),
          Expanded(
            child: _future == null
                ? const AppEmptyState(
                    message: 'Digite ao menos 2 caracteres para pesquisar.',
                    icon: Icons.search_rounded,
                  )
                : FutureBuilder<List<ElectionsItem>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.error is EndpointUnavailableException) {
                        final err =
                            snap.error! as EndpointUnavailableException;
                        return EndpointPendingState(
                          path: err.path,
                          message:
                              'Pesquisa preparada. Aguardando '
                              '/v1/elections/search.',
                        );
                      }
                      if (snap.hasError) {
                        return AppErrorState(
                          error: snap.error,
                          onRetry: () =>
                              setState(() => _future = _search(_last)),
                        );
                      }
                      final items = snap.data ?? const <ElectionsItem>[];
                      if (items.isEmpty) {
                        return const AppEmptyState(
                          message: 'Nenhum item encontrado.',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              title: Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                item.region ?? item.summary ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () =>
                                  context.push('/home/elections/candidates'),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
