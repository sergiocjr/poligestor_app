import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'demo_banner.dart';
import 'demo_repository_support.dart';

/// Conteúdo rico de demonstração — substitui telas "em preparação".
class DemoExperiencePane extends StatelessWidget {
  const DemoExperiencePane({
    super.key,
    required this.path,
    this.title,
    @Deprecated('Ignorado — mantido só para migração de call sites')
    this.message,
  });

  final String path;
  final String? title;

  /// Ignorado (compatibilidade com call sites antigos de Pending).
  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = DemoRepositorySupport.listRoot(path)['data']! as List;
    final heading = title ?? _titleFromPath(path);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const DemoDataBanner(),
        const SizedBox(height: 14),
        Text(
          heading,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _KpiChip(label: 'Total', value: '24', scheme: scheme),
            _KpiChip(label: 'Ativos', value: '18', scheme: scheme),
            _KpiChip(label: 'Pendentes', value: '3', scheme: scheme),
            _KpiChip(label: 'Concluídos', value: '15', scheme: scheme),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Exemplos recentes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((raw) {
          final map = Map<String, dynamic>.from(raw as Map);
          final itemTitle = (map['title'] ?? map['name'] ?? 'Item').toString();
          final summary = (map['summary'] ?? map['description'] ?? '').toString();
          final when = DateTime.tryParse(
            (map['published_at'] ?? map['created_at'] ?? '').toString(),
          );
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.article_outlined, color: scheme.primary),
              ),
              title: Text(
                itemTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                [
                  if (summary.isNotEmpty) summary,
                  if (when != null) dateFmt.format(when.toLocal()),
                ].join('\n'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDemoDetail(context, map),
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _openDemoDetail(context, items.first as Map),
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Ver detalhe de exemplo'),
        ),
      ],
    );
  }

  String _titleFromPath(String path) {
    final slug = path.split('/').where((p) => p.isNotEmpty).lastOrNull ?? 'recurso';
    return switch (slug) {
      'dashboard' => 'Painel demonstrativo',
      'feed' => 'Feed demonstrativo',
      'mentions' => 'Menções demonstrativas',
      'alerts' => 'Alertas demonstrativos',
      'reports' => 'Relatórios demonstrativos',
      'search' => 'Busca demonstrativa',
      'filters' => 'Filtros demonstrativos',
      _ => 'Conteúdo demonstrativo',
    };
  }

  void _openDemoDetail(BuildContext context, Map raw) {
    final map = Map<String, dynamic>.from(raw);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DemoDataBanner(compact: true),
                const SizedBox(height: 12),
                Text(
                  (map['title'] ?? 'Detalhe').toString(),
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text((map['summary'] ?? '').toString()),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.check),
                  label: const Text('Entendi'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({
    required this.label,
    required this.value,
    required this.scheme,
  });

  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
