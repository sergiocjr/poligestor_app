import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_states.dart';
import '../../data/intelligence_models.dart';

class IntelPeriodFilterBar extends StatelessWidget {
  const IntelPeriodFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.onCustomRange,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCustomRange;

  static const options = <(String, String)>[
    ('today', 'Hoje'),
    ('7d', '7 dias'),
    ('30d', '30 dias'),
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
          if (onCustomRange != null)
            FilterChip(
              label: const Text('Período'),
              selected: value == 'custom',
              onSelected: (_) => onCustomRange!(),
            ),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight, this.onAction});

  final IntelligenceInsight insight;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final attention = insight.priority == 'attention';
    return Semantics(
      label:
          '${insight.categoryLabel}. ${insight.title}. ${insight.body}. '
          'Sugestão: ${insight.recommendedAction}',
      child: Card(
        color: attention ? scheme.errorContainer.withValues(alpha: 0.28) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(insight.categoryLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    insight.priority == 'attention'
                        ? 'Prioritário'
                        : 'Informativo',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                insight.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(insight.body),
              const SizedBox(height: 8),
              Text(
                'Sugestão: ${insight.recommendedAction}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (onAction != null) ...[
                const SizedBox(height: 4),
                TextButton(onPressed: onAction, child: const Text('Abrir')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TrendSeriesCard extends StatelessWidget {
  const TrendSeriesCard({super.key, required this.title, required this.points});

  final String title;
  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Card(
        child: ListTile(
          title: Text(title),
          subtitle: const Text('Sem série no período.'),
        ),
      );
    }
    final recent = points.length > 8
        ? points.sublist(points.length - 8)
        : points;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final p in recent.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text('${p.created} novas'),
                    const SizedBox(width: 12),
                    Text('${p.resolved} resolvidas'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class IntelStaleNotice extends StatelessWidget {
  const IntelStaleNotice({super.key, required this.ageLabel});

  final String ageLabel;

  @override
  Widget build(BuildContext context) {
    return SoftNotice(
      message: 'Dados salvos ($ageLabel). Puxe para atualizar.',
      icon: Icons.cloud_off_outlined,
    );
  }
}

class IntelSectionTitle extends StatelessWidget {
  const IntelSectionTitle({
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
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text(seeAllLabel)),
        ],
      ),
    );
  }
}
