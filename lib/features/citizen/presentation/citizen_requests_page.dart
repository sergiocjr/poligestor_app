import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../../protocols/data/protocol_models.dart';
import '../../protocols/data/protocols_repository.dart';

class CitizenRequestsPage extends StatefulWidget {
  const CitizenRequestsPage({super.key, this.initialStatusFilter});

  final String? initialStatusFilter;

  @override
  State<CitizenRequestsPage> createState() => _CitizenRequestsPageState();
}

class _CitizenRequestsPageState extends State<CitizenRequestsPage> {
  Future<List<ProtocolSummary>>? _future;
  late RequestStatusFilter? _filter;

  @override
  void initState() {
    super.initState();
    _filter = RequestStatusFilter.tryParse(widget.initialStatusFilter);
  }

  @override
  void didUpdateWidget(covariant CitizenRequestsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatusFilter != widget.initialStatusFilter) {
      _filter = RequestStatusFilter.tryParse(widget.initialStatusFilter);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<ProtocolSummary>> _load() {
    final auth = context.read<AuthController>();
    return context.read<ProtocolsRepository>().list(mode: auth.mode);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  List<ProtocolSummary> _applyFilter(List<ProtocolSummary> items) {
    final filter = _filter;
    if (filter == null) return items;
    return items.where(filter.matches).toList();
  }

  String _relativeOrTime(DateTime? dt, DateFormat dateFmt, DateFormat timeFmt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final sameDay = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    if (sameDay) return timeFmt.format(local);
    return dateFmt.format(local);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    final timeFmt = DateFormat('HH:mm');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas solicitações'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/citizen/requests/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todas'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                for (final f in RequestStatusFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f.label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProtocolSummary>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: const [
                      SkeletonBox(height: 88, radius: 18),
                      SizedBox(height: 12),
                      SkeletonBox(height: 88, radius: 18),
                      SizedBox(height: 12),
                      SkeletonBox(height: 88, radius: 18),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return AppErrorState(
                    error: snapshot.error,
                    onRetry: _reload,
                  );
                }
                final items = _applyFilter(snapshot.data ?? const []);
                if (items.isEmpty) {
                  return AppEmptyState(
                    message: UserMessages.emptyRequests,
                    actionLabel: 'Criar solicitação',
                    onAction: () => context.push('/citizen/requests/new'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = items[index];
                      final unread = p.showUnreadBadge;
                      final updated = p.updatedAt ?? p.createdAt;
                      return Semantics(
                        button: true,
                        label: [
                          p.title,
                          if (unread) 'nova mensagem',
                          if (p.awaitingCitizen) 'aguardando sua resposta',
                        ].join(', '),
                        child: Card(
                          color: unread
                              ? scheme.primaryContainer.withValues(alpha: 0.35)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: unread
                                ? BorderSide(color: scheme.primary, width: 1.2)
                                : BorderSide.none,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            leading: unread
                                ? Badge(
                                    smallSize: 10,
                                    child: Icon(
                                      Icons.mark_chat_unread_rounded,
                                      color: scheme.primary,
                                    ),
                                  )
                                : Icon(
                                    p.awaitingCitizen
                                        ? Icons.help_outline_rounded
                                        : Icons.description_outlined,
                                    color: scheme.primary,
                                  ),
                            title: Text(
                              p.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight:
                                    unread ? FontWeight.w900 : FontWeight.w700,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    if (p.number != null) 'nº ${p.number}',
                                    ProtocolStatusLabel.pt(p.status),
                                    if (updated != null)
                                      _relativeOrTime(
                                        updated,
                                        dateFmt,
                                        timeFmt,
                                      ),
                                  ].join(' · '),
                                ),
                                if (p.lastMessagePreview != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    p.lastMessagePreview!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: unread
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                                if (p.awaitingCitizen) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'O gabinete precisa de mais informações',
                                    style: TextStyle(
                                      color: scheme.tertiary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () async {
                              await context
                                  .push('/citizen/requests/${p.id}');
                              if (mounted) await _reload();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
