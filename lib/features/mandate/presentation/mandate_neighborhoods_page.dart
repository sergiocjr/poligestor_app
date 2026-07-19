import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';
import 'widgets/mandate_widgets.dart';

class MandateNeighborhoodsPage extends StatefulWidget {
  const MandateNeighborhoodsPage({super.key});

  @override
  State<MandateNeighborhoodsPage> createState() =>
      _MandateNeighborhoodsPageState();
}

class _MandateNeighborhoodsPageState extends State<MandateNeighborhoodsPage> {
  Future<MandateNeighborhoodsData>? _future;
  String _period = '7d';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<MandateNeighborhoodsData> _load() =>
      context.read<MandateRepository>().neighborhoods(
            filter: MandateFilter(period: _period),
          );

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bairros com mais solicitações')),
      body: Column(
        children: [
          MandatePeriodFilterBar(
            value: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load();
            }),
          ),
          Expanded(
            child: FutureBuilder<MandateNeighborhoodsData>(
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
                if (data.districts.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhum bairro com solicitações no período.',
                    icon: Icons.location_off_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: data.districts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final d = data.districts[i];
                      final cats = d.topCategories
                          .take(3)
                          .map((c) => '${c.name} (${c.count})')
                          .join(' · ');
                      final trend = d.previousTotal == null
                          ? null
                          : d.total - d.previousTotal!;
                      return MandateRankingTile(
                        rank: i + 1,
                        title: d.district,
                        subtitle: [
                          '${d.total} no período · ${d.open} abertas · ${d.resolved} resolvidas',
                          if (cats.isNotEmpty) cats,
                          if (trend != null)
                            trend >= 0
                                ? 'Tendência: +$trend vs período anterior'
                                : 'Tendência: $trend vs período anterior',
                        ].join('\n'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => _DistrictDetailPage(stat: d),
                            ),
                          );
                        },
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

class _DistrictDetailPage extends StatelessWidget {
  const _DistrictDetailPage({required this.stat});

  final MandateDistrictStat stat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stat.district)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Total ${stat.total}')),
              Chip(label: Text('Abertas ${stat.open}')),
              Chip(label: Text('Resolvidas ${stat.resolved}')),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Principais assuntos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          if (stat.topCategories.isEmpty)
            const Text('Sem categorias destacadas.')
          else
            ...stat.topCategories.map(
              (c) => ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(c.name),
                trailing: Text('${c.count}'),
              ),
            ),
        ],
      ),
    );
  }
}
