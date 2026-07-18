import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../notifications/domain/notifications_controller.dart';
import '../../protocols/data/protocol_models.dart';
import '../../protocols/data/protocols_repository.dart';
import '../../protocols/domain/protocol_message_merge.dart';
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
  bool _openedSuccessfully = false;
  ProtocolDetail? _cached;
  Timer? _pollTimer;
  bool _newMessagesBanner = false;

  /// Loading local do composer/envio — nunca cobre a tela inteira.
  bool get _composerBusy => _busy || _picking;

  @override
  void initState() {
    super.initState();
    _messageFocus.addListener(_onComposerFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageFocus.removeListener(_onComposerFocusChange);
    _scrollController.dispose();
    _messageCtrl.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    // Fallback REST enquanto não há WebSocket/contrato Fase 7.
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // ignore: discarded_futures
      _softRefresh();
    });
  }

  void _onComposerFocusChange() {
    if (_messageFocus.hasFocus) {
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
      debugPrint(
        '[RequestDetail] load start id=${widget.id} mounted=$mounted',
      );
    }
    try {
      final auth = context.read<AuthController>();
      final repo = context.read<ProtocolsRepository>();
      final path = '${auth.mode.protocolsPath}/${widget.id}';
      if (kDebugMode) {
        debugPrint('[RequestDetail] GET $path');
      }
      final detail = await repo.getById(mode: auth.mode, id: widget.id);
      _openedSuccessfully = true;
      _cached = detail;
      _startPolling();
      _logConversation(detail);
      if (kDebugMode) {
        final keys = detail.raw?.keys.toList() ?? const [];
        debugPrint(
          '[RequestDetail] success number=${detail.number} '
          'status=${detail.status} titleLen=${detail.title.length} '
          'comments=${detail.messages.length} '
          'timeline=${detail.history.length} '
          'attachments=${detail.attachments.length} '
          'rootKeys=$keys',
        );
      }
      if (!_markedRead) {
        _markedRead = true;
        // ignore: unawaited_futures
        _markAsRead(detail);
      }
      return detail;
    } catch (e, st) {
      _openedSuccessfully = false;
      if (kDebugMode) {
        debugPrint('[RequestDetail] load error=$e');
        debugPrint('$st');
      }
      rethrow;
    } finally {
      if (kDebugMode) {
        debugPrint(
          '[RequestDetail] load finally busy=$_busy picking=$_picking '
          'mounted=$mounted',
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

  Future<void> _softRefresh() async {
    if (!mounted || _busy || _picking) return;
    try {
      final auth = context.read<AuthController>();
      final repo = context.read<ProtocolsRepository>();
      final fresh = await repo.getById(mode: auth.mode, id: widget.id);
      if (!mounted) return;
      final prev = _cached;
      final msgChanged = prev == null ||
          prev.messages.length != fresh.messages.length ||
          prev.status != fresh.status ||
          prev.updatedAt != fresh.updatedAt;
      if (!msgChanged) return;

      final nearEnd = !_scrollController.hasClients ||
          isNearScrollEnd(
            _scrollController.offset,
            _scrollController.position.maxScrollExtent,
          );

      final mergedMessages = mergeProtocolMessages(
        prev?.messages ?? const [],
        fresh.messages,
      );
      final merged = ProtocolDetail(
        id: fresh.id,
        title: fresh.title,
        number: fresh.number,
        status: fresh.status,
        priority: fresh.priority,
        category: fresh.category,
        createdAt: fresh.createdAt,
        updatedAt: fresh.updatedAt,
        description: fresh.description,
        unreadCount: fresh.unreadCount,
        hasUnread: fresh.hasUnread,
        lastMessagePreview: fresh.lastMessagePreview,
        awaitingCitizen: fresh.awaitingCitizen,
        address: fresh.address,
        publicAssignee: fresh.publicAssignee,
        deadlineAt: fresh.deadlineAt,
        deadlineLabel: fresh.deadlineLabel,
        isOverdue: fresh.isOverdue,
        messages: mergedMessages,
        history: fresh.history,
        attachments: fresh.attachments,
        pendingQuestion: fresh.pendingQuestion,
        canRate: fresh.canRate,
        canEditRating: fresh.canEditRating,
        rating: fresh.rating,
        markReadUrl: fresh.markReadUrl,
        rateUrl: fresh.rateUrl,
        raw: fresh.raw,
      );

      setState(() {
        _cached = merged;
        _future = Future.value(merged);
        _newMessagesBanner = !nearEnd &&
            (prev?.messages.length ?? 0) < merged.messages.length;
      });
      if (nearEnd) {
        _scrollToEnd();
        _newMessagesBanner = false;
      }
      // ignore: discarded_futures
      context.read<NotificationsController>().refresh();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RequestDetail] softRefresh error=$e');
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
      _scrollToEnd();
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

  Widget _buildComposer(ProtocolDetail p, ColorScheme scheme) {
    final highlight = p.isAwaitingCitizen;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    // Composer no rodapé do Column (não em bottomNavigationBar): o Scaffold
    // com resizeToAvoidBottomInset sobe o bloco junto com o teclado.
    return Material(
      key: const Key('request_detail_composer_bar'),
      color: highlight
          ? scheme.tertiaryContainer.withValues(alpha: 0.45)
          : scheme.surface,
      elevation: 4,
      child: SafeArea(
        top: false,
        // Com teclado aberto o inset já vem do Scaffold; evita padding duplo.
        bottom: !keyboardOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                key: const Key('btn_composer_gallery'),
                tooltip: 'Anexar foto',
                onPressed:
                    _composerBusy ? null : () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.image_outlined),
              ),
              IconButton(
                key: const Key('btn_composer_attach'),
                tooltip: 'Anexar documento',
                onPressed: _composerBusy ? null : _pickDocument,
                icon: const Icon(Icons.attach_file),
              ),
              Expanded(
                child: TextField(
                  key: const Key('request_detail_composer'),
                  controller: _messageCtrl,
                  focusNode: _messageFocus,
                  enabled: !_composerBusy,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: highlight
                        ? 'Sua resposta ao gabinete'
                        : 'Escreva uma mensagem',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                key: const Key('btn_composer_send'),
                tooltip: 'Enviar',
                onPressed: _composerBusy ? null : _sendMessage,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBody() {
    return ListView(
      key: const Key('request_detail_loading'),
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

  Widget _buildSuccessBody(ProtocolDetail detail, DateFormat dateFmt) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        key: const Key('request_detail_scroll'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        children: [
          Text(
            detail.title,
            key: const Key('request_detail_title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (detail.number != null)
                Chip(label: Text('Protocolo nº ${detail.number}')),
              Chip(label: Text(ProtocolStatusLabel.pt(detail.status))),
              if (detail.category != null) Chip(label: Text(detail.category!)),
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
            value: (detail.updatedAt ?? detail.createdAt) != null
                ? dateFmt.format(
                    (detail.updatedAt ?? detail.createdAt)!.toLocal(),
                  )
                : '—',
          ),
          if (detail.address != null)
            _MetaRow(label: 'Endereço', value: detail.address!),
          if (detail.publicAssignee != null)
            _MetaRow(label: 'Responsável', value: detail.publicAssignee!),
          _MetaRow(
            label: 'Prazo',
            value: _prazoText(detail),
            emphasize: detail.isOverdue,
          ),
          const SizedBox(height: 16),
          Text(
            'Descrição',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          if (detail.isAwaitingCitizen) ...[
            const SizedBox(height: 16),
            ProtocolAwaitingBanner(
              question: detail.pendingQuestion ??
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
                onPressed:
                    _composerBusy ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Foto'),
              ),
              OutlinedButton.icon(
                key: const Key('btn_anexo_galeria'),
                onPressed:
                    _composerBusy ? null : () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.image_outlined),
                label: const Text('Galeria'),
              ),
              OutlinedButton.icon(
                key: const Key('btn_anexo_doc'),
                onPressed: _composerBusy ? null : _pickDocument,
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
                  context.read<ProtocolsRepository>().cancelUpload(u.id);
                  setState(() {
                    _pending.removeWhere((e) => e.id == u.id);
                    _picking = false;
                  });
                },
                onRetry: () => _uploadOne(u),
                onRemove: u.progress == null
                    ? () {
                        setState(() {
                          _pending.removeWhere((e) => e.id == u.id);
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
          ProtocolConversationPanel(
            key: const Key('request_detail_conversation'),
            messages: detail.messages,
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
        ],
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
        final hasData = snapshot.hasData && snapshot.data != null;
        final isLoading = snapshot.connectionState != ConnectionState.done;
        final hasError = snapshot.hasError;
        final detail = snapshot.data;

        Widget body;
        if (isLoading && !hasData) {
          body = _buildLoadingBody();
        } else if (hasError && !hasData) {
          body = AppErrorState(
            key: const Key('request_detail_error'),
            message: UserMessages.forProtocolError(snapshot.error),
            error: snapshot.error,
            onRetry: _reload,
          );
        } else if (hasData && detail != null) {
          body = _buildSuccessBody(detail, dateFmt);
        } else {
          body = AppErrorState(
            key: const Key('request_detail_empty'),
            message: UserMessages.protocolNotFound,
            onRetry: _reload,
          );
        }

        // Scaffold
        // └── Column
        //     ├── Expanded → lista
        //     └── Composer  (sobe com o teclado via resizeToAvoidBottomInset)
        final content = hasData && detail != null
            ? Column(
                children: [
                  if (_newMessagesBanner)
                    Material(
                      color: scheme.primaryContainer,
                      child: ListTile(
                        dense: true,
                        title: const Text('Há novas mensagens'),
                        trailing: TextButton(
                          onPressed: () {
                            setState(() => _newMessagesBanner = false);
                            _scrollToEnd();
                          },
                          child: const Text('Ver'),
                        ),
                      ),
                    ),
                  Expanded(child: body),
                  _buildComposer(detail, scheme),
                ],
              )
            : body;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (context.canPop()) {
              context.pop(_openedSuccessfully);
            }
          },
          child: Scaffold(
            backgroundColor: scheme.surface,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('Detalhes da solicitação'),
              leading: BackButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop(_openedSuccessfully);
                  }
                },
              ),
            ),
            body: content,
          ),
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
