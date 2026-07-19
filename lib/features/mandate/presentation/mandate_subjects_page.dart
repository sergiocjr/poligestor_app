import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';
import 'widgets/mandate_widgets.dart';

class MandateSubjectsPage extends StatefulWidget {
  const MandateSubjectsPage({super.key});

  @override
  State<MandateSubjectsPage> createState() => _MandateSubjectsPageState();
}

class _MandateSubjectsPageState extends State<MandateSubjectsPage> {
  Future<MandateSubjectsData>? _future;
  String _period = '7d';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<MandateSubjectsData> _load() => context
      .read<MandateRepository>()
      .subjects(filter: MandateFilter(period: _period));

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assuntos mais solicitados')),
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
            child: FutureBuilder<MandateSubjectsData>(
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
                if (data.byTheme.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhum assunto no período.',
                    icon: Icons.category_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: data.byTheme.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final s = data.byTheme[i];
                      final trend = s.trendPercent;
                      final trendLabel = trend == null
                          ? null
                          : trend >= 0
                          ? 'Variação +${trend.toStringAsFixed(0)}%'
                          : 'Variação ${trend.toStringAsFixed(0)}%';
                      return MandateRankingTile(
                        rank: i + 1,
                        title: s.label,
                        subtitle: [
                          '${s.quantity} solicitações',
                          if (s.previousQuantity != null)
                            'Anterior: ${s.previousQuantity}',
                          ?trendLabel,
                        ].join(' · '),
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (_) => Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Quantidade: ${s.quantity}'),
                                  if (s.previousQuantity != null)
                                    Text(
                                      'Período anterior: ${s.previousQuantity}',
                                    ),
                                  if (trendLabel != null) Text(trendLabel),
                                ],
                              ),
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
