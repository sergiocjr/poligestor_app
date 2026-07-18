import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/config.dart';
import '../../domain/chat_message.dart';

typedef ProtocolTrackCallback = void Function(ChatProtocolInfo protocol);

/// Card de sucesso quando o assistente cria um protocolo de verdade.
class ProtocolCreatedCard extends StatelessWidget {
  const ProtocolCreatedCard({
    super.key,
    required this.protocol,
    this.onTrack,
    this.onCopied,
    this.copyText,
  });

  final ChatProtocolInfo protocol;
  final ProtocolTrackCallback? onTrack;
  final VoidCallback? onCopied;
  final Future<void> Function(String text)? copyText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final number = protocol.number.trim().isNotEmpty
        ? protocol.number.trim()
        : protocol.id;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.88,
        ),
        child: Container(
          key: const Key('protocol-created-card'),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(AppConfig.primaryTeal).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(AppConfig.primaryTeal)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(AppConfig.primaryTeal),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Solicitação registrada',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Número do protocolo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      number,
                      key: const Key('protocol-number'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: Color(AppConfig.seedNavy),
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('copy-protocol'),
                    tooltip: 'Copiar protocolo',
                    onPressed: () async {
                      final copier = copyText ??
                          (value) => Clipboard.setData(ClipboardData(text: value));
                      await copier(number);
                      onCopied?.call();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Número do protocolo copiado.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
              if (protocol.status != null && protocol.status!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Status: ${protocol.status}',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('track-request'),
                  onPressed: onTrack == null ? null : () => onTrack!(protocol),
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Acompanhar solicitação'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
