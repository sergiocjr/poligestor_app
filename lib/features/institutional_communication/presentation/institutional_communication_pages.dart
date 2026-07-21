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
import '../data/institutional_communication_contracts.dart';
import '../data/institutional_communication_models.dart';
import '../data/institutional_communication_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _IcRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindIcRefresh(VoidCallback reload) {
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

/// Hub — Comunicação Institucional (Fase 15).
class InstitutionalCommunicationHubPage extends StatelessWidget {
  const InstitutionalCommunicationHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Feed de notícias',
      'Notícias institucionais',
      Icons.newspaper_outlined,
      'feed',
      '/home/institutional-communication/feed',
    ),
    _Entry(
      'Comunicados',
      'Avisos oficiais',
      Icons.campaign_outlined,
      'announcements',
      '/home/institutional-communication/announcements',
    ),
    _Entry(
      'Campanhas',
      'Campanhas de comunicação',
      Icons.flag_outlined,
      'campaigns',
      '/home/institutional-communication/campaigns',
    ),
    _Entry(
      'Biblioteca de mídia',
      'Imagens, vídeos e arquivos',
      Icons.photo_library_outlined,
      'media',
      '/home/institutional-communication/media',
    ),
    _Entry(
      'Publicações',
      'Conteúdos publicados',
      Icons.article_outlined,
      'publications',
      '/home/institutional-communication/publications',
    ),
    _Entry(
      'Agenda de publicações',
      'Programação editorial',
      Icons.event_note_outlined,
      'schedule',
      '/home/institutional-communication/schedule',
    ),
    _Entry(
      'Notificação push',
      'Envios push',
      Icons.notifications_active_outlined,
      'push',
      '/home/institutional-communication/push',
    ),
    _Entry(
      'E-mail',
      'Disparos por e-mail',
      Icons.mail_outline,
      'email',
      '/home/institutional-communication/email',
    ),
    _Entry(
      'WhatsApp',
      'Mensagens WhatsApp',
      Icons.chat_outlined,
      'whatsapp',
      '/home/institutional-communication/whatsapp',
    ),
    _Entry(
      'Histórico',
      'Envios e publicações',
      Icons.history_rounded,
      'history',
      '/home/institutional-communication/history',
    ),
    _Entry(
      'Pesquisa',
      'Buscar conteúdos',
      Icons.search_rounded,
      'search',
      '/home/institutional-communication/search',
    ),
    _Entry(
      'Filtros',
      'Filtros disponíveis',
      Icons.filter_list,
      'filters',
      '/home/institutional-communication/filters',
    ),
    _Entry(
      'Compartilhamento',
      'Links e compartilhamentos',
      Icons.share_outlined,
      'share',
      '/home/institutional-communication/share',
    ),
    _Entry(
      'Relatórios',
      'Indicadores de comunicação',
      Icons.summarize_outlined,
      'reports',
      '/home/institutional-communication/reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Comunicação Institucional')),
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
                  final live = institutionalCommunicationPathLive(e.slug);
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

typedef IcListLoader =
    Future<List<InstitutionalCommunicationItem>> Function(
      InstitutionalCommunicationRepository repo,
      String tenant,
    );

class InstitutionalCommunicationListPage extends StatefulWidget {
  const InstitutionalCommunicationListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final IcListLoader loader;
  final String emptyMessage;

  @override
  State<InstitutionalCommunicationListPage> createState() =>
      _InstitutionalCommunicationListPageState();
}

class _InstitutionalCommunicationListPageState
    extends State<InstitutionalCommunicationListPage>
    with _IcRefresh {
  Future<List<InstitutionalCommunicationItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindIcRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<InstitutionalCommunicationItem>> _load() => widget.loader(
    context.read<InstitutionalCommunicationRepository>(),
    _tenantOf(context),
  );

  void _openItem(InstitutionalCommunicationItem item) {
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
                if (item.channel != null) Text('Canal: ${item.channel}'),
                if (item.kind != null) Text('Tipo: ${item.kind}'),
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
        child: FutureBuilder<List<InstitutionalCommunicationItem>>(
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
            var items = snap.data ?? const <InstitutionalCommunicationItem>[];
            if (_query.trim().isNotEmpty) {
              final q = _query.trim().toLowerCase();
              items = items
                  .where(
                    (e) =>
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.channel ?? ''}'
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
                              Icons.campaign_outlined,
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
                              if (item.channel != null) item.channel!,
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

class InstitutionalCommunicationSearchPage extends StatefulWidget {
  const InstitutionalCommunicationSearchPage({super.key});

  @override
  State<InstitutionalCommunicationSearchPage> createState() =>
      _InstitutionalCommunicationSearchPageState();
}

class _InstitutionalCommunicationSearchPageState
    extends State<InstitutionalCommunicationSearchPage>
    with _IcRefresh {
  final _ctrl = TextEditingController();
  Future<List<InstitutionalCommunicationItem>>? _future;
  String _last = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindIcRefresh(() {
      if (_last.length >= 2) {
        setState(() => _future = _search(_last));
      }
    });
  }

  Future<List<InstitutionalCommunicationItem>> _search(String q) => context
      .read<InstitutionalCommunicationRepository>()
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
                hintText: 'Título, canal, assunto…',
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
                : FutureBuilder<List<InstitutionalCommunicationItem>>(
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
                      final items =
                          snap.data ?? const <InstitutionalCommunicationItem>[];
                      if (items.isEmpty) {
                        return const AppEmptyState(
                          message: 'Nenhum conteúdo encontrado.',
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
                                item.channel ?? item.summary ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context.push(
                                '/home/institutional-communication/history',
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
