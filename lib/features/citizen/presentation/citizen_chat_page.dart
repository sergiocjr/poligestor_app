import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';

class CitizenChatPage extends StatefulWidget {
  const CitizenChatPage({super.key, this.initialDraft});

  final String? initialDraft;

  @override
  State<CitizenChatPage> createState() => _CitizenChatPageState();
}

class _CitizenChatPageState extends State<CitizenChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_ChatMsg>[
    _ChatMsg(
      fromBot: true,
      text:
          'Olá! Sou o assistente do PoliGestor. Como posso ajudar você hoje?',
    ),
  ];
  bool _busy = false;
  bool _sentInitial = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft?.trim();
    if (draft != null && draft.isNotEmpty) {
      _ctrl.text = draft;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_sentInitial && mounted) {
          _sentInitial = true;
          _send();
        }
      });
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
    if (text.isEmpty || _busy) return;
    setState(() {
      _messages.add(_ChatMsg(fromBot: false, text: text));
      _ctrl.clear();
      _busy = true;
    });
    _scrollToEnd();

    final auth = context.read<AuthController>();
    final api = context.read<ApiClient>();

    try {
      final envelope = await api.postEnvelope<Map<String, dynamic>>(
        auth.mode.aiChatPath,
        data: {'message': text},
        mode: auth.mode,
        parse: (raw) {
          if (raw is Map<String, dynamic>) return raw;
          if (raw is Map) return Map<String, dynamic>.from(raw);
          return {'reply': raw?.toString() ?? ''};
        },
      );
      final reply = (envelope.data['reply'] ??
              envelope.data['message'] ??
              envelope.data['content'] ??
              envelope.data['answer'] ??
              'Recebi sua mensagem. Em breve retorno com mais detalhes.')
          .toString();
      setState(() => _messages.add(_ChatMsg(fromBot: true, text: reply)));
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMsg(fromBot: true, text: UserMessages.fromError(e)),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollToEnd();
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Assistente')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_busy ? 1 : 0),
              itemBuilder: (context, index) {
                if (_busy && index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SoftNotice(
                        message: 'Digitando...',
                        icon: Icons.more_horiz,
                      ),
                    ),
                  );
                }
                final m = _messages[index];
                final align =
                    m.fromBot ? Alignment.centerLeft : Alignment.centerRight;
                final bg = m.fromBot ? Colors.white : scheme.primary;
                final fg = m.fromBot ? scheme.onSurface : scheme.onPrimary;
                return FadeSlideIn(
                  child: Align(
                    alignment: align,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(18),
                        border: m.fromBot
                            ? Border.all(color: scheme.outlineVariant)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(color: fg, height: 1.35),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Escreva sua mensagem...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
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

class _ChatMsg {
  _ChatMsg({required this.fromBot, required this.text});
  final bool fromBot;
  final String text;
}
