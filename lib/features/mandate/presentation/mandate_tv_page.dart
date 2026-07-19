import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';
import 'widgets/mandate_widgets.dart';

/// Painel do mandato — visualização ampla / tablet.
class MandateTvPage extends StatefulWidget {
  const MandateTvPage({super.key});

  @override
  State<MandateTvPage> createState() => _MandateTvPageState();
}

class _MandateTvPageState extends State<MandateTvPage> {
  Future<MandateTvData>? _future;
  Timer? _refreshTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<MandateTvData> _load() async {
    final data = await context.read<MandateRepository>().tv();
    _refreshTimer?.cancel();
    final sec = data.refreshSeconds.clamp(15, 120);
    _refreshTimer = Timer.periodic(Duration(seconds: sec), (_) {
      if (!mounted) return;
      setState(() => _future = context.read<MandateRepository>().tv());
    });
    return data;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do mandato'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<MandateTvData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && !snap.hasData) {
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
          final data = snap.data!;
          final k = data.kpis;
          final indicators = [
            MandateIndicatorCard(label: 'Abertas', value: '${k.open}'),
            MandateIndicatorCard(
              label: 'Novas hoje',
              value: '${k.newToday}',
            ),
            MandateIndicatorCard(
              label: 'Resolvidas hoje',
              value: '${k.resolvedToday}',
            ),
            MandateIndicatorCard(
              label: 'Em atraso',
              value: '${k.overdue}',
              emphasis: k.overdue > 0,
            ),
            MandateIndicatorCard(
              label: 'Aguardando cidadão',
              value: '${k.waitingCitizen}',
            ),
            MandateIndicatorCard(
              label: 'Tempo médio',
              value: '${k.avgResolutionHours.toStringAsFixed(1)} h',
            ),
          ];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: wide ? 3 : 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: wide ? 1.6 : 1.35,
                  children: indicators,
                ),
                const MandateSectionSeeAll(title: 'Fila prioritária'),
                if (data.queueTop.isEmpty)
                  const Text('Fila vazia.')
                else
                  ...data.queueTop.take(8).map((q) {
                    final title =
                        (q['number'] ?? q['title'] ?? q['subject'] ?? 'Item')
                            .toString();
                    final sub = [
                      if (q['status_label'] != null) q['status_label'],
                      if (q['district'] != null) q['district'],
                    ].join(' · ');
                    return Card(
                      child: ListTile(
                        title: Text(title),
                        subtitle: sub.isEmpty ? null : Text(sub),
                      ),
                    );
                  }),
                const MandateSectionSeeAll(title: 'Agenda de hoje'),
                if (data.agendaToday.isEmpty)
                  const Text('Sem compromissos hoje.')
                else
                  ...data.agendaToday.take(6).map((e) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.event_outlined),
                        title: Text((e['title'] ?? 'Compromisso').toString()),
                        subtitle: Text(
                          [
                            if (e['starts_at'] != null) e['starts_at'],
                            if (e['location'] != null) e['location'],
                          ].join(' · '),
                        ),
                      ),
                    );
                  }),
                if (data.briefing != null &&
                    data.briefing!.bullets.isNotEmpty) ...[
                  const MandateSectionSeeAll(title: 'Resumo'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final b in data.briefing!.bullets.take(5))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('• $b'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
