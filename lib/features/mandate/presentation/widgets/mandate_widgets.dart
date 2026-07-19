import 'package:flutter/material.dart';

/// Card compacto de indicador (número + rótulo).
class MandateIndicatorCard extends StatelessWidget {
  const MandateIndicatorCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.icon,
    this.onTap,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final String? hint;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = Card(
      color: emphasis ? scheme.primaryContainer.withValues(alpha: 0.45) : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 4),
              Text(
                hint!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: child,
    );
  }
}

class MandatePeriodFilterBar extends StatelessWidget {
  const MandatePeriodFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const options = <(String, String)>[
    ('today', 'Hoje'),
    ('7d', '7 dias'),
    ('month', 'Mês'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          for (final (id, label) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: value == id,
                onSelected: (_) => onChanged(id),
              ),
            ),
        ],
      ),
    );
  }
}

class MandateRankingTile extends StatelessWidget {
  const MandateRankingTile({
    super.key,
    required this.rank,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final int rank;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            '$rank',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class MandateAttentionTile extends StatelessWidget {
  const MandateAttentionTile({
    super.key,
    required this.title,
    required this.explanation,
    this.onAction,
    this.actionLabel,
  });

  final String title;
  final String explanation;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(explanation),
            if (onAction != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel ?? 'Abrir'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MandateStaleBanner extends StatelessWidget {
  const MandateStaleBanner({super.key, required this.ageLabel});

  final String ageLabel;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text('Exibindo dados salvos ($ageLabel). Puxe para atualizar.'),
      leading: const Icon(Icons.cloud_off_outlined),
      actions: [
        TextButton(
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text('Ok'),
        ),
      ],
    );
  }
}

class MandateSectionSeeAll extends StatelessWidget {
  const MandateSectionSeeAll({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllLabel = 'Ver todos',
  });

  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text(seeAllLabel)),
        ],
      ),
    );
  }
}
