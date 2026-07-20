import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';
import '../domain/mandate_search_helpers.dart';

class MandateSearchPage extends StatefulWidget {
  const MandateSearchPage({super.key});

  @override
  State<MandateSearchPage> createState() => _MandateSearchPageState();
}

class _MandateSearchPageState extends State<MandateSearchPage> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  Future<MandateSearchData>? _future;
  String _lastQuery = '';

  static const _groupLabels = {
    'people': 'Pessoas',
    'protocols': 'Protocolos',
    'districts': 'Bairros',
    'streets': 'Ruas',
    'contacts': 'Contatos',
    'documents': 'Documentos',
    'categories': 'Categorias',
    'assignees': 'Responsáveis',
    'agenda_events': 'Agenda',
  };

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (!mandateSearchQueryReady(q)) {
      setState(() {
        _future = null;
        _lastQuery = '';
      });
      return;
    }
    _debounce = Timer(mandateSearchDebounce(), () {
      setState(() {
        _lastQuery = q;
        _future = context.read<MandateRepository>().search(query: q);
      });
    });
  }

  void _openHit(MandateSearchHit hit) {
    if (hit.type == 'protocol' && hit.id.isNotEmpty) {
      context.push('/home/protocols/${hit.id}');
      return;
    }
    if (hit.url != null && hit.url!.contains('/protocolos/')) {
      final id = hit.url!.split('/protocolos/').last.split('/').first;
      if (id.isNotEmpty) {
        context.push('/home/protocols/$id');
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Este resultado é apenas informativo.'),
      ),
    );
  }

  bool _hitOpenable(MandateSearchHit hit) {
    if (hit.type == 'protocol' && hit.id.isNotEmpty) return true;
    if (hit.url != null && hit.url!.contains('/protocolos/')) {
      final id = hit.url!.split('/protocolos/').last.split('/').first;
      return id.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _ctrl,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Pessoa, protocolo, bairro, telefone…',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!mandateSearchQueryReady(_ctrl.text)) {
      return const AppEmptyState(
        message: 'Digite ao menos 2 caracteres para pesquisar.',
        icon: Icons.search_rounded,
      );
    }
    return FutureBuilder<MandateSearchData>(
      future: _future,
      builder: (context, snap) {
        if (_future == null) {
          return const AppEmptyState(
            message: 'Digite ao menos 2 caracteres para pesquisar.',
            icon: Icons.search_rounded,
          );
        }
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return AppErrorState(
            message: UserMessages.fromError(snap.error),
            error: snap.error,
            onRetry: () => setState(() {
              _future = context.read<MandateRepository>().search(
                query: _lastQuery,
              );
            }),
          );
        }
        final data = snap.data!;
        final nonEmpty = data.groups.entries
            .where((e) => e.value.isNotEmpty)
            .toList();
        if (nonEmpty.isEmpty) {
          return AppEmptyState(
            message: 'Nenhum resultado para “${data.query}”.',
            icon: Icons.search_off_rounded,
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          children: [
            for (final g in nonEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                child: Text(
                  _groupLabels[g.key] ?? g.key,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              ...g.value.map(
                (hit) {
                  final openable = _hitOpenable(hit);
                  return Card(
                    child: ListTile(
                      title: Text(
                        hit.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: hit.subtitle == null
                          ? null
                          : Text(
                              hit.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: openable
                          ? const Icon(Icons.chevron_right_rounded)
                          : Text(
                              'Informativo',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline,
                                  ),
                            ),
                      onTap: openable ? () => _openHit(hit) : null,
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
