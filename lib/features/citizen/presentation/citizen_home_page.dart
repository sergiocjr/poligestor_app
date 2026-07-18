import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../agenda/data/appointments_repository.dart';
import '../../protocols/data/protocol_models.dart';
import '../data/portal_home_models.dart';
import '../data/portal_home_repository.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage>
    with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Carga única na criação da aba; IndexedStack preserva o estado.
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final auth = context.read<AuthController>();
    final repo = context.read<PortalHomeRepository>();

    try {
      final home = await repo.fetchHome(tenantSlug: auth.session?.tenantSlug);
      final actions = home.quickActions.isNotEmpty
          ? home.quickActions.map((e) => e.toRequestCategory()).toList()
          : RequestCategory.all;

      return _HomeData(
        displayName: home.user.firstName,
        neighborhoodLabel: home.user.neighborhoodLabel,
        photoUrl: home.user.foto,
        assistantPrompt: home.assistant.message,
        quickActions: actions,
        protocols: home.recentProtocols,
        open: home.summary.protocolosAbertos,
        inProgress: home.summary.protocolosAndamento,
        resolved: home.summary.protocolosResolvidos,
        appointments: home.appointments,
        unread: home.summary.notificacoesNaoLidas,
        hasSyncIssue: false,
      );
    } catch (e) {
      final offline = UserMessages.fromError(e) == UserMessages.offline;
      return _HomeData.error(
        offline ? UserMessages.offline : UserMessages.homeUpdateFailed,
      );
    }
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  void _openChat([String? draft]) {
    context.push('/citizen/chat', extra: draft);
  }

  void _onQuickAction(RequestCategory c) {
    if (c.id == 'protocolo' || c.id == 'acompanhar') {
      context.go('/citizen/requests');
      return;
    }
    if (c.id == 'assistente' || c.id == 'chat') {
      _openChat();
      return;
    }
    context.push('/citizen/requests/new', extra: {'category': c.id});
  }

  IconData _iconFor(RequestCategory c) => switch (c.iconName) {
        'help' => Icons.handshake_rounded,
        'alert' || 'report' => Icons.report_rounded,
        'idea' || 'lightbulb' => Icons.lightbulb_rounded,
        'home' => Icons.home_work_rounded,
        'calendar' || 'event' => Icons.event_available_rounded,
        'search' => Icons.travel_explore_rounded,
        'file' || 'attach' => Icons.upload_file_rounded,
        'chat' => Icons.forum_rounded,
        _ => Icons.apps_rounded,
      };

  Color _colorFor(RequestCategory c, ColorScheme scheme) => switch (c.id) {
        'ajuda' => scheme.primary,
        'denuncia' => const Color(0xFFC2410C),
        'sugestao' => const Color(0xFFCA8A04),
        'agenda' || 'atendimento' || 'visita' => const Color(0xFF0369A1),
        'protocolo' || 'acompanhar' => const Color(0xFF0F766E),
        'documento' => const Color(0xFF4338CA),
        'assistente' => const Color(0xFF0F766E),
        _ => scheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  _HomeData.error(UserMessages.homeUpdateFailed);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding:
                        EdgeInsets.fromLTRB(horizontal, 12, horizontal, 120),
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
                            'Olá, ${data.displayName}',
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SoftNotice(
                                  message: data.syncMessage ??
                                      UserMessages.homeUpdateFailed,
                                  icon: Icons.sync_problem_rounded,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: _reload,
                                    child: const Text('Tentar novamente'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 80),
                          child: AssistantHero(
                            greeting: 'Olá, ${data.displayName}',
                            prompt: data.assistantPrompt,
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
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 120),
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
                                  for (final c in data.quickActions)
                                    FeatureActionCard(
                                      icon: _iconFor(c),
                                      title: c.label,
                                      description: c.description,
                                      color: _colorFor(
                                        c,
                                        Theme.of(context).colorScheme,
                                      ),
                                      onTap: () => _onQuickAction(c),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 160),
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
                                value: data.open,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              _SummaryCard(
                                label: 'Andamento',
                                value: data.inProgress,
                                color: const Color(0xFFC2410C),
                              ),
                              const SizedBox(width: 10),
                              _SummaryCard(
                                label: 'Resolvidas',
                                value: data.resolved,
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
                                        ? UserMessages.homeUpdateFailed
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
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 260),
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
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 300),
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
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 340),
                          child: SectionHeader(title: 'Meu Bairro'),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 360),
                          child: NeighborhoodCard(
                            neighborhoodLabel: data.neighborhoodLabel,
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
    required this.displayName,
    required this.neighborhoodLabel,
    required this.assistantPrompt,
    required this.quickActions,
    required this.protocols,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.appointments,
    required this.unread,
    required this.hasSyncIssue,
    this.photoUrl,
    this.syncMessage,
  });

  factory _HomeData.error(String message) {
    return _HomeData(
      displayName: 'Cidadão',
      neighborhoodLabel: 'Sua região',
      assistantPrompt: 'Como podemos ajudar você hoje?',
      quickActions: RequestCategory.all,
      protocols: const [],
      open: 0,
      inProgress: 0,
      resolved: 0,
      appointments: const [],
      unread: 0,
      hasSyncIssue: true,
      syncMessage: message,
    );
  }

  final String displayName;
  final String neighborhoodLabel;
  final String? photoUrl;
  final String assistantPrompt;
  final List<RequestCategory> quickActions;
  final List<ProtocolSummary> protocols;
  final int open;
  final int inProgress;
  final int resolved;
  final List<AppointmentItem> appointments;
  final int unread;
  final bool hasSyncIssue;
  final String? syncMessage;
}
