import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/advanced_ai_contracts.dart';
import '../data/advanced_ai_models.dart';
import '../data/advanced_ai_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _AdvancedAiRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindAdvancedAiRefresh(VoidCallback reload) {
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

/// Hub — IA Avançada (Fase 18).
class AdvancedAiHubPage extends StatelessWidget {
  const AdvancedAiHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Conversa com IA',
      'Enviar mensagens e receber respostas',
      Icons.forum_outlined,
      'chat',
      '/home/advanced-ai/chat',
    ),
    _Entry(
      'Conversas',
      'Sessões e threads de conversa',
      Icons.chat_bubble_outline,
      'conversations',
      '/home/advanced-ai/conversations',
    ),
    _Entry(
      'Secretária Virtual',
      'Assistente administrativo inteligente',
      Icons.support_agent_outlined,
      'secretary',
      '/home/advanced-ai/secretary',
    ),
    _Entry(
      'Assessor Parlamentar',
      'Apoio legislativo e normas',
      Icons.gavel_outlined,
      'parliamentary-advisor',
      '/home/advanced-ai/parliamentary-advisor',
    ),
    _Entry(
      'Analista Político',
      'Análise de cenário e tendências',
      Icons.analytics_outlined,
      'political-analyst',
      '/home/advanced-ai/political-analyst',
    ),
    _Entry(
      'Analista Financeiro',
      'Indicadores e projeções financeiras',
      Icons.account_balance_wallet_outlined,
      'financial-analyst',
      '/home/advanced-ai/financial-analyst',
    ),
    _Entry(
      'Assessor de Comunicação',
      'Mensagens e estratégia de comunicação',
      Icons.campaign_outlined,
      'communication-advisor',
      '/home/advanced-ai/communication-advisor',
    ),
    _Entry(
      'Assessor Jurídico',
      'Orientações e pareceres jurídicos',
      Icons.balance_outlined,
      'legal-advisor',
      '/home/advanced-ai/legal-advisor',
    ),
    _Entry(
      'Planejamento estratégico',
      'Metas, cenários e planos de ação',
      Icons.route_outlined,
      'strategic-planning',
      '/home/advanced-ai/strategic-planning',
    ),
    _Entry(
      'Resumos do dia',
      'Resumos executivos gerados pela IA',
      Icons.article_outlined,
      'briefings',
      '/home/advanced-ai/briefings',
    ),
    _Entry(
      'Resumos',
      'Gerar resumos sob demanda',
      Icons.summarize_outlined,
      'summary',
      '/home/advanced-ai/summary',
    ),
    _Entry(
      'Sugestões inteligentes',
      'Ações sugeridas com base no contexto',
      Icons.lightbulb_outline,
      'suggestions',
      '/home/advanced-ai/suggestions',
    ),
    _Entry(
      'Histórico',
      'Registro de interações anteriores',
      Icons.history,
      'history',
      '/home/advanced-ai/history',
    ),
    _Entry(
      'Biblioteca de prompts',
      'Modelos e prompts reutilizáveis',
      Icons.library_books_outlined,
      'prompts',
      '/home/advanced-ai/prompts',
    ),
    _Entry(
      'Avaliação',
      'Enviar avaliação sobre respostas da IA',
      Icons.rate_review_outlined,
      'feedback',
      '/home/advanced-ai/feedback',
    ),
    _Entry(
      'Configurações',
      'Preferências da IA avançada',
      Icons.settings_outlined,
      'settings',
      '/home/advanced-ai/settings',
    ),
    _Entry(
      'Pesquisa',
      'Buscar na IA avançada',
      Icons.search_rounded,
      'search',
      '/home/advanced-ai/search',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('IA Avançada')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final body = ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              SoftNotice(
                message:
                    'Namespace /v1/ai/* sincronizado. Chip Ativo = contrato '
                    'publicado; Em preparação = ainda 404 na VPS.',
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisExtent: cross == 1 ? 104 : 112,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  final live = advancedAiPathLive(e.slug);
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push(e.route),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: live
                                  ? scheme.primary.withValues(alpha: 0.12)
                                  : scheme.surfaceContainerHighest,
                              child: Icon(
                                e.icon,
                                color: live
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    e.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    e.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Chip(
                              label: Text(
                                uiContractChip(available: live),
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
          if (!wide) return body;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: body,
            ),
          );
        },
      ),
    );
  }
}

class _Entry {
  const _Entry(this.title, this.subtitle, this.icon, this.slug, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String slug;
  final String route;
}

typedef AdvancedAiListLoader =
    Future<List<AdvancedAiItem>> Function(
      AdvancedAiRepository repo,
      String tenant,
    );

class AdvancedAiListPage extends StatefulWidget {
  const AdvancedAiListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
    this.pendingPath,
  });

  final String title;
  final AdvancedAiListLoader loader;
  final String emptyMessage;
  final String? pendingPath;

  @override
  State<AdvancedAiListPage> createState() => _AdvancedAiListPageState();
}

class _AdvancedAiListPageState extends State<AdvancedAiListPage>
    with _AdvancedAiRefresh {
  Future<List<AdvancedAiItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAdvancedAiRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<AdvancedAiItem>> _load() =>
      widget.loader(context.read<AdvancedAiRepository>(), _tenantOf(context));

  void _openItem(AdvancedAiItem item) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (item.role != null) Text('Papel: ${item.role}'),
                if (item.kind != null) Text('Tipo: ${item.kind}'),
                if (item.status != null)
                  Text('Situação: ${uiStatusLabel(item.status)}'),
                if (item.date != null)
                  Text('Data: ${dateFmt.format(item.date!.toLocal())}'),
                if (item.summary != null) ...[
                  const SizedBox(height: 8),
                  Text(item.summary!),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<AdvancedAiItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  SkeletonBox(height: 72, radius: 16),
                  SizedBox(height: 10),
                  SkeletonBox(height: 72, radius: 16),
                ],
              );
            }
            if (snap.error is EndpointUnavailableException) {
              final err = snap.error! as EndpointUnavailableException;
              return EndpointPendingState(
                path: err.path,
                message:
                    '${widget.title} preparado. Aguardando contrato ativo '
                    'em /v1/ai.',
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            var items = snap.data ?? const <AdvancedAiItem>[];
            if (_query.trim().isNotEmpty) {
              final q = _query.trim().toLowerCase();
              items = items
                  .where(
                    (e) =>
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.role ?? ''}'
                            .toLowerCase()
                            .contains(q),
                  )
                  .toList();
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(12),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Filtrar nesta lista…',
                    prefixIcon: Icon(Icons.filter_list),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: AppEmptyState(
                      message: widget.emptyMessage,
                      icon: Icons.inbox_outlined,
                    ),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: scheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(
                              Icons.psychology_outlined,
                              color: scheme.primary,
                            ),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              if (item.role != null) item.role!,
                              if (item.status != null)
                                uiStatusLabel(item.status),
                            ].where((s) => s.isNotEmpty).join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _openItem(item),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AdvancedAiChatPage extends StatefulWidget {
  const AdvancedAiChatPage({super.key, this.agentSlug, this.title});

  final String? agentSlug;
  final String? title;

  @override
  State<AdvancedAiChatPage> createState() => _AdvancedAiChatPageState();
}

class _AdvancedAiChatPageState extends State<AdvancedAiChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <AaiChatMessage>[];
  bool _sending = false;
  EndpointUnavailableException? _pending;
  String? _error;

  String get _title => widget.title ?? 'Conversa com IA';

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
      _messages.add(AaiChatMessage(role: 'user', content: text));
      _ctrl.clear();
    });
    try {
      final reply = await context.read<AdvancedAiRepository>().sendChatMessage(
        text,
        agentSlug: widget.agentSlug,
      );
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
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
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
        appBar: AppBar(title: Text(_title)),
        body: EndpointPendingState(
          path: _pending!.path,
          message: 'Conversa preparada. Aguardando contrato ativo.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          if (widget.agentSlug != null)
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.smart_toy_outlined),
                title: Text('Agente: ${widget.agentSlug}'),
                subtitle: const Text('Conversa com o agente inteligente'),
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? const AppEmptyState(
                    message: 'Envie uma mensagem para iniciar a conversa.',
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
                        hintText: 'Digite sua mensagem…',
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
        ],
      ),
    );
  }
}

/// Papel de assessoria via catálogo LIVE `GET /v1/ai/agents`.
class AdvancedAiAgentRolePage extends StatefulWidget {
  const AdvancedAiAgentRolePage({
    super.key,
    required this.title,
    required this.hubSlug,
    required this.pendingPath,
  });

  final String title;
  final String hubSlug;
  final String pendingPath;

  @override
  State<AdvancedAiAgentRolePage> createState() =>
      _AdvancedAiAgentRolePageState();
}

class _AdvancedAiAgentRolePageState extends State<AdvancedAiAgentRolePage>
    with _AdvancedAiRefresh {
  Future<AdvancedAiItem?>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAdvancedAiRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<AdvancedAiItem?> _load() async {
    final agentSlug = advancedAiAgentSlugForHub(widget.hubSlug);
    if (agentSlug == null) {
      throw EndpointUnavailableException(widget.pendingPath, statusCode: 404);
    }
    final item = await context.read<AdvancedAiRepository>().agentRole(
      tenantSlug: _tenantOf(context),
      agentSlug: agentSlug,
    );
    if (item == null) {
      throw EndpointUnavailableException(widget.pendingPath, statusCode: 404);
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    final agentSlug = advancedAiAgentSlugForHub(widget.hubSlug);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<AdvancedAiItem?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.error is EndpointUnavailableException) {
            final err = snap.error! as EndpointUnavailableException;
            return EndpointPendingState(
              path: err.path,
              message:
                  '${widget.title} preparado. Aguardando contrato ativo '
                  'em /v1/ai.',
            );
          }
          if (snap.hasError) {
            return AppErrorState(
              error: snap.error,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final item = snap.data;
          if (item == null) {
            return EndpointPendingState(
              path: widget.pendingPath,
              message:
                  '${widget.title} preparado. Aguardando contrato ativo '
                  'em /v1/ai.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SoftNotice(
                message:
                    'Contrato ativo: GET /v1/ai/agents · conversa via '
                    'POST /v1/ai/chat',
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (item.summary != null) ...[
                        const SizedBox(height: 8),
                        Text(item.summary!),
                      ],
                      if (agentSlug != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Identificador: $agentSlug',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: agentSlug == null
                    ? null
                    : () => context.push(
                        '/home/advanced-ai/chat',
                        extra: {
                          'agentSlug': agentSlug,
                          'title': widget.title,
                        },
                      ),
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Abrir conversa com este agente'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdvancedAiPostFormPage extends StatefulWidget {
  const AdvancedAiPostFormPage({
    super.key,
    required this.title,
    required this.path,
    required this.hint,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String title;
  final String path;
  final String hint;
  final String submitLabel;
  final Future<Map<String, dynamic>> Function(String text) onSubmit;

  @override
  State<AdvancedAiPostFormPage> createState() => _AdvancedAiPostFormPageState();
}

class _AdvancedAiPostFormPageState extends State<AdvancedAiPostFormPage> {
  final _ctrl = TextEditingController();
  bool _sending = false;
  String? _error;
  Map<String, dynamic>? _result;
  EndpointUnavailableException? _pending;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _result = null;
      _pending = null;
    });
    try {
      final data = await widget.onSubmit(text);
      if (!mounted) return;
      setState(() => _result = data);
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      setState(() => _pending = e);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatResult(Map<String, dynamic> data) {
    final content = data['content'] ??
        data['summary'] ??
        data['text'] ??
        data['message'] ??
        data['body'];
    if (content != null) return content.toString();
    final suggestions = data['suggestions'] ?? data['items'];
    if (suggestions is List && suggestions.isNotEmpty) {
      return suggestions.map((s) => s.toString()).join('\n\n');
    }
    return data.entries
        .where((e) => e.value is! Map && e.value is! List)
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    if (_pending != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: EndpointPendingState(path: _pending!.path),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _ctrl,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(widget.submitLabel),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_formatResult(_result!)),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            widget.path,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class AdvancedAiFeedbackPage extends StatefulWidget {
  const AdvancedAiFeedbackPage({super.key});

  @override
  State<AdvancedAiFeedbackPage> createState() => _AdvancedAiFeedbackPageState();
}

class _AdvancedAiFeedbackPageState extends State<AdvancedAiFeedbackPage> {
  final _commentCtrl = TextEditingController();
  int _rating = 4;
  bool _sending = false;
  String? _error;
  String? _success;
  EndpointUnavailableException? _pending;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _success = null;
      _pending = null;
    });
    try {
      await context.read<AdvancedAiRepository>().postFeedback(
        body: {
          'rating': _rating,
          if (_commentCtrl.text.trim().isNotEmpty)
            'comment': _commentCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      setState(() => _success = 'Avaliação enviada com sucesso.');
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      setState(() => _pending = e);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
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
        appBar: AppBar(title: const Text('Avaliação')),
        body: EndpointPendingState(path: _pending!.path),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Avaliação')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Como foi a resposta da IA?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return IconButton(
                tooltip: '$star estrela${star > 1 ? 's' : ''}',
                onPressed: () => setState(() => _rating = star),
                icon: Icon(
                  star <= _rating ? Icons.star : Icons.star_border,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }),
          ),
          TextField(
            controller: _commentCtrl,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Comentário opcional…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: const Text('Enviar avaliação'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_success != null) ...[
            const SizedBox(height: 12),
            Text(
              _success!,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            AuthMode.staff.advancedAiFeedbackPath,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class AdvancedAiSearchPage extends StatefulWidget {
  const AdvancedAiSearchPage({super.key});

  @override
  State<AdvancedAiSearchPage> createState() => _AdvancedAiSearchPageState();
}

class _AdvancedAiSearchPageState extends State<AdvancedAiSearchPage>
    with _AdvancedAiRefresh {
  final _ctrl = TextEditingController();
  Future<List<AdvancedAiItem>>? _future;
  String _last = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAdvancedAiRefresh(() {
      if (_last.length >= 2) {
        setState(() => _future = _search(_last));
      }
    });
  }

  Future<List<AdvancedAiItem>> _search(String q) => context
      .read<AdvancedAiRepository>()
      .search(tenantSlug: _tenantOf(context), query: q);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Título, prompt, conteúdo…',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                final q = v.trim();
                if (q.length < 2) {
                  setState(() {
                    _future = null;
                    _last = '';
                  });
                  return;
                }
                setState(() {
                  _last = q;
                  _future = _search(q);
                });
              },
            ),
          ),
          Expanded(
            child: _future == null
                ? const AppEmptyState(
                    message: 'Digite ao menos 2 caracteres para pesquisar.',
                    icon: Icons.search_rounded,
                  )
                : FutureBuilder<List<AdvancedAiItem>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.error is EndpointUnavailableException) {
                        final err =
                            snap.error! as EndpointUnavailableException;
                        return EndpointPendingState(
                          path: err.path,
                          message:
                              'Pesquisa preparada. Aguardando /v1/ai/search.',
                        );
                      }
                      if (snap.hasError) {
                        return AppErrorState(
                          error: snap.error,
                          onRetry: () =>
                              setState(() => _future = _search(_last)),
                        );
                      }
                      final items = snap.data ?? const <AdvancedAiItem>[];
                      if (items.isEmpty) {
                        return const AppEmptyState(
                          message: 'Nenhum item encontrado.',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              title: Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                item.summary ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
