import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/pg_design_system.dart';
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

  Future<MandateTvData> _fetch() => context.read<MandateRepository>().tv();

  Future<MandateTvData> _load() async {
    final data = await _fetch();
    _refreshTimer?.cancel();
    final sec = data.refreshSeconds.clamp(15, 120);
    _refreshTimer = Timer.periodic(Duration(seconds: sec), (_) {
      if (!mounted) return;
      setState(() => _future = _fetch());
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
    final scheme = Theme.of(context).colorScheme;
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
            MandateIndicatorCard(label: 'Novas hoje', value: '${k.newToday}'),
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
              value: pgFormatResolutionHours(k.avgResolutionHours),
              hint: 'Prazo de atendimento',
            ),
          ];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                SoftNotice(
                  message:
                      'Painel informativo para acompanhamento. Os cartões '
                      'abaixo são apenas indicadores.',
                ),
                const SizedBox(height: 12),
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
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Fila vazia.'),
                  )
                else
                  ...data.queueTop.take(8).map((q) {
                    final title =
                        (q['number'] ?? q['title'] ?? q['subject'] ?? 'Item')
                            .toString();
                    final sub = [
                      if (q['status_label'] != null) q['status_label'],
                      if (q['district'] != null) q['district'],
                    ].join(' · ');
                    final id = (q['id'] ?? q['uuid'])?.toString();
                    final openable = id != null && id.isNotEmpty;
                    return Card(
                      child: ListTile(
                        title: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: sub.isEmpty
                            ? null
                            : Text(
                                sub,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        trailing: openable
                            ? Icon(
                                Icons.chevron_right_rounded,
                                color: scheme.primary,
                              )
                            : Text(
                                'Informativo',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: scheme.outline),
                              ),
                        onTap: openable
                            ? () => context.push('/home/protocols/$id')
                            : null,
                      ),
                    );
                  }),
                const MandateSectionSeeAll(title: 'Agenda de hoje'),
                if (data.agendaToday.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Sem compromissos hoje.'),
                  )
                else
                  ...data.agendaToday.take(6).map((e) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.event_outlined,
                          color: scheme.primary,
                        ),
                        title: Text(
                          (e['title'] ?? 'Compromisso').toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          [
                            if (e['starts_at'] != null) e['starts_at'],
                            if (e['location'] != null) e['location'],
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          'Informativo',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.outline),
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
