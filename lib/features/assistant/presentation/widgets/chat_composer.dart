import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/chat_message.dart';

typedef AttachmentPick = void Function(ChatAttachmentKind kind);

/// Campo de composição com ações futuras (imagem, documento, localização, áudio).
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.enabled,
    this.onPickAttachment,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final AttachmentPick? onPickAttachment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _AttachButton(
                    icon: Icons.add_circle_outline_rounded,
                    tooltip: 'Anexar',
                    onPressed: !enabled
                        ? null
                        : () => _showAttachSheet(context),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: enabled,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (enabled) onSend();
                      },
                      decoration: InputDecoration(
                        hintText: 'Escreva sua mensagem...',
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.55),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(
                            color: scheme.primary.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: enabled
                        ? () {
                            HapticFeedback.selectionClick();
                            onSend();
                          }
                        : null,
                    tooltip: 'Enviar',
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAttachSheet(BuildContext context) async {
    final kind = await showModalBottomSheet<ChatAttachmentKind>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Imagem'),
                  subtitle: const Text('Em breve'),
                  onTap: () =>
                      Navigator.pop(context, ChatAttachmentKind.image),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Documento'),
                  subtitle: const Text('Em breve'),
                  onTap: () =>
                      Navigator.pop(context, ChatAttachmentKind.document),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Localização'),
                  subtitle: const Text('Em breve'),
                  onTap: () =>
                      Navigator.pop(context, ChatAttachmentKind.location),
                ),
                ListTile(
                  leading: const Icon(Icons.mic_none_rounded),
                  title: const Text('Áudio'),
                  subtitle: const Text('Em breve'),
                  onTap: () =>
                      Navigator.pop(context, ChatAttachmentKind.audio),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (kind != null) onPickAttachment?.call(kind);
  }
}

class _AttachButton extends StatelessWidget {
  const _AttachButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
    );
  }
}
