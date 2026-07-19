import 'package:flutter/material.dart';

import '../../../../core/config.dart';

/// Atalhos opcionais quando o assistente pede confirmação.
class ConfirmationShortcuts extends StatelessWidget {
  const ConfirmationShortcuts({
    super.key,
    required this.onConfirm,
    required this.onCorrect,
    this.enabled = true,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCorrect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              key: const Key('shortcut-confirm'),
              avatar: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Confirmar'),
              onPressed: enabled ? onConfirm : null,
              backgroundColor: const Color(
                AppConfig.primaryTeal,
              ).withValues(alpha: 0.12),
            ),
            ActionChip(
              key: const Key('shortcut-correct'),
              avatar: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Corrigir informações'),
              onPressed: enabled ? onCorrect : null,
            ),
          ],
        ),
      ),
    );
  }
}
