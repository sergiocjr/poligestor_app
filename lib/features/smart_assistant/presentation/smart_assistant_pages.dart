import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_mode.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/smart_assistant_models.dart';
import '../data/smart_assistant_repository.dart';

/// Hub IA — Sprint 10.5 (rota existente `/home/chat`).
class SmartAssistantHubPage extends StatelessWidget {
  const SmartAssistantHubPage({super.key});

  static const _entries = <_HubEntry>[
    _HubEntry(
      title: 'Chat do Gabinete',
      subtitle: 'Conversar com a IA do mandato',
      icon: Icons.forum_outlined,
      route: '/home/chat/gabinete',
      live: true,
    ),
    _HubEntry(
      title: 'Resumos',
      subtitle: 'Resumos gerados para o gabinete',
      icon: Icons.article_outlined,
      route: '/home/chat/briefings',
      live: true,
    ),
    _HubEntry(
      title: 'Resumo do dia',
      subtitle: 'Síntese diária do mandato',
      icon: Icons.today_outlined,
      route: '/home/chat/summary/daily',
      live: true,
    ),
    _HubEntry(
      title: 'Resumo semanal',
      subtitle: 'Síntese semanal do mandato',
      icon: Icons.date_range_outlined,
      route: '/home/chat/summary/weekly',
      live: false,
    ),
    _HubEntry(
      title: 'Sugestões',
      subtitle: 'Ações sugeridas pela IA',
      icon: Icons.lightbulb_outline,
      route: '/home/chat/suggestions',
      live: false,
    ),
    _HubEntry(
      title: 'Prioridades',
      subtitle: 'Fila de prioridades do gabinete',
      icon: Icons.flag_outlined,
      route: '/home/chat/priorities',
      live: false,
    ),
    _HubEntry(
      title: 'Análises',
      subtitle: 'Alertas e oportunidades',
      icon: Icons.insights_outlined,
      route: '/home/chat/insights',
      live: true,
    ),
    _HubEntry(
      title: 'Perguntas ao gabinete',
      subtitle: 'Perguntas frequentes',
      icon: Icons.help_outline,
      route: '/home/chat/questions',
      live: false,
    ),
    _HubEntry(
      title: 'Histórico',
      subtitle: 'Conversas e sessões recentes',
      icon: Icons.history,
      route: '/home/chat/history',
      live: true,
    ),
    _HubEntry(
      title: 'Favoritos',
      subtitle: 'Itens salvos do assistente',
      icon: Icons.star_outline,
      route: '/home/chat/favorites',
      live: false,
    ),
    _HubEntry(
      title: 'Compartilhar',
      subtitle: 'Compartilhar resumos e análises',
      icon: Icons.ios_share_outlined,
      route: '/home/chat/share',
      live: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistente Inteligente')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final grid = GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisExtent: 124,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _entries.length,
            itemBuilder: (context, i) {
              final e = _entries[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push(e.route),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(child: Icon(e.icon)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                e.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                e.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(uiContractChip(available: e.live)),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: e.live
                              ? Colors.green.shade50
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
          if (!wide) return grid;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: grid,
            ),
          );
        },
      ),
    );
  }
}

class _HubEntry {
  const _HubEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.live,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool live;
}

/// Página genérica para endpoints ainda não publicados.
class SmartAssistantPendingPage extends StatefulWidget {
  const SmartAssistantPendingPage({
    super.key,
    required this.title,
    required this.path,
    required this.probe,
  });

  final String title;
  final String path;
  final Future<void> Function(SmartAssistantRepository repo) probe;

  @override
  State<SmartAssistantPendingPage> createState() =>
      _SmartAssistantPendingPageState();
}

class _SmartAssistantPendingPageState extends State<SmartAssistantPendingPage> {
  Future<void>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= widget.probe(context.read<SmartAssistantRepository>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            final err = snap.error;
            if (err is EndpointUnavailableException) {
              return EndpointPendingState(
                path: err.path,
                message:
                    '${widget.title} preparado. Aguardando contrato ativo na VPS.',
              );
            }
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = widget.probe(
                  context.read<SmartAssistantRepository>(),
                );
              }),
            );
          }
          // Se algum dia passar a responder 200 sem payload útil.
          return EndpointPendingState(
            path: widget.path,
            message:
                '${widget.title} ainda sem UI de detalhe — contrato inesperado.',
          );
        },
      ),
    );
  }
}

class SmartAssistantBriefingsPage extends StatefulWidget {
  const SmartAssistantBriefingsPage({super.key});

  @override
  State<SmartAssistantBriefingsPage> createState() =>
      _SmartAssistantBriefingsPageState();
}

class _SmartAssistantBriefingsPageState
    extends State<SmartAssistantBriefingsPage> {
  Future<SaBriefingView>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<SmartAssistantRepository>().briefings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumos')),
      body: _BriefingBody(
        future: _future,
        onRetry: () => setState(() {
          _future = context.read<SmartAssistantRepository>().briefings();
        }),
      ),
    );
  }
}

class SmartAssistantDaySummaryPage extends StatefulWidget {
  const SmartAssistantDaySummaryPage({super.key});

  @override
  State<SmartAssistantDaySummaryPage> createState() =>
      _SmartAssistantDaySummaryPageState();
}

class _SmartAssistantDaySummaryPageState
    extends State<SmartAssistantDaySummaryPage> {
  Future<SaBriefingView>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<SmartAssistantRepository>().daySummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumo do dia')),
      body: _BriefingBody(
        future: _future,
        onRetry: () => setState(() {
          _future = context.read<SmartAssistantRepository>().daySummary();
        }),
      ),
    );
  }
}

class _BriefingBody extends StatelessWidget {
  const _BriefingBody({required this.future, required this.onRetry});

  final Future<SaBriefingView>? future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SaBriefingView>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          final err = snap.error;
          if (err is EndpointUnavailableException) {
            return EndpointPendingState(path: err.path);
          }
          return AppErrorState(error: snap.error, onRetry: onRetry);
        }
        final view = snap.data!;
        if (view.bullets.isEmpty) {
          return const AppEmptyState(message: 'Nenhum item no resumo.');
        }
        final fmt = DateFormat('dd/MM/yyyy HH:mm');
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (view.fromCache)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Exibindo dados salvos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (view.title != null)
              Text(
                view.title!,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            if (view.generatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  'Gerado em ${fmt.format(view.generatedAt!.toLocal())}'
                  '${view.scope != null ? ' · ${view.scope}' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ...view.bullets.map(
              (b) => Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(b),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SmartAssistantInsightsPage extends StatefulWidget {
  const SmartAssistantInsightsPage({super.key});

  @override
  State<SmartAssistantInsightsPage> createState() =>
      _SmartAssistantInsightsPageState();
}

class _SmartAssistantInsightsPageState extends State<SmartAssistantInsightsPage>
    with _SaRefresh {
  Future<List<SaInsightItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindSaRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<SaInsightItem>> _load() =>
      context.read<SmartAssistantRepository>().insights();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análises')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<SaInsightItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snap.hasError) {
              final err = snap.error;
              if (err is EndpointUnavailableException) {
                return EndpointPendingState(path: err.path);
              }
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final items = snap.data ?? const [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(message: 'Nenhuma análise no momento.'),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = items[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.insights_outlined),
                    title: Text(
                      it.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [
                        if (it.priority != null) it.priority!,
                        if (it.type != null) it.type!,
                        it.body,
                      ].join(' · '),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SmartAssistantHistoryPage extends StatefulWidget {
  const SmartAssistantHistoryPage({super.key});

  @override
  State<SmartAssistantHistoryPage> createState() =>
      _SmartAssistantHistoryPageState();
}

class _SmartAssistantHistoryPageState extends State<SmartAssistantHistoryPage> {
  Future<List<SaConversationItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<SmartAssistantRepository>().conversations();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: FutureBuilder<List<SaConversationItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            final err = snap.error;
            if (err is EndpointUnavailableException) {
              return EndpointPendingState(path: err.path);
            }
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() {
                _future = context
                    .read<SmartAssistantRepository>()
                    .conversations();
              }),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const AppEmptyState(
              message: 'Nenhuma conversa no histórico.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = items[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(
                    c.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    [
                      if (c.updatedAt != null)
                        fmt.format(c.updatedAt!.toLocal()),
                      if (c.messageCount > 0) '${c.messageCount} msgs',
                    ].join(' · '),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SmartAssistantGabineteChatPage extends StatefulWidget {
  const SmartAssistantGabineteChatPage({super.key});

  @override
  State<SmartAssistantGabineteChatPage> createState() =>
      _SmartAssistantGabineteChatPageState();
}

class _SmartAssistantGabineteChatPageState
    extends State<SmartAssistantGabineteChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <SaChatMessage>[];
  bool _sending = false;
  EndpointUnavailableException? _pending;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _messages.add(SaChatMessage(role: 'user', content: text));
      _ctrl.clear();
    });
    try {
      final reply = await context
          .read<SmartAssistantRepository>()
          .sendGabineteMessage(text);
      if (!mounted) return;
      setState(() => _messages.add(reply.message));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_scroll.hasClients) {
        await _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      setState(() => _pending = e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pending != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat do Gabinete')),
        body: EndpointPendingState(
          path: _pending!.path,
          message: 'Chat do Gabinete preparado. Aguardando contrato ativo.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat do Gabinete')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const AppEmptyState(
                    message:
                        'Envie uma mensagem para o assistente do gabinete.',
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final m = _messages[i];
                      final align = m.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft;
                      final bg = m.isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest;
                      return Align(
                        alignment: align,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(m.content),
                        ),
                      );
                    },
                  ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Pergunte ao gabinete…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _send,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              AuthMode.staff.aiChatPath,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

mixin _SaRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindSaRefresh(VoidCallback reload) {
    final r = context.watch<MandateRefreshController>();
    if (!identical(_refresh, r)) {
      _refresh = r;
      _gen = r.generation;
    } else if (r.generation != _gen) {
      _gen = r.generation;
      reload();
    }
  }
}
