import 'package:flutter/material.dart';

import '../../data/virtual_team_models.dart';

class VtKpiGrid extends StatelessWidget {
  const VtKpiGrid({super.key, required this.dashboard});

  final VtDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData)>[
      (
        'Agentes',
        '${dashboard.agentsActive}/${dashboard.agentsTotal}',
        Icons.groups_outlined,
      ),
      (
        'Eficiência',
        '${dashboard.efficiencyPct.toStringAsFixed(0)}%',
        Icons.speed_outlined,
      ),
      (
        'Tarefas abertas',
        '${dashboard.tasksOpen}',
        Icons.task_alt_outlined,
      ),
      (
        'Fila',
        '${dashboard.queueDepth}',
        Icons.queue_outlined,
      ),
      (
        'Execuções 24h',
        '${dashboard.executions24h}',
        Icons.play_circle_outline,
      ),
      (
        'Hand-offs 24h',
        '${dashboard.handoffs24h}',
        Icons.swap_horiz_outlined,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        for (final (label, value, icon) in items)
          Semantics(
            label: '$label: $value',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 20),
                    const Spacer(),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class VtNavTile extends StatelessWidget {
  const VtNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class VtStatusChip extends StatelessWidget {
  const VtStatusChip({super.key, required this.label, this.online});

  final String label;
  final bool? online;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg = scheme.surfaceContainerHighest;
    if (online == true) bg = scheme.primaryContainer;
    if (online == false) bg = scheme.errorContainer.withValues(alpha: 0.4);
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: bg,
    );
  }
}

class VtAgentCard extends StatelessWidget {
  const VtAgentCard({super.key, required this.agent, required this.onTap});

  final VtAgent agent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            agent.name.isEmpty ? '?' : agent.name[0].toUpperCase(),
          ),
        ),
        title: Text(agent.name),
        subtitle: Text(
          '${agent.specialty.isEmpty ? agent.slug : agent.specialty}'
          ' · ${agent.stateLabel}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VtStatusChip(
              label: agent.isOnline ? 'Online' : 'Offline',
              online: agent.isOnline,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class VtEndpointPendingState extends StatelessWidget {
  const VtEndpointPendingState({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return AppEndpointPending(
      path: path,
    );
  }
}

/// Estado honesto quando o backend ainda não expõe a rota.
class AppEndpointPending extends StatelessWidget {
  const AppEndpointPending({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'Endpoint ainda indisponível no backend',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              path,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
