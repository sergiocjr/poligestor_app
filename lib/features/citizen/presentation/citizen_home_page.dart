import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
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

  static final _mockNews = [
    NewsItem(
      title: 'Mutirão de limpeza neste sábado',
      summary:
          'Equipes percorrem as principais avenidas do Taquaral a partir das 8h.',
      category: 'Bairro',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NewsItem(
      title: 'Abertas as inscrições para capacitação',
      summary:
          'Cursos gratuitos de qualificação profissional com vagas limitadas.',
      category: 'Oportunidades',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NewsItem(
      title: 'Iluminação reforçada em pontos críticos',
      summary:
          'Novos postes foram instalados em trechos com maior circulação noturna.',
      category: 'Cidade',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

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
    ProtocolStats stats =
        ProtocolStats(open: 0, inProgress: 0, resolved: 0, total: 0);
    List<AppointmentItem> next = const [];
    var unread = 0;
    String? syncMessage;
    var hasSyncIssue = false;

    try {
      protocolItems = await protocols.list(mode: mode);
      stats = ProtocolStats.fromList(protocolItems);
    } catch (e) {
      hasSyncIssue = true;
      syncMessage = UserMessages.fromError(e);
    }

    try {
      unread = await notifications.unreadCount(mode: mode);
    } catch (_) {
      hasSyncIssue = true;
      syncMessage ??= UserMessages.syncFailed;
    }

    try {
      next = await appointments.upcoming(mode: mode);
    } catch (_) {
      // Agenda pode falhar sem bloquear a home.
    }

    if (auth.apiDegraded) {
      hasSyncIssue = true;
      syncMessage ??= UserMessages.syncFailed;
    }

    return _HomeData(
      protocols: protocolItems,
      stats: stats,
      appointments: next,
      unread: unread,
      hasSyncIssue: hasSyncIssue,
      syncMessage: syncMessage,
    );
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  void _openChat([String? draft]) {
    context.push('/citizen/chat', extra: draft);
  }

  IconData _iconFor(RequestCategory c) => switch (c.iconName) {
        'help' => Icons.handshake_rounded,
        'report' => Icons.report_rounded,
        'lightbulb' => Icons.lightbulb_rounded,
        'event' => Icons.event_available_rounded,
        'search' => Icons.travel_explore_rounded,
        'attach' => Icons.upload_file_rounded,
        _ => Icons.apps_rounded,
      };

  Color _colorFor(RequestCategory c, ColorScheme scheme) => switch (c.id) {
        'ajuda' => scheme.primary,
        'denuncia' => const Color(0xFFC2410C),
        'sugestao' => const Color(0xFFCA8A04),
        'atendimento' => const Color(0xFF0369A1),
        'acompanhar' => const Color(0xFF0F766E),
        'documento' => const Color(0xFF4338CA),
        _ => scheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.session?.user;
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 720 ? 32.0 : 20.0;
    final dateFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final timeFmt = DateFormat('dd/MM · HH:mm');

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snapshot) {
              final loading = snapshot.connectionState != ConnectionState.done &&
                  !snapshot.hasData;
              if (loading) {
                return const HomeSkeleton();
              }

              final data = snapshot.data ??
                  _HomeData(
                    protocols: const [],
                    stats: ProtocolStats(
                      open: 0,
                      inProgress: 0,
                      resolved: 0,
                      total: 0,
                    ),
                    appointments: const [],
                    unread: 0,
                    hasSyncIssue: snapshot.hasError,
                    syncMessage: UserMessages.fromError(snapshot.error),
                  );

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        FadeSlideIn(
                          child: Text(
                            dateFmt.format(DateTime.now()),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 40),
                          child: Text(
                            'Olá, ${user?.firstName ?? 'Cidadão'}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (data.hasSyncIssue) ...[
                          const SizedBox(height: 12),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 60),
                            child: SoftNotice(
                              message:
                                  data.syncMessage ?? UserMessages.syncFailed,
                              icon: Icons.sync_problem_rounded,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 80),
                          child: AssistantHero(
                            greeting: 'Olá, ${user?.firstName ?? 'Cidadão'}',
                            onSubmit: _openChat,
                            onOpenChat: () => _openChat(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 100),
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/citizen/requests/new'),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Nova solicitação'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 120),
                          child: SectionHeader(
                            title: 'Ações rápidas',
                            subtitle: 'Escolha o que deseja fazer agora',
                          ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 140),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final cross = constraints.maxWidth >= 680 ? 3 : 2;
                              return GridView.count(
                                crossAxisCount: cross,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio:
                                    constraints.maxWidth >= 680 ? 1.35 : 1.05,
                                children: [
                                  for (final c in RequestCategory.all)
                                    FeatureActionCard(
                                      icon: _iconFor(c),
                                      title: c.label,
                                      description: c.description,
                                      color: _colorFor(
                                        c,
                                        Theme.of(context).colorScheme,
                                      ),
                                      onTap: () {
                                        if (c.id == 'acompanhar') {
                                          context.go('/citizen/requests');
                                        } else {
                                          context.push(
                                            '/citizen/requests/new',
                                            extra: {'category': c.id},
                                          );
                                        }
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 160),
                          child: SectionHeader(
                            title: 'Resumo',
                            subtitle: 'Acompanhe seu andamento',
                          ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 180),
                          child: Row(
                            children: [
                              _SummaryCard(
                                label: 'Abertas',
                                value: data.stats.open,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              _SummaryCard(
                                label: 'Andamento',
                                value: data.stats.inProgress,
                                color: const Color(0xFFC2410C),
                              ),
                              const SizedBox(width: 10),
                              _SummaryCard(
                                label: 'Resolvidas',
                                value: data.stats.resolved,
                                color: const Color(0xFF15803D),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 200),
                          child: PressableScale(
                            onTap: () => context.go('/citizen/notifications'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      data.unread == 0
                                          ? 'Você está em dia com os avisos'
                                          : '${data.unread} notificação(ões) não lida(s)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 220),
                          child: SectionHeader(
                            title: 'Minhas solicitações recentes',
                            actionLabel: 'Ver todas',
                            onAction: () => context.go('/citizen/requests'),
                          ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 240),
                          child: data.protocols.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                  ),
                                  child: Text(
                                    data.hasSyncIssue
                                        ? UserMessages.syncFailed
                                        : UserMessages.emptyRequests,
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (var i = 0;
                                        i < data.protocols.take(4).length;
                                        i++)
                                      RequestTimelineTile(
                                        title: data.protocols[i].title,
                                        number: data.protocols[i].number,
                                        statusLabel: ProtocolStatusLabel.pt(
                                          data.protocols[i].status,
                                        ),
                                        isLast: i ==
                                            data.protocols.take(4).length - 1,
                                        onTap: () => context.push(
                                          '/citizen/requests/${data.protocols[i].id}',
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 260),
                          child: SectionHeader(
                            title: 'Agenda',
                            subtitle: 'Próximos compromissos',
                          ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 280),
                          child: SizedBox(
                            height: 150,
                            child: data.appointments.isEmpty
                                ? ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: const [
                                      AgendaMiniCard(
                                        title: 'Nenhum compromisso',
                                        when: 'Sua agenda está livre',
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data.appointments.length,
                                    itemBuilder: (context, index) {
                                      final a = data.appointments[index];
                                      return AgendaMiniCard(
                                        title: a.title,
                                        when: a.startsAt == null
                                            ? null
                                            : timeFmt
                                                .format(a.startsAt!.toLocal()),
                                        location: a.location,
                                      );
                                    },
                                  ),
                          ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 300),
                          child: SectionHeader(
                            title: 'Últimas notícias',
                            subtitle: 'Atualizações da cidade',
                          ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 320),
                          child: SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _mockNews.length,
                              itemBuilder: (context, index) =>
                                  NewsCard(item: _mockNews[index]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 340),
                          child: SectionHeader(title: 'Meu Bairro'),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 360),
                          child: NeighborhoodCard(
                            neighborhoodLabel:
                                user?.neighborhoodLabel ?? 'Sua região',
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: ChatFab(onPressed: () => _openChat()),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
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
    required this.hasSyncIssue,
    this.syncMessage,
  });

  final List<ProtocolSummary> protocols;
  final ProtocolStats stats;
  final List<AppointmentItem> appointments;
  final int unread;
  final bool hasSyncIssue;
  final String? syncMessage;
}
