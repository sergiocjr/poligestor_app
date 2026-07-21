import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../data/protocol_models.dart';
import '../data/protocols_repository.dart';

class ProtocolDetailPage extends StatefulWidget {
  const ProtocolDetailPage({super.key, required this.id});

  final String id;

  @override
  State<ProtocolDetailPage> createState() => _ProtocolDetailPageState();
}

class _ProtocolDetailPageState extends State<ProtocolDetailPage> {
  Future<ProtocolDetail>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<ProtocolDetail> _load() {
    final auth = context.read<AuthController>();
    return context.read<ProtocolsRepository>().getById(
      mode: auth.mode,
      id: widget.id,
    );
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  String? _originLabel(ProtocolDetail p) {
    final raw = p.raw;
    final value = raw?['origin'] ??
        raw?['source'] ??
        raw?['channel'] ??
        raw?['origem'] ??
        raw?['canal'];
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  Future<void> _openAttachment(ProtocolAttachment a) async {
    final raw = a.url?.trim();
    if (raw == null || raw.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anexo sem endereço disponível.')),
      );
      return;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o anexo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe do protocolo'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<ProtocolDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done &&
              !snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 28, radius: 8),
                SizedBox(height: 12),
                SkeletonBox(height: 80, radius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 160, radius: 16),
              ],
            );
          }
          if (snapshot.hasError && !snapshot.hasData) {
            return AppErrorState(
              message: UserMessages.forProtocolError(snapshot.error),
              error: snapshot.error,
              onRetry: _reload,
            );
          }
          final p = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                Text(
                  p.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (p.number != null)
                      Chip(label: Text('#${p.number}')),
                    Chip(label: Text(p.displayStatus)),
                    if (p.priority != null)
                      Chip(label: Text(uiPriorityLabel(p.priority))),
                    if (p.createdAt != null)
                      Chip(
                        label: Text(dateFmt.format(p.createdAt!.toLocal())),
                      ),
                    if (p.deadlineLabel != null || p.deadlineAt != null)
                      Chip(
                        avatar: Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: p.isOverdue ? scheme.error : null,
                        ),
                        label: Text(
                          p.deadlineLabel ??
                              dateFmt.format(p.deadlineAt!.toLocal()),
                          style: p.isOverdue
                              ? TextStyle(color: scheme.error)
                              : null,
                        ),
                      ),
                  ],
                ),
                if (p.address != null && p.address!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SoftNotice(
                    icon: Icons.place_outlined,
                    message: p.address!,
                  ),
                ],
                if (p.publicAssignee != null &&
                    p.publicAssignee!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Responsável: ${p.publicAssignee}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (p.category != null && p.category!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeader(title: 'Classificação'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: const Text('Categoria'),
                      subtitle: Text(p.category!, maxLines: 3, softWrap: true),
                    ),
                  ),
                ],
                if (_originLabel(p) != null) ...[
                  Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      leading: const Icon(Icons.source_outlined),
                      title: const Text('Origem'),
                      subtitle: Text(
                        _originLabel(p)!,
                        maxLines: 3,
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SectionHeader(title: 'Descrição'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      p.description?.trim().isNotEmpty == true
                          ? p.description!
                          : 'Sem descrição.',
                    ),
                  ),
                ),
                if (p.attachments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Anexos',
                    subtitle: '${p.attachments.length} arquivo(s)',
                  ),
                  const SizedBox(height: 8),
                  ...p.attachments.map(
                    (a) => Card(
                      child: ListTile(
                        leading: Icon(
                          a.isImage
                              ? Icons.image_outlined
                              : a.isPdf
                              ? Icons.picture_as_pdf_outlined
                              : Icons.attach_file_rounded,
                          color: scheme.primary,
                        ),
                        title: Text(
                          a.name?.trim().isNotEmpty == true
                              ? a.name!
                              : 'Anexo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.open_in_new_rounded),
                        onTap: () => _openAttachment(a),
                      ),
                    ),
                  ),
                ],
                if (p.messages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Mensagens',
                    subtitle: '${p.messages.length} na conversa',
                  ),
                  const SizedBox(height: 8),
                  ...p.messages.map((m) {
                    final when = m.createdAt == null
                        ? null
                        : dateFmt.format(m.createdAt!.toLocal());
                    final who = m.authorName?.trim().isNotEmpty == true
                        ? m.authorName!
                        : (m.isFromCabinet ? 'Gabinete' : 'Cidadão');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        color: m.isFromCabinet
                            ? scheme.primaryContainer.withValues(alpha: 0.35)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      who,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (when != null)
                                    Text(
                                      when,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                              if (m.body.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(m.body),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
                if (p.history.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Histórico',
                    subtitle: 'Linha do tempo do protocolo',
                  ),
                  const SizedBox(height: 8),
                  ...p.history.map((h) {
                    final when = h.createdAt == null
                        ? null
                        : dateFmt.format(h.createdAt!.toLocal());
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.history_rounded,
                          color: scheme.primary,
                        ),
                        title: Text(
                          h.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          [
                            if (when != null) when,
                            if (h.description?.trim().isNotEmpty == true)
                              h.description!,
                          ].join(' · '),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: h.description?.trim().isNotEmpty == true,
                      ),
                    );
                  }),
                ],
                if (p.messages.isEmpty &&
                    p.history.isEmpty &&
                    p.attachments.isEmpty) ...[
                  const SizedBox(height: 12),
                  SoftNotice(
                    message:
                        'Este protocolo ainda não tem mensagens, histórico '
                        'ou anexos visíveis.',
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
