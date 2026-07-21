import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_mode.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../../virtual_team/data/virtual_team_models.dart';
import '../../virtual_team/presentation/widgets/virtual_team_widgets.dart';
import '../data/automation_models.dart';
import '../data/automation_repository.dart';

/// Hub — Central de Automação Inteligente (Sprint 10.6).
class AutomationHubPage extends StatelessWidget {
  const AutomationHubPage({super.key});

  static const _entries = <_AutoEntry>[
    _AutoEntry(
      'Painel',
      'Indicadores operacionais ativos',
      Icons.dashboard_outlined,
      '/home/automation/dashboard',
      true,
    ),
    _AutoEntry(
      'Automações',
      'Catálogo e editor',
      Icons.account_tree_outlined,
      '/home/automation/list',
      false,
    ),
    _AutoEntry(
      'Execuções',
      'Histórico operacional',
      Icons.play_circle_outline,
      '/home/automation/executions',
      true,
    ),
    _AutoEntry(
      'Aprovações',
      'Fila de aprovadores',
      Icons.verified_outlined,
      '/home/automation/approvals',
      false,
    ),
    _AutoEntry(
      'Alertas',
      'SLA e falhas',
      Icons.notification_important_outlined,
      '/home/automation/alerts',
      true,
    ),
    _AutoEntry(
      'Agentes',
      'Equipe Virtual',
      Icons.smart_toy_outlined,
      '/home/automation/agents',
      true,
    ),
    _AutoEntry(
      'Agenda',
      'Próximas execuções',
      Icons.schedule_outlined,
      '/home/automation/schedule',
      false,
    ),
    _AutoEntry(
      'Histórico',
      'Linha do tempo operacional',
      Icons.history,
      '/home/automation/history',
      true,
    ),
    _AutoEntry(
      'Registros',
      'Auditoria e eventos',
      Icons.article_outlined,
      '/home/automation/logs',
      true,
    ),
    _AutoEntry(
      'Métricas',
      'Eficiência e fila',
      Icons.analytics_outlined,
      '/home/automation/metrics',
      true,
    ),
    _AutoEntry(
      'Autonomia',
      'Níveis 0–5',
      Icons.tune_outlined,
      '/home/automation/autonomy',
      true,
    ),
    _AutoEntry(
      'Edição',
      'Fluxo guiado',
      Icons.edit_note_outlined,
      '/home/automation/editor',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central de Automação')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisExtent: 100,
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

class _AutoEntry {
  const _AutoEntry(this.title, this.subtitle, this.icon, this.route, this.live);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool live;
}

class AutomationPendingPage extends StatefulWidget {
  const AutomationPendingPage({
    super.key,
    required this.title,
    required this.path,
    required this.probe,
  });

  final String title;
  final String path;
  final Future<void> Function(AutomationRepository repo) probe;

  @override
  State<AutomationPendingPage> createState() => _AutomationPendingPageState();
}

class _AutomationPendingPageState extends State<AutomationPendingPage> {
  Future<void>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= widget.probe(context.read<AutomationRepository>());
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
                _future = widget.probe(context.read<AutomationRepository>());
              }),
            );
          }
          return EndpointPendingState(path: widget.path);
        },
      ),
    );
  }
}

class AutomationDashboardPage extends StatefulWidget {
  const AutomationDashboardPage({super.key});

  @override
  State<AutomationDashboardPage> createState() =>
      _AutomationDashboardPageState();
}

class _AutomationDashboardPageState extends State<AutomationDashboardPage>
    with _AutoRefresh {
  Future<AutoDashboardSnapshot>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAutoRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<AutoDashboardSnapshot> _load() {
    final tenant =
        context.read<TenantController>().organization?.slug ?? 'demo';
    return context.read<AutomationRepository>().dashboard(tenantSlug: tenant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de automação'),
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
        child: FutureBuilder<AutoDashboardSnapshot>(
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
            final items = <(String, String, IconData)>[
              (
                'Agentes ativos',
                '${d.agentsActive}/${d.agentsTotal}',
                Icons.groups_outlined,
              ),
              (
                'Execuções 24h',
                '${d.executionsToday}',
                Icons.play_circle_outline,
              ),
              ('Sucesso', '${d.successToday}', Icons.check_circle_outline),
              ('Falhas', '${d.failuresToday}', Icons.error_outline),
              ('Fila', '${d.queueDepth}', Icons.queue_outlined),
              (
                'Alertas críticos',
                '${d.alertsCritical}',
                Icons.warning_amber_outlined,
              ),
              (
                'Eficiência',
                '${d.efficiencyPct.toStringAsFixed(0)}%',
                Icons.speed_outlined,
              ),
              ('Aprovações*', '${d.pendingApprovals}', Icons.verified_outlined),
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
                  'Fonte ativa: Equipe Virtual até publicar o painel de automações',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth >= 600 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.4,
                      children: [
                        for (final (label, value, icon) in items)
                          Card(
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
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '* Aprovações dedicadas aguardam /v1/automations/approvals',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => context.push('/home/virtual-team'),
                  child: const Text('Abrir Equipe Virtual'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AutomationAutomationsPage extends StatefulWidget {
  const AutomationAutomationsPage({super.key});

  @override
  State<AutomationAutomationsPage> createState() =>
      _AutomationAutomationsPageState();
}

class _AutomationAutomationsPageState extends State<AutomationAutomationsPage> {
  Future<List<AutoAutomation>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AutomationRepository>().automations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automações'),
        actions: [
          IconButton(
            tooltip: 'Nova (quando disponível)',
            onPressed: () => context.push('/home/automation/editor'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<AutoAutomation>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.error is EndpointUnavailableException) {
            final err = snap.error! as EndpointUnavailableException;
            return EndpointPendingState(
              path: err.path,
              message:
                  'Lista e ações de automações preparadas. Aguardando /v1/automations.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<AutomationRepository>().automations();
              }),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(
              message: 'Nenhuma automação cadastrada.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = items[i];
              return Card(
                child: ListTile(
                  title: Text(
                    a.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    [a.statusLabel, a.agentSlug, a.trigger]
                        .whereType<String>()
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                  ),
                  onTap: () => context.push('/home/automation/list/${a.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AutomationExecutionsPage extends StatefulWidget {
  const AutomationExecutionsPage({super.key});

  @override
  State<AutomationExecutionsPage> createState() =>
      _AutomationExecutionsPageState();
}

class _AutomationExecutionsPageState extends State<AutomationExecutionsPage>
    with _AutoRefresh {
  Future<VtPagedList<VtExecution>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAutoRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<VtPagedList<VtExecution>> _load() =>
      context.read<AutomationRepository>().executions();

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Execuções')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<VtPagedList<VtExecution>>(
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
            final items = snap.data?.items ?? const [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Nenhuma execução.'),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = items[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text(
                      e.agentSlug ?? e.agentName ?? e.id,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [
                        uiStatusLabel(e.status),
                        if (e.startedAt != null)
                          fmt.format(e.startedAt!.toLocal()),
                      ].join(' · '),
                    ),
                    onTap: () => context.push('/home/virtual-team/executions'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AutomationAlertsPage extends StatefulWidget {
  const AutomationAlertsPage({super.key});

  @override
  State<AutomationAlertsPage> createState() => _AutomationAlertsPageState();
}

class _AutomationAlertsPageState extends State<AutomationAlertsPage>
    with _AutoRefresh {
  Future<VtPagedList<VtAlert>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAutoRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<VtPagedList<VtAlert>> _load() =>
      context.read<AutomationRepository>().alerts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<VtPagedList<VtAlert>>(
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
            final items = snap.data?.items ?? const [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Nenhum alerta.'),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = items[i];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.warning_amber_outlined,
                      color: a.severity == 'high' || a.severity == 'critical'
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                    title: Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${uiSeverityLabel(a.severity)} · ${a.body}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      if (a.agentSlug != null && a.agentSlug!.isNotEmpty) {
                        context.push(
                          '/home/virtual-team/agents/${a.agentSlug}',
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AutomationAgentsPage extends StatefulWidget {
  const AutomationAgentsPage({super.key});

  @override
  State<AutomationAgentsPage> createState() => _AutomationAgentsPageState();
}

class _AutomationAgentsPageState extends State<AutomationAgentsPage> {
  Future<List<VtAgent>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AutomationRepository>().agents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agentes'),
        actions: [
          TextButton(
            onPressed: () => context.push('/home/virtual-team/agents'),
            child: const Text('Equipe Virtual'),
          ),
        ],
      ),
      body: FutureBuilder<List<VtAgent>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<AutomationRepository>().agents();
              }),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Nenhum agente.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = items[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(a.name.isEmpty ? '?' : a.name[0]),
                  ),
                  title: Text(
                    a.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${a.stateLabel} · ${a.specialty}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push('/home/virtual-team/agents/${a.slug}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AutomationLogsPage extends StatefulWidget {
  const AutomationLogsPage({super.key});

  @override
  State<AutomationLogsPage> createState() => _AutomationLogsPageState();
}

class _AutomationLogsPageState extends State<AutomationLogsPage> {
  Future<VtPagedList<VtLogEntry>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AutomationRepository>().logs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registros')),
      body: FutureBuilder<VtPagedList<VtLogEntry>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<AutomationRepository>().logs();
              }),
            );
          }
          final items = snap.data?.items ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Nenhum registro.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final l = items[i];
              return Card(
                child: ListTile(
                  title: Text(
                    l.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    [l.level, l.type, l.source]
                        .whereType<String>()
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AutomationHistoryPage extends StatefulWidget {
  const AutomationHistoryPage({super.key});

  @override
  State<AutomationHistoryPage> createState() => _AutomationHistoryPageState();
}

class _AutomationHistoryPageState extends State<AutomationHistoryPage> {
  Future<VtPagedList<VtTimelineItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AutomationRepository>().timeline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico / Linha do tempo')),
      body: FutureBuilder<VtPagedList<VtTimelineItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<AutomationRepository>().timeline();
              }),
            );
          }
          final items = snap.data?.items ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Linha do tempo vazia.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final t = items[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.timeline),
                  title: Text(
                    t.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    t.body ?? t.kind,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AutomationMetricsPage extends StatefulWidget {
  const AutomationMetricsPage({super.key});

  @override
  State<AutomationMetricsPage> createState() => _AutomationMetricsPageState();
}

class _AutomationMetricsPageState extends State<AutomationMetricsPage> {
  Future<VtDashboard>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AutomationRepository>().metrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Métricas')),
      body: FutureBuilder<VtDashboard>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<AutomationRepository>().metrics();
              }),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              VtKpiGrid(dashboard: snap.data!),
              const SizedBox(height: 12),
              Text(
                'Reutiliza métricas ativas da Equipe Virtual',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

class AutomationAutonomyPage extends StatefulWidget {
  const AutomationAutonomyPage({super.key});

  @override
  State<AutomationAutonomyPage> createState() => _AutomationAutonomyPageState();
}

class _AutomationAutonomyPageState extends State<AutomationAutonomyPage> {
  Future<List<AutoAgentAutonomy>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AutomationRepository>().agentAutonomies();
  }

  Future<void> _confirmChange(
    AutoAgentAutonomy current,
    AutonomyLevel next,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar autonomia'),
        content: Text(
          'Alterar ${current.agentSlug} de "${current.level.label}" para "${next.label}"?\n\n'
          'Ação crítica: exige confirmação e contrato ativo de escrita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<AutomationRepository>().autonomyWrite();
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Contrato pendente'),
          content: EndpointPendingState(
            path: e.path,
            message: 'Leitura ativa ok. Escrita de autonomia aguarda publicação.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autonomia')),
      body: FutureBuilder<List<AutoAgentAutonomy>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context
                    .read<AutomationRepository>()
                    .agentAutonomies();
              }),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(
              message: 'Nenhuma autonomia publicada em /v1/ai/team.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                'Níveis 0–5. Escrita exige confirmação + contrato ativo.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ...items.map((a) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.agentSlug,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text('Atual: ${a.level.label} (${a.level.value})'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final lvl in AutonomyLevel.values)
                              ActionChip(
                                label: Text('${lvl.value}'),
                                onPressed: lvl == a.level
                                    ? null
                                    : () => _confirmChange(a, lvl),
                              ),
                          ],
                        ),
                      ],
                    ),
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

/// Editor guiado (10 passos) — persistência aguarda /v1/automations.
class AutomationEditorPage extends StatelessWidget {
  const AutomationEditorPage({super.key});

  static const _steps = [
    'Nome e descrição',
    'Agente',
    'Gatilho',
    'Condições',
    'Ações',
    'Autonomia',
    'Aprovação',
    'Agenda',
    'Limites',
    'Revisão',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edição de automação')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EndpointPendingState(
            path: AuthMode.staff.automationsRootPath,
            message: 'Edição preparada. O salvamento aguarda contrato ativo.',
          ),
          const SizedBox(height: 12),
          ..._steps.asMap().entries.map((e) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${e.key + 1}')),
                title: Text(e.value),
                subtitle: const Text(
                  'Preencha os campos — salvamento após sincronização',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

mixin _AutoRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindAutoRefresh(VoidCallback reload) {
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
