import 'package:flutter/material.dart';

import '../../../../core/config.dart';
import '../../domain/chat_message.dart';


class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    final bg = isUser ? const Color(AppConfig.primaryTeal) : Colors.white;
    final fg = isUser ? Colors.white : scheme.onSurface;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isUser ? 20 : 6),
      bottomRight: Radius.circular(isUser ? 6 : 20),
    );

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: isUser
                ? null
                : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isUser ? 0.08 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.hasAttachment) ...[
                _AttachmentChip(
                  kind: message.attachmentKind,
                  label: message.attachmentLabel ?? 'Anexo',
                  onUser: isUser,
                ),
                if (message.text != null && message.text!.isNotEmpty)
                  const SizedBox(height: 8),
              ],
              if (message.text != null && message.text!.isNotEmpty)
                Text(
                  message.text!,
                  style: TextStyle(
                    color: fg,
                    height: 1.4,
                    fontSize: 15,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  color: fg.withValues(alpha: 0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.kind,
    required this.label,
    required this.onUser,
  });

  final ChatAttachmentKind kind;
  final String label;
  final bool onUser;

  IconData get _icon => switch (kind) {
        ChatAttachmentKind.image => Icons.image_outlined,
        ChatAttachmentKind.document => Icons.description_outlined,
        ChatAttachmentKind.location => Icons.location_on_outlined,
        ChatAttachmentKind.audio => Icons.mic_none_rounded,
        ChatAttachmentKind.none => Icons.attach_file,
      };

  @override
  Widget build(BuildContext context) {
    final fg = onUser ? Colors.white : Theme.of(context).colorScheme.primary;
    final bg = onUser
        ? Colors.white.withValues(alpha: 0.16)
        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
