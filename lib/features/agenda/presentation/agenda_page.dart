import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../citizen/presentation/citizen_content_pages.dart';
import '../data/appointments_repository.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key, this.focusId});

  /// Quando informado, a lista tenta posicionar/destacar o compromisso.
  final String? focusId;

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  Future<List<AppointmentItem>>? _future;
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    setState(() => _future = _load());
    await _future;
  }

  void _openDetail(AppointmentItem e, DateFormat dateFmt) {
    final when =
        e.startsAt == null ? null : dateFmt.format(e.startsAt!.toLocal());
    final page = CitizenAppointmentDetailPage(
      title: e.title,
      when: when,
      location: e.location,
      status: e.status,
      description: e.description,
    );
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
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<AppointmentItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView(message: 'Carregando agenda...');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum evento encontrado.'));
          }

          final focus = widget.focusId;
          int? focusIndex;
          if (focus != null && focus.isNotEmpty) {
            focusIndex = items.indexWhere((e) => '${e.id}' == focus);
            if (focusIndex >= 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_scrollController.hasClients) return;
                final offset = (focusIndex! * 72.0).clamp(
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

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = items[index];
                final highlighted = focusIndex == index;
                return Material(
                  color: highlighted
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08)
                      : null,
                  child: ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: Text(e.title),
                    subtitle: Text([
                      if (e.startsAt != null)
                        dateFmt.format(e.startsAt!.toLocal()),
                      if (e.location != null) e.location!,
                      if (e.status != null) e.status!,
                    ].join(' · ')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openDetail(e, dateFmt),
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
