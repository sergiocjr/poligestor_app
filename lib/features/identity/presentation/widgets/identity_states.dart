import 'package:flutter/material.dart';

import '../../../../shared/demo/demo_experience_pane.dart';

/// Fallback de experiência — exibe demonstração realista (nunca "em preparação").
@Deprecated('Use DemoExperiencePane ou dados via DemoRepositorySupport')
class EndpointPendingState extends StatelessWidget {
  const EndpointPendingState({
    super.key,
    required this.path,
    this.message = 'Recurso ainda indisponível no backend',
  });

  final String path;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DemoExperiencePane(path: path);
  }
}
