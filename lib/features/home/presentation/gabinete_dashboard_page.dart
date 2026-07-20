import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../mandate/data/mandate_models.dart';
import '../../mandate/data/mandate_repository.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../../regional_news/presentation/news_pages.dart';

/// Tela inicial do Gabinete — acabamento alinhado ao Início do Cidadão.
class GabineteDashboardPage extends StatefulWidget {
  const GabineteDashboardPage({super.key});

  @override
  State<GabineteDashboardPage> createState() => _GabineteDashboardPageState();
}

class _GabineteDashboardPageState extends State<GabineteDashboardPage>
    with AutomaticKeepAliveClientMixin {
  Future<MandateExecutive?>? _future;
  Object? _error;
  MandateRefreshController? _refreshCtrl;
  int _lastGen = -1;

  @override
  bool get wantKeepAlive => true;

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
    _error = null;
    try {
      return await context.read<MandateRepository>().executive(
        filter: const MandateFilter(period: '7d'),
      );
    } on ApiException catch (e) {
      _error = e;
      return null;
    } catch (e) {
      _error = e;
      return null;
    }
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final org = context.watch<TenantController>().organization;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final pad = width >= 720 ? 28.0 : 16.0;
    final dateFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gabinete'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<MandateExecutive?>(
          future: _future,
          builder: (context, snap) {
            final loading =
                snap.connectionState != ConnectionState.done && !snap.hasData;
            if (loading) {
              return const HomeSkeleton();
            }

            final exec = snap.data;
            final day = exec?.daySummary;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(pad, 4, pad, 28),
              children: [
                FadeSlideIn(
                  child: Text(
                    dateFmt.format(DateTime.now()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 40),
                  child: Text(
                    org?.name ?? 'Gabinete',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: Text(
                    'Resumo do dia e atalhos do mandato',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (exec?.fromCache == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Dados salvos ${exec!.cacheAgeLabel ?? ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 20),
                if (exec == null && _error != null)
                  AppErrorState(error: _error, onRetry: _reload)
                else if (exec == null)
                  const AppEmptyState(
                    message: 'Resumo do gabinete indisponível no momento.',
                  )
                else ...[
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: SectionHeader(
                      title: 'Hoje',
                      subtitle: 'Toque em um indicador para abrir protocolos',
                    ),
                  ),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final cols = box.maxWidth >= 560 ? 4 : 2;
                        return GridView.count(
                          crossAxisCount: cols,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: box.maxWidth < 380 ? 1.2 : 1.45,
                          children: [
                            _MetricCard(
                              label: 'Abertos',
                              value: '${day!.open}',
                              icon: Icons.inbox_rounded,
                              tint: scheme.primary,
                              onTap: () => context.go('/home/protocols'),
                            ),
                            _MetricCard(
                              label: 'Em atraso',
                              value: '${day.overdue}',
                              icon: Icons.warning_amber_rounded,
                              tint: const Color(0xFFC2410C),
                              onTap: () => context.go('/home/protocols'),
                            ),
                            _MetricCard(
                              label: 'Concluídos',
                              value: '${day.resolvedToday}',
                              icon: Icons.check_circle_rounded,
                              tint: const Color(0xFF0F766E),
                              onTap: () => context.go('/home/protocols'),
                            ),
                            _MetricCard(
                              label: 'Aguard. cidadão',
                              value: '${day.waitingCitizen}',
                              icon: Icons.person_rounded,
                              tint: const Color(0xFF0369A1),
                              onTap: () => context.go('/home/protocols'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (exec.attention.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SectionHeader(
                      title: 'Pontos de atenção',
                      subtitle: 'Prioridades que pedem ação',
                    ),
                    ...exec.attention.take(4).map((a) {
                      final actionable = a.routeHint != null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: actionable
                                ? () => context.go(a.routeHint!)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: scheme.primaryContainer,
                                    child: Icon(
                                      Icons.priority_high_rounded,
                                      size: 18,
                                      color: scheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          a.explanation,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                        ),
                                        if (!actionable) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            'Informativo',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: scheme.outline,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (actionable)
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: scheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
                const SizedBox(height: 16),
                const GabineteNewsHomeSection(),
                const SizedBox(height: 8),
                SectionHeader(
                  title: 'Atalhos',
                  subtitle: 'Acesso rápido às áreas do gabinete',
                ),
                LayoutBuilder(
                  builder: (context, box) {
                    final cols = box.maxWidth >= 560 ? 3 : 2;
                    const shortcuts = <(String, String, IconData, String)>[
                      (
                        'Protocolos',
                        'Fila e trâmite',
                        Icons.assignment_rounded,
                        '/home/protocols',
                      ),
                      (
                        'Agenda',
                        'Compromissos',
                        Icons.event_rounded,
                        '/home/agenda',
                      ),
                      (
                        'Mandato',
                        'Visão executiva',
                        Icons.account_balance_rounded,
                        '/home/mandate',
                      ),
                      (
                        'Inteligência',
                        'Resumos e percepções',
                        Icons.auto_awesome_rounded,
                        '/home/intelligence',
                      ),
                      (
                        'Mais',
                        'Painéis e módulos',
                        Icons.apps_rounded,
                        '/home/more',
                      ),
                    ];
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: box.maxWidth < 380 ? 2.15 : 2.4,
                      children: [
                        for (final s in shortcuts)
                          _ShortcutTile(
                            title: s.$1,
                            subtitle: s.$2,
                            icon: s.$3,
                            route: s.$4,
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableScale(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: 0.10),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 22, color: tint),
                const Spacer(),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PressableScale(
      onTap: () => context.go(route),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                child: Icon(icon, size: 18, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
