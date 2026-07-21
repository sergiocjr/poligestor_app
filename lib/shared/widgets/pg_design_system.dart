import 'package:flutter/material.dart';

import '../i18n/ui_labels.dart';

/// Design system PoliGestor — componentes padronizados RC.

/// Ícones: preferir sufixo `_rounded` nos pontos de uso.
IconData get pgIconRefresh => Icons.refresh_rounded;

/// Formata horas de atendimento sem exibir "0.0 h".
String pgFormatResolutionHours(double? hours) {
  if (hours == null || hours <= 0) return '—';
  if (hours < 1) return '${(hours * 60).round()} min';
  if (hours >= 48) {
    return '${(hours / 24).toStringAsFixed(1)} dias';
  }
  final decimals = hours >= 10 ? 0 : 1;
  return '${hours.toStringAsFixed(decimals)} h';
}

/// Chip de status/contrato — tamanho e tipografia únicos.
class PgStatusChip extends StatelessWidget {
  const PgStatusChip({
    super.key,
    required this.label,
    this.tone = PgStatusTone.neutral,
    this.compact = false,
  });

  factory PgStatusChip.contract({required bool available, bool compact = false}) {
    return PgStatusChip(
      label: uiContractChip(available: available),
      tone: available ? PgStatusTone.success : PgStatusTone.demo,
      compact: compact,
    );
  }

  factory PgStatusChip.status(String? raw, {bool compact = false}) {
    final label = uiStatusLabel(raw);
    final tone = switch ((raw ?? '').toLowerCase()) {
      'failed' || 'error' || 'erro' || 'overdue' || 'atrasado' => PgStatusTone.danger,
      'running' || 'in_progress' || 'em_andamento' || 'active' || 'ativo' =>
        PgStatusTone.info,
      'completed' || 'concluido' || 'concluído' || 'resolved' || 'resolvido' =>
        PgStatusTone.success,
      'pending' || 'aguardando' || 'paused' || 'pausado' => PgStatusTone.warning,
      _ => PgStatusTone.neutral,
    };
    return PgStatusChip(label: label, tone: tone, compact: compact);
  }

  factory PgStatusChip.severity(String? raw, {bool compact = false}) {
    return PgStatusChip(
      label: uiSeverityLabel(raw),
      tone: switch ((raw ?? '').toLowerCase()) {
        'critical' || 'critica' || 'crítica' || 'high' || 'alta' =>
          PgStatusTone.danger,
        'medium' || 'med' || 'média' || 'media' => PgStatusTone.warning,
        _ => PgStatusTone.neutral,
      },
      compact: compact,
    );
  }

  final String label;
  final PgStatusTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      PgStatusTone.success => (
          scheme.primaryContainer.withValues(alpha: 0.65),
          scheme.onPrimaryContainer,
        ),
      PgStatusTone.info => (
          scheme.secondaryContainer.withValues(alpha: 0.65),
          scheme.onSecondaryContainer,
        ),
      PgStatusTone.warning => (
          scheme.tertiaryContainer.withValues(alpha: 0.65),
          scheme.onTertiaryContainer,
        ),
      PgStatusTone.danger => (
          scheme.errorContainer.withValues(alpha: 0.65),
          scheme.onErrorContainer,
        ),
      PgStatusTone.demo => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
      PgStatusTone.neutral => (
          scheme.surfaceContainerHigh,
          scheme.onSurface,
        ),
    };

    return Semantics(
      label: label,
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 24 : 28),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

enum PgStatusTone { neutral, success, info, warning, danger, demo }

/// AppBar padrão RC — altura, refresh e tipografia consistentes.
class PgStandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PgStandardAppBar({
    super.key,
    required this.title,
    this.onRefresh,
    this.actions = const [],
    this.leading,
  });

  final String title;
  final VoidCallback? onRefresh;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final extra = <Widget>[
      if (onRefresh != null)
        IconButton(
          tooltip: 'Atualizar',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ...actions,
    ];
    return AppBar(
      leading: leading,
      title: Text(
        title,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.visible,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: extra,
      centerTitle: false,
    );
  }
}

/// Campo de busca padronizado.
class PgSearchField extends StatelessWidget {
  const PgSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Buscar…',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

/// Tile de hub de módulo — título completo, sem corte.
class PgHubModuleTile extends StatelessWidget {
  const PgHubModuleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.live,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool live;
  final VoidCallback onTap;

  static double gridExtent({required int crossAxisCount}) =>
      crossAxisCount <= 1 ? 136 : 124;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: live
                    ? scheme.primary.withValues(alpha: 0.12)
                    : scheme.surfaceContainerHighest,
                child: Icon(
                  icon,
                  color: live ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 3,
                      softWrap: true,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 3,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              PgStatusChip.contract(available: live, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet padronizado.
Future<T?> pgShowStandardBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  bool scrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: scrollControlled,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            16 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: child),
            ],
          ),
        ),
      );
    },
  );
}
