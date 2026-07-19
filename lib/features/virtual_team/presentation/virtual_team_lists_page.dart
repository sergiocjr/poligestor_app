import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/virtual_team_models.dart';
import '../data/virtual_team_repository.dart';
import 'widgets/virtual_team_widgets.dart';

mixin _VtRefreshMixin<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  void bindRefresh(VoidCallback reload) {
    final refresh = context.watch<MandateRefreshController>();
    if (!identical(_refreshCtrl, refresh)) {
      _refreshCtrl = refresh;
      _lastGen = refresh.generation;
    } else if (refresh.generation != _lastGen) {
      _lastGen = refresh.generation;
      reload();
    }
  }
}

class VirtualTeamTasksPage extends StatefulWidget {
  const VirtualTeamTasksPage({super.key, this.agentSlug});

  final String? agentSlug;

  @override
  State<VirtualTeamTasksPage> createState() => _VirtualTeamTasksPageState();
}

class _VirtualTeamTasksPageState extends State<VirtualTeamTasksPage>
    with _VtRefreshMixin {
  Future<VtPagedList<VtTask>>? _future;
  String? _status;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<VtPagedList<VtTask>> _load() =>
      context.read<VirtualTeamRepository>().tasks(
        filter: VirtualTeamFilter(status: _status),
        agentSlug: widget.agentSlug,
      );

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
              ? 'Tarefas'
              : 'Tarefas · ${widget.agentSlug}',
        ),
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
              builder: (context, snap) => _buildList(
                snap,
                onRetry: _refresh,
                empty: 'Nenhuma tarefa registrada.',
                itemBuilder: (t) => Card(
                  child: ListTile(
                    title: Text(t.title),
                    subtitle: Text(
                      [
                        if (t.code != null) t.code!,
                        uiStatusLabel(t.status),
                        if (t.agentSlug != null) t.agentSlug!,
                        if (t.priority != null) uiPriorityLabel(t.priority),
                      ].join(' · '),
                    ),
                    trailing: Text(
                      vtFormatWhen(t.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
                items: snap.data?.items ?? const [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VirtualTeamExecutionsPage extends StatefulWidget {
  const VirtualTeamExecutionsPage({super.key, this.agentSlug});

  final String? agentSlug;

  @override
  State<VirtualTeamExecutionsPage> createState() =>
      _VirtualTeamExecutionsPageState();
}

class _VirtualTeamExecutionsPageState extends State<VirtualTeamExecutionsPage>
    with _VtRefreshMixin {
  Future<VtPagedList<VtExecution>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<VtPagedList<VtExecution>> _load() => context
      .read<VirtualTeamRepository>()
      .executions(agentSlug: widget.agentSlug);

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
              ? 'Execuções'
              : 'Execuções · ${widget.agentSlug}',
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtExecution>>(
        future: _future,
        builder: (context, snap) => _buildList(
          snap,
          onRetry: _refresh,
          empty: 'Nenhuma execução registrada.',
          items: snap.data?.items ?? const [],
          itemBuilder: (e) => Card(
            child: ListTile(
              title: Text(e.agentSlug ?? e.id),
              subtitle: Text(
                [
                  uiStatusLabel(e.status),
                  if (e.durationMs != null) '${e.durationMs} ms',
                  if (e.error != null) e.error!,
                ].join(' · '),
              ),
              trailing: Text(
                vtFormatWhen(e.startedAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
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

class _VirtualTeamHandoffsPageState extends State<VirtualTeamHandoffsPage>
    with _VtRefreshMixin {
  Future<VtPagedList<VtHandoff>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindRefresh(() => setState(() => _future = _load()));
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
        title: const Text('TransferÃªncias'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<VtPagedList<VtHandoff>>(
        future: _future,
        builder: (context, snap) => _buildList(
          snap,
          onRetry: _refresh,
          empty: 'Nenhuma transferência registrada.',
          items: snap.data?.items ?? const [],
          itemBuilder: (h) => Card(
            child: ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text('${h.fromAgent} → ${h.toAgent}'),
              subtitle: Text(
                [
                  if (h.kind != null) h.kind!,
                  if (h.reason.isNotEmpty) h.reason,
                  if (h.status.isNotEmpty) uiStatusLabel(h.status),
                ].join(' · '),
              ),
              trailing: Text(
                vtFormatWhen(h.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VirtualTeamEventsPage extends StatefulWidget {
  const VirtualTeamEventsPage({super.key});

  @override
  State<VirtualTeamEventsPage> createState() => _VirtualTeamEventsPageState();
}

class _VirtualTeamEventsPageState extends State<VirtualTeamEventsPage>
    with _VtRefreshMixin {
  Future<VtPagedList<VtEvent>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindRefresh(() => setState(() => _future = _load()));
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
        builder: (context, snap) => _buildList(
          snap,
          onRetry: _refresh,
          empty: 'Nenhum evento registrado.',
          items: snap.data?.items ?? const [],
          itemBuilder: (e) => Card(
            child: ListTile(
              title: Text(e.title),
              subtitle: Text(
                [e.type, if (e.agentSlug != null) e.agentSlug!].join(' · '),
              ),
              trailing: Text(
                vtFormatWhen(e.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VirtualTeamMemoryPage extends StatefulWidget {
  const VirtualTeamMemoryPage({super.key});

  @override
  State<VirtualTeamMemoryPage> createState() => _VirtualTeamMemoryPageState();
}

class _VirtualTeamMemoryPageState extends State<VirtualTeamMemoryPage>
    with _VtRefreshMixin {
  Future<List<VtMemoryItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<VtMemoryItem>> _load() =>
      context.read<VirtualTeamRepository>().memory();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memória')),
      body: FutureBuilder<List<VtMemoryItem>>(
        future: _future,
        builder: (context, snap) => _buildPlainList(
          snap,
          onRetry: _refresh,
          empty: 'Memória vazia no momento.',
          items: snap.data ?? const [],
          itemBuilder: (m) => ListTile(
            title: Text(m.label),
            subtitle: Text(
              [
                if (m.kind != null) m.kind!,
                if (m.agentSlug != null) m.agentSlug!,
                if (m.detail != null) m.detail!,
              ].join(' · '),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
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

class _VirtualTeamLearningPageState extends State<VirtualTeamLearningPage>
    with _VtRefreshMixin {
  Future<List<VtLearningItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<VtLearningItem>> _load() =>
      context.read<VirtualTeamRepository>().learning();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aprendizado')),
      body: FutureBuilder<List<VtLearningItem>>(
        future: _future,
        builder: (context, snap) => _buildPlainList(
          snap,
          onRetry: _refresh,
          empty: 'Nenhum aprendizado registrado.',
          items: snap.data ?? const [],
          itemBuilder: (m) => ListTile(
            title: Text(m.title),
            subtitle: Text(
              [
                if (m.outcome != null) m.outcome!,
                if (m.agentSlug != null) m.agentSlug!,
                if (m.body != null) m.body!,
              ].join(' · '),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class VirtualTeamQueuePage extends StatefulWidget {
  const VirtualTeamQueuePage({super.key});

  @override
  State<VirtualTeamQueuePage> createState() => _VirtualTeamQueuePageState();
}

class _VirtualTeamQueuePageState extends State<VirtualTeamQueuePage>
    with _VtRefreshMixin {
  Future<List<VtQueueItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<VtQueueItem>> _load() =>
      context.read<VirtualTeamRepository>().queue();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fila')),
      body: FutureBuilder<List<VtQueueItem>>(
        future: _future,
        builder: (context, snap) => _buildPlainList(
          snap,
          onRetry: _refresh,
          empty: 'Fila vazia no momento.',
          items: snap.data ?? const [],
          itemBuilder: (q) => ListTile(
            title: Text(q.label),
            subtitle: Text(
              [
                if (q.agentSlug != null) q.agentSlug!,
                if (q.priority != null) 'prioridade ${uiPriorityLabel(q.priority)}',
              ].join(' · '),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildList<T>(
  AsyncSnapshot snap, {
  required VoidCallback onRetry,
  required String empty,
  required List<T> items,
  required Widget Function(T item) itemBuilder,
}) {
  if (snap.connectionState != ConnectionState.done && !snap.hasData) {
    return const Center(child: CircularProgressIndicator());
  }
  if (snap.hasError && !snap.hasData) {
    final err = snap.error;
    if (err is ApiException && err.isForbidden) {
      return const AppEmptyState(
        message: 'Sem permissão.',
        icon: Icons.lock_outline,
      );
    }
    return AppErrorState(
      error: err,
      message: UserMessages.fromError(err),
      onRetry: onRetry,
    );
  }
  if (items.isEmpty) {
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          AppEmptyState(message: empty),
        ],
      ),
    );
  }
  return RefreshIndicator(
    onRefresh: () async => onRetry(),
    child: ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: items.length,
      itemBuilder: (context, i) => itemBuilder(items[i]),
    ),
  );
}

Widget _buildPlainList<T>(
  AsyncSnapshot snap, {
  required VoidCallback onRetry,
  required String empty,
  required List<T> items,
  required Widget Function(T item) itemBuilder,
}) => _buildList(
  snap,
  onRetry: onRetry,
  empty: empty,
  items: items,
  itemBuilder: itemBuilder,
);
