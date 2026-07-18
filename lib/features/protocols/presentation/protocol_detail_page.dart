import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/protocol_models.dart';
import '../data/protocols_repository.dart';

class ProtocolDetailPage extends StatefulWidget {
  const ProtocolDetailPage({super.key, required this.id});

  final String id;

  @override
  State<ProtocolDetailPage> createState() => _ProtocolDetailPageState();
}

class _ProtocolDetailPageState extends State<ProtocolDetailPage> {
  Future<ProtocolDetail>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<ProtocolDetail> _load() {
    final auth = context.read<AuthController>();
    final repo = context.read<ProtocolsRepository>();
    return repo.getById(mode: auth.mode, id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do protocolo')),
      body: FutureBuilder<ProtocolDetail>(
        future: _future!,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final p = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                p.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (p.number != null) Chip(label: Text('#${p.number}')),
                  if (p.status != null)
                    Chip(label: Text(ProtocolStatusLabel.pt(p.status))),
                  if (p.createdAt != null)
                    Chip(label: Text(dateFmt.format(p.createdAt!.toLocal()))),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Descrição',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(p.description?.isNotEmpty == true
                  ? p.description!
                  : 'Sem descrição.'),
            ],
          );
        },
      ),
    );
  }
}
