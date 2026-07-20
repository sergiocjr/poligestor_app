import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/communication_models.dart';
import '../data/communication_repository.dart';

/// Hub staff — Central de Comunicação (somente PoliGestor).
class CommunicationHubPage extends StatefulWidget {
  const CommunicationHubPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<CommunicationHubPage> createState() => _CommunicationHubPageState();
}

class _CommunicationHubPageState extends State<CommunicationHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Comunicação'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Conversas'),
            Tab(text: 'Canais'),
            Tab(text: 'Modelos'),
            Tab(text: 'Campanhas'),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final child = TabBarView(
            controller: _tabs,
            children: const [
              _OmnichannelInboxTab(),
              _ChannelsTab(),
              CommunicationTemplatesPage(embedded: true),
              CommunicationCampaignsPage(embedded: true),
            ],
          );
          if (!wide) return child;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _OmnichannelInboxTab extends StatefulWidget {
  const _OmnichannelInboxTab();

  @override
  State<_OmnichannelInboxTab> createState() => _OmnichannelInboxTabState();
}

class _OmnichannelSnapshot {
  const _OmnichannelSnapshot({
    required this.conversations,
    required this.queue,
    required this.operators,
  });

  final List<CommConversation> conversations;
  final CommQueueSnapshot queue;
  final List<CommOperator> operators;
}

class _OmnichannelInboxTabState extends State<_OmnichannelInboxTab>
    with _CommsRefresh {
  Future<_OmnichannelSnapshot>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindCommsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<_OmnichannelSnapshot> _load() async {
    final repo = context.read<CommunicationRepository>();
    final conversations = repo.conversations();
    final queue = repo.queue();
    final operators = repo.operators();
    return _OmnichannelSnapshot(
      conversations: await conversations,
      queue: await queue,
      operators: await operators,
    );
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<_OmnichannelSnapshot>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 88, radius: 14),
                SizedBox(height: 10),
                SkeletonBox(height: 72, radius: 14),
                SizedBox(height: 10),
                SkeletonBox(height: 72, radius: 14),
              ],
            );
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: AppErrorState(error: snap.error, onRetry: _reload),
                ),
              ],
            );
          }
          final data = snap.data!;
          final q = data.queue;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              Text(
                'Fila',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QueueChip(label: 'Na fila', value: q.queue),
                  _QueueChip(label: 'Atribuídas', value: q.assigned),
                  _QueueChip(label: 'Fechadas', value: q.closed),
                  _QueueChip(label: 'Operadores', value: q.operators),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Operadores',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (data.operators.isEmpty)
                const Card(
                  child: ListTile(title: Text('Nenhum operador disponível.')),
                )
              else
                ...data.operators.map(
                  (op) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: op.isOnline
                            ? Colors.green.shade100
                            : null,
                        child: Icon(
                          Icons.support_agent_outlined,
                          color: op.isOnline ? Colors.green.shade800 : null,
                        ),
                      ),
                      title: Text(
                        op.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        [
                          op.statusLabel,
                          if (op.email != null && op.email!.isNotEmpty)
                            op.email!,
                          '${op.activeConversations} ativa(s)',
                        ].join(' · '),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Conversas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (data.conversations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: AppEmptyState(message: 'Nenhuma conversa no momento.'),
                )
              else
                ...data.conversations.map((c) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.forum_outlined),
                      ),
                      title: Text(
                        c.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        [
                          c.statusLabel,
                          if (c.channelType != null &&
                              c.channelType!.isNotEmpty)
                            c.channelType!,
                          if (c.contactName != null &&
                              c.contactName!.isNotEmpty)
                            c.contactName!,
                          if (c.assignedTo != null && c.assignedTo!.isNotEmpty)
                            c.assignedTo!,
                          if (c.updatedAt != null)
                            dateFmt.format(c.updatedAt!.toLocal()),
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: c.unreadCount > 0
                          ? Badge(label: Text('${c.unreadCount}'))
                          : null,
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _QueueChip extends StatelessWidget {
  const _QueueChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        child: Text(
          '$value',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      label: Text(label),
    );
  }
}

mixin _CommsRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindCommsRefresh(VoidCallback reload) {
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

class _ChannelsTab extends StatefulWidget {
  const _ChannelsTab();

  @override
  State<_ChannelsTab> createState() => _ChannelsTabState();
}

class _ChannelsTabState extends State<_ChannelsTab> with _CommsRefresh {
  Future<List<CommChannel>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindCommsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<CommChannel>> _load() =>
      context.read<CommunicationRepository>().channels();

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<CommChannel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 72, radius: 14),
                SizedBox(height: 10),
                SkeletonBox(height: 72, radius: 14),
              ],
            );
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: AppErrorState(error: snap.error, onRetry: _reload),
                ),
              ],
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                AppEmptyState(message: 'Nenhum canal configurado.'),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = items[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(_channelIcon(c.type))),
                  title: Text(
                    c.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    [
                      c.typeLabel,
                      if (c.provider != null && c.provider!.isNotEmpty)
                        c.provider!,
                      if (c.isDefault) 'padrão',
                      c.isActive ? 'ativo' : 'inativo',
                    ].join(' · '),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _channelIcon(String? type) {
    return switch ((type ?? '').toLowerCase()) {
      'email' || 'e-mail' => Icons.email_outlined,
      'sms' => Icons.sms_outlined,
      'whatsapp' || 'wa' => Icons.chat_outlined,
      'push' => Icons.notifications_outlined,
      _ => Icons.hub_outlined,
    };
  }
}

class CommunicationTemplatesPage extends StatefulWidget {
  const CommunicationTemplatesPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<CommunicationTemplatesPage> createState() =>
      _CommunicationTemplatesPageState();
}

class _CommunicationTemplatesPageState extends State<CommunicationTemplatesPage>
    with _CommsRefresh {
  Future<List<CommTemplate>>? _future;
  final _search = TextEditingController();
  String? _channelType;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindCommsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<CommTemplate>> _load() {
    return context.read<CommunicationRepository>().templates(
      filter: CommunicationFilter(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
        channelType: _channelType,
      ),
    );
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: TextField(
            controller: _search,
            onChanged: (_) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 350), _reload);
            },
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Pesquisar modelos',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              for (final (id, label) in const [
                (null, 'Todos'),
                ('email', 'E-mail'),
                ('sms', 'SMS'),
                ('whatsapp', 'WhatsApp'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: _channelType == id,
                    onSelected: (_) => setState(() {
                      _channelType = id;
                      _future = _load();
                    }),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _reload,
            child: FutureBuilder<List<CommTemplate>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SkeletonBox(height: 88, radius: 14),
                      SizedBox(height: 10),
                      SkeletonBox(height: 88, radius: 14),
                    ],
                  );
                }
                if (snap.hasError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 280,
                        child: AppErrorState(
                          error: snap.error,
                          onRetry: _reload,
                        ),
                      ),
                    ],
                  );
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      AppEmptyState(message: 'Nenhum modelo encontrado.'),
                    ],
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        wide ? 24 : 12,
                        4,
                        wide ? 24 : 12,
                        24,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final t = items[i];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              t.isActive
                                  ? Icons.description_outlined
                                  : Icons.block_outlined,
                            ),
                            title: Text(
                              t.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              [
                                t.channelLabel,
                                if (t.subject != null && t.subject!.isNotEmpty)
                                  t.subject!,
                                t.isActive ? 'ativo' : 'inativo',
                              ].join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(
                              '/home/communication/templates/${t.id}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Modelos')),
      body: body,
    );
  }
}

class CommunicationTemplateDetailPage extends StatefulWidget {
  const CommunicationTemplateDetailPage({super.key, required this.id});

  final String id;

  @override
  State<CommunicationTemplateDetailPage> createState() =>
      _CommunicationTemplateDetailPageState();
}

class _CommunicationTemplateDetailPageState
    extends State<CommunicationTemplateDetailPage> {
  Future<CommTemplate>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<CommunicationRepository>().templateById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modelo')),
      body: FutureBuilder<CommTemplate>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<CommunicationRepository>().templateById(
                  widget.id,
                );
              }),
            );
          }
          final t = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                t.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(t.channelLabel)),
                  Chip(label: Text(t.isActive ? 'Ativo' : 'Inativo')),
                  if (t.slug != null) Chip(label: Text(t.slug!)),
                ],
              ),
              if (t.subject != null && t.subject!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Assunto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(t.subject!),
              ],
              const SizedBox(height: 16),
              Text(
                'Pré-visualização',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    (t.body == null || t.body!.trim().isEmpty)
                        ? 'Sem corpo de mensagem.'
                        : t.body!,
                  ),
                ),
              ),
              if (t.variables.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Variáveis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final v in t.variables) Chip(label: Text('{{ $v }}')),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Aplicação em conversas/campanhas fica disponível quando os '
                'endpoints de conversa estiverem ativos neste produto.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

class CommunicationCampaignsPage extends StatefulWidget {
  const CommunicationCampaignsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<CommunicationCampaignsPage> createState() =>
      _CommunicationCampaignsPageState();
}

class _CommunicationCampaignsPageState extends State<CommunicationCampaignsPage>
    with _CommsRefresh {
  Future<List<CommCampaign>>? _future;
  final _search = TextEditingController();
  String? _status;
  String _sort = '-created_at';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindCommsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<CommCampaign>> _load() {
    return context.read<CommunicationRepository>().campaigns(
      filter: CommunicationFilter(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
        status: _status,
        sort: _sort,
      ),
    );
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (_) {
                    _debounce?.cancel();
                    _debounce = Timer(
                      const Duration(milliseconds: 350),
                      _reload,
                    );
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Pesquisar campanhas',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Ordenar',
                initialValue: _sort,
                onSelected: (v) {
                  setState(() {
                    _sort = v;
                    _future = _load();
                  });
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: '-created_at',
                    child: Text('Mais recentes'),
                  ),
                  PopupMenuItem(
                    value: 'created_at',
                    child: Text('Mais antigas'),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.sort_rounded),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              for (final (id, label) in const [
                (null, 'Todas'),
                ('scheduled', 'Agendadas'),
                ('running', 'Em execução'),
                ('completed', 'Concluídas'),
                ('failed', 'Falhas'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: _status == id,
                    onSelected: (_) => setState(() {
                      _status = id;
                      _future = _load();
                    }),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _reload,
            child: FutureBuilder<List<CommCampaign>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SkeletonBox(height: 96, radius: 14),
                      SizedBox(height: 10),
                      SkeletonBox(height: 96, radius: 14),
                    ],
                  );
                }
                if (snap.hasError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 280,
                        child: AppErrorState(
                          error: snap.error,
                          onRetry: _reload,
                        ),
                      ),
                    ],
                  );
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      AppEmptyState(message: 'Nenhuma campanha encontrada.'),
                    ],
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = items[i];
                    final when = c.completedAt ?? c.startedAt ?? c.scheduledAt;
                    return Card(
                      child: ListTile(
                        title: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              [
                                c.statusLabel,
                                if (c.channelType != null) c.channelType!,
                                '${c.sentCount}/${c.totalRecipients} enviados',
                                if (when != null)
                                  dateFmt.format(when.toLocal()),
                              ].join(' · '),
                            ),
                            if (c.totalRecipients > 0) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(value: c.progress),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          '/home/communication/campaigns/${c.id}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Campanhas')),
      body: body,
    );
  }
}

class CommunicationCampaignDetailPage extends StatefulWidget {
  const CommunicationCampaignDetailPage({super.key, required this.id});

  final String id;

  @override
  State<CommunicationCampaignDetailPage> createState() =>
      _CommunicationCampaignDetailPageState();
}

class _CommunicationCampaignDetailPageState
    extends State<CommunicationCampaignDetailPage> {
  Future<CommCampaign>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<CommunicationRepository>().campaignById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Campanha')),
      body: FutureBuilder<CommCampaign>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<CommunicationRepository>().campaignById(
                  widget.id,
                );
              }),
            );
          }
          final c = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                c.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(c.statusLabel)),
                  if (c.channelType != null) Chip(label: Text(c.channelType!)),
                  if (c.segment != null) Chip(label: Text(c.segment!)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Métricas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Destinatários: ${c.totalRecipients}'),
                      Text('Enviados: ${c.sentCount}'),
                      Text('Falhas: ${c.failedCount}'),
                      if (c.totalRecipients > 0) ...[
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: c.progress),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Agenda / execução',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (c.scheduledAt != null)
                Text('Agendada: ${dateFmt.format(c.scheduledAt!.toLocal())}'),
              if (c.startedAt != null)
                Text('Início: ${dateFmt.format(c.startedAt!.toLocal())}'),
              if (c.completedAt != null)
                Text('Fim: ${dateFmt.format(c.completedAt!.toLocal())}'),
              if (c.subject != null && c.subject!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Assunto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(c.subject!),
              ],
              if (c.body != null && c.body!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Conteúdo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(c.body!),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
