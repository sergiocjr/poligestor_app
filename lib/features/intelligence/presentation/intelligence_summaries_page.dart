import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_states.dart';
import '../data/intelligence_models.dart';
import '../data/intelligence_repository.dart';
import 'widgets/intelligence_widgets.dart';

class IntelligenceSummariesPage extends StatefulWidget {
  const IntelligenceSummariesPage({super.key});

  @override
  State<IntelligenceSummariesPage> createState() =>
      _IntelligenceSummariesPageState();
}

class _IntelligenceSummariesPageState extends State<IntelligenceSummariesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _scopes = const ['daily', 'weekly', 'monthly'];
  final _labels = const ['Diário', 'Semanal', 'Mensal'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumos'),
        bottom: TabBar(
          controller: _tabs,
          tabs: [for (final l in _labels) Tab(text: l)],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          for (final scope in _scopes) _BriefingsScopeView(scope: scope),
        ],
      ),
    );
  }
}

class _BriefingsScopeView extends StatefulWidget {
  const _BriefingsScopeView({required this.scope});

  final String scope;

  @override
  State<_BriefingsScopeView> createState() => _BriefingsScopeViewState();
}

class _BriefingsScopeViewState extends State<_BriefingsScopeView> {
  Future<IntelligenceBriefingsHistory>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<IntelligenceBriefingsHistory> _load() =>
      context.read<IntelligenceRepository>().briefings(scope: widget.scope);

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<IntelligenceBriefingsHistory>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done && !snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: SkeletonBox(height: 120, radius: 16),
          );
        }
        if (snap.hasError && !snap.hasData) {
          return AppErrorState(
            message: UserMessages.fromError(snap.error),
            error: snap.error,
            onRetry: _refresh,
          );
        }
        final data = snap.data!;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              if (data.fromCache && data.cacheAgeLabel != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IntelStaleNotice(ageLabel: data.cacheAgeLabel!),
                ),
              if (data.bullets.isEmpty)
                AppEmptyState(
                  message: data.message ??
                      'Nenhum resumo persistido ainda para este período.',
                  icon: Icons.menu_book_outlined,
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final b in data.bullets)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text('• $b'),
                          ),
                        if (data.source != null)
                          Text(
                            'Fonte: ${data.source}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
