import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../protocols/data/protocol_models.dart';
import '../../protocols/data/protocols_repository.dart';
import 'widgets/protocol_attendance_widgets.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage({super.key, required this.id});

  final String id;

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _PendingUpload {
  _PendingUpload({
    required this.id,
    required this.path,
    required this.name,
    this.mimeType,
  });

  final String id;
  final String path;
  final String name;
  final String? mimeType;
  double? progress;
  bool failed = false;
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  Future<ProtocolDetail>? _future;
  final _messageCtrl = TextEditingController();
  final _messageFocus = FocusNode();
  final _scrollController = ScrollController();
  bool _busy = false;
  bool _ratingBusy = false;
  final List<_PendingUpload> _pending = [];
  bool _markedRead = false;

  bool get _blocking => _busy || _ratingBusy;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _scrollController.addListener(_debugScroll);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      _scrollController.removeListener(_debugScroll);
    }
    _scrollController.dispose();
    _messageCtrl.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  void _debugScroll() {
    if (!kDebugMode || !_scrollController.hasClients) return;
    debugPrint(
      '[RequestDetail] offset=${_scrollController.offset.toStringAsFixed(1)} '
      'busy=$_busy ratingBusy=$_ratingBusy '
      'focus=${_messageFocus.hasFocus} mounted=$mounted',
    );
  }

  void _clearFocus() {
    if (_messageFocus.hasFocus) {
      _messageFocus.unfocus();
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<ProtocolDetail> _load() async {
    final auth = context.read<AuthController>();
    final repo = context.read<ProtocolsRepository>();
    final detail = await repo.getById(mode: auth.mode, id: widget.id);
    if (!_markedRead) {
      _markedRead = true;
      // ignore: unawaited_futures
      _markAsRead(detail);
    }
    return detail;
  }

  Future<void> _reload() async {
    _clearFocus();
    setState(() {
      _markedRead = false;
      _future = _load();
    });
    await _future;
  }

  Future<void> _markAsRead(ProtocolDetail detail) async {
    if (!mounted) return;
    final auth = context.read<AuthController>();
    final protocolsRepo = context.read<ProtocolsRepository>();
    final notificationsRepo = context.read<NotificationsRepository>();
    try {
      await protocolsRepo.markMessagesRead(
        mode: auth.mode,
        detail: detail,
      );
    } catch (_) {}

    // Marca avisos relacionados via endpoint real de notificações.
    try {
      final notes = await notificationsRepo.list(mode: auth.mode);
      if (!mounted) return;
      final idStr = '${detail.id}';
      final number = detail.number;
      for (final n in notes.where((e) => e.isUnread)) {
        final link = (n.link ?? '').toLowerCase();
        final blob = '${n.title} ${n.body ?? ''} ${n.link ?? ''}'.toLowerCase();
        final match = link.contains(idStr) ||
            link.contains('/requests/$idStr') ||
            link.contains('/protocols/$idStr') ||
            (number != null && blob.contains(number.toLowerCase()));
        if (!match) continue;
        try {
          await notificationsRepo.markRead(mode: auth.mode, id: n.id);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty && _pending.isEmpty) return;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthController>();
      final repo = context.read<ProtocolsRepository>();
      if (text.isNotEmpty) {
        await repo.addComment(
          mode: auth.mode,
          protocolId: widget.id,
          body: text,
        );
      }
      for (final p in List<_PendingUpload>.from(_pending)) {
        await _uploadOne(p);
      }
      _messageCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UserMessages.messageSent)),
        );
      }
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserMessages.fromError(e))),
        );
      }
    } finally {
      if (mounted) {
        _clearFocus();
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    setState(() {
      _pending.add(
        _PendingUpload(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          path: file.path,
          name: file.name,
          mimeType: file.mimeType,
        ),
      );
    });
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final file = await picker.pickMedia();
    if (file == null) return;
    setState(() {
      _pending.add(
        _PendingUpload(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          path: file.path,
          name: file.name,
          mimeType: file.mimeType,
        ),
      );
    });
  }

  Future<void> _uploadOne(_PendingUpload item) async {
    setState(() {
      item.failed = false;
      item.progress = 0;
    });
    try {
      final auth = context.read<AuthController>();
      await context.read<ProtocolsRepository>().uploadAttachment(
            mode: auth.mode,
            protocolId: widget.id,
            filePath: item.path,
            fileName: item.name,
            mimeType: item.mimeType,
            uploadId: item.id,
            onProgress: (p) {
              if (!mounted) return;
              setState(() => item.progress = p);
            },
          );
      if (mounted) {
        setState(() => _pending.removeWhere((e) => e.id == item.id));
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        if (mounted) {
          setState(() => _pending.removeWhere((x) => x.id == item.id));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(UserMessages.uploadCanceled)),
          );
        }
        return;
      }
      if (mounted) {
        setState(() {
          item.failed = true;
          item.progress = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UserMessages.uploadFailed)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          item.failed = true;
          item.progress = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UserMessages.uploadFailed)),
        );
      }
    }
  }

  Future<void> _submitRating(int stars, bool resolved, String? comment) async {
    final detail = await _future;
    if (detail == null || !mounted) return;
    setState(() => _ratingBusy = true);
    try {
      final auth = context.read<AuthController>();
      await context.read<ProtocolsRepository>().submitRating(
            mode: auth.mode,
            detail: detail,
            input: ProtocolRatingInput(
              stars: stars,
              resolved: resolved,
              comment: comment,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UserMessages.ratingSent)),
        );
      }
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserMessages.fromError(e))),
        );
      }
    } finally {
      if (mounted) {
        _clearFocus();
        setState(() => _ratingBusy = false);
      }
    }
  }

  String _prazoText(ProtocolDetail p) {
    if (p.isOverdue) return 'Atrasado';
    if (p.deadlineLabel != null && p.deadlineLabel!.trim().isNotEmpty) {
      return p.deadlineLabel!;
    }
    if (p.deadlineAt != null) {
      return DateFormat("dd/MM/yyyy 'às' HH:mm").format(p.deadlineAt!.toLocal());
    }
    return 'Sem prazo informado';
  }

  bool _onScrollNotification(ScrollNotification notification) {
    // Drag do usuário: libera focus para o TextField não roubar o gesto.
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _clearFocus();
    }
    if (kDebugMode && notification is ScrollUpdateNotification) {
      debugPrint(
        '[RequestDetail] scroll pixels=${notification.metrics.pixels.toStringAsFixed(1)} '
        'blocking=$_blocking overlays=${_blocking ? 1 : 0}',
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da solicitação')),
      body: FutureBuilder<ProtocolDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                SkeletonBox(height: 28, width: 220),
                SizedBox(height: 12),
                SkeletonBox(height: 18, width: 160),
                SizedBox(height: 20),
                SkeletonBox(height: 120, radius: 18),
                SizedBox(height: 16),
                SkeletonBox(height: 180, radius: 18),
              ],
            );
          }
          if (snapshot.hasError) {
            return AppErrorState(error: snapshot.error, onRetry: _reload);
          }
          final p = snapshot.data!;
          final highlightComposer = p.isAwaitingCitizen;
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

          return Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: _onScrollNotification,
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: CustomScrollView(
                    key: const Key('request_detail_scroll'),
                    controller: _scrollController,
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          12,
                          20,
                          24 + bottomInset,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            FadeSlideIn(
                              child: Text(
                                p.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (p.number != null)
                                  Chip(
                                    label: Text('Protocolo nº ${p.number}'),
                                  ),
                                Chip(
                                  label: Text(
                                    ProtocolStatusLabel.pt(p.status),
                                  ),
                                ),
                                if (p.category != null)
                                  Chip(label: Text(p.category!)),
                                if (p.priority != null)
                                  Chip(
                                    label: Text(
                                      'Prioridade: ${ProtocolPriorityLabel.pt(p.priority)}',
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _MetaRow(
                              label: 'Aberta em',
                              value: p.createdAt != null
                                  ? dateFmt.format(p.createdAt!.toLocal())
                                  : '—',
                            ),
                            _MetaRow(
                              label: 'Última atualização',
                              value: (p.updatedAt ?? p.createdAt) != null
                                  ? dateFmt.format(
                                      (p.updatedAt ?? p.createdAt)!.toLocal(),
                                    )
                                  : '—',
                            ),
                            if (p.address != null)
                              _MetaRow(label: 'Endereço', value: p.address!),
                            if (p.publicAssignee != null)
                              _MetaRow(
                                label: 'Responsável',
                                value: p.publicAssignee!,
                              ),
                            _MetaRow(
                              label: 'Prazo',
                              value: _prazoText(p),
                              emphasize: p.isOverdue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Descrição',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.description?.isNotEmpty == true
                                  ? p.description!
                                  : 'Sem descrição.',
                              softWrap: true,
                            ),
                            if (p.isAwaitingCitizen &&
                                p.pendingQuestion != null) ...[
                              const SizedBox(height: 16),
                              ProtocolAwaitingBanner(
                                question: p.pendingQuestion!,
                              ),
                            ] else if (p.isAwaitingCitizen) ...[
                              const SizedBox(height: 16),
                              const ProtocolAwaitingBanner(
                                question:
                                    'Responda na conversa abaixo para continuar o atendimento.',
                              ),
                            ],
                            const SectionHeader(title: 'Anexos'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _blocking
                                      ? null
                                      : () => _pick(ImageSource.camera),
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('Foto'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _blocking
                                      ? null
                                      : () => _pick(ImageSource.gallery),
                                  icon: const Icon(Icons.image_outlined),
                                  label: const Text('Galeria'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _blocking ? null : _pickDocument,
                                  icon: const Icon(Icons.attach_file),
                                  label: const Text('Documento'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (p.attachments.isEmpty && _pending.isEmpty)
                              const Text('Nenhum anexo.')
                            else ...[
                              ...p.attachments.map(
                                (a) => ProtocolAttachmentTile(attachment: a),
                              ),
                              ..._pending.map(
                                (u) => ProtocolAttachmentTile(
                                  attachment: ProtocolAttachment(
                                    id: u.id,
                                    name: u.name,
                                    mimeType: u.mimeType,
                                  ),
                                  progress: u.progress,
                                  failed: u.failed,
                                  onCancel: () {
                                    context
                                        .read<ProtocolsRepository>()
                                        .cancelUpload(u.id);
                                    setState(
                                      () => _pending
                                          .removeWhere((e) => e.id == u.id),
                                    );
                                  },
                                  onRetry: () => _uploadOne(u),
                                  onRemove: u.progress == null
                                      ? () => setState(
                                            () => _pending.removeWhere(
                                              (e) => e.id == u.id,
                                            ),
                                          )
                                      : null,
                                ),
                              ),
                            ],
                            const SectionHeader(
                              title: 'Conversa',
                              subtitle: 'Troca de mensagens com o gabinete',
                            ),
                            ProtocolConversationPanel(
                              messages: p.messages,
                              composer: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: highlightComposer
                                      ? scheme.tertiaryContainer
                                          .withValues(alpha: 0.45)
                                      : scheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: highlightComposer
                                        ? scheme.tertiary
                                        : scheme.outlineVariant,
                                    width: highlightComposer ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      key: const Key('request_detail_composer'),
                                      controller: _messageCtrl,
                                      focusNode: _messageFocus,
                                      minLines: highlightComposer ? 3 : 2,
                                      maxLines: 5,
                                      // Evita Scrollable interno roubar o gesto
                                      // do CustomScrollView no Android físico.
                                      scrollPhysics:
                                          const NeverScrollableScrollPhysics(),
                                      textInputAction: TextInputAction.newline,
                                      decoration: InputDecoration(
                                        labelText: highlightComposer
                                            ? 'Sua resposta ao gabinete'
                                            : 'Escreva uma mensagem',
                                        alignLabelWithHint: true,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: 'Anexar foto',
                                          onPressed: _blocking
                                              ? null
                                              : () =>
                                                  _pick(ImageSource.gallery),
                                          icon: const Icon(
                                            Icons.image_outlined,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Anexar documento',
                                          onPressed:
                                              _blocking ? null : _pickDocument,
                                          icon: const Icon(Icons.attach_file),
                                        ),
                                        const Spacer(),
                                        FilledButton.icon(
                                          onPressed: _blocking
                                              ? null
                                              : () => _sendMessage(),
                                          icon: const Icon(Icons.send_rounded),
                                          label: Text(
                                            _busy ? 'Enviando...' : 'Enviar',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SectionHeader(title: 'Histórico'),
                            ProtocolHistorySection(events: p.history),
                            if (p.canRate || p.rating != null) ...[
                              const SizedBox(height: 8),
                              const SectionHeader(title: 'Avaliação'),
                              ProtocolRatingCard(
                                canRate: p.canRate,
                                canEdit: p.canEditRating,
                                existing: p.rating,
                                busy: _ratingBusy,
                                onSubmit: _submitRating,
                              ),
                            ],
                            const SizedBox(height: 24),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_blocking)
                const Positioned.fill(
                  key: Key('request_detail_blocking_overlay'),
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: Color(0x33000000),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: emphasize ? scheme.error : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
