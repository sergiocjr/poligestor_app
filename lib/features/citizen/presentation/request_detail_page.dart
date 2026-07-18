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
  bool _picking = false;
  final List<_PendingUpload> _pending = [];
  bool _markedRead = false;

  /// Loading local do composer/envio — nunca cobre a tela inteira.
  bool get _composerBusy => _busy || _picking;

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
      'busy=$_busy picking=$_picking focus=${_messageFocus.hasFocus} '
      'mounted=$mounted',
    );
  }

  void _clearFocus() {
    if (_messageFocus.hasFocus) {
      _messageFocus.unfocus();
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _logConversation(ProtocolDetail detail, {Object? error}) {
    if (!kDebugMode) return;
    debugPrint(
      '[RequestDetail] conversation '
      'messages=${detail.messages.length} '
      'attachments=${detail.attachments.length} '
      'history=${detail.history.length} '
      'busy=$_busy picking=$_picking '
      'mounted=$mounted '
      'error=${error?.runtimeType ?? 'none'}',
    );
  }

  Future<ProtocolDetail> _load() async {
    if (kDebugMode) {
      debugPrint('[RequestDetail] load start id=${widget.id}');
    }
    try {
      final auth = context.read<AuthController>();
      final repo = context.read<ProtocolsRepository>();
      final detail = await repo.getById(mode: auth.mode, id: widget.id);
      _logConversation(detail);
      if (!_markedRead) {
        _markedRead = true;
        // ignore: unawaited_futures
        _markAsRead(detail);
      }
      return detail;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[RequestDetail] load error=${e.runtimeType}');
        debugPrint('$st');
      }
      rethrow;
    } finally {
      if (kDebugMode) {
        debugPrint(
          '[RequestDetail] load finally busy=$_busy picking=$_picking',
        );
      }
    }
  }

  Future<void> _reload() async {
    _clearFocus();
    setState(() {
      _markedRead = false;
      _future = _load();
    });
    try {
      await _future;
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _picking = false;
        });
      }
    }
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
    setState(() {
      _busy = true;
    });
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
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (_picking || _busy) return;
    _clearFocus();
    setState(() {
      _picking = true;
    });
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 85);
      if (!mounted) return;
      if (file == null) return; // cancelou — libera toque no finally
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserMessages.fromError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _picking = false;
        });
      }
    }
  }

  Future<void> _pickDocument() async {
    if (_picking || _busy) return;
    _clearFocus();
    setState(() {
      _picking = true;
    });
    try {
      final picker = ImagePicker();
      final file = await picker.pickMedia();
      if (!mounted) return;
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserMessages.fromError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _picking = false;
        });
      }
    }
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
              setState(() {
                item.progress = p;
              });
            },
          );
      if (mounted) {
        setState(() {
          _pending.removeWhere((e) => e.id == item.id);
        });
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        if (mounted) {
          setState(() {
            _pending.removeWhere((x) => x.id == item.id);
          });
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
    setState(() {
      _ratingBusy = true;
    });
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
        setState(() {
          _ratingBusy = false;
        });
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
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _clearFocus();
    }
    return false;
  }

  Widget _buildComposer(ProtocolDetail p, ColorScheme scheme) {
    final highlight = p.isAwaitingCitizen;
    return Material(
      key: const Key('request_detail_composer_bar'),
      elevation: 6,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: highlight
                ? scheme.tertiaryContainer.withValues(alpha: 0.45)
                : scheme.surface,
            border: Border(
              top: BorderSide(
                color: highlight ? scheme.tertiary : scheme.outlineVariant,
                width: highlight ? 1.5 : 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_composerBusy)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              TextField(
                key: const Key('request_detail_composer'),
                controller: _messageCtrl,
                focusNode: _messageFocus,
                enabled: !_composerBusy,
                minLines: highlight ? 2 : 1,
                maxLines: 4,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: highlight
                      ? 'Sua resposta ao gabinete'
                      : 'Escreva uma mensagem',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  IconButton(
                    key: const Key('btn_composer_gallery'),
                    tooltip: 'Anexar foto',
                    onPressed: _composerBusy
                        ? null
                        : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined),
                  ),
                  IconButton(
                    key: const Key('btn_composer_attach'),
                    tooltip: 'Anexar documento',
                    onPressed: _composerBusy ? null : _pickDocument,
                    icon: const Icon(Icons.attach_file),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('btn_composer_send'),
                    onPressed: _composerBusy ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    label: Text(_busy ? 'Enviando...' : 'Enviar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<ProtocolDetail>(
      future: _future,
      builder: (context, snapshot) {
        final loaded = snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            snapshot.data != null;
        final p = snapshot.data;

        return Scaffold(
          appBar: AppBar(title: const Text('Detalhes da solicitação')),
          // Composer no bottomNavigationBar: sem Column+Expanded no body
          // (evita tela branca quando o shell não limita altura).
          bottomNavigationBar:
              loaded && p != null ? _buildComposer(p, scheme) : null,
          body: () {
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
            final detail = p!;
            return NotificationListener<ScrollNotification>(
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          FadeSlideIn(
                            child: Text(
                              detail.title,
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
                              if (detail.number != null)
                                Chip(
                                  label:
                                      Text('Protocolo nº ${detail.number}'),
                                ),
                              Chip(
                                label: Text(
                                  ProtocolStatusLabel.pt(detail.status),
                                ),
                              ),
                              if (detail.category != null)
                                Chip(label: Text(detail.category!)),
                              if (detail.priority != null)
                                Chip(
                                  label: Text(
                                    'Prioridade: ${ProtocolPriorityLabel.pt(detail.priority)}',
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _MetaRow(
                            label: 'Aberta em',
                            value: detail.createdAt != null
                                ? dateFmt.format(detail.createdAt!.toLocal())
                                : '—',
                          ),
                          _MetaRow(
                            label: 'Última atualização',
                            value: (detail.updatedAt ?? detail.createdAt) !=
                                    null
                                ? dateFmt.format(
                                    (detail.updatedAt ?? detail.createdAt)!
                                        .toLocal(),
                                  )
                                : '—',
                          ),
                          if (detail.address != null)
                            _MetaRow(
                              label: 'Endereço',
                              value: detail.address!,
                            ),
                          if (detail.publicAssignee != null)
                            _MetaRow(
                              label: 'Responsável',
                              value: detail.publicAssignee!,
                            ),
                          _MetaRow(
                            label: 'Prazo',
                            value: _prazoText(detail),
                            emphasize: detail.isOverdue,
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
                            detail.description?.isNotEmpty == true
                                ? detail.description!
                                : 'Sem descrição.',
                            softWrap: true,
                          ),
                          if (detail.isAwaitingCitizen &&
                              detail.pendingQuestion != null) ...[
                            const SizedBox(height: 16),
                            ProtocolAwaitingBanner(
                              question: detail.pendingQuestion!,
                            ),
                          ] else if (detail.isAwaitingCitizen) ...[
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
                                key: const Key('btn_anexo_foto'),
                                onPressed: _composerBusy
                                    ? null
                                    : () => _pick(ImageSource.camera),
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Foto'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('btn_anexo_galeria'),
                                onPressed: _composerBusy
                                    ? null
                                    : () => _pick(ImageSource.gallery),
                                icon: const Icon(Icons.image_outlined),
                                label: const Text('Galeria'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('btn_anexo_doc'),
                                onPressed:
                                    _composerBusy ? null : _pickDocument,
                                icon: const Icon(Icons.attach_file),
                                label: const Text('Documento'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (detail.attachments.isEmpty && _pending.isEmpty)
                            const Text('Nenhum anexo.')
                          else ...[
                            ...detail.attachments.map(
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
                                  setState(() {
                                    _pending.removeWhere((e) => e.id == u.id);
                                    _picking = false;
                                  });
                                },
                                onRetry: () => _uploadOne(u),
                                onRemove: u.progress == null
                                    ? () {
                                        setState(() {
                                          _pending.removeWhere(
                                            (e) => e.id == u.id,
                                          );
                                          _picking = false;
                                        });
                                      }
                                    : null,
                              ),
                            ),
                          ],
                          const SectionHeader(
                            title: 'Conversa',
                            subtitle: 'Troca de mensagens com o gabinete',
                          ),
                          RepaintBoundary(
                            child: ProtocolConversationPanel(
                              key: const Key('request_detail_conversation'),
                              messages: detail.messages,
                            ),
                          ),
                          const SectionHeader(title: 'Histórico'),
                          ProtocolHistorySection(events: detail.history),
                          if (detail.canRate || detail.rating != null) ...[
                            const SizedBox(height: 8),
                            const SectionHeader(title: 'Avaliação'),
                            ProtocolRatingCard(
                              canRate: detail.canRate,
                              canEdit: detail.canEditRating,
                              existing: detail.rating,
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
            );
          }(),
        );
      },
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
