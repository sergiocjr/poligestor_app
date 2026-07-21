import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/pg_design_system.dart';

import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/crm_contracts.dart';
import '../data/crm_models.dart';
import '../data/crm_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _CrmRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindCrmRefresh(VoidCallback reload) {
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

/// Hub — CRM Político (Fase 16).
class CrmHubPage extends StatelessWidget {
  const CrmHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel',
      'Visão geral do CRM',
      Icons.dashboard_outlined,
      'dashboard',
      '/home/crm/dashboard',
    ),
    _Entry(
      'Líderes',
      'Lideranças políticas',
      Icons.military_tech_outlined,
      'leaders',
      '/home/crm/leaders',
    ),
    _Entry(
      'Apoiadores',
      'Base de apoiadores',
      Icons.thumb_up_alt_outlined,
      'supporters',
      '/home/crm/supporters',
    ),
    _Entry(
      'Eleitores',
      'Cadastro de eleitores',
      Icons.how_to_vote_outlined,
      'voters',
      '/home/crm/voters',
    ),
    _Entry(
      'Voluntários',
      'Equipe de voluntários',
      Icons.volunteer_activism_outlined,
      'volunteers',
      '/home/crm/volunteers',
    ),
    _Entry(
      'Equipe',
      'Equipe do mandato',
      Icons.groups_outlined,
      'team',
      '/home/crm/team',
    ),
    _Entry(
      'Entidades',
      'Entidades cadastradas',
      Icons.apartment_outlined,
      'entities',
      '/home/crm/entities',
    ),
    _Entry(
      'Associações',
      'Associações e entidades',
      Icons.diversity_3_outlined,
      'associations',
      '/home/crm/associations',
    ),
    _Entry(
      'Igrejas',
      'Comunidades religiosas',
      Icons.church_outlined,
      'churches',
      '/home/crm/churches',
    ),
    _Entry(
      'Empresas',
      'Empresas e negócios',
      Icons.business_outlined,
      'companies',
      '/home/crm/companies',
    ),
    _Entry(
      'Influenciadores',
      'Influência digital e local',
      Icons.record_voice_over_outlined,
      'influencers',
      '/home/crm/influencers',
    ),
    _Entry(
      'Segmentação',
      'Segmentos de público',
      Icons.category_outlined,
      'segmentation',
      '/home/crm/segmentation',
    ),
    _Entry(
      'Etiquetas',
      'Marcadores e rótulos',
      Icons.label_outline,
      'tags',
      '/home/crm/tags',
    ),
    _Entry(
      'Grupos',
      'Grupos de relacionamento',
      Icons.group_work_outlined,
      'groups',
      '/home/crm/groups',
    ),
    _Entry(
      'Regiões',
      'Regiões de atuação',
      Icons.map_outlined,
      'regions',
      '/home/crm/regions',
    ),
    _Entry(
      'Bairros',
      'Bairros e localidades',
      Icons.location_city_outlined,
      'neighborhoods',
      '/home/crm/neighborhoods',
    ),
    _Entry(
      'Zonas eleitorais',
      'Zonas e seções',
      Icons.place_outlined,
      'electoral-zones',
      '/home/crm/electoral-zones',
    ),
    _Entry(
      'Histórico de relacionamento',
      'Linha do tempo de contatos',
      Icons.history_rounded,
      'relationship-history',
      '/home/crm/relationship-history',
    ),
    _Entry(
      'Interações',
      'Interações registradas',
      Icons.forum_outlined,
      'interactions',
      '/home/crm/interactions',
    ),
    _Entry(
      'Visitas',
      'Visitas e encontros',
      Icons.directions_walk_outlined,
      'visits',
      '/home/crm/visits',
    ),
    _Entry(
      'Ligações',
      'Chamadas telefônicas',
      Icons.call_outlined,
      'calls',
      '/home/crm/calls',
    ),
    _Entry(
      'Mensagens',
      'Mensagens enviadas',
      Icons.mail_outline,
      'messages',
      '/home/crm/messages',
    ),
    _Entry(
      'Reuniões',
      'Reuniões agendadas',
      Icons.event_outlined,
      'meetings',
      '/home/crm/meetings',
    ),
    _Entry(
      'Demandas vinculadas',
      'Demandas ligadas a contatos',
      Icons.assignment_outlined,
      'linked-demands',
      '/home/crm/linked-demands',
    ),
    _Entry(
      'Protocolos vinculados',
      'Protocolos ligados a contatos',
      Icons.description_outlined,
      'linked-protocols',
      '/home/crm/linked-protocols',
    ),
    _Entry(
      'Campanhas',
      'Campanhas de relacionamento',
      Icons.flag_outlined,
      'campaigns',
      '/home/crm/campaigns',
    ),
    _Entry(
      'Tarefas',
      'Tarefas do CRM',
      Icons.task_alt_outlined,
      'tasks',
      '/home/crm/tasks',
    ),
    _Entry(
      'Lembretes',
      'Lembretes e alertas',
      Icons.alarm_outlined,
      'reminders',
      '/home/crm/reminders',
    ),
    _Entry(
      'Nível de apoio',
      'Grau de apoio político',
      Icons.trending_up_outlined,
      'support-level',
      '/home/crm/support-level',
    ),
    _Entry(
      'Potencial de influência',
      'Capacidade de influência',
      Icons.insights_outlined,
      'influence-potential',
      '/home/crm/influence-potential',
    ),
    _Entry(
      'Relacionamentos',
      'Rede de relacionamentos',
      Icons.hub_outlined,
      'relationships',
      '/home/crm/relationships',
    ),
    _Entry(
      'Importação',
      'Importar contatos e dados',
      Icons.upload_file_outlined,
      'import',
      '/home/crm/import',
    ),
    _Entry(
      'Exportação',
      'Exportar dados do CRM',
      Icons.download_outlined,
      'export',
      '/home/crm/export',
    ),
    _Entry(
      'Pesquisa',
      'Buscar no CRM',
      Icons.search_rounded,
      'search',
      '/home/crm/search',
    ),
    _Entry(
      'Filtros',
      'Filtros disponíveis',
      Icons.filter_list,
      'filters',
      '/home/crm/filters',
    ),
    _Entry(
      'Indicadores',
      'Indicadores do CRM',
      Icons.analytics_outlined,
      'indicators',
      '/home/crm/indicators',
    ),
    _Entry(
      'Relatórios',
      'Relatórios de relacionamento',
      Icons.summarize_outlined,
      'reports',
      '/home/crm/reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('CRM Político')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final body = ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisExtent: PgHubModuleTile.gridExtent(
                    crossAxisCount: cross,
                  ),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  final live = crmPathLive(e.slug);
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
                                    maxLines: 3,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    e.subtitle,
                                    maxLines: 3,
                                    softWrap: true,
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

typedef CrmListLoader =
    Future<List<CrmItem>> Function(CrmRepository repo, String tenant);

class CrmListPage extends StatefulWidget {
  const CrmListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final CrmListLoader loader;
  final String emptyMessage;

  @override
  State<CrmListPage> createState() => _CrmListPageState();
}

class _CrmListPageState extends State<CrmListPage> with _CrmRefresh {
  Future<List<CrmItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindCrmRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<CrmItem>> _load() =>
      widget.loader(context.read<CrmRepository>(), _tenantOf(context));

  void _openItem(CrmItem item) {
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
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
        title: Text(widget.title, maxLines: 2, softWrap: true),
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
        child: FutureBuilder<List<CrmItem>>(
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
              return const AppEmptyState(
                message: 'Nenhum registro encontrado.',
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            var items = snap.data ?? const <CrmItem>[];
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
                              Icons.people_outline,
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

class CrmSearchPage extends StatefulWidget {
  const CrmSearchPage({super.key});

  @override
  State<CrmSearchPage> createState() => _CrmSearchPageState();
}

class _CrmSearchPageState extends State<CrmSearchPage> with _CrmRefresh {
  final _ctrl = TextEditingController();
  Future<List<CrmItem>>? _future;
  String _last = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindCrmRefresh(() {
      if (_last.length >= 2) {
        setState(() => _future = _search(_last));
      }
    });
  }

  Future<List<CrmItem>> _search(String q) => context
      .read<CrmRepository>()
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
                : FutureBuilder<List<CrmItem>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.error is EndpointUnavailableException) {
                        return const AppEmptyState(
                          message: 'Nenhum registro encontrado.',
                        );
                      }
                      if (snap.hasError) {
                        return AppErrorState(
                          error: snap.error,
                          onRetry: () =>
                              setState(() => _future = _search(_last)),
                        );
                      }
                      final items = snap.data ?? const <CrmItem>[];
                      if (items.isEmpty) {
                        return const AppEmptyState(
                          message: 'Nenhum contato encontrado.',
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
                              onTap: () => context.push(
                                '/home/crm/relationship-history',
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
    );
  }
}
