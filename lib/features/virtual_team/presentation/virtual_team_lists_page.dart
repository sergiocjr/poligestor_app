import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/virtual_team_models.dart';
import '../data/virtual_team_repository.dart';
import 'widgets/virtual_team_widgets.dart';

/// Lista genérica com filtro de status opcional.
class VirtualTeamTasksPage extends StatefulWidget {
  const VirtualTeamTasksPage({super.key});

  @override
  State<VirtualTeamTasksPage> createState() => _VirtualTeamTasksPageState();
}

class _VirtualTeamTasksPageState extends State<VirtualTeamTasksPage> {
  Future<VtPagedList<VtTask>>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;
  String? _status;

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

  Future<VtPagedList<VtTask>> _load() => context
      .read<VirtualTeamRepository>()
      .tasks(filter: VirtualTeamFilter(status: _status));

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                for (final (id, label) in const [
                  (null, 'Todas'),
                  ('pending', 'Pendentes'),
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
            child: FutureBuilder<VtPagedList<VtTask>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError && !snap.hasData) {
                  return AppErrorState(
                    error: snap.error,
                    message: UserMessages.fromError(snap.error),
                    onRetry: _refresh,
                  );
                }
                final page = snap.data!;
                if (page.items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        AppEmptyState(
                          message: 'Nenhuma tarefa registrada ainda.',
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    itemCount: page.items.length,
                    itemBuilder: (context, i) {
                      final t = page.items[i];
                      return Card(
                        child: ListTile(
                          title: Text(t.title),
                          subtitle: Text(
                            [
                              t.status,
                              if (t.agentName != null || t.agentSlug != null)
                                t.agentName ?? t.agentSlug!,
                              if (t.priority != null) 'prio ${t.priority}',
                            ].join(' · '),
                          ),
                          trailing: t.createdAt == null
                              ? null
                              : Text(
                                  '${t.createdAt!.day}/${t.createdAt!.month}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VirtualTeamExecutionsPage extends StatefulWidget {
  const VirtualTeamExecutionsPage({super.key});

  @override
  State<VirtualTeamExecutionsPage> createState() =>
      _VirtualTeamExecutionsPageState();
}

class _VirtualTeamExecutionsPageState extends State<VirtualTeamExecutionsPage> {
  Future<VtPagedList<VtExecution>>? _future;
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

  Future<VtPagedList<VtExecution>> _load() =>
      context.read<VirtualTeamRepository>().executions();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Execuções'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtExecution>>(
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
                  AppEmptyState(message: 'Nenhuma execução registrada ainda.'),
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
                    title: Text(e.agentName ?? e.agentSlug ?? e.id),
                    subtitle: Text(
                      [
                        e.status,
                        if (e.result != null) e.result!,
                        if (e.durationMs != null) '${e.durationMs} ms',
                      ].join(' · '),
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

class VirtualTeamHandoffsPage extends StatefulWidget {
  const VirtualTeamHandoffsPage({super.key});

  @override
  State<VirtualTeamHandoffsPage> createState() =>
      _VirtualTeamHandoffsPageState();
}

class _VirtualTeamHandoffsPageState extends State<VirtualTeamHandoffsPage> {
  Future<VtPagedList<VtHandoff>>? _future;
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

  Future<VtPagedList<VtHandoff>> _load() =>
      context.read<VirtualTeamRepository>().handoffs();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hand-offs'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtHandoff>>(
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
                  AppEmptyState(message: 'Nenhum hand-off registrado.'),
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
                final h = items[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: Text('${h.fromAgent} → ${h.toAgent}'),
                    subtitle: Text(
                      [
                        if (h.reason.isNotEmpty) h.reason,
                        if (h.status.isNotEmpty) h.status,
                      ].join(' · '),
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

class VirtualTeamEventsPage extends StatefulWidget {
  const VirtualTeamEventsPage({super.key});

  @override
  State<VirtualTeamEventsPage> createState() => _VirtualTeamEventsPageState();
}

class _VirtualTeamEventsPageState extends State<VirtualTeamEventsPage> {
  Future<VtPagedList<VtEvent>>? _future;
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

  Future<VtPagedList<VtEvent>> _load() =>
      context.read<VirtualTeamRepository>().events();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtEvent>>(
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
                  AppEmptyState(message: 'Nenhum evento registrado ainda.'),
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
                    title: Text(e.title),
                    subtitle: Text(
                      [
                        e.type,
                        if (e.agentSlug != null) e.agentSlug!,
                      ].join(' · '),
                    ),
                    trailing: e.createdAt == null
                        ? null
                        : Text(
                            '${e.createdAt!.day}/${e.createdAt!.month}',
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

class VirtualTeamMemoryPage extends StatefulWidget {
  const VirtualTeamMemoryPage({super.key});

  @override
  State<VirtualTeamMemoryPage> createState() => _VirtualTeamMemoryPageState();
}

class _VirtualTeamMemoryPageState extends State<VirtualTeamMemoryPage> {
  Future<List<VtMemoryItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<VirtualTeamRepository>().memory();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = context.read<VirtualTeamRepository>().memory();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memória')),
      body: FutureBuilder<List<VtMemoryItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Memória vazia no momento.'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final m = items[i];
                return ListTile(
                  title: Text(m.label),
                  subtitle: m.detail == null ? null : Text(m.detail!),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VirtualTeamLearningPage extends StatefulWidget {
  const VirtualTeamLearningPage({super.key});

  @override
  State<VirtualTeamLearningPage> createState() =>
      _VirtualTeamLearningPageState();
}

class _VirtualTeamLearningPageState extends State<VirtualTeamLearningPage> {
  Future<List<VtLearningItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<VirtualTeamRepository>().learning();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = context.read<VirtualTeamRepository>().learning();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aprendizado')),
      body: FutureBuilder<List<VtLearningItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Nenhum aprendizado registrado.'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final m = items[i];
                return ListTile(
                  title: Text(m.title),
                  subtitle: m.body == null ? null : Text(m.body!),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VirtualTeamQueuePage extends StatefulWidget {
  const VirtualTeamQueuePage({super.key});

  @override
  State<VirtualTeamQueuePage> createState() => _VirtualTeamQueuePageState();
}

class _VirtualTeamQueuePageState extends State<VirtualTeamQueuePage> {
  Future<List<VtQueueItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<VirtualTeamRepository>().queue();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = context.read<VirtualTeamRepository>().queue();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fila')),
      body: FutureBuilder<List<VtQueueItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              message: UserMessages.fromError(snap.error),
              onRetry: _refresh,
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Fila vazia no momento.'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final q = items[i];
                return ListTile(
                  title: Text(q.label),
                  subtitle: Text(
                    [
                      if (q.agentSlug != null) q.agentSlug!,
                      if (q.priority != null) 'prio ${q.priority}',
                    ].join(' · '),
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

/// Telas preparadas para endpoints ainda 404.
class VirtualTeamPendingEndpointPage extends StatefulWidget {
  const VirtualTeamPendingEndpointPage({
    super.key,
    required this.title,
    required this.loader,
  });

  final String title;
  final Future<Object> Function(VirtualTeamRepository repo) loader;

  @override
  State<VirtualTeamPendingEndpointPage> createState() =>
      _VirtualTeamPendingEndpointPageState();
}

class _VirtualTeamPendingEndpointPageState
    extends State<VirtualTeamPendingEndpointPage> {
  Future<Object>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= widget.loader(context.read<VirtualTeamRepository>());
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.loader(context.read<VirtualTeamRepository>());
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<Object>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            final err = snap.error;
            if (err is EndpointUnavailableException) {
              return AppEndpointPending(path: err.path);
            }
            if (err is ApiException && err.statusCode == 404) {
              return const AppEndpointPending(
                path: '(404 — endpoint ausente)',
              );
            }
            return AppErrorState(
              error: err,
              message: UserMessages.fromError(err),
              onRetry: _refresh,
            );
          }
          final data = snap.data;
          if (data is VtPagedList && data.items.isEmpty) {
            return const AppEmptyState(message: 'Nenhum registro.');
          }
          if (data is Map && data.isEmpty) {
            return const AppEmptyState(message: 'Sem resultados.');
          }
          // Quando o backend subir: renderização básica de mapas.
          if (data is VtPagedList<Map<String, dynamic>>) {
            return ListView.builder(
              itemCount: data.items.length,
              itemBuilder: (context, i) {
                final row = data.items[i];
                return ListTile(
                  title: Text(
                    '${row['title'] ?? row['id'] ?? row['message'] ?? row}',
                  ),
                );
              },
            );
          }
          if (data is Map<String, List<Map<String, dynamic>>>) {
            return ListView(
              children: [
                for (final e in data.entries) ...[
                  ListTile(
                    title: Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final row in e.value)
                    ListTile(
                      dense: true,
                      title: Text(
                        '${row['title'] ?? row['name'] ?? row['id'] ?? row}',
                      ),
                    ),
                ],
              ],
            );
          }
          return const AppEmptyState(message: 'Dados recebidos.');
        },
      ),
    );
  }
}
