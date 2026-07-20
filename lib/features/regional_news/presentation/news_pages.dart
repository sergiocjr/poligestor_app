import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/news_contracts.dart';
import '../data/news_models.dart';
import '../data/news_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

AuthMode _modeOf(BuildContext context) =>
    context.read<AuthController>().mode;

mixin _NewsRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindNewsRefresh(VoidCallback reload) {
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

Future<void> openNewsOriginal(BuildContext context, String? url) async {
  if (url == null || url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link da notícia indisponível.')),
    );
    return;
  }
  final uri = Uri.tryParse(url);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link inválido.')),
    );
    return;
  }
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o link.')),
    );
  }
}

Future<void> shareNewsLink(BuildContext context, RegionalNewsItem item) async {
  final link = item.originalUrl ?? '';
  if (link.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não há link para compartilhar.')),
    );
    return;
  }
  await Clipboard.setData(ClipboardData(text: '${item.title}\n$link'));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Link copiado para compartilhar.')),
  );
}

/// Card horizontal para a home do Gabinete (3–5 itens ou estado pendente).
class GabineteNewsHomeSection extends StatefulWidget {
  const GabineteNewsHomeSection({super.key});

  @override
  State<GabineteNewsHomeSection> createState() =>
      _GabineteNewsHomeSectionState();
}

class _GabineteNewsHomeSectionState extends State<GabineteNewsHomeSection>
    with _NewsRefresh {
  Future<List<RegionalNewsItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindNewsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<RegionalNewsItem>> _load() {
    if (!newsPathLive('mentions') && !newsPathLive('dashboard')) {
      return Future.error(
        EndpointUnavailableException(
          AuthMode.staff.newsMentionsPath,
          statusCode: 404,
        ),
      );
    }
    return context.read<NewsRepository>().recent(
      tenantSlug: _tenantOf(context),
      mode: _modeOf(context),
      limit: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Notícias regionais',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/home/news'),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        Text(
          'Atualizações da região e menções',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 196,
          child: FutureBuilder<List<RegionalNewsItem>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 180, radius: 16)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBox(height: 180, radius: 16)),
                  ],
                );
              }
              if (snap.error is EndpointUnavailableException) {
                final err = snap.error! as EndpointUnavailableException;
                return EndpointPendingState(path: err.path);
              }
              if (snap.hasError) {
                return AppErrorState(
                  message: 'Não foi possível carregar notícias.',
                  onRetry: () => setState(() => _future = _load()),
                );
              }
              final items = snap.data ?? const <RegionalNewsItem>[];
              if (items.isEmpty) {
                return const AppEmptyState(
                  message: 'Nenhuma notícia recente.',
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length.clamp(0, 5),
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return _HomeNewsCard(
                    item: item,
                    onTap: () => context.push('/home/news/${item.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeNewsCard extends StatelessWidget {
  const _HomeNewsCard({required this.item, required this.onTap});

  final RegionalNewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy');
    return SizedBox(
      width: 260,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: item.mentionsPolitician ? 2 : 0,
        color: item.mentionsPolitician
            ? scheme.tertiaryContainer.withValues(alpha: 0.55)
            : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.mentionsPolitician)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.campaign_outlined,
                          size: 18,
                          color: scheme.tertiary,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        item.source ?? 'Fonte',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: scheme.primary),
                      ),
                    ),
                    if (item.publishedAt != null)
                      Text(
                        dateFmt.format(item.publishedAt!.toLocal()),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    item.summary ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (item.mentionsPolitician)
                  Text(
                    'Menção ao político',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hub completo — feed, menções, favoritos e alertas.
class NewsHubPage extends StatefulWidget {
  const NewsHubPage({super.key});

  @override
  State<NewsHubPage> createState() => _NewsHubPageState();
}

class _NewsHubPageState extends State<NewsHubPage>
    with SingleTickerProviderStateMixin, _NewsRefresh {
  late final TabController _tabs;
  Future<List<RegionalNewsItem>>? _feedFuture;
  Future<List<RegionalNewsItem>>? _mentionsFuture;
  Future<List<RegionalNewsItem>>? _favoritesFuture;
  Future<List<RegionalNewsItem>>? _alertsFuture;
  Future<List<NewsFilterOption>>? _filtersFuture;

  String _query = '';
  String? _city;
  String? _source;
  String? _period;
  String? _topic;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindNewsRefresh(() => _reloadAll());
    _feedFuture ??= _loadFeed();
    _mentionsFuture ??= _loadMentions();
    _favoritesFuture ??= _loadFavorites();
    _alertsFuture ??= _loadAlerts();
    _filtersFuture ??= _loadFilters();
  }

  void _reloadAll() {
    setState(() {
      _feedFuture = _loadFeed();
      _mentionsFuture = _loadMentions();
      _favoritesFuture = _loadFavorites();
      _alertsFuture = _loadAlerts();
      _filtersFuture = _loadFilters();
    });
  }

  Future<List<RegionalNewsItem>> _loadFeed() {
    if (!newsPathLive('mentions')) {
      return Future.error(
        EndpointUnavailableException(
          AuthMode.staff.newsMentionsPath,
          statusCode: 404,
        ),
      );
    }
    return context.read<NewsRepository>().feed(
      tenantSlug: _tenantOf(context),
      mode: _modeOf(context),
      city: _city,
      source: _source,
      period: _period,
      topic: _topic,
      q: _query.isEmpty ? null : _query,
    );
  }

  Future<List<RegionalNewsItem>> _loadMentions() {
    if (!newsPathLive('mentions')) {
      return Future.error(
        EndpointUnavailableException(
          AuthMode.staff.newsMentionsPath,
          statusCode: 404,
        ),
      );
    }
    return context.read<NewsRepository>().mentions(
      tenantSlug: _tenantOf(context),
      mode: _modeOf(context),
    );
  }

  Future<List<RegionalNewsItem>> _loadFavorites() {
    if (!newsPathLive('favorites')) {
      return Future.error(
        EndpointUnavailableException(
          AuthMode.staff.newsFavoritesPath,
          statusCode: 404,
        ),
      );
    }
    return context.read<NewsRepository>().favorites(
      tenantSlug: _tenantOf(context),
      mode: _modeOf(context),
    );
  }

  Future<List<RegionalNewsItem>> _loadAlerts() {
    if (!newsPathLive('alerts')) {
      return Future.error(
        EndpointUnavailableException(
          AuthMode.staff.newsAlertsPath,
          statusCode: 404,
        ),
      );
    }
    return context.read<NewsRepository>().alerts(
      tenantSlug: _tenantOf(context),
      mode: _modeOf(context),
    );
  }

  Future<List<NewsFilterOption>> _loadFilters() {
    if (!newsPathLive('sources') && !newsPathLive('filters')) {
      return Future.value(const <NewsFilterOption>[]);
    }
    return context.read<NewsRepository>().filters(
      tenantSlug: _tenantOf(context),
      mode: _modeOf(context),
    );
  }

  Future<void> _openFiltersSheet() async {
    final options = await (_filtersFuture ?? _loadFilters());
    if (!mounted) return;
    if (!newsPathLive('sources') && !newsPathLive('filters')) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => const Padding(
          padding: EdgeInsets.all(16),
          child: EndpointPendingState(path: '/v1/news/filters'),
        ),
      );
      return;
    }
    String? city = _city;
    String? source = _source;
    String? period = _period;
    String? topic = _topic;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            List<NewsFilterOption> ofGroup(String g) => options
                .where(
                  (o) =>
                      (o.group ?? '').toLowerCase().contains(g) ||
                      o.group == null,
                )
                .toList();
            Widget chipRow(String label, List<NewsFilterOption> opts, String? selected, ValueChanged<String?> onPick) {
              if (opts.isEmpty) {
                return Text(
                  '$label: nenhum filtro publicado.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Todas'),
                        selected: selected == null,
                        onSelected: (_) => setLocal(() => onPick(null)),
                      ),
                      ...opts.map(
                        (o) => FilterChip(
                          label: Text(o.label),
                          selected: selected == o.id,
                          onSelected: (_) => setLocal(() => onPick(o.id)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filtros',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    chipRow('Cidade', ofGroup('city'), city, (v) => city = v),
                    const SizedBox(height: 12),
                    chipRow('Fonte', ofGroup('source'), source, (v) => source = v),
                    const SizedBox(height: 12),
                    chipRow('Período', ofGroup('period'), period, (v) => period = v),
                    const SizedBox(height: 12),
                    chipRow('Assunto', ofGroup('topic'), topic, (v) => topic = v),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _city = city;
                          _source = source;
                          _period = period;
                          _topic = topic;
                          _feedFuture = _loadFeed();
                        });
                      },
                      child: const Text('Aplicar filtros'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notícias regionais'),
        actions: [
          IconButton(
            tooltip: 'Filtros',
            onPressed: _openFiltersSheet,
            icon: const Icon(Icons.filter_list_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Recentes'),
            Tab(text: 'Menções ao político'),
            Tab(text: 'Favoritos'),
            Tab(text: 'Alertas'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar notícias',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    if (!newsPathLive('mentions')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Busca indisponível no momento.',
                          ),
                        ),
                      );
                      return;
                    }
                    setState(() => _feedFuture = _loadFeed());
                    _tabs.animateTo(0);
                  },
                ),
              ),
              onChanged: (v) => _query = v.trim(),
              onSubmitted: (v) {
                _query = v.trim();
                setState(() => _feedFuture = _loadFeed());
                _tabs.animateTo(0);
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _NewsListPane(
                  future: _feedFuture,
                  emptyMessage: 'Nenhuma notícia encontrada.',
                  onRefresh: () async {
                    setState(() => _feedFuture = _loadFeed());
                    await _feedFuture;
                  },
                ),
                _NewsListPane(
                  future: _mentionsFuture,
                  emptyMessage: 'Nenhuma menção ao político.',
                  onRefresh: () async {
                    setState(() => _mentionsFuture = _loadMentions());
                    await _mentionsFuture;
                  },
                ),
                _NewsListPane(
                  future: _favoritesFuture,
                  emptyMessage: 'Nenhum favorito salvo.',
                  onRefresh: () async {
                    setState(() => _favoritesFuture = _loadFavorites());
                    await _favoritesFuture;
                  },
                ),
                _NewsListPane(
                  future: _alertsFuture,
                  emptyMessage: 'Nenhum alerta de menção.',
                  onRefresh: () async {
                    setState(() => _alertsFuture = _loadAlerts());
                    await _alertsFuture;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsListPane extends StatelessWidget {
  const _NewsListPane({
    required this.future,
    required this.emptyMessage,
    required this.onRefresh,
  });

  final Future<List<RegionalNewsItem>>? future;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: FutureBuilder<List<RegionalNewsItem>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 96, radius: 16),
                SizedBox(height: 10),
                SkeletonBox(height: 96, radius: 16),
              ],
            );
          }
          if (snap.error is EndpointUnavailableException) {
            final err = snap.error! as EndpointUnavailableException;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                EndpointPendingState(
                  path: err.path,
                  message:
                      'Área preparada. Aguardando contrato ativo em /v1/news.',
                ),
              ],
            );
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                AppErrorState(
                  message: 'Não foi possível carregar as notícias.',
                  onRetry: () => onRefresh(),
                ),
              ],
            );
          }
          final items = snap.data ?? const <RegionalNewsItem>[];
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [AppEmptyState(message: emptyMessage)],
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return _NewsTile(
                item: item,
                onTap: () => context.push('/home/news/${item.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.item, required this.onTap});

  final RegionalNewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      color: item.mentionsPolitician
          ? scheme.tertiaryContainer.withValues(alpha: 0.45)
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: item.imageUrl == null
                      ? ColoredBox(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.newspaper_outlined,
                            color: scheme.onSurfaceVariant,
                          ),
                        )
                      : Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: scheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.mentionsPolitician)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.campaign_outlined,
                              size: 16,
                              color: scheme.tertiary,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (item.source != null) item.source!,
                        if (item.publishedAt != null)
                          dateFmt.format(item.publishedAt!.toLocal()),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (item.summary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key, required this.id});

  final String id;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  Future<RegionalNewsItem>? _future;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<RegionalNewsItem> _load() {
    if (!newsPathLive('detail')) {
      return Future.error(
        EndpointUnavailableException(
          AuthMode.staff.newsItemPath(widget.id),
          statusCode: 404,
        ),
      );
    }
    return context.read<NewsRepository>().detail(
      tenantSlug: _tenantOf(context),
      mode: _modeOf(context),
      id: widget.id,
    );
  }

  Future<void> _toggleFavorite(RegionalNewsItem item) async {
    if (!newsPathLive('favorites') || _busy) return;
    setState(() => _busy = true);
    try {
      final repo = context.read<NewsRepository>();
      if (item.favorite) {
        await repo.removeFavorite(mode: _modeOf(context), id: item.id);
      } else {
        await repo.addFavorite(mode: _modeOf(context), id: item.id);
      }
      if (!mounted) return;
      setState(() => _future = _load());
    } on EndpointUnavailableException {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar favoritos.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat("dd/MM/yyyy 'às' HH:mm");
    return Scaffold(
      appBar: AppBar(title: const Text('Notícia')),
      body: FutureBuilder<RegionalNewsItem>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: SkeletonBox(height: 220, radius: 16),
            );
          }
          if (snap.error is EndpointUnavailableException) {
            final err = snap.error! as EndpointUnavailableException;
            return EndpointPendingState(
              path: err.path,
              message:
                  'Detalhe preparado. Aguardando contrato ativo em /v1/news.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              message: 'Não foi possível carregar a notícia.',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final item = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              if (item.mentionsPolitician)
                SoftNotice(
                  message: 'Esta notícia menciona o político.',
                ),
              if (item.mentionsPolitician) const SizedBox(height: 10),
              if (item.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: scheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              if (item.imageUrl != null) const SizedBox(height: 12),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                [
                  if (item.source != null) item.source!,
                  if (item.city != null) item.city!,
                  if (item.publishedAt != null)
                    dateFmt.format(item.publishedAt!.toLocal()),
                ].join(' · '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (item.summary != null) ...[
                const SizedBox(height: 14),
                Text(item.summary!),
              ],
              const SizedBox(height: 8),
              Text(
                'A matéria completa permanece no site de origem.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => openNewsOriginal(context, item.originalUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir notícia original'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => shareNewsLink(context, item),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartilhar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: newsPathLive('favorites')
                    ? () => _toggleFavorite(item)
                    : null,
                icon: Icon(
                  item.favorite ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(
                  item.favorite ? 'Remover dos favoritos' : 'Salvar favorito',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

List<RouteBase> buildNewsChildRoutes() => [
  GoRoute(
    path: ':id',
    builder: (_, state) => NewsDetailPage(id: state.pathParameters['id']!),
  ),
];
