import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.onTitleTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        );
    final titleWidget = onTitleTap == null
        ? Text(title, style: titleStyle)
        : Semantics(
            button: true,
            label: title,
            child: InkWell(
              onTap: onTitleTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(title, style: titleStyle)),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget,
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.enabled
          ? () {
              HapticFeedback.selectionClick();
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Métricas do grid de ações rápidas (aspect ratio / altura derivados da largura).
class FeatureActionGridMetrics {
  FeatureActionGridMetrics._();

  static const double spacing = 12;

  /// Largura mínima de conteúdo para a palavra mais longa dos títulos
  /// (`atendimento` ≈ 153px em titleSmall w800) sem quebrar no meio.
  static const double minTitleContentWidth = 156;

  static int crossAxisCountFor(
    double maxWidth, {
    double textScale = 1.0,
  }) {
    if (maxWidth >= 900) return 4;
    if (maxWidth >= 680) return 3;

    final minContent = minTitleContentWidth * textScale;
    final minCell =
        minContent + FeatureActionCard.horizontalPadding * 2;
    // 2 colunas só quando cada célula comporta títulos longos sem corte.
    if (maxWidth >= minCell * 2 + spacing) return 2;
    return 1;
  }

  static double cellWidthFor(double maxWidth, int crossAxisCount) {
    return (maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
  }

  static double _textScaleOf(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1);
  }

  /// Altura mínima do grid cobrindo o maior card (cresce com texto/acessibilidade).
  static double mainAxisExtentFor({
    required BuildContext context,
    required double maxWidth,
    required Iterable<({String title, String description})> items,
  }) {
    final cross = crossAxisCountFor(
      maxWidth,
      textScale: _textScaleOf(context),
    );
    final cellWidth = cellWidthFor(maxWidth, cross);
    var maxHeight = FeatureActionCard.minHeightForEmpty(context);
    for (final item in items) {
      final h = FeatureActionCard.estimateHeight(
        context,
        width: cellWidth,
        title: item.title,
        description: item.description,
      );
      if (h > maxHeight) maxHeight = h;
    }
    // Respiro Material 3 entre conteúdo e borda inferior da célula.
    return maxHeight + 4;
  }

  static double childAspectRatioFor({
    required BuildContext context,
    required double maxWidth,
    required Iterable<({String title, String description})> items,
  }) {
    final cross = crossAxisCountFor(
      maxWidth,
      textScale: _textScaleOf(context),
    );
    final cellWidth = cellWidthFor(maxWidth, cross);
    final height = mainAxisExtentFor(
      context: context,
      maxWidth: maxWidth,
      items: items,
    );
    return cellWidth / height;
  }
}

class FeatureActionCard extends StatelessWidget {
  const FeatureActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.color,
  });

  static const double horizontalPadding = 12;
  static const double topPadding = 12;
  static const double bottomPadding = 12;
  static const double iconBox = 32;
  static const double iconGlyph = 18;
  static const double gapAfterIcon = 8;
  static const double gapTitleDesc = 4;
  static const int titleMaxLines = 3;
  static const int descriptionMaxLines = 2;

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color? color;

  static TextStyle? titleStyleOf(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.25,
        );
  }

  static TextStyle? descriptionStyleOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.35,
        );
  }

  /// Altura reservada para N linhas (alinha todos os cards no mesmo eixo).
  static double lineSlotHeight(
    BuildContext context,
    TextStyle? style,
    int maxLines,
  ) {
    final scaler = MediaQuery.textScalerOf(context);
    final fontSize = style?.fontSize ?? 14;
    final height = style?.height ?? 1.2;
    return scaler.scale(fontSize) * height * maxLines;
  }

  static double minHeightForEmpty(BuildContext context) {
    return topPadding +
        iconBox +
        gapAfterIcon +
        lineSlotHeight(context, titleStyleOf(context), titleMaxLines) +
        gapTitleDesc +
        lineSlotHeight(
          context,
          descriptionStyleOf(context),
          descriptionMaxLines,
        ) +
        bottomPadding;
  }

  /// Altura do card = slots fixos (não depende do texto de cada item).
  static double estimateHeight(
    BuildContext context, {
    required double width,
    required String title,
    required String description,
  }) {
    // width/title/description mantidos na assinatura para compatibilidade
    // com o grid; o alinhamento usa slots fixos.
    return minHeightForEmpty(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    final titleH =
        lineSlotHeight(context, titleStyleOf(context), titleMaxLines);
    final descH = lineSlotHeight(
      context,
      descriptionStyleOf(context),
      descriptionMaxLines,
    );

    return PressableScale(
      onTap: onTap,
      child: Material(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: iconBox,
                  height: iconBox,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: iconGlyph),
                ),
                const SizedBox(height: gapAfterIcon),
                SizedBox(
                  width: double.infinity,
                  height: titleH,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title,
                      maxLines: titleMaxLines,
                      softWrap: true,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyleOf(context),
                    ),
                  ),
                ),
                const SizedBox(height: gapTitleDesc),
                SizedBox(
                  width: double.infinity,
                  height: descH,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      description,
                      maxLines: descriptionMaxLines,
                      softWrap: true,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: descriptionStyleOf(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AssistantHero extends StatefulWidget {
  const AssistantHero({
    super.key,
    required this.greeting,
    required this.onSubmit,
    this.onOpenChat,
    this.prompt = 'Como podemos ajudar você hoje?',
  });

  final String greeting;
  final String prompt;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onOpenChat;

  @override
  State<AssistantHero> createState() => _AssistantHeroState();
}

class _AssistantHeroState extends State<AssistantHero> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(AppConfig.seedNavy),
            Color(0xFF123A5C),
            Color(AppConfig.primaryTeal),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(AppConfig.seedNavy).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.greeting,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.prompt,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 18),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.smart_toy_outlined, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        hintText: 'Pergunte ao assistente...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: _submit,
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_upward_rounded),
                    tooltip: 'Enviar para o assistente',
                  ),
                ],
              ),
            ),
          ),
          if (widget.onOpenChat != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: widget.onOpenChat,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Abrir conversa completa'),
            ),
          ],
        ],
      ),
    );
  }
}

class NeighborhoodCard extends StatelessWidget {
  const NeighborhoodCard({
    super.key,
    required this.neighborhoodLabel,
    this.onTap,
  });

  final String neighborhoodLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Meu Bairro: $neighborhoodLabel',
      child: PressableScale(
      onTap: onTap ?? () {},
      enabled: onTap != null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              const Color(AppConfig.seedNavy),
              const Color(AppConfig.primaryTeal).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.location_city_rounded,
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Meu Bairro',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.8)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              neighborhoodLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Avisos, serviços e oportunidades da sua região em breve.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.publishedAt,
    this.content = '',
  });

  final String id;
  final String title;
  final String summary;
  final String category;
  final DateTime publishedAt;
  final String content;
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.item, this.onTap});

  final NewsItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: onTap != null,
      label: 'Notícia: ${item.title}',
      child: PressableScale(
        onTap: onTap ?? () {},
        enabled: onTap != null,
        child: Container(
          width: 260,
          height: 180,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  item.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgendaMiniCard extends StatelessWidget {
  const AgendaMiniCard({
    super.key,
    required this.title,
    this.when,
    this.location,
    this.onTap,
  });

  final String title;
  final String? when;
  final String? location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: onTap != null,
      label: 'Compromisso: $title',
      child: PressableScale(
        onTap: onTap ?? () {},
        enabled: onTap != null,
        child: Container(
          width: 220,
          height: 150,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
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
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event_available,
                      color: scheme.primary,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              if (when != null)
                Text(
                  when!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              if (location != null) ...[
                const SizedBox(height: 2),
                Text(
                  location!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RequestTimelineTile extends StatelessWidget {
  const RequestTimelineTile({
    super.key,
    required this.title,
    required this.statusLabel,
    this.number,
    this.isLast = false,
    this.onTap,
  });

  final String title;
  final String statusLabel;
  final String? number;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 56,
                    color: scheme.primary.withValues(alpha: 0.2),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (number != null) '#$number',
                      statusLabel,
                    ].join(' · '),
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class ChatFab extends StatelessWidget {
  const ChatFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      child: Material(
        elevation: 6,
        shadowColor: const Color(AppConfig.primaryTeal).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        color: const Color(AppConfig.primaryTeal),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.forum_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Assistente',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
