import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/finance_contracts.dart';
import '../data/finance_models.dart';
import '../data/finance_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _FinanceRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindFinanceRefresh(VoidCallback reload) {
    final r = context.watch<MandateRefreshController>();
    if (!identical(_refresh, r)) {
      _refresh = r;
      _gen = r.generation;
    } else if (r.generation != _gen) {
      _gen = r.generation;
      reload();
    }
  }
}

/// Hub — Gestão Financeira do Mandato (Fase 14).
class FinanceHubPage extends StatelessWidget {
  const FinanceHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry('Painel financeiro', 'Visão geral', Icons.account_balance_wallet_outlined, 'dashboard', '/home/finance/dashboard'),
    _Entry('Indicadores', 'KPIs financeiros', Icons.speed_outlined, 'indicators', '/home/finance/indicators'),
    _Entry('Saldo', 'Saldo atual', Icons.savings_outlined, 'balance', '/home/finance/balance'),
    _Entry('Receitas', 'Entradas', Icons.trending_up, 'revenues', '/home/finance/revenues'),
    _Entry('Despesas', 'Saídas', Icons.trending_down, 'expenses', '/home/finance/expenses'),
    _Entry('Transações', 'Lançamentos financeiros', Icons.swap_horiz_rounded, 'transactions', '/home/finance/transactions'),
    _Entry('Pagamentos', 'Pagamentos realizados', Icons.payment_outlined, 'payments', '/home/finance/payments'),
    _Entry('Contas bancárias', 'Contas e bancos', Icons.account_balance_outlined, 'bank-accounts', '/home/finance/bank-accounts'),
    _Entry('Categorias', 'Classificação', Icons.category_outlined, 'categories', '/home/finance/categories'),
    _Entry('Centros de custo', 'Rateio de custos', Icons.hub_outlined, 'cost-centers', '/home/finance/cost-centers'),
    _Entry('Fornecedores', 'Cadastro de fornecedores', Icons.storefront_outlined, 'suppliers', '/home/finance/suppliers'),
    _Entry('Contratos', 'Contratos financeiros', Icons.handshake_outlined, 'contracts', '/home/finance/contracts'),
    _Entry('Reembolsos', 'Solicitações de reembolso', Icons.replay_outlined, 'refunds', '/home/finance/refunds'),
    _Entry('Adiantamentos', 'Adiantamentos', Icons.payments_outlined, 'advances', '/home/finance/advances'),
    _Entry('Verbas', 'Verbas do mandato', Icons.paid_outlined, 'funds', '/home/finance/funds'),
    _Entry('Orçamento', 'Planejamento orçamentário', Icons.pie_chart_outline, 'budget', '/home/finance/budget'),
    _Entry('Execução orçamentária', 'Acompanhamento', Icons.ssid_chart, 'budget-execution', '/home/finance/budget-execution'),
    _Entry('Prestação de contas', 'Prestação de contas', Icons.fact_check_outlined, 'accountability', '/home/finance/accountability'),
    _Entry('Comprovantes', 'Comprovantes fiscais', Icons.receipt_long_outlined, 'receipts', '/home/finance/receipts'),
    _Entry('Anexos', 'Arquivos vinculados', Icons.attach_file_rounded, 'attachments', '/home/finance/attachments'),
    _Entry('Aprovações', 'Fluxo de aprovação', Icons.verified_outlined, 'approvals', '/home/finance/approvals'),
    _Entry('Conciliação', 'Conciliação bancária', Icons.compare_arrows, 'reconciliation', '/home/finance/reconciliation'),
    _Entry('Fluxo de caixa', 'Entradas e saídas', Icons.waterfall_chart, 'cash-flow', '/home/finance/cash-flow'),
    _Entry('Contas a pagar', 'Obrigações a pagar', Icons.outbound_outlined, 'payables', '/home/finance/payables'),
    _Entry('Contas a receber', 'Valores a receber', Icons.call_received, 'receivables', '/home/finance/receivables'),
    _Entry('Alertas', 'Alertas financeiros', Icons.notifications_active_outlined, 'alerts', '/home/finance/alerts'),
    _Entry('Histórico', 'Movimentações', Icons.history_rounded, 'history', '/home/finance/history'),
    _Entry('Filtros', 'Filtros disponíveis', Icons.filter_list, 'filters', '/home/finance/filters'),
    _Entry('Pesquisa', 'Buscar lançamentos', Icons.search_rounded, 'search', '/home/finance/search'),
    _Entry('Relatórios', 'Relatórios financeiros', Icons.summarize_outlined, 'reports', '/home/finance/reports'),
    _Entry('Exportação', 'Exportar dados', Icons.file_download_outlined, 'exports', '/home/finance/exports'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão Financeira')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final body = ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              SoftNotice(
                message:
                    'Consome somente /v1/finance/*. Chip Ativo = contrato '
                    'publicado; Em preparação = aguardando a VPS.',
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisExtent: cross == 1 ? 104 : 112,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  final live = financePathLive(e.slug);
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push(e.route),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: live
                                  ? scheme.primary.withValues(alpha: 0.12)
                                  : scheme.surfaceContainerHighest,
                              child: Icon(
                                e.icon,
                                color: live
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    e.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    e.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Chip(
                              label: Text(
                                uiContractChip(available: live),
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
          if (!wide) return body;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: body,
            ),
          );
        },
      ),
    );
  }
}

class _Entry {
  const _Entry(this.title, this.subtitle, this.icon, this.slug, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String slug;
  final String route;
}

typedef FinanceListLoader =
    Future<List<FinanceItem>> Function(FinanceRepository repo, String tenant);

class FinanceListPage extends StatefulWidget {
  const FinanceListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final FinanceListLoader loader;
  final String emptyMessage;

  @override
  State<FinanceListPage> createState() => _FinanceListPageState();
}

class _FinanceListPageState extends State<FinanceListPage>
    with _FinanceRefresh {
  Future<List<FinanceItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindFinanceRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<FinanceItem>> _load() => widget.loader(
    context.read<FinanceRepository>(),
    _tenantOf(context),
  );

  void _openItem(FinanceItem item) {
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
    final dateFmt = DateFormat('dd/MM/yyyy');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (item.code != null) Text('Código: ${item.code}'),
                if (item.category != null) Text('Categoria: ${item.category}'),
                if (item.status != null)
                  Text('Situação: ${uiStatusLabel(item.status)}'),
                if (item.amount != null)
                  Text('Valor: ${money.format(item.amount)}'),
                if (item.date != null)
                  Text('Data: ${dateFmt.format(item.date!.toLocal())}'),
                if (item.summary != null) ...[
                  const SizedBox(height: 8),
                  Text(item.summary!),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<FinanceItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  SkeletonBox(height: 72, radius: 16),
                  SizedBox(height: 10),
                  SkeletonBox(height: 72, radius: 16),
                ],
              );
            }
            if (snap.error is EndpointUnavailableException) {
              final err = snap.error! as EndpointUnavailableException;
              return EndpointPendingState(
                path: err.path,
                message:
                    '${widget.title} preparado. Aguardando contrato ativo em /v1/finance.',
              );
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            var items = snap.data ?? const <FinanceItem>[];
            if (_query.trim().isNotEmpty) {
              final q = _query.trim().toLowerCase();
              items = items
                  .where(
                    (e) =>
                        '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.category ?? ''}'
                            .toLowerCase()
                            .contains(q),
                  )
                  .toList();
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(12),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Filtrar nesta lista',
                    prefixIcon: Icon(Icons.filter_list),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: AppEmptyState(message: widget.emptyMessage),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                scheme.primary.withValues(alpha: 0.12),
                            child: Icon(
                              Icons.payments_outlined,
                              color: scheme.primary,
                            ),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              if (item.code != null) item.code!,
                              if (item.category != null) item.category!,
                              if (item.status != null)
                                uiStatusLabel(item.status),
                              if (item.amount != null)
                                money.format(item.amount),
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.primary,
                          ),
                          onTap: () => _openItem(item),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage>
    with _FinanceRefresh {
  Future<FinanceDashboard>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindFinanceRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<FinanceDashboard> _load() => context
      .read<FinanceRepository>()
      .dashboard(tenantSlug: _tenantOf(context));

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel financeiro'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<FinanceDashboard>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done && !snap.hasData) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  SkeletonBox(height: 88, radius: 16),
                  SizedBox(height: 12),
                  SkeletonBox(height: 88, radius: 16),
                ],
              );
            }
            if (snap.error is EndpointUnavailableException) {
              final err = snap.error! as EndpointUnavailableException;
              return EndpointPendingState(
                path: err.path,
                message:
                    'Painel financeiro preparado. Aguardando /v1/finance/dashboard.',
              );
            }
            if (snap.hasError) {
              return AppErrorState(error: snap.error, onRetry: _reload);
            }
            final d = snap.data!;
            final cards = <(String, String, IconData, String)>[
              ('Saldo', money.format(d.balance), Icons.savings_outlined, '/home/finance/balance'),
              ('Receitas', money.format(d.revenues), Icons.trending_up, '/home/finance/revenues'),
              ('Despesas', money.format(d.expenses), Icons.trending_down, '/home/finance/expenses'),
              ('A pagar', money.format(d.payables), Icons.outbound_outlined, '/home/finance/payables'),
              ('A receber', money.format(d.receivables), Icons.call_received, '/home/finance/receivables'),
              ('Alertas', '${d.alerts}', Icons.notifications_active_outlined, '/home/finance/alerts'),
            ];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                if (d.fromCache)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SoftNotice(
                      message:
                          'Dados salvos ${d.cacheAgeLabel ?? ''}. Puxe para atualizar.',
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, box) {
                    final cols = box.maxWidth >= 600 ? 3 : 2;
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: box.maxWidth < 380 ? 1.15 : 1.35,
                      children: [
                        for (final (label, value, icon, route) in cards)
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.push(route),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(icon, size: 20, color: scheme.primary),
                                        const Spacer(),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: scheme.primary,
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        value,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FinanceSearchPage extends StatefulWidget {
  const FinanceSearchPage({super.key});

  @override
  State<FinanceSearchPage> createState() => _FinanceSearchPageState();
}

class _FinanceSearchPageState extends State<FinanceSearchPage>
    with _FinanceRefresh {
  final _ctrl = TextEditingController();
  Future<List<FinanceItem>>? _future;
  String _last = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindFinanceRefresh(() {
      if (_last.trim().length >= 2) {
        setState(() => _future = _search(_last));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<List<FinanceItem>> _search(String q) => context
      .read<FinanceRepository>()
      .search(tenantSlug: _tenantOf(context), query: q);

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa financeira')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Descrição, fornecedor, categoria…',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                final q = v.trim();
                if (q.length < 2) {
                  setState(() {
                    _future = null;
                    _last = '';
                  });
                  return;
                }
                setState(() {
                  _last = q;
                  _future = _search(q);
                });
              },
            ),
          ),
          Expanded(
            child: _future == null
                ? const AppEmptyState(
                    message: 'Digite ao menos 2 caracteres para pesquisar.',
                    icon: Icons.search_rounded,
                  )
                : FutureBuilder<List<FinanceItem>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.error is EndpointUnavailableException) {
                        final err =
                            snap.error! as EndpointUnavailableException;
                        return EndpointPendingState(
                          path: err.path,
                          message:
                              'Pesquisa preparada. Aguardando /v1/finance/search.',
                        );
                      }
                      if (snap.hasError) {
                        return AppErrorState(
                          error: snap.error,
                          onRetry: () =>
                              setState(() => _future = _search(_last)),
                        );
                      }
                      final items = snap.data ?? const <FinanceItem>[];
                      if (items.isEmpty) {
                        return const AppEmptyState(
                          message: 'Nenhum lançamento encontrado.',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              title: Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  if (item.category != null) item.category!,
                                  if (item.amount != null)
                                    money.format(item.amount),
                                ].join(' · '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context.push('/home/finance/history'),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
