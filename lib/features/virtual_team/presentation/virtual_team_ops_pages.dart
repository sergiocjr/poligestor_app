import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/virtual_team_models.dart';
import '../data/virtual_team_repository.dart';
import 'widgets/virtual_team_widgets.dart';

class VirtualTeamLogsPage extends StatefulWidget {
  const VirtualTeamLogsPage({super.key, this.agentSlug});

  final String? agentSlug;

  @override
  State<VirtualTeamLogsPage> createState() => _VirtualTeamLogsPageState();
}

class _VirtualTeamLogsPageState extends State<VirtualTeamLogsPage> {
  Future<VtPagedList<VtLogEntry>>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refresh = context.watch<MandateRefreshController>();
    if (!identical(_refreshCtrl, refresh)) {
      _refreshCtrl = refresh;
      _lastGen = refresh.generation;
    } else if (refresh.generation != _lastGen) {
      _lastGen = refresh.generation;
      _future = _load();
    }
    _future ??= _load();
  }

  Future<VtPagedList<VtLogEntry>> _load() => context
      .read<VirtualTeamRepository>()
      .logs(agentSlug: widget.agentSlug);

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.agentSlug == null ? 'Logs' : 'Logs · ${widget.agentSlug}',
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtLogEntry>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && !snap.hasData) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          final items = snap.data!.items;
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Nenhum log registrado.'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final e = items[i];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      e.level == 'error'
                          ? Icons.error_outline
                          : Icons.article_outlined,
                    ),
                    title: Text(e.message, maxLines: 3, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      [
                        e.source,
                        e.type,
                        if (e.agentSlug != null) e.agentSlug!,
                      ].join(' · '),
                    ),
                    trailing: Text(
                      vtFormatWhen(e.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VirtualTeamAuditPage extends StatefulWidget {
  const VirtualTeamAuditPage({super.key});

  @override
  State<VirtualTeamAuditPage> createState() => _VirtualTeamAuditPageState();
}

class _VirtualTeamAuditPageState extends State<VirtualTeamAuditPage> {
  Future<VtPagedList<VtAuditEntry>>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refresh = context.watch<MandateRefreshController>();
    if (!identical(_refreshCtrl, refresh)) {
      _refreshCtrl = refresh;
      _lastGen = refresh.generation;
    } else if (refresh.generation != _lastGen) {
      _lastGen = refresh.generation;
      _future = _load();
    }
    _future ??= _load();
  }

  Future<VtPagedList<VtAuditEntry>> _load() =>
      context.read<VirtualTeamRepository>().audit();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditoria'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtAuditEntry>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && !snap.hasData) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          final items = snap.data!.items;
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Nenhum registro de auditoria.');
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final e = items[i];
                return Card(
                  child: ListTile(
                    title: Text(e.decisionType),
                    subtitle: Text(
                      [
                        'por ${e.decidedBy}',
                        if (e.agentSlug != null) e.agentSlug!,
                        e.rationale,
                      ].join(' · '),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      vtFormatWhen(e.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VirtualTeamTimelinePage extends StatefulWidget {
  const VirtualTeamTimelinePage({super.key, this.agentSlug});

  final String? agentSlug;

  @override
  State<VirtualTeamTimelinePage> createState() =>
      _VirtualTeamTimelinePageState();
}

class _VirtualTeamTimelinePageState extends State<VirtualTeamTimelinePage> {
  Future<VtPagedList<VtTimelineItem>>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refresh = context.watch<MandateRefreshController>();
    if (!identical(_refreshCtrl, refresh)) {
      _refreshCtrl = refresh;
      _lastGen = refresh.generation;
    } else if (refresh.generation != _lastGen) {
      _lastGen = refresh.generation;
      _future = _load();
    }
    _future ??= _load();
  }

  Future<VtPagedList<VtTimelineItem>> _load() => context
      .read<VirtualTeamRepository>()
      .timeline(agentSlug: widget.agentSlug);

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.agentSlug == null
              ? 'Timeline'
              : 'Timeline · ${widget.agentSlug}',
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtTimelineItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && !snap.hasData) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          final items = snap.data!.items;
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Timeline vazia.');
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = items[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i < items.length - 1)
                          Container(
                            width: 2,
                            height: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: Text(e.title),
                          subtitle: Text(
                            [
                              e.kind,
                              if (e.agentSlug != null) e.agentSlug!,
                              if (e.body != null) e.body!,
                            ].join(' · '),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            vtFormatWhen(e.createdAt),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VirtualTeamAlertsPage extends StatefulWidget {
  const VirtualTeamAlertsPage({super.key});

  @override
  State<VirtualTeamAlertsPage> createState() => _VirtualTeamAlertsPageState();
}

class _VirtualTeamAlertsPageState extends State<VirtualTeamAlertsPage> {
  Future<VtPagedList<VtAlert>>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refresh = context.watch<MandateRefreshController>();
    if (!identical(_refreshCtrl, refresh)) {
      _refreshCtrl = refresh;
      _lastGen = refresh.generation;
    } else if (refresh.generation != _lastGen) {
      _lastGen = refresh.generation;
      _future = _load();
    }
    _future ??= _load();
  }

  Future<VtPagedList<VtAlert>> _load() =>
      context.read<VirtualTeamRepository>().alerts();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtAlert>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && !snap.hasData) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          final items = snap.data!.items;
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Nenhum alerta aberto.');
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final a = items[i];
                final high = a.severity == 'high' || a.severity == 'critical';
                return Card(
                  color: high
                      ? Theme.of(context)
                          .colorScheme
                          .errorContainer
                          .withValues(alpha: 0.35)
                      : null,
                  child: ListTile(
                    leading: Icon(
                      Icons.warning_amber_rounded,
                      color: high
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                    title: Text(a.title),
                    subtitle: Text(
                      [
                        a.severity,
                        a.status,
                        if (a.agentSlug != null) a.agentSlug!,
                        a.body,
                      ].join(' · '),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      vtFormatWhen(a.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VirtualTeamMetricsPage extends StatefulWidget {
  const VirtualTeamMetricsPage({super.key, this.agentSlug});

  final String? agentSlug;

  @override
  State<VirtualTeamMetricsPage> createState() => _VirtualTeamMetricsPageState();
}

class _VirtualTeamMetricsPageState extends State<VirtualTeamMetricsPage> {
  Future<VtDashboard>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refresh = context.watch<MandateRefreshController>();
    if (!identical(_refreshCtrl, refresh)) {
      _refreshCtrl = refresh;
      _lastGen = refresh.generation;
    } else if (refresh.generation != _lastGen) {
      _lastGen = refresh.generation;
      _future = _load();
    }
    _future ??= _load();
  }

  Future<VtDashboard> _load() => context
      .read<VirtualTeamRepository>()
      .metrics(agentSlug: widget.agentSlug);

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.agentSlug == null
              ? 'Métricas'
              : 'Métricas · ${widget.agentSlug}',
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtDashboard>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && !snap.hasData) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                VtKpiGrid(dashboard: snap.data!),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VirtualTeamSearchPage extends StatefulWidget {
  const VirtualTeamSearchPage({super.key});

  @override
  State<VirtualTeamSearchPage> createState() => _VirtualTeamSearchPageState();
}

class _VirtualTeamSearchPageState extends State<VirtualTeamSearchPage> {
  final _controller = TextEditingController();
  Future<VtSearchResults>? _future;
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;
    setState(() {
      _lastQuery = query;
      _future = context.read<VirtualTeamRepository>().search(query: query);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar tarefas, agentes, hand-offs…',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _run(_controller.text),
                ),
              ),
              onSubmitted: _run,
            ),
          ),
          Expanded(
            child: _future == null
                ? const AppEmptyState(
                    message: 'Digite um termo para pesquisar na Equipe Virtual.',
                    icon: Icons.search,
                  )
                : FutureBuilder<VtSearchResults>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done &&
                          !snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError && !snap.hasData) {
                        final err = snap.error;
                        if (err is ApiException && err.isForbidden) {
                          return const AppEmptyState(
                            message: 'Sem permissão para pesquisar.',
                            icon: Icons.lock_outline,
                          );
                        }
                        return AppErrorState(
                          error: err,
                          message: UserMessages.fromError(err),
                          onRetry: () => _run(_lastQuery),
                        );
                      }
                      final data = snap.data!;
                      if (data.isEmpty) {
                        return AppEmptyState(
                          message:
                              'Nenhum resultado para “${data.query}”.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${data.total} resultado(s) para “${data.query}”',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          ..._section('Tarefas', data.tasks),
                          ..._section('Agentes', data.agents),
                          ..._section('Hand-offs', data.handoffs),
                          ..._section('Memória', data.memory),
                          ..._section('Execuções', data.executions),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _section(String title, List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const [];
    return [
      ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      for (final row in rows)
        Card(
          child: ListTile(
            title: Text(
              '${row['title'] ?? row['name'] ?? row['id'] ?? row}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              [
                if (row['status'] != null) '${row['status']}',
                if (row['from_agent'] != null && row['to_agent'] != null)
                  '${row['from_agent']} → ${row['to_agent']}',
                if (row['slug'] != null) '${row['slug']}',
              ].where((e) => e.isNotEmpty).join(' · '),
            ),
          ),
        ),
    ];
  }
}
