import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../agenda/data/appointments_repository.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../protocols/data/protocol_models.dart';
import '../../protocols/data/protocols_repository.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage> {
  Future<_HomeData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_HomeData> _load() async {
    final auth = context.read<AuthController>();
    final protocols = context.read<ProtocolsRepository>();
    final notifications = context.read<NotificationsRepository>();
    final appointments = context.read<AppointmentsRepository>();
    final mode = auth.mode;

    List<ProtocolSummary> protocolItems = const [];
    ProtocolStats stats = ProtocolStats(open: 0, inProgress: 0, resolved: 0, total: 0);
    List<AppointmentItem> next = const [];
    int unread = 0;
    String? error;

    try {
      protocolItems = await protocols.list(mode: mode);
      stats = ProtocolStats.fromList(protocolItems);
    } catch (e) {
      error = e.toString();
    }

    try {
      unread = await notifications.unreadCount(mode: mode);
    } catch (_) {}

    try {
      next = await appointments.upcoming(mode: mode);
    } catch (_) {}

    return _HomeData(
      protocols: protocolItems,
      stats: stats,
      appointments: next,
      unread: unread,
      error: error,
    );
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  IconData _iconFor(RequestCategory c) => switch (c.iconName) {
        'help' => Icons.handshake_outlined,
        'report' => Icons.report_outlined,
        'lightbulb' => Icons.lightbulb_outline,
        'event' => Icons.event_available_outlined,
        'search' => Icons.travel_explore_outlined,
        'attach' => Icons.upload_file_outlined,
        _ => Icons.apps_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.session?.user;
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done &&
                  !snapshot.hasData) {
                return const LoadingView(message: 'Carregando sua home...');
              }

              final data = snapshot.data ??
                  _HomeData(
                    protocols: const [],
                    stats: ProtocolStats(
                        open: 0, inProgress: 0, resolved: 0, total: 0),
                    appointments: const [],
                    unread: 0,
                    error: snapshot.error?.toString(),
                  );

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                children: [
                  Text(
                    dateFmt.format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Olá, ${user?.firstName ?? 'Cidadão'}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(AppConfig.seedNavy),
                        ),
                  ),
                  Text(
                    'O que você precisa resolver hoje?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  if (auth.apiDegraded) ...[
                    const SizedBox(height: 12),
                    const ApiDegradedBanner(),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => context.go('/citizen/chat'),
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: const Text('Falar com o assistente'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/citizen/requests/new'),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Nova solicitação'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SectionHeader(title: 'Ações rápidas'),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    children: RequestCategory.all.map((c) {
                      return _QuickCard(
                        icon: _iconFor(c),
                        title: c.label,
                        onTap: () {
                          if (c.id == 'acompanhar') {
                            context.go('/citizen/requests');
                          } else if (c.id == 'atendimento') {
                            context.push('/citizen/requests/new',
                                extra: {'category': c.id});
                          } else {
                            context.push('/citizen/requests/new',
                                extra: {'category': c.id});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SectionHeader(title: 'Resumo'),
                  Row(
                    children: [
                      StatChip(
                        label: 'Abertas',
                        value: data.stats.open,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      StatChip(
                        label: 'Andamento',
                        value: data.stats.inProgress,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 8),
                      StatChip(
                        label: 'Resolvidas',
                        value: data.stats.resolved,
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ActionTileCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'Notificações não lidas',
                    subtitle: '${data.unread} pendente(s)',
                    onTap: () => context.go('/citizen/notifications'),
                  ),
                  SectionHeader(
                    title: 'Solicitações recentes',
                    actionLabel: 'Ver todas',
                    onAction: () => context.go('/citizen/requests'),
                  ),
                  if (data.error != null)
                    ErrorView(message: data.error!, onRetry: _reload)
                  else if (data.protocols.isEmpty)
                    const Text('Nenhuma solicitação ainda.')
                  else
                    ...data.protocols.take(4).map((p) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(p.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          [
                            if (p.number != null) '#${p.number}',
                            ProtocolStatusLabel.pt(p.status),
                          ].join(' · '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push('/citizen/requests/${p.id}'),
                      );
                    }),
                  const SectionHeader(title: 'Próximos compromissos'),
                  if (data.appointments.isEmpty)
                    Text(
                      'Nenhum compromisso agendado.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    )
                  else
                    ...data.appointments.map((a) {
                      final fmt = DateFormat('dd/MM HH:mm');
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_outlined),
                        title: Text(a.title),
                        subtitle: Text([
                          if (a.startsAt != null) fmt.format(a.startsAt!),
                          if (a.location != null) a.location!,
                        ].join(' · ')),
                      );
                    }),
                  const SectionHeader(title: 'Meu Bairro'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(AppConfig.seedNavy),
                          scheme.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Meu Bairro',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.neighborhoodLabel ??
                              'Em breve: avisos e serviços da sua região.',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/citizen/chat'),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Chat'),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeData {
  _HomeData({
    required this.protocols,
    required this.stats,
    required this.appointments,
    required this.unread,
    this.error,
  });

  final List<ProtocolSummary> protocols;
  final ProtocolStats stats;
  final List<AppointmentItem> appointments;
  final int unread;
  final String? error;
}
