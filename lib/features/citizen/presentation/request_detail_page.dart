import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../protocols/data/protocol_models.dart';
import '../../protocols/data/protocols_repository.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage({super.key, required this.id});

  final String id;

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  Future<ProtocolDetail>? _future;
  final _commentCtrl = TextEditingController();
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<ProtocolDetail> _load() {
    final auth = context.read<AuthController>();
    final repo = context.read<ProtocolsRepository>();
    return repo.getById(mode: auth.mode, id: widget.id);
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthController>();
      await context.read<ProtocolsRepository>().addComment(
            mode: auth.mode,
            protocolId: widget.id,
            body: text,
          );
      _commentCtrl.clear();
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserMessages.fromError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _attachPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;
    await _upload(file.path, file.name, file.mimeType);
  }

  Future<void> _attachGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    await _upload(file.path, file.name, file.mimeType);
  }

  Future<void> _attachDocument() async {
    final picker = ImagePicker();
    final file = await picker.pickMedia();
    if (file == null) return;
    await _upload(file.path, file.name, file.mimeType);
  }

  Future<void> _upload(String path, String name, String? mime) async {
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthController>();
      await context.read<ProtocolsRepository>().uploadAttachment(
            mode: auth.mode,
            protocolId: widget.id,
            filePath: path,
            fileName: name,
            mimeType: mime,
          );
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anexo enviado.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserMessages.fromError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

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
              ],
            );
          }
          if (snapshot.hasError) {
            return AppErrorState(error: snapshot.error, onRetry: _reload);
          }
          final p = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              FadeSlideIn(
                child: Text(
                  p.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (p.number != null) Chip(label: Text('#${p.number}')),
                  Chip(label: Text(ProtocolStatusLabel.pt(p.status))),
                  if (p.category != null) Chip(label: Text(p.category!)),
                  if (p.createdAt != null)
                    Chip(label: Text(dateFmt.format(p.createdAt!.toLocal()))),
                ],
              ),
              const SizedBox(height: 16),
              Text('Descrição',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                p.description?.isNotEmpty == true
                    ? p.description!
                    : 'Sem descrição.',
              ),
              SectionHeader(title: 'Anexos'),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _attachPhoto,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Foto'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _attachGallery,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Galeria'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _attachDocument,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Documento'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (p.attachments.isEmpty)
                const Text('Nenhum anexo.')
              else
                ...p.attachments.map(
                  (a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file_outlined),
                    title: Text(a.name ?? 'Arquivo'),
                  ),
                ),
              const SectionHeader(title: 'Linha do tempo'),
              if (p.comments.isEmpty)
                const Text('Sem atualizações ainda.')
              else
                ...p.comments.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  return RequestTimelineTile(
                    title: c.body,
                    statusLabel: [
                      if (c.authorName != null) c.authorName!,
                      if (c.createdAt != null)
                        dateFmt.format(c.createdAt!.toLocal()),
                    ].join(' · '),
                    isLast: i == p.comments.length - 1,
                  );
                }),
              const SizedBox(height: 12),
              TextField(
                controller: _commentCtrl,
                decoration: InputDecoration(
                  labelText: 'Adicionar comentário',
                  suffixIcon: IconButton(
                    onPressed: _busy ? null : _sendComment,
                    icon: const Icon(Icons.send_rounded),
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
