import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';
import 'widgets/mandate_widgets.dart';

class MandateMapPage extends StatefulWidget {
  const MandateMapPage({super.key});

  @override
  State<MandateMapPage> createState() => _MandateMapPageState();
}

class _MandateMapPageState extends State<MandateMapPage> {
  Future<MandateMapData>? _future;
  String _period = '7d';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<MandateMapData> _load() => context.read<MandateRepository>().map(
        filter: MandateFilter(period: _period),
      );

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa do mandato')),
      body: Column(
        children: [
          MandatePeriodFilterBar(
            value: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load();
            }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SoftNotice(
              message:
                  'Concentração por bairro (dados da API). Mapa cartográfico '
                  'depende de coordenadas quando o backend enviar.',
            ),
          ),
          Expanded(
            child: FutureBuilder<MandateMapData>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SkeletonBox(height: 100, radius: 16),
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
                if (data.neighborhoods.isEmpty) {
                  return const AppEmptyState(
                    message: 'Sem dados geográficos no período.',
                    icon: Icons.map_outlined,
                  );
                }
                final maxTotal = data.neighborhoods
                    .map((e) => e.total)
                    .fold<int>(1, (a, b) => a > b ? a : b);
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: data.neighborhoods.length,
                    itemBuilder: (context, i) {
                      final n = data.neighborhoods[i];
                      final intensity = (n.total / maxTotal).clamp(0.15, 1.0);
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: intensity),
                            child: Text(
                              '${n.total}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          title: Text(n.district),
                          subtitle: Text(
                            '${n.open} abertas · ${n.resolved} resolvidas'
                            '${n.topCategories.isEmpty ? '' : ' · ${n.topCategories.first.name}'}',
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
