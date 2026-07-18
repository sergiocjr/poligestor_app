import 'package:flutter/material.dart';

import '../../core/ux/user_messages.dart';
import 'app_states.dart';

/// Compatibilidade com telas legadas — usa estados amigáveis.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final friendly = UserMessages.fromError(message);
    return AppErrorState(message: friendly, onRetry: onRetry);
  }
}
