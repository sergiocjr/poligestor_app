import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';

class MandateAgendaPage extends StatefulWidget {
  const MandateAgendaPage({super.key});

  @override
  State<MandateAgendaPage> createState() => _MandateAgendaPageState();
}

class _MandateAgendaPageState extends State<MandateAgendaPage> {
  Future<MandateAgendaData>? _future;
  String? _type;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<MandateAgendaData> _load() {
    return context.read<MandateRepository>().agenda(
          filter: MandateFilter(type: _type),
        );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda do mandato')),
      body: FutureBuilder<MandateAgendaData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: SkeletonBox(height: 120, radius: 16),
            );
          }
          if (snap.hasError && !snap.hasData) {
            return AppErrorState(
              message: UserMessages.fromError(snap.error),
              error: snap.error,
              onRetry: _refresh,
            );
          }
          final data = snap.data!;
          final types = data.eventTypes.entries.toList();
          return Column(
            children: [
              if (types.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: _type == null,
                        onSelected: (_) {
                          setState(() {
                            _type = null;
                            _future = _load();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      for (final e in types.take(8))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(e.value),
                            selected: _type == e.key,
                            onSelected: (_) {
                              setState(() {
                                _type = e.key;
                                _future = _load();
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: data.events.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            AppEmptyState(
                              message: 'Nenhum compromisso neste período.',
                              icon: Icons.event_busy_outlined,
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                          itemCount: data.events.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final e = data.events[i];
                            final when = e.startsAt != null
                                ? df.format(e.startsAt!.toLocal())
                                : 'Sem horário';
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.event_outlined),
                                title: Text(e.title),
                                subtitle: Text(
                                  [
                                    if (e.typeLabel != null) e.typeLabel!,
                                    when,
                                    if (e.location != null) e.location!,
                                    if (e.assigneeName != null) e.assigneeName!,
                                  ].join(' · '),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
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
