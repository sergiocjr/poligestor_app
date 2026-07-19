import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/ux/user_messages.dart';
import '../../../protocols/data/protocol_models.dart';

IconData historyIcon(IconDataForHistory kind) => switch (kind) {
  IconDataForHistory.inbox => Icons.inbox_rounded,
  IconDataForHistory.search => Icons.search_rounded,
  IconDataForHistory.forward => Icons.forward_to_inbox_rounded,
  IconDataForHistory.progress => Icons.autorenew_rounded,
  IconDataForHistory.help => Icons.help_outline_rounded,
  IconDataForHistory.reply => Icons.mark_chat_read_rounded,
  IconDataForHistory.done => Icons.check_circle_rounded,
  IconDataForHistory.dot => Icons.circle,
};

class ProtocolAwaitingBanner extends StatelessWidget {
  const ProtocolAwaitingBanner({super.key, required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: 'O gabinete precisa de mais informações',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.tertiary.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_rounded, color: scheme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'O gabinete precisa de mais informações.',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class ProtocolHistorySection extends StatelessWidget {
  const ProtocolHistorySection({super.key, required this.events});

  final List<ProtocolHistoryEvent> events;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    final timeFmt = DateFormat('HH:mm');
    if (events.isEmpty) {
      return const Text(UserMessages.emptyHistory);
    }

    // Agrupa por dia (estilo timeline Jira).
    final groups = <DateTime, List<ProtocolHistoryEvent>>{};
    for (final e in events) {
      final at =
          e.createdAt?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
      final day = DateTime(at.year, at.month, at.day);
      (groups[day] ??= <ProtocolHistoryEvent>[]).add(e);
    }
    final days = groups.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final day in days) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Row(
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.calendar_today_outlined, size: 14),
                  label: Text(
                    _dayLabel(day, dateFmt),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < groups[day]!.length; i++)
            _HistoryTile(
              event: groups[day]![i],
              isLast: day == days.last && i == groups[day]!.length - 1,
              dateFmt: dateFmt,
              timeFmt: timeFmt,
              showDate: false,
            ),
        ],
      ],
    );
  }

  String _dayLabel(DateTime day, DateFormat dateFmt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'Hoje';
    if (day == yesterday) return 'Ontem';
    return dateFmt.format(day);
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.event,
    required this.isLast,
    required this.dateFmt,
    required this.timeFmt,
    this.showDate = true,
  });

  final ProtocolHistoryEvent event;
  final bool isLast;
  final DateFormat dateFmt;
  final DateFormat timeFmt;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = historyIcon(ProtocolHistoryLabels.iconFor(event.kind));
    final when = event.createdAt?.toLocal();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 28,
                      margin: const EdgeInsets.only(top: 4),
                      color: scheme.outlineVariant,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (event.description != null &&
                      event.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.description!,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                  if (when != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      showDate
                          ? '${dateFmt.format(when)} · ${timeFmt.format(when)}'
                          : timeFmt.format(when),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProtocolConversationPanel extends StatelessWidget {
  const ProtocolConversationPanel({
    super.key,
    required this.messages,
    this.composer,
    this.errorMessage,
    this.onRetry,
    this.loading = false,
  });

  final List<ProtocolMessage> messages;
  final Widget? composer;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM · HH:mm');
    final scheme = Theme.of(context).colorScheme;

    // Sem ListView/ScrollView próprio — o scroll é o da tela de detalhes.
    return Column(
      key: const Key('protocol_conversation_column'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (errorMessage != null) ...[
          Text(errorMessage!, style: TextStyle(color: scheme.error)),
          if (onRetry != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('conversation_retry'),
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
            ),
        ] else if (messages.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(UserMessages.emptyConversation),
          )
        else
          ...messages.map((m) => _MessageBubble(message: m, dateFmt: dateFmt)),
        if (composer != null) ...[const SizedBox(height: 8), composer!],
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.dateFmt});

  final ProtocolMessage message;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mine = !message.isFromCabinet;
    final bg = mine
        ? scheme.primaryContainer.withValues(alpha: 0.65)
        : scheme.surfaceContainerHighest;
    final align = mine ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(mine ? 16 : 4),
      bottomRight: Radius.circular(mine ? 4 : 16),
    );

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: message.isUnread && message.isFromCabinet
                ? Border.all(color: scheme.primary, width: 1.5)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.isFromCabinet
                          ? (message.authorName ?? 'Gabinete')
                          : (message.authorName ?? 'Você'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (message.isUnread && message.isFromCabinet)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Nova',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              if (message.body.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(message.body, softWrap: true),
              ],
              if (message.attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...message.attachments.map(
                  (a) => ProtocolAttachmentTile(attachment: a, compact: true),
                ),
              ],
              if (message.createdAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  dateFmt.format(message.createdAt!.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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

class ProtocolAttachmentTile extends StatelessWidget {
  const ProtocolAttachmentTile({
    super.key,
    required this.attachment,
    this.compact = false,
    this.progress,
    this.failed = false,
    this.onRetry,
    this.onCancel,
    this.onRemove,
  });

  final ProtocolAttachment attachment;
  final bool compact;
  final double? progress;
  final bool failed;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final VoidCallback? onRemove;

  Future<void> _open(BuildContext context) async {
    final url = attachment.url;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UserMessages.openAttachmentFailed)),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UserMessages.openAttachmentFailed)),
      );
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UserMessages.openAttachmentFailed)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UserMessages.openAttachmentFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = attachment.name ?? 'Arquivo';
    // Layout simples (sem ListTile+Row de IconButtons) para evitar overflow
    // e disputa de gestos no A10 ao entrar na região de anexos.
    return Card(
      margin: EdgeInsets.only(bottom: compact ? 6 : 8),
      child: InkWell(
        onTap: attachment.url != null ? () => _open(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 8 : 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                attachment.isImage
                    ? Icons.image_outlined
                    : attachment.isPdf
                    ? Icons.picture_as_pdf_outlined
                    : attachment.isAudio
                    ? Icons.audiotrack_outlined
                    : attachment.isVideo
                    ? Icons.videocam_outlined
                    : Icons.insert_drive_file_outlined,
                color: scheme.primary,
              ),
              const SizedBox(width: 10),
              if (attachment.isImage &&
                  attachment.url != null &&
                  attachment.url!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    attachment.url!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    if (progress != null)
                      LinearProgressIndicator(value: progress!.clamp(0, 1))
                    else
                      Text(
                        failed ? 'Falha no envio' : attachment.kindLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: failed
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (onCancel != null)
                IconButton(
                  tooltip: 'Cancelar',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded),
                ),
              if (failed && onRetry != null)
                IconButton(
                  tooltip: 'Tentar novamente',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              if (onRemove != null && progress == null && !failed)
                IconButton(
                  tooltip: 'Remover',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              if (attachment.url != null)
                IconButton(
                  tooltip: attachment.isImage
                      ? 'Ver imagem'
                      : 'Abrir documento',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _open(context),
                  icon: const Icon(Icons.open_in_new_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProtocolRatingCard extends StatefulWidget {
  const ProtocolRatingCard({
    super.key,
    required this.canRate,
    required this.canEdit,
    required this.existing,
    required this.onSubmit,
    required this.busy,
  });

  final bool canRate;
  final bool canEdit;
  final ProtocolRating? existing;
  final Future<void> Function(int stars, bool resolved, String? comment)
  onSubmit;
  final bool busy;

  @override
  State<ProtocolRatingCard> createState() => _ProtocolRatingCardState();
}

class _ProtocolRatingCardState extends State<ProtocolRatingCard> {
  late int _stars;
  bool? _resolved;
  int? _nps;
  final _comment = TextEditingController();
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _stars = widget.existing?.stars ?? 0;
    _resolved = widget.existing?.resolved;
    _comment.text = widget.existing?.comment ?? '';
    _sent = widget.existing != null;
  }

  @override
  void didUpdateWidget(covariant ProtocolRatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existing != oldWidget.existing && widget.existing != null) {
      _stars = widget.existing!.stars;
      _resolved = widget.existing!.resolved;
      _comment.text = widget.existing!.comment ?? '';
      _sent = true;
    }
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _editable => (widget.canRate && !_sent) || (widget.canEdit && _sent);

  @override
  Widget build(BuildContext context) {
    if (!widget.canRate && widget.existing == null) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como foi o atendimento?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: !_editable || widget.busy
                      ? null
                      : () => setState(() => _stars = i),
                  icon: Icon(
                    i <= _stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: scheme.primary,
                    size: 32,
                  ),
                  tooltip: '$i estrela${i > 1 ? 's' : ''}',
                ),
            ],
          ),
          const SizedBox(height: 8),
          // NPS preparado — UI visível; envio no payload só quando preenchido.
          Text(
            'Recomendaria o atendimento? (NPS)',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (var n = 0; n <= 10; n++)
                ChoiceChip(
                  label: Text('$n'),
                  selected: _nps == n,
                  onSelected: !_editable || widget.busy
                      ? null
                      : (_) => setState(() => _nps = n),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Seu problema foi resolvido?',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Sim'),
                selected: _resolved == true,
                onSelected: !_editable || widget.busy
                    ? null
                    : (_) => setState(() => _resolved = true),
              ),
              ChoiceChip(
                label: const Text('Não'),
                selected: _resolved == false,
                onSelected: !_editable || widget.busy
                    ? null
                    : (_) => setState(() => _resolved = false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('protocol_rating_comment'),
            controller: _comment,
            enabled: _editable && !widget.busy,
            maxLines: 3,
            // Campo dentro do scroll principal: não competir pelo gesto vertical.
            scrollPhysics: const NeverScrollableScrollPhysics(),
            decoration: const InputDecoration(
              labelText: 'Comentário (opcional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          if (_sent && !_editable)
            Text(
              UserMessages.ratingSent,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            FilledButton(
              onPressed:
                  !_editable || widget.busy || _stars < 1 || _resolved == null
                  ? null
                  : () async {
                      await widget.onSubmit(
                        _stars,
                        _resolved!,
                        _comment.text.trim().isEmpty
                            ? null
                            : _comment.text.trim(),
                      );
                      if (mounted) setState(() => _sent = true);
                    },
              child: Text(widget.busy ? 'Enviando...' : 'Enviar avaliação'),
            ),
        ],
      ),
    );
  }
}
