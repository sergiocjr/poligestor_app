import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/demo/demo_experience_pane.dart';
import '../../../shared/widgets/pg_design_system.dart';

import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/events_models.dart';
import '../data/events_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

String _kindLabel(String? kind) {
  switch ((kind ?? '').toLowerCase()) {
    case 'meeting':
    case 'reuniao':
    case 'reunião':
      return 'Reunião';
    case 'appointment':
    case 'audience':
    case 'audiencia':
    case 'audiência':
      return 'Audiência';
    default:
      return kind == null || kind.isEmpty ? 'Evento' : kind;
  }
}

mixin _EventsRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindEventsRefresh(VoidCallback reload) {
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

/// Hub — Painel de Eventos (Fase 11).
class EventsHubPage extends StatelessWidget {
  const EventsHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel',
      'Indicadores de eventos',
      Icons.dashboard_outlined,
      '/home/events/dashboard',
      true,
    ),
    _Entry(
      'Eventos',
      'Lista e trâmite',
      Icons.event_outlined,
      '/home/events/list',
      true,
    ),
    _Entry(
      'Agenda',
      'Visão por dia',
      Icons.view_agenda_outlined,
      '/home/events/agenda',
      true,
    ),
    _Entry(
      'Calendário',
      'Visão mensal',
      Icons.calendar_month_outlined,
      '/home/events/calendar',
      true,
    ),
    _Entry(
      'Audiências',
      'Atendimentos e audiências',
      Icons.record_voice_over_outlined,
      '/home/events/audiences',
      true,
    ),
    _Entry(
      'Reuniões',
      'Reuniões institucionais',
      Icons.groups_outlined,
      '/home/events/meetings',
      true,
    ),
    _Entry(
      'Participantes',
      'Lista de participantes',
      Icons.people_outline,
      '/home/events/participants',
      false,
    ),
    _Entry(
      'Convites',
      'Convites enviados',
      Icons.mail_outline,
      '/home/events/invites',
      false,
    ),
    _Entry(
      'Presença',
      'Controle de presença',
      Icons.how_to_reg_outlined,
      '/home/events/attendance',
      false,
    ),
    _Entry(
      'Check-in',
      'Entrada no evento',
      Icons.login,
      '/home/events/check-in',
      false,
    ),
    _Entry(
      'Check-out',
      'Saída do evento',
      Icons.logout,
      '/home/events/check-out',
      false,
    ),
    _Entry(
      'QR Code',
      'Códigos de acesso',
      Icons.qr_code_2,
      '/home/events/qr-code',
      false,
    ),
    _Entry(
      'Galeria',
      'Mídia do evento',
      Icons.photo_library_outlined,
      '/home/events/gallery',
      false,
    ),
    _Entry(
      'Fotos',
      'Registro fotográfico',
      Icons.photo_outlined,
      '/home/events/photos',
      false,
    ),
    _Entry(
      'Vídeos',
      'Registro em vídeo',
      Icons.videocam_outlined,
      '/home/events/videos',
      false,
    ),
    _Entry(
      'Documentos',
      'Documentação oficial',
      Icons.description_outlined,
      '/home/events/documents',
      false,
    ),
    _Entry(
      'Certificados',
      'Certificados emitidos',
      Icons.workspace_premium_outlined,
      '/home/events/certificates',
      false,
    ),
    _Entry(
      'Linha do Tempo',
      'Eventos do histórico',
      Icons.timeline,
      '/home/events/timeline',
      false,
    ),
    _Entry(
      'Mapa',
      'Localização dos eventos',
      Icons.map_outlined,
      '/home/events/map',
      false,
    ),
    _Entry(
      'Indicadores',
      'Métricas de desempenho',
      Icons.analytics_outlined,
      '/home/events/indicators',
      false,
    ),
    _Entry(
      'Relatórios',
      'Exportações',
      Icons.summarize_outlined,
      '/home/events/reports',
      false,
    ),
    _Entry(
      'Pesquisa',
      'Busca de eventos',
      Icons.search,
      '/home/events/search',
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel de Eventos')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisExtent: PgHubModuleTile.gridExtent(crossAxisCount: cross),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(uiContractChip(available: e.live)),
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
  const _Entry(this.title, this.subtitle, this.icon, this.route, this.live);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool live;
}

typedef EventsListLoader =
    Future<List<EventsItem>> Function(EventsRepository repo, String tenant);

class EventsListPage extends StatefulWidget {
  const EventsListPage({
    super.key,
    required this.title,
    required this.loader,
    required this.detailRoutePrefix,
    this.emptyMessage = 'Nenhum item encontrado.',
    this.openDetail = true,
  });

  final String title;
  final EventsListLoader loader;
  final String detailRoutePrefix;
  final String emptyMessage;
  final bool openDetail;

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> with _EventsRefresh {
  Future<List<EventsItem>>? _future;
  String _query = '';
  String? _statusFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindEventsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<EventsItem>> _load() =>
      widget.loader(context.read<EventsRepository>(), _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
        child: FutureBuilder<List<EventsItem>>(
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
            var items = snap.data ?? const <EventsItem>[];
            final statuses =
                items.map((e) => e.status).whereType<String>().toSet().toList()
                  ..sort();
            if (_statusFilter != null) {
              items = items.where((e) => e.status == _statusFilter).toList();
            }
            if (_query.trim().isNotEmpty) {
              final q = _query.trim().toLowerCase();
              items = items
                  .where(
                    (e) =>
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.location ?? ''} ${e.personName ?? ''} ${_kindLabel(e.kind)}'
                            .toLowerCase()
                            .contains(q),
                  )
                  .toList();
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                if (statuses.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: _statusFilter == null,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                      for (final s in statuses)
                        FilterChip(
                          label: Text(uiStatusLabel(s)),
                          selected: _statusFilter == s,
                          onSelected: (_) => setState(() => _statusFilter = s),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: AppEmptyState(message: widget.emptyMessage),
                  )
                else
                  ...items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              _kindLabel(item.kind),
                              if (item.status != null) uiStatusLabel(item.status),
                              if (item.location != null) item.location!,
                              if (item.startsAt != null)
                                fmt.format(item.startsAt!.toLocal()),
                              if (item.personName != null) item.personName!,
                            ].join(' · '),
                          ),
                          trailing: widget.openDetail && item.id.isNotEmpty
                              ? const Icon(Icons.chevron_right)
                              : null,
                          onTap: !widget.openDetail || item.id.isEmpty
                              ? null
                              : () => context.push(
                                  '${widget.detailRoutePrefix}/${item.id}',
                                ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class EventsDashboardPage extends StatefulWidget {
  const EventsDashboardPage({super.key});

  @override
  State<EventsDashboardPage> createState() => _EventsDashboardPageState();
}

class _EventsDashboardPageState extends State<EventsDashboardPage>
    with _EventsRefresh {
  Future<EventsDashboard>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindEventsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<EventsDashboard> _load() => context
      .read<EventsRepository>()
      .dashboard(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel de eventos')),
      body: FutureBuilder<EventsDashboard>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
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
          final d = snap.data!;
          final items = <(String, String, IconData)>[
            ('Total', '${d.total}', Icons.event_outlined),
            ('Agendados', '${d.scheduled}', Icons.schedule),
            ('Concluídos', '${d.completed}', Icons.check_circle_outline),
            ('Cancelados', '${d.cancelled}', Icons.cancel_outlined),
            ('Reuniões', '${d.meetings}', Icons.groups_outlined),
            ('Audiências', '${d.audiences}', Icons.record_voice_over_outlined),
            ('Hoje', '${d.today}', Icons.today_outlined),
            ('Próximos', '${d.upcoming}', Icons.event_available_outlined),
          ];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (d.fromCache)
                Text(
                  'Dados salvos ${d.cacheAgeLabel ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              LayoutBuilder(
                builder: (context, box) {
                  final cols = box.maxWidth >= 600 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.35,
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
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  label,
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
            ],
          );
        },
      ),
    );
  }
}

class EventsDetailPage extends StatefulWidget {
  const EventsDetailPage({super.key, required this.id});

  final String id;

  @override
  State<EventsDetailPage> createState() => _EventsDetailPageState();
}

class _EventsDetailPageState extends State<EventsDetailPage> {
  Future<EventsItem>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<EventsRepository>().eventDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do evento')),
      body: FutureBuilder<EventsItem>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.error is EndpointUnavailableException) {
            final err = snap.error! as EndpointUnavailableException;
            return DemoExperiencePane(path: err.path);
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context.read<EventsRepository>().eventDetail(
                  widget.id,
                );
              }),
            );
          }
          final item = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text('Tipo: ${_kindLabel(item.kind)}'),
              if (item.status != null)
                Text('Situação: ${uiStatusLabel(item.status)}'),
              if (item.priority != null)
                Text('Prioridade: ${uiStatusLabel(item.priority)}'),
              if (item.location != null) Text('Local: ${item.location}'),
              if (item.personName != null) Text('Pessoa: ${item.personName}'),
              if (item.startsAt != null)
                Text('Início: ${fmt.format(item.startsAt!.toLocal())}'),
              if (item.endsAt != null)
                Text('Fim: ${fmt.format(item.endsAt!.toLocal())}'),
              if (item.allDay) const Text('Dia inteiro: sim'),
              const SizedBox(height: 12),
              Text(
                item.summary?.isNotEmpty == true
                    ? item.summary!
                    : 'Sem resumo.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/events/timeline'),
                    child: const Text('Linha do tempo'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/events/gallery'),
                    child: const Text('Galeria'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/events/participants'),
                    child: const Text('Participantes'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/events/attendance'),
                    child: const Text('Presença'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/home/events/documents'),
                    child: const Text('Documentos'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class EventsAgendaPage extends StatefulWidget {
  const EventsAgendaPage({super.key});

  @override
  State<EventsAgendaPage> createState() => _EventsAgendaPageState();
}

class _EventsAgendaPageState extends State<EventsAgendaPage>
    with _EventsRefresh {
  Future<List<EventsItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindEventsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<EventsItem>> _load() => context
      .read<EventsRepository>()
      .events(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat("EEEE, dd 'de' MMMM", 'pt_BR');
    final timeFmt = DateFormat('HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<EventsItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final items = [...(snap.data ?? const <EventsItem>[])]
            ..sort((a, b) {
              final aa = a.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bb = b.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return aa.compareTo(bb);
            });
          if (items.isEmpty) {
            return const AppEmptyState(message: 'Nenhum evento na agenda.');
          }
          final groups = <String, List<EventsItem>>{};
          for (final e in items) {
            final key = e.startsAt == null
                ? 'Sem data'
                : dayFmt.format(e.startsAt!.toLocal());
            (groups[key] ??= []).add(e);
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final entry in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ...entry.value.map(
                  (item) => Card(
                    child: ListTile(
                      leading: Text(
                        item.startsAt == null
                            ? '--:--'
                            : timeFmt.format(item.startsAt!.toLocal()),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        [
                          _kindLabel(item.kind),
                          if (item.location != null) item.location!,
                          if (item.status != null) uiStatusLabel(item.status),
                        ].join(' · '),
                      ),
                      onTap: item.id.isEmpty
                          ? null
                          : () => context.push('/home/events/list/${item.id}'),
                    ),
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

class EventsCalendarPage extends StatefulWidget {
  const EventsCalendarPage({super.key});

  @override
  State<EventsCalendarPage> createState() => _EventsCalendarPageState();
}

class _EventsCalendarPageState extends State<EventsCalendarPage>
    with _EventsRefresh {
  Future<List<EventsItem>>? _future;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindEventsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<EventsItem>> _load() => context
      .read<EventsRepository>()
      .events(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'pt_BR').format(_month);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        actions: [
          IconButton(
            tooltip: 'Mês anterior',
            onPressed: () => setState(() {
              _month = DateTime(_month.year, _month.month - 1);
            }),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Próximo mês',
            onPressed: () => setState(() {
              _month = DateTime(_month.year, _month.month + 1);
            }),
            icon: const Icon(Icons.chevron_right),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<EventsItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final items = snap.data ?? const <EventsItem>[];
          final byDay = <int, List<EventsItem>>{};
          for (final e in items) {
            final s = e.startsAt?.toLocal();
            if (s == null) continue;
            if (s.year == _month.year && s.month == _month.month) {
              (byDay[s.day] ??= []).add(e);
            }
          }
          final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
          final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
          final cells = <Widget>[
            for (final d in ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'])
              Center(
                child: Text(
                  d,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            for (var i = 1; i < firstWeekday; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              _DayCell(
                day: day,
                count: byDay[day]?.length ?? 0,
                onTap: () {
                  final dayItems = byDay[day] ?? const <EventsItem>[];
                  if (dayItems.isEmpty) return;
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (ctx) => ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Text(
                          'Dia $day',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final item in dayItems)
                          ListTile(
                            title: Text(item.title),
                            subtitle: Text(_kindLabel(item.kind)),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.push('/home/events/list/${item.id}');
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
          ];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                monthLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cells,
              ),
              const SizedBox(height: 16),
              Text(
                'Toque em um dia com eventos para ver detalhes.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.count,
    required this.onTap,
  });

  final int day;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final has = count > 0;
    return InkWell(
      onTap: has ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: has
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: const TextStyle(fontWeight: FontWeight.w700)),
            if (has)
              Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}

class EventsSearchPage extends StatefulWidget {
  const EventsSearchPage({super.key});

  @override
  State<EventsSearchPage> createState() => _EventsSearchPageState();
}

class _EventsSearchPageState extends State<EventsSearchPage>
    with _EventsRefresh {
  Future<List<EventsItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindEventsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<EventsItem>> _load() => context
      .read<EventsRepository>()
      .events(tenantSlug: _tenantOf(context));

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa de eventos')),
      body: FutureBuilder<List<EventsItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          var items = snap.data ?? const <EventsItem>[];
          if (_query.trim().isNotEmpty) {
            final q = _query.trim().toLowerCase();
            items = items
                .where(
                  (e) =>
                      '${e.title} ${e.summary ?? ''} ${e.location ?? ''} ${e.personName ?? ''} ${_kindLabel(e.kind)}'
                          .toLowerCase()
                          .contains(q),
                )
                .toList();
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar eventos',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 8),
              Text(
                'Busca local nos eventos ativos. Resultados ilustrativos quando necessário.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: AppEmptyState(message: 'Nenhum evento encontrado.'),
                )
              else
                ...items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        [
                          _kindLabel(item.kind),
                          if (item.startsAt != null)
                            fmt.format(item.startsAt!.toLocal()),
                        ].join(' · '),
                      ),
                      onTap: () =>
                          context.push('/home/events/list/${item.id}'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
