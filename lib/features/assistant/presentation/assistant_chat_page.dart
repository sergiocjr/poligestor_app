import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/assistant_repository.dart';
import '../domain/chat_message.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_composer.dart';
import 'widgets/typing_indicator.dart';

/// Tela de conversa do assistente — UI + POST /v1/portal/assistant/message.
class AssistantChatPage extends StatefulWidget {
  const AssistantChatPage({super.key, this.initialDraft});

  final String? initialDraft;

  @override
  State<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends State<AssistantChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  late final List<ChatMessage> _messages;
  bool _typing = false;
  bool _sentInitial = false;
  int _seq = 100;

  @override
  void initState() {
    super.initState();
    _messages = assistantWelcomeMessages();
    final draft = widget.initialDraft?.trim();
    if (draft != null && draft.isNotEmpty) {
      _ctrl.text = draft;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_sentInitial && mounted) {
          _sentInitial = true;
          _send();
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _typing) return;

    final userMsg = ChatMessage(
      id: 'u${_seq++}',
      sender: ChatSender.user,
      createdAt: DateTime.now(),
      text: text,
    );

    setState(() {
      _messages.add(userMsg);
      _ctrl.clear();
      _typing = true;
    });
    _scrollToEnd();

    final repo = context.read<AssistantRepository>();

    try {
      final result = await repo.sendMessage(text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'a${_seq++}',
            sender: ChatSender.assistant,
            createdAt: DateTime.now(),
            text: result.reply,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'e${_seq++}',
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

  String _friendlyAssistantError(Object error) {
    final mapped = UserMessages.fromError(error);
    if (mapped == UserMessages.offline) return mapped;
    return UserMessages.assistantFailed;
  }

  void _onPickAttachment(ChatAttachmentKind kind) {
    final label = switch (kind) {
      ChatAttachmentKind.image => 'Imagem (em breve)',
      ChatAttachmentKind.document => 'Documento (em breve)',
      ChatAttachmentKind.location => 'Localização (em breve)',
      ChatAttachmentKind.audio => 'Áudio (em breve)',
      ChatAttachmentKind.none => 'Anexo',
    };

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'att${_seq++}',
          sender: ChatSender.user,
          createdAt: DateTime.now(),
          text: 'Anexo preparado para envio futuro.',
          attachmentKind: kind,
          attachmentLabel: label,
        ),
      );
    });
    _scrollToEnd();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — interface pronta, envio ainda não ativo.')),
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, index) {
                if (_typing && index == _messages.length) {
                  return const FadeSlideIn(child: TypingIndicator());
                }
                final msg = _messages[index];
                return FadeSlideIn(
                  key: ValueKey(msg.id),
                  child: ChatBubble(message: msg),
                );
              },
            ),
          ),
          ChatComposer(
            controller: _ctrl,
            enabled: !_typing,
            onSend: _send,
            onPickAttachment: _onPickAttachment,
          ),
        ],
      ),
    );
  }
}
