import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/intelligence_models.dart';
import '../data/intelligence_repository.dart';
import 'widgets/intelligence_widgets.dart';

class IntelligenceInsightsPage extends StatefulWidget {
  const IntelligenceInsightsPage({super.key, this.opportunitiesOnly = false});

  final bool opportunitiesOnly;

  @override
  State<IntelligenceInsightsPage> createState() =>
      _IntelligenceInsightsPageState();
}

class _IntelligenceInsightsPageState extends State<IntelligenceInsightsPage> {
  Future<IntelligenceInsightsData>? _future;
  String _period = '7d';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load(generate: true);
  }

  Future<IntelligenceInsightsData> _load({bool generate = false}) =>
      context.read<IntelligenceRepository>().insights(
            filter: IntelligenceFilter(period: _period),
            generate: generate,
          );

  Future<void> _refresh() async {
    setState(() => _future = _load(generate: true));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.opportunitiesOnly ? 'Oportunidades' : 'Insights';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          IntelPeriodFilterBar(
            value: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load(generate: false);
            }),
          ),
          Expanded(
            child: FutureBuilder<IntelligenceInsightsData>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
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
                final items = widget.opportunitiesOnly
                    ? data.items.where((e) => e.isOpportunity).toList()
                    : data.items;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            if (data.fromCache && data.cacheAgeLabel != null)
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: IntelStaleNotice(
                                  ageLabel: data.cacheAgeLabel!,
                                ),
                              ),
                            AppEmptyState(
                              message: widget.opportunitiesOnly
                                  ? 'Nenhuma oportunidade no período.'
                                  : 'Nenhum insight no período.',
                              icon: Icons.lightbulb_outline,
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                          itemCount: items.length +
                              (data.fromCache && data.cacheAgeLabel != null
                                  ? 1
                                  : 0),
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            if (data.fromCache &&
                                data.cacheAgeLabel != null &&
                                i == 0) {
                              return IntelStaleNotice(
                                ageLabel: data.cacheAgeLabel!,
                              );
                            }
                            final idx = data.fromCache &&
                                    data.cacheAgeLabel != null
                                ? i - 1
                                : i;
                            final insight = items[idx];
                            return InsightCard(
                              insight: insight,
                              onAction: insight.routeHint == null
                                  ? null
                                  : () => context.push(insight.routeHint!),
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
