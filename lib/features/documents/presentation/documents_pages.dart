import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/demo/demo_experience_pane.dart';
import '../../../shared/widgets/pg_design_system.dart';

import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/documents_contracts.dart';
import '../data/documents_models.dart';
import '../data/documents_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _DocsRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindDocsRefresh(VoidCallback reload) {
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

/// Hub — Gestão Documental (Fase 13).
class DocumentsHubPage extends StatelessWidget {
  const DocumentsHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Documentos',
      'Lista de documentos',
      Icons.folder_outlined,
      'list',
      '/home/documents/list',
    ),
    _Entry(
      'Pesquisa',
      'Buscar documentos',
      Icons.search_rounded,
      'search',
      '/home/documents/search',
    ),
    _Entry(
      'Filtros',
      'Filtros disponíveis',
      Icons.filter_list,
      'filters',
      '/home/documents/filters',
    ),
    _Entry(
      'Categorias',
      'Organização por categoria',
      Icons.category_outlined,
      'categories',
      '/home/documents/categories',
    ),
    _Entry(
      'Favoritos',
      'Documentos marcados',
      Icons.star_outline_rounded,
      'favorites',
      '/home/documents/favorites',
    ),
    _Entry(
      'Histórico',
      'Acessos e alterações',
      Icons.history_rounded,
      'history',
      '/home/documents/history',
    ),
    _Entry(
      'Linha do tempo',
      'Eventos do documento',
      Icons.timeline,
      'timeline',
      '/home/documents/timeline',
    ),
    _Entry(
      'Visualizador PDF',
      'Abrir documentos PDF',
      Icons.picture_as_pdf_outlined,
      'viewer',
      '/home/documents/viewer',
    ),
    _Entry(
      'Assinaturas',
      'Assinaturas digitais',
      Icons.draw_outlined,
      'signatures',
      '/home/documents/signatures',
    ),
    _Entry(
      'Aprovações',
      'Fluxo de aprovação',
      Icons.verified_outlined,
      'approvals',
      '/home/documents/approvals',
    ),
    _Entry(
      'Compartilhamento',
      'Links e permissões',
      Icons.share_outlined,
      'share',
      '/home/documents/share',
    ),
    _Entry(
      'Modelos',
      'Modelos de documento',
      Icons.description_outlined,
      'templates',
      '/home/documents/templates',
    ),
    _Entry(
      'Baixar',
      'Baixar arquivos',
      Icons.download_outlined,
      'download',
      '/home/documents/download',
    ),
    _Entry(
      'Enviar',
      'Enviar arquivos',
      Icons.upload_file_outlined,
      'upload',
      '/home/documents/upload',
    ),
    _Entry(
      'Anexos',
      'Anexos vinculados',
      Icons.attach_file_rounded,
      'attachments',
      '/home/documents/attachments',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão Documental')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              SoftNotice(
                message:
                    'Contratos documentais sincronizados. Todos os '
                    'módulos abaixo estão Ativos e consomem o contrato publicado.',
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisExtent: PgHubModuleTile.gridExtent(crossAxisCount: cross),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  final live = documentsPathLive(e.slug);
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
                                    maxLines: 3,
                                    softWrap: true,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(uiContractChip(available: live)),
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
  const _Entry(this.title, this.subtitle, this.icon, this.slug, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String slug;
  final String route;
}

typedef DocsListLoader =
    Future<List<DocumentItem>> Function(
      DocumentsRepository repo,
      String tenant,
    );

class DocumentsListPage extends StatefulWidget {
  const DocumentsListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum documento encontrado.',
  });

  final String title;
  final DocsListLoader loader;
  final String emptyMessage;

  @override
  State<DocumentsListPage> createState() => _DocumentsListPageState();
}

class _DocumentsListPageState extends State<DocumentsListPage> with _DocsRefresh {
  Future<List<DocumentItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindDocsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<DocumentItem>> _load() => widget.loader(
    context.read<DocumentsRepository>(),
    _tenantOf(context),
  );

  void _openItem(DocumentItem item) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
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
                if (item.category != null) Text('Categoria: ${item.category}'),
                if (item.status != null)
                  Text('Situação: ${uiStatusLabel(item.status)}'),
                if (item.updatedAt != null)
                  Text(
                    'Atualizado: ${dateFmt.format(item.updatedAt!.toLocal())}',
                  ),
                if (item.summary != null) ...[
                  const SizedBox(height: 8),
                  Text(item.summary!),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (item.url != null && item.url!.isNotEmpty)
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          final uri = Uri.tryParse(item.url!);
                          if (uri == null) return;
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(
                          item.isPdf
                              ? Icons.picture_as_pdf_outlined
                              : Icons.open_in_new_rounded,
                        ),
                        label: Text(item.isPdf ? 'Abrir PDF' : 'Abrir'),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
                if (item.url == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Detalhe informativo — sem arquivo vinculado.',
                      style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                      ),
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
        child: FutureBuilder<List<DocumentItem>>(
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
              return DemoExperiencePane(path: err.path);
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            var items = snap.data ?? const <DocumentItem>[];
            if (_query.trim().isNotEmpty) {
              final q = _query.trim().toLowerCase();
              items = items
                  .where(
                    (e) =>
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.category ?? ''}'
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
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                scheme.primary.withValues(alpha: 0.12),
                            child: Icon(
                              item.isPdf
                                  ? Icons.picture_as_pdf_outlined
                                  : Icons.description_outlined,
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
                              if (item.code != null) item.code!,
                              if (item.category != null) item.category!,
                              if (item.status != null)
                                uiStatusLabel(item.status),
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.primary,
                          ),
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

class DocumentsSearchPage extends StatefulWidget {
  const DocumentsSearchPage({super.key});

  @override
  State<DocumentsSearchPage> createState() => _DocumentsSearchPageState();
}

class _DocumentsSearchPageState extends State<DocumentsSearchPage>
    with _DocsRefresh {
  final _ctrl = TextEditingController();
  Future<List<DocumentItem>>? _future;
  String _last = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindDocsRefresh(() {
      if (_last.trim().length >= 2) {
        setState(() => _future = _search(_last));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<List<DocumentItem>> _search(String q) => context
      .read<DocumentsRepository>()
      .search(tenantSlug: _tenantOf(context), query: q);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa de documentos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Título, código, categoria…',
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
                : FutureBuilder<List<DocumentItem>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.error is EndpointUnavailableException) {
                        final err =
                            snap.error! as EndpointUnavailableException;
                        return DemoExperiencePane(path: err.path);
                      }
                      if (snap.hasError) {
                        return AppErrorState(
                          error: snap.error,
                          onRetry: () => setState(
                            () => _future = _search(_last),
                          ),
                        );
                      }
                      final items = snap.data ?? const <DocumentItem>[];
                      if (items.isEmpty) {
                        return const AppEmptyState(
                          message: 'Nenhum documento encontrado.',
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
                                [
                                  if (item.code != null) item.code!,
                                  if (item.category != null) item.category!,
                                ].join(' · '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context.push(
                                '/home/documents/viewer',
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
