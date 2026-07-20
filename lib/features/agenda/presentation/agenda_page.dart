import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/appointments_repository.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key, this.focusId});

  /// Quando informado, a lista tenta posicionar/destacar o compromisso.
  final String? focusId;

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage>
    with AutomaticKeepAliveClientMixin {
  Future<List<AppointmentItem>>? _future;
  final _scrollController = ScrollController();
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  bool get wantKeepAlive => true;

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<AppointmentItem>> _load() {
    final auth = context.read<AuthController>();
    return context.read<AppointmentsRepository>().list(mode: auth.mode);
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  void _openDetail(AppointmentItem e, DateFormat dateFmt) {
    final when = e.startsAt == null
        ? null
        : dateFmt.format(e.startsAt!.toLocal());
    final auth = context.read<AuthController>();
    if (auth.mode == AuthMode.portal) {
      context.push(
        '/citizen/appointments/detail',
        extra: {
          'title': e.title,
          'when': when,
          'location': e.location,
          'status': e.status,
          'description': e.description,
        },
      );
      return;
    }
    // Staff: sheet modal — evita empilhar rotas sobre o shell.
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (when != null) Text('Quando: $when'),
                if (e.location != null) Text('Local: ${e.location}'),
                if (e.status != null)
                  Text('Situação: ${uiStatusLabel(e.status)}'),
                const SizedBox(height: 12),
                Text(
                  (e.description?.trim().isNotEmpty == true)
                      ? e.description!
                      : 'Sem descrição.',
                ),
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
    super.build(context);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final dayFmt = DateFormat("EEEE, dd 'de' MMMM", 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<AppointmentItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snapshot.error is EndpointUnavailableException) {
              final err = snapshot.error! as EndpointUnavailableException;
              return EndpointPendingState(
                path: err.path,
                message:
                    'Agenda preparada. Aguardando contrato ativo na VPS.',
              );
            }
            if (snapshot.hasError) {
              return AppErrorState(
                error: snapshot.error,
                onRetry: _reload,
              );
            }

            final items = snapshot.data ?? const <AppointmentItem>[];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  AppEmptyState(message: 'Nenhum compromisso na agenda.'),
                ],
              );
            }

            final focus = widget.focusId;
            int? focusIndex;
            if (focus != null && focus.isNotEmpty) {
              focusIndex = items.indexWhere((e) => '${e.id}' == focus);
              if (focusIndex >= 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_scrollController.hasClients) return;
                  final offset = (focusIndex! * 76.0).clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  );
                  _scrollController.animateTo(
                    offset,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                  );
                });
              }
            }

            String? lastDayKey;
            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final e = items[index];
                final dayKey = e.startsAt == null
                    ? 'Sem data'
                    : dayFmt.format(e.startsAt!.toLocal());
                final showHeader = dayKey != lastDayKey;
                lastDayKey = dayKey;
                final highlighted = focusIndex == index;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: EdgeInsets.fromLTRB(4, index == 0 ? 4 : 16, 4, 8),
                        child: Text(
                          dayKey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    Card(
                      color: highlighted
                          ? Theme.of(context).colorScheme.primaryContainer
                                .withValues(alpha: 0.35)
                          : null,
                      child: ListTile(
                        leading: Icon(
                          Icons.event_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          e.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          [
                            if (e.startsAt != null)
                              dateFmt.format(e.startsAt!.toLocal()),
                            if (e.location != null) e.location!,
                            if (e.status != null) uiStatusLabel(e.status),
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openDetail(e, dateFmt),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
