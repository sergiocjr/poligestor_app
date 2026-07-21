import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/assistant_chat_controller.dart';
import '../data/assistant_repository.dart';
import '../domain/chat_message.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_composer.dart';
import 'widgets/confirmation_shortcuts.dart';
import 'widgets/protocol_created_card.dart';
import 'widgets/typing_indicator.dart';

/// Tela de conversa do assistente — retoma histórico e envia mensagens.
class AssistantChatPage extends StatefulWidget {
  const AssistantChatPage({
    super.key,
    this.initialDraft,
    this.onTrackProtocol,
    this.controller,
  });

  final String? initialDraft;

  /// Hook de teste / override de navegação.
  final ProtocolTrackCallback? onTrackProtocol;

  /// Controller injetável para testes.
  final AssistantChatController? controller;

  @override
  State<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends State<AssistantChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  AssistantChatController? _chat;
  bool _typing = false;
  bool _clearing = false;
  bool _sentInitial = false;
  bool _bootstrapped = false;
  int _seq = 100;

  AssistantChatController get chat => _chat!;

  String _nextId([String prefix = 'm']) => '$prefix${_seq++}';

  @override
  void initState() {
    super.initState();
    _chat = widget.controller;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chat ??= AssistantChatController(
      repository: context.read<AssistantRepository>(),
    );
    if (!_bootstrapped) {
      _bootstrapped = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loadConversation();
    if (!mounted) return;

    final draft = widget.initialDraft?.trim();
    if (draft != null && draft.isNotEmpty && !_sentInitial) {
      _sentInitial = true;
      _ctrl.text = draft;
      await _send();
    }
  }

  Future<void> _loadConversation() async {
    setState(() {
      chat.loading = true;
      chat.loadError = null;
    });

    try {
      await chat.loadConversation();
      if (!mounted) return;
      setState(() {});
      _scrollToEnd(animated: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        chat.loading = false;
        chat.loadError = _friendlyLoadError(e);
      });
    }
  }

  String _friendlyLoadError(Object error) {
    final mapped = UserMessages.fromError(error);
    if (mapped == UserMessages.offline) return mapped;
    return UserMessages.conversationLoadFailed;
  }

  Future<void> _confirmNewConversation() async {
    if (_typing || _clearing || chat.loading) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova conversa'),
          content: const Text(
            'Isso apaga o histórico atual desta conversa. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    await _startNewConversation();
  }

  Future<void> _startNewConversation() async {
    setState(() => _clearing = true);
    final repo = context.read<AssistantRepository>();

    try {
      await repo.clearConversation();
      if (!mounted) return;
      setState(() {
        chat.clearLocalForNewConversation();
        _clearing = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _clearing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            UserMessages.fromError(e) == UserMessages.offline
                ? UserMessages.offline
                : 'Não foi possível iniciar uma nova conversa. Tente novamente.',
          ),
        ),
      );
    }
  }

  Future<void> _sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _typing || chat.loading || _clearing) {
      return;
    }

    final userMsg = ChatMessage(
      id: _nextId('u'),
      sender: ChatSender.user,
      createdAt: DateTime.now(),
      text: trimmed,
    );

    setState(() {
      chat.messages.add(userMsg);
      _ctrl.clear();
      _typing = true;
    });
    _scrollToEnd();

    final repo = context.read<AssistantRepository>();

    try {
      final result = await repo.sendMessage(trimmed);
      if (!mounted) return;
      setState(() {
        if (result.conversationId != null) {
          chat.conversationId = result.conversationId;
        }
        chat.finished = result.finished;
        chat.messages.addAll(
          chat.presenter.present(result, nextId: () => _nextId('a')),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        chat.messages.add(
          ChatMessage(
            id: _nextId('e'),
            sender: ChatSender.assistant,
            createdAt: DateTime.now(),
            text: _friendlyAssistantError(e),
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _typing = false);
        _scrollToEnd();
      }
    }
  }

  Future<void> _send() => _sendText(_ctrl.text);

  String _friendlyAssistantError(Object error) {
    final mapped = UserMessages.fromError(error);
    if (mapped == UserMessages.offline) return mapped;
    return UserMessages.assistantFailed;
  }

  void _trackProtocol(ChatProtocolInfo protocol) {
    if (widget.onTrackProtocol != null) {
      widget.onTrackProtocol!(protocol);
      return;
    }
    final id = protocol.id.trim();
    if (id.isNotEmpty) {
      context.push('/citizen/requests/$id');
    } else {
      context.go('/citizen/requests');
    }
  }

  void _onPickAttachment(ChatAttachmentKind kind) {
    final label = switch (kind) {
      ChatAttachmentKind.image => 'Imagem (demonstração)',
      ChatAttachmentKind.document => 'Documento (demonstração)',
      ChatAttachmentKind.location => 'Localização (demonstração)',
      ChatAttachmentKind.audio => 'Áudio (demonstração)',
      ChatAttachmentKind.none => 'Anexo',
    };

    setState(() {
      chat.messages.add(
        ChatMessage(
          id: _nextId('att'),
          sender: ChatSender.user,
          createdAt: DateTime.now(),
          text: 'Anexo de demonstração ($label).',
          attachmentKind: kind,
          attachmentLabel: label,
        ),
      );
    });
    _scrollToEnd();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — anexo ilustrativo na conversa.'),
      ),
    );
  }

  void _scrollToEnd({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final extent = _scroll.position.maxScrollExtent;
      if (!animated) {
        _scroll.jumpTo(extent);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scroll.hasClients) return;
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        });
        return;
      }
      _scroll.animateTo(
        extent + 120,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.isProtocolCard && msg.protocol != null) {
      return FadeSlideIn(
        key: ValueKey(msg.id),
        child: ProtocolCreatedCard(
          protocol: msg.protocol!,
          onTrack: _trackProtocol,
        ),
      );
    }

    return FadeSlideIn(
      key: ValueKey(msg.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (msg.text != null && msg.text!.isNotEmpty)
            ChatBubble(message: msg),
          if (msg.showConfirmShortcuts)
            ConfirmationShortcuts(
              enabled: !_typing && !chat.loading && !_clearing,
              onConfirm: () => _sendText('Confirmar'),
              onCorrect: () => _sendText('Corrigir informações'),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_chat == null || (chat.loading && chat.messages.isEmpty)) {
      return const _ConversationSkeleton();
    }

    if (chat.loadError != null && chat.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chat.loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadConversation,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          itemCount: chat.messages.length + (_typing ? 1 : 0),
          itemBuilder: (context, index) {
            if (_typing && index == chat.messages.length) {
              return const FadeSlideIn(child: TypingIndicator());
            }
            return _buildMessageItem(chat.messages[index]);
          },
        ),
        if (chat.loadError != null && chat.messages.isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            top: 8,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat.loadError!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadConversation,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_clearing)
          const ColoredBox(
            color: Color(0x66FFFFFF),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _chat == null || chat.loading || _clearing;
    final composerEnabled =
        !busy &&
        !_typing &&
        (chat.loadError == null || chat.messages.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(AppConfig.seedNavy),
                    Color(AppConfig.primaryTeal),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assistente',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  Text(
                    'Pronto para ajudar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<_AssistantMenuAction>(
            tooltip: 'Mais opções',
            enabled: !busy && !_typing,
            onSelected: (action) {
              if (action == _AssistantMenuAction.newConversation) {
                _confirmNewConversation();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _AssistantMenuAction.newConversation,
                child: Text('Nova conversa'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          ChatComposer(
            controller: _ctrl,
            enabled: composerEnabled,
            onSend: _send,
            onPickAttachment: _onPickAttachment,
          ),
        ],
      ),
    );
  }
}

enum _AssistantMenuAction { newConversation }

class _ConversationSkeleton extends StatelessWidget {
  const _ConversationSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      children: const [
        _SkeletonBubble(widthFactor: 0.72, alignEnd: false),
        SizedBox(height: 12),
        _SkeletonBubble(widthFactor: 0.55, alignEnd: true),
        SizedBox(height: 12),
        _SkeletonBubble(widthFactor: 0.8, alignEnd: false),
        SizedBox(height: 12),
        _SkeletonBubble(widthFactor: 0.48, alignEnd: true),
      ],
    );
  }
}

class _SkeletonBubble extends StatelessWidget {
  const _SkeletonBubble({required this.widthFactor, required this.alignEnd});

  final double widthFactor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EEF0),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
