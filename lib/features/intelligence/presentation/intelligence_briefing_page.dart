import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/intelligence_models.dart';
import '../data/intelligence_repository.dart';
import 'widgets/intelligence_widgets.dart';

class IntelligenceBriefingPage extends StatefulWidget {
  const IntelligenceBriefingPage({super.key});

  @override
  State<IntelligenceBriefingPage> createState() =>
      _IntelligenceBriefingPageState();
}

class _IntelligenceBriefingPageState extends State<IntelligenceBriefingPage> {
  Future<IntelligenceBriefingView>? _future;
  String _period = '7d';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<IntelligenceBriefingView> _load() =>
      context.read<IntelligenceRepository>().briefing(
            filter: IntelligenceFilter(period: _period),
          );

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Briefing diário')),
      body: Column(
        children: [
          IntelPeriodFilterBar(
            value: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load();
            }),
          ),
          Expanded(
            child: FutureBuilder<IntelligenceBriefingView>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SkeletonBox(height: 160, radius: 16),
                  );
                }
                if (snap.hasError && !snap.hasData) {
                  return AppErrorState(
                    message: UserMessages.fromError(snap.error),
                    error: snap.error,
                    onRetry: _refresh,
                  );
                }
                final view = snap.data!;
                final b = view.briefing;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    children: [
                      if (view.fromCache && view.cacheAgeLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: IntelStaleNotice(ageLabel: view.cacheAgeLabel!),
                        ),
                      if (b.bullets.isEmpty)
                        const AppEmptyState(
                          message: 'Sem resumo do dia por enquanto.',
                          icon: Icons.wb_sunny_outlined,
                        )
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resumo do dia',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 12),
                                for (final line in b.bullets)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('•  '),
                                        Expanded(child: Text(line)),
                                      ],
                                    ),
                                  ),
                                if (b.source != null)
                                  Text(
                                    'Fonte: ${b.source}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      const SoftNotice(
                        message:
                            'Principais acontecimentos, bairros, assuntos e atrasos '
                            'vêm do texto gerado pela API — sem cálculos no app.',
                      ),
                    ],
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
