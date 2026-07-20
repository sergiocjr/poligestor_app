import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../mandate/data/mandate_models.dart';
import '../../mandate/data/mandate_repository.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';

/// Tela inicial do Gabinete (staff) — painel resumido, não a lista de protocolos.
class GabineteDashboardPage extends StatefulWidget {
  const GabineteDashboardPage({super.key});

  @override
  State<GabineteDashboardPage> createState() => _GabineteDashboardPageState();
}

class _GabineteDashboardPageState extends State<GabineteDashboardPage> {
  Future<MandateExecutive?>? _future;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refresh = context.watch<MandateRefreshController>();
    if (!identical(_refreshCtrl, refresh)) {
      _refreshCtrl = refresh;
      _lastGen = refresh.generation;
    } else if (refresh.generation != _lastGen) {
      _lastGen = refresh.generation;
      _future = _load();
    }
    _future ??= _load();
  }

  Future<MandateExecutive?> _load() async {
    try {
      return await context.read<MandateRepository>().executive(
        filter: const MandateFilter(period: '7d'),
      );
    } on ApiException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = context.watch<TenantController>().organization;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 840 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gabinete'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            Text(
              org?.name ?? 'Gabinete',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Painel do gabinete — resumo e atalhos',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<MandateExecutive?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return AppErrorState(
                    error: snap.error,
                    onRetry: () => setState(() => _future = _load()),
                  );
                }
                final exec = snap.data;
                if (exec == null) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: AppEmptyState(
                      message: 'Resumo do gabinete indisponível no momento.',
                    ),
                  );
                }
                final day = exec.daySummary;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exec.fromCache)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Dados salvos ${exec.cacheAgeLabel ?? ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: width < 400 ? 1.55 : 1.7,
                      children: [
                        _KpiCard(
                          label: 'Abertos',
                          value: '${day.open}',
                          icon: Icons.inbox_outlined,
                        ),
                        _KpiCard(
                          label: 'Em atraso',
                          value: '${day.overdue}',
                          icon: Icons.warning_amber_outlined,
                        ),
                        _KpiCard(
                          label: 'Concluídos',
                          value: '${day.resolvedToday}',
                          icon: Icons.check_circle_outline,
                        ),
                        _KpiCard(
                          label: 'Aguard. cidadão',
                          value: '${day.waitingCitizen}',
                          icon: Icons.person_outline,
                        ),
                      ],
                    ),
                    if (exec.attention.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Pontos de atenção',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...exec.attention.take(3).map((a) {
                        return Card(
                          child: ListTile(
                            dense: true,
                            title: Text(
                              a.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              a.explanation,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: a.routeHint == null
                                ? null
                                : const Icon(Icons.chevron_right),
                            onTap: a.routeHint == null
                                ? null
                                : () => context.go(a.routeHint!),
                          ),
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Atalhos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: width < 400 ? 2.4 : 2.8,
              children: const [
                _ShortcutCard(
                  label: 'Protocolos',
                  icon: Icons.assignment_outlined,
                  route: '/home/protocols',
                ),
                _ShortcutCard(
                  label: 'Agenda',
                  icon: Icons.event_outlined,
                  route: '/home/agenda',
                ),
                _ShortcutCard(
                  label: 'Mandato',
                  icon: Icons.account_balance_outlined,
                  route: '/home/mandate',
                ),
                _ShortcutCard(
                  label: 'Inteligência',
                  icon: Icons.auto_awesome_outlined,
                  route: '/home/intelligence',
                ),
                _ShortcutCard(
                  label: 'Mais',
                  icon: Icons.more_horiz,
                  route: '/home/more',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
