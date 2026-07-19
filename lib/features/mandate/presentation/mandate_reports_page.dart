import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/mandate_models.dart';
import '../data/mandate_repository.dart';
import 'widgets/mandate_widgets.dart';

class MandateReportsPage extends StatefulWidget {
  const MandateReportsPage({super.key});

  @override
  State<MandateReportsPage> createState() => _MandateReportsPageState();
}

class _MandateReportsPageState extends State<MandateReportsPage> {
  Future<MandateReportsData>? _future;
  String _period = '7d';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<MandateReportsData> _load() =>
      context.read<MandateRepository>().reports(
            filter: MandateFilter(period: _period),
          );

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: Column(
        children: [
          MandatePeriodFilterBar(
            value: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load();
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SoftNotice(
              message:
                  'Listagem fornecida pela API. Exportação PDF/Excel/CSV '
                  'aparece quando o backend disponibilizar links de geração.',
            ),
          ),
          Expanded(
            child: FutureBuilder<MandateReportsData>(
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
                if (data.rows.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhuma linha de relatório no período.',
                    icon: Icons.summarize_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: data.rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = data.rows[i];
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${r.number} — ${r.subject}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            [
                              r.statusLabel,
                              if (r.district != null) r.district!,
                              if (r.themeLabel != null) r.themeLabel!,
                              if (r.assigneeName != null) r.assigneeName!,
                            ].join(' · '),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: r.id.isEmpty
                              ? null
                              : () => context.push('/home/protocols/${r.id}'),
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
