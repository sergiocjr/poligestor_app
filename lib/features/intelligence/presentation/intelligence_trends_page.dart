import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/intelligence_models.dart';
import '../data/intelligence_repository.dart';
import 'widgets/intelligence_widgets.dart';

class IntelligenceTrendsPage extends StatefulWidget {
  const IntelligenceTrendsPage({super.key});

  @override
  State<IntelligenceTrendsPage> createState() => _IntelligenceTrendsPageState();
}

class _IntelligenceTrendsPageState extends State<IntelligenceTrendsPage> {
  Future<IntelligenceTrendsData>? _future;
  String _period = '30d';
  String? _district;
  String? _category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<IntelligenceTrendsData> _load() =>
      context.read<IntelligenceRepository>().trends(
            filter: IntelligenceFilter(
              period: _period,
              district: _district,
              category: _category,
            ),
          );

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _editTextFilter({
    required String title,
    required String? current,
    required ValueChanged<String?> onSave,
  }) async {
    final ctrl = TextEditingController(text: current ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Deixe vazio para limpar',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (value == null) return;
    onSave(value.isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tendências')),
      body: Column(
        children: [
          IntelPeriodFilterBar(
            value: _period == 'today' || _period == '7d' || _period == '30d'
                ? _period
                : '30d',
            onChanged: (v) => setState(() {
              _period = v;
              _future = _load();
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: Text(_district == null ? 'Bairro' : 'Bairro: $_district'),
                  onPressed: () => _editTextFilter(
                    title: 'Filtrar por bairro',
                    current: _district,
                    onSave: (v) => setState(() {
                      _district = v;
                      _future = _load();
                    }),
                  ),
                ),
                ActionChip(
                  label: Text(
                    _category == null ? 'Assunto' : 'Assunto: $_category',
                  ),
                  onPressed: () => _editTextFilter(
                    title: 'Filtrar por assunto',
                    current: _category,
                    onSave: (v) => setState(() {
                      _category = v;
                      _future = _load();
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<IntelligenceTrendsData>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done &&
                    !snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SkeletonBox(height: 140, radius: 16),
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
                final s = data.signals;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    children: [
                      if (data.fromCache && data.cacheAgeLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: IntelStaleNotice(ageLabel: data.cacheAgeLabel!),
                        ),
                      Card(
                        child: ListTile(
                          title: const Text('Comparação e ritmo'),
                          subtitle: Text(
                            'Momento: ${s.momentumLabel}\n'
                            'Novas vs resolvidas: ${s.createdVsResolved}\n'
                            'Inclinação novas: ${s.createdSlope.toStringAsFixed(3)}\n'
                            'Inclinação resolvidas: ${s.resolvedSlope.toStringAsFixed(3)}',
                          ),
                          isThreeLine: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TrendSeriesCard(title: 'Histórico diário', points: data.daily),
                      const SizedBox(height: 8),
                      TrendSeriesCard(title: 'Evolução semanal', points: data.weekly),
                      const SizedBox(height: 8),
                      TrendSeriesCard(title: 'Evolução mensal', points: data.monthly),
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
