import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';

class CitizenChatPage extends StatefulWidget {
  const CitizenChatPage({super.key});

  @override
  State<CitizenChatPage> createState() => _CitizenChatPageState();
}

class _CitizenChatPageState extends State<CitizenChatPage> {
  final _ctrl = TextEditingController();
  final _messages = <_ChatMsg>[
    _ChatMsg(
      fromBot: true,
      text:
          'Olá! Sou o assistente do PoliGestor. Como posso ajudar com sua solicitação?',
    ),
  ];
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
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
              'Recebi sua mensagem.')
          .toString();
      setState(() => _messages.add(_ChatMsg(fromBot: true, text: reply)));
    } on ApiException catch (e) {
      setState(() {
        _messages.add(_ChatMsg(
          fromBot: true,
          text: auth.mode == AuthMode.portal && e.isUnauthorized
              ? 'Não consegui responder agora: a API do portal rejeitou o token (401). '
                  'Assim que o backend corrigir a autenticação do cidadão, o chat funciona aqui.'
              : 'Erro: ${e.message}',
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMsg(fromBot: true, text: 'Erro: $e'));
      });
    } finally {
      setState(() => _busy = false);
    }
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
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final align =
                    m.fromBot ? Alignment.centerLeft : Alignment.centerRight;
                final bg = m.fromBot
                    ? scheme.surfaceContainerHighest
                    : scheme.primary;
                final fg = m.fromBot ? scheme.onSurface : scheme.onPrimary;
                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(m.text, style: TextStyle(color: fg)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Escreva sua mensagem...',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: _busy
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

class _ChatMsg {
  _ChatMsg({required this.fromBot, required this.text});
  final bool fromBot;
  final String text;
}
