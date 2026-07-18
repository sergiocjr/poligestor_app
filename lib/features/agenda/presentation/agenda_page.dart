import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/appointments_repository.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  Future<List<AppointmentItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<AppointmentItem>> _load() {
    final auth = context.read<AuthController>();
    return context.read<AppointmentsRepository>().list(mode: auth.mode);
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
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
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = items[index];
                return ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(e.title),
                  subtitle: Text([
                    if (e.startsAt != null)
                      dateFmt.format(e.startsAt!.toLocal()),
                    if (e.location != null) e.location!,
                    if (e.status != null) e.status!,
                  ].join(' · ')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
