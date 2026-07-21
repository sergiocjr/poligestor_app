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
import '../data/platform_contracts.dart';
import '../data/platform_models.dart';
import '../data/platform_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

/// Títulos PT-BR por slug de rota (`/platform/{slug}`).
const platformSlugTitles = <String, String>{
  'dashboard': 'Painel geral',
  'companies': 'Empresas',
  'offices': 'Gabinetes',
  'users': 'Usuários',
  'profiles': 'Perfis e permissões',
  'plans': 'Planos',
  'licensing': 'Licenciamento',
  'subscriptions': 'Assinaturas',
  'charges': 'Cobranças',
  'invoices': 'Faturas',
  'payments': 'Pagamentos',
  'consumption': 'Consumo por gabinete',
  'plan-limits': 'Limites dos planos',
  'metrics': 'Métricas',
  'monitoring': 'Monitoramento',
  'health': 'Saúde dos serviços',
  'logs': 'Registros',
  'audit': 'Auditoria',
  'sessions': 'Sessões',
  'integrations': 'Integrações',
  'webhooks': 'Webhooks',
  'global-settings': 'Configurações globais',
  'tenant-settings': 'Configurações por tenant',
  'support': 'Suporte',
  'tickets': 'Chamados',
  'knowledge-base': 'Base de conhecimento',
  'announcements': 'Comunicados',
  'releases': 'Versões',
  'maintenances': 'Manutenções',
  'reports': 'Relatórios',
  'exports': 'Exportações',
  'search': 'Busca',
  'filters': 'Filtros',
};

mixin _PlatformRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindPlatformRefresh(VoidCallback reload) {
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

class _HubEntry {
  const _HubEntry(
    this.title,
    this.subtitle,
    this.icon,
    this.slug,
    this.route,
  );
  final String title;
  final String subtitle;
  final IconData icon;
  final String slug;
  final String route;
}

const _hubEntries = <_HubEntry>[
  _HubEntry(
    'Painel geral',
    'Indicadores da plataforma',
    Icons.dashboard_outlined,
    'dashboard',
    '/platform/dashboard',
  ),
  _HubEntry(
    'Empresas',
    'Cadastro de empresas',
    Icons.business_outlined,
    'companies',
    '/platform/companies',
  ),
  _HubEntry(
    'Gabinetes',
    'Gabinetes e mandatos',
    Icons.account_balance_outlined,
    'offices',
    '/platform/offices',
  ),
  _HubEntry(
    'Usuários',
    'Usuários da plataforma',
    Icons.person_outline,
    'users',
    '/platform/users',
  ),
  _HubEntry(
    'Perfis e permissões',
    'Perfis de acesso e permissões (/v1/platform/permissions)',
    Icons.badge_outlined,
    'profiles',
    '/platform/profiles',
  ),
  _HubEntry(
    'Planos',
    'Planos comerciais',
    Icons.layers_outlined,
    'plans',
    '/platform/plans',
  ),
  _HubEntry(
    'Licenciamento',
    'Licenças ativas',
    Icons.verified_outlined,
    'licensing',
    '/platform/licensing',
  ),
  _HubEntry(
    'Assinaturas',
    'Assinaturas de clientes',
    Icons.subscriptions_outlined,
    'subscriptions',
    '/platform/subscriptions',
  ),
  _HubEntry(
    'Cobranças',
    'Cobranças em aberto',
    Icons.request_quote_outlined,
    'charges',
    '/platform/charges',
  ),
  _HubEntry(
    'Faturas',
    'Faturas emitidas',
    Icons.receipt_long_outlined,
    'invoices',
    '/platform/invoices',
  ),
  _HubEntry(
    'Pagamentos',
    'Pagamentos recebidos',
    Icons.payment_outlined,
    'payments',
    '/platform/payments',
  ),
  _HubEntry(
    'Consumo por gabinete',
    'Uso e consumo por gabinete',
    Icons.data_usage_outlined,
    'consumption',
    '/platform/consumption',
  ),
  _HubEntry(
    'Limites dos planos',
    'Limites e quotas por plano',
    Icons.speed_outlined,
    'plan-limits',
    '/platform/plan-limits',
  ),
  _HubEntry(
    'Métricas',
    'Métricas operacionais',
    Icons.analytics_outlined,
    'metrics',
    '/platform/metrics',
  ),
  _HubEntry(
    'Monitoramento',
    'Monitoramento da plataforma',
    Icons.monitor_heart_outlined,
    'monitoring',
    '/platform/monitoring',
  ),
  _HubEntry(
    'Saúde dos serviços',
    'Indicadores de saúde',
    Icons.health_and_safety_outlined,
    'health',
    '/platform/health',
  ),
  _HubEntry(
    'Registros',
    'Registros da plataforma',
    Icons.receipt_long_outlined,
    'logs',
    '/platform/logs',
  ),
  _HubEntry(
    'Auditoria',
    'Trilha de auditoria',
    Icons.fact_check_outlined,
    'audit',
    '/platform/audit',
  ),
  _HubEntry(
    'Sessões',
    'Sessões ativas',
    Icons.devices_outlined,
    'sessions',
    '/platform/sessions',
  ),
  _HubEntry(
    'Integrações',
    'Integrações externas',
    Icons.extension_outlined,
    'integrations',
    '/platform/integrations',
  ),
  _HubEntry(
    'Webhooks',
    'Webhooks configurados',
    Icons.webhook_outlined,
    'webhooks',
    '/platform/webhooks',
  ),
  _HubEntry(
    'Configurações globais',
    'Parâmetros globais da plataforma',
    Icons.settings_outlined,
    'global-settings',
    '/platform/global-settings',
  ),
  _HubEntry(
    'Configurações por tenant',
    'Parâmetros por organização',
    Icons.tune_outlined,
    'tenant-settings',
    '/platform/tenant-settings',
  ),
  _HubEntry(
    'Suporte',
    'Central de suporte',
    Icons.support_agent_outlined,
    'support',
    '/platform/support',
  ),
  _HubEntry(
    'Chamados',
    'Chamados de suporte',
    Icons.confirmation_number_outlined,
    'tickets',
    '/platform/tickets',
  ),
  _HubEntry(
    'Base de conhecimento',
    'Artigos e procedimentos',
    Icons.menu_book_outlined,
    'knowledge-base',
    '/platform/knowledge-base',
  ),
  _HubEntry(
    'Comunicados',
    'Comunicados da plataforma',
    Icons.campaign_outlined,
    'announcements',
    '/platform/announcements',
  ),
  _HubEntry(
    'Versões',
    'Versões publicadas',
    Icons.new_releases_outlined,
    'releases',
    '/platform/releases',
  ),
  _HubEntry(
    'Manutenções',
    'Janelas de manutenção',
    Icons.build_circle_outlined,
    'maintenances',
    '/platform/maintenances',
  ),
  _HubEntry(
    'Relatórios',
    'Relatórios administrativos',
    Icons.summarize_outlined,
    'reports',
    '/platform/reports',
  ),
  _HubEntry(
    'Exportações',
    'Exportar dados',
    Icons.download_outlined,
    'exports',
    '/platform/exports',
  ),
  _HubEntry(
    'Busca',
    'Busca global da plataforma',
    Icons.search_rounded,
    'search',
    '/platform/search',
  ),
  _HubEntry(
    'Filtros',
    'Filtros disponíveis',
    Icons.filter_list,
    'filters',
    '/platform/filters',
  ),
];

/// Hub — Portal Administrativo Web (Fase 20).
class PlatformHubPage extends StatelessWidget {
  const PlatformHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            SoftNotice(
              message:
                  'Namespace /v1/platform/* sincronizado. Chip Ativo = contrato '
                  'Ativo = contrato publicado; Demonstração = conteúdo ilustrativo.',
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
              itemCount: _hubEntries.length,
              itemBuilder: (context, i) {
                final e = _hubEntries[i];
                final live = platformPathLive(e.slug);
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall,
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
      },
    );
  }
}

typedef PlatformListLoader =
    Future<List<PlatformItem>> Function(PlatformRepository repo, String tenant);

class PlatformListPage extends StatefulWidget {
  const PlatformListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
    this.extraNotice,
  });

  final String title;
  final PlatformListLoader loader;
  final String emptyMessage;
  final String? extraNotice;

  @override
  State<PlatformListPage> createState() => _PlatformListPageState();
}

class _PlatformListPageState extends State<PlatformListPage>
    with _PlatformRefresh {
  Future<List<PlatformItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindPlatformRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<PlatformItem>> _load() =>
      widget.loader(context.read<PlatformRepository>(), _tenantOf(context));

  void _openItem(PlatformItem item) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
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
                if (item.email != null) Text('E-mail: ${item.email}'),
                if (item.scope != null) Text('Escopo: ${item.scope}'),
                if (item.kind != null) Text('Tipo: ${item.kind}'),
                if (item.status != null)
                  Text('Situação: ${uiStatusLabel(item.status)}'),
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
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _future = _load());
        await _future;
      },
      child: FutureBuilder<List<PlatformItem>>(
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
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                EndpointPendingState(
                  path: err.path,
                  message:
                      '${widget.title} preparado. Aguardando contrato ativo '
                      'em /v1/platform.',
                ),
              ],
            );
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                AppErrorState(
                  error: snap.error,
                  onRetry: () => setState(() => _future = _load()),
                ),
              ],
            );
          }
          var items = snap.data ?? const <PlatformItem>[];
          if (_query.trim().isNotEmpty) {
            final q = _query.trim().toLowerCase();
            items = items
                .where(
                  (e) =>
                      '${e.code ?? ''} ${e.title} ${e.summary ?? ''} ${e.email ?? ''} ${e.scope ?? ''}'
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
              if (widget.extraNotice != null) ...[
                SoftNotice(message: widget.extraNotice!),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Atualizar',
                    onPressed: () => setState(() => _future = _load()),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Filtrar nesta lista…',
                  prefixIcon: Icon(Icons.filter_list),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: AppEmptyState(
                    message: widget.emptyMessage,
                    icon: Icons.inbox_outlined,
                  ),
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_outlined,
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
                            if (item.scope != null) item.scope!,
                            if (item.email != null) item.email!,
                            if (item.status != null)
                              uiStatusLabel(item.status),
                          ].where((s) => s.isNotEmpty).join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openItem(item),
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

class PlatformSearchPage extends StatefulWidget {
  const PlatformSearchPage({super.key});

  @override
  State<PlatformSearchPage> createState() => _PlatformSearchPageState();
}

class _PlatformSearchPageState extends State<PlatformSearchPage>
    with _PlatformRefresh {
  final _ctrl = TextEditingController();
  Future<List<PlatformItem>>? _future;
  String _last = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindPlatformRefresh(() {
      if (_last.length >= 2) {
        setState(() => _future = _search(_last));
      }
    });
  }

  Future<List<PlatformItem>> _search(String q) => context
      .read<PlatformRepository>()
      .search(tenantSlug: _tenantOf(context), query: q);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Nome, e-mail, código…',
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
              : FutureBuilder<List<PlatformItem>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.error is EndpointUnavailableException) {
                      final err = snap.error! as EndpointUnavailableException;
                      return EndpointPendingState(
                        path: err.path,
                        message:
                            'Busca preparada. Aguardando /v1/platform/search.',
                      );
                    }
                    if (snap.hasError) {
                      return AppErrorState(
                        error: snap.error,
                        onRetry: () =>
                            setState(() => _future = _search(_last)),
                      );
                    }
                    final items = snap.data ?? const <PlatformItem>[];
                    if (items.isEmpty) {
                      return const AppEmptyState(
                        message: 'Nenhum item encontrado.',
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
                              item.scope ?? item.summary ?? item.email ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Rotas filhas de `/platform` para o ShellRoute.
List<RouteBase> buildPlatformChildRoutes() => [
  GoRoute(
    path: 'dashboard',
    builder: (_, _) => PlatformListPage(
      title: 'Painel geral',
      emptyMessage: 'Nenhum indicador no painel.',
      loader: (repo, tenant) => repo.dashboard(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'companies',
    builder: (_, _) => PlatformListPage(
      title: 'Empresas',
      emptyMessage: 'Nenhuma empresa encontrada.',
      loader: (repo, tenant) => repo.companies(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'offices',
    builder: (_, _) => PlatformListPage(
      title: 'Gabinetes',
      emptyMessage: 'Nenhum gabinete encontrado.',
      loader: (repo, tenant) => repo.offices(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'users',
    builder: (_, _) => PlatformListPage(
      title: 'Usuários',
      emptyMessage: 'Nenhum usuário encontrado.',
      loader: (repo, tenant) => repo.users(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'profiles',
    builder: (_, _) => PlatformListPage(
      title: 'Perfis e permissões',
      emptyMessage: 'Nenhum perfil encontrado.',
      extraNotice:
          'Permissões granulares em /v1/platform/permissions quando o '
          'contrato estiver ativo.',
      loader: (repo, tenant) => repo.profiles(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'plans',
    builder: (_, _) => PlatformListPage(
      title: 'Planos',
      emptyMessage: 'Nenhum plano encontrado.',
      loader: (repo, tenant) => repo.plans(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'licensing',
    builder: (_, _) => PlatformListPage(
      title: 'Licenciamento',
      emptyMessage: 'Nenhuma licença encontrada.',
      loader: (repo, tenant) => repo.licensing(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'subscriptions',
    builder: (_, _) => PlatformListPage(
      title: 'Assinaturas',
      emptyMessage: 'Nenhuma assinatura encontrada.',
      loader: (repo, tenant) => repo.subscriptions(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'charges',
    builder: (_, _) => PlatformListPage(
      title: 'Cobranças',
      emptyMessage: 'Nenhuma cobrança encontrada.',
      loader: (repo, tenant) => repo.charges(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'invoices',
    builder: (_, _) => PlatformListPage(
      title: 'Faturas',
      emptyMessage: 'Nenhuma fatura encontrada.',
      loader: (repo, tenant) => repo.invoices(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'payments',
    builder: (_, _) => PlatformListPage(
      title: 'Pagamentos',
      emptyMessage: 'Nenhum pagamento encontrado.',
      loader: (repo, tenant) => repo.payments(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'consumption',
    builder: (_, _) => PlatformListPage(
      title: 'Consumo por gabinete',
      emptyMessage: 'Nenhum registro de consumo.',
      loader: (repo, tenant) => repo.consumption(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'plan-limits',
    builder: (_, _) => PlatformListPage(
      title: 'Limites dos planos',
      emptyMessage: 'Nenhum limite configurado.',
      loader: (repo, tenant) => repo.planLimits(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'metrics',
    builder: (_, _) => PlatformListPage(
      title: 'Métricas',
      emptyMessage: 'Nenhuma métrica disponível.',
      loader: (repo, tenant) => repo.metrics(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'monitoring',
    builder: (_, _) => PlatformListPage(
      title: 'Monitoramento',
      emptyMessage: 'Nenhum dado de monitoramento.',
      loader: (repo, tenant) => repo.monitoring(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'health',
    builder: (_, _) => PlatformListPage(
      title: 'Saúde dos serviços',
      emptyMessage: 'Nenhum indicador de saúde.',
      loader: (repo, tenant) => repo.health(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'logs',
    builder: (_, _) => PlatformListPage(
      title: 'Registros',
      emptyMessage: 'Nenhum registro encontrado.',
      loader: (repo, tenant) => repo.logs(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'audit',
    builder: (_, _) => PlatformListPage(
      title: 'Auditoria',
      emptyMessage: 'Nenhum evento de auditoria.',
      loader: (repo, tenant) => repo.audit(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'sessions',
    builder: (_, _) => PlatformListPage(
      title: 'Sessões',
      emptyMessage: 'Nenhuma sessão ativa.',
      loader: (repo, tenant) => repo.sessions(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'integrations',
    builder: (_, _) => PlatformListPage(
      title: 'Integrações',
      emptyMessage: 'Nenhuma integração configurada.',
      loader: (repo, tenant) => repo.integrations(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'webhooks',
    builder: (_, _) => PlatformListPage(
      title: 'Webhooks',
      emptyMessage: 'Nenhum webhook configurado.',
      loader: (repo, tenant) => repo.webhooks(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'global-settings',
    builder: (_, _) => PlatformListPage(
      title: 'Configurações globais',
      emptyMessage: 'Nenhuma configuração global.',
      loader: (repo, tenant) => repo.globalSettings(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'tenant-settings',
    builder: (_, _) => PlatformListPage(
      title: 'Configurações por tenant',
      emptyMessage: 'Nenhuma configuração por tenant.',
      loader: (repo, tenant) => repo.tenantSettings(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'support',
    builder: (_, _) => PlatformListPage(
      title: 'Suporte',
      emptyMessage: 'Nenhum item de suporte.',
      loader: (repo, tenant) => repo.support(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'tickets',
    builder: (_, _) => PlatformListPage(
      title: 'Chamados',
      emptyMessage: 'Nenhum chamado encontrado.',
      loader: (repo, tenant) => repo.tickets(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'knowledge-base',
    builder: (_, _) => PlatformListPage(
      title: 'Base de conhecimento',
      emptyMessage: 'Nenhum artigo encontrado.',
      loader: (repo, tenant) => repo.knowledgeBase(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'announcements',
    builder: (_, _) => PlatformListPage(
      title: 'Comunicados',
      emptyMessage: 'Nenhum comunicado encontrado.',
      loader: (repo, tenant) => repo.announcements(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'releases',
    builder: (_, _) => PlatformListPage(
      title: 'Versões',
      emptyMessage: 'Nenhuma release encontrada.',
      loader: (repo, tenant) => repo.releases(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'maintenances',
    builder: (_, _) => PlatformListPage(
      title: 'Manutenções',
      emptyMessage: 'Nenhuma manutenção agendada.',
      loader: (repo, tenant) => repo.maintenances(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'reports',
    builder: (_, _) => PlatformListPage(
      title: 'Relatórios',
      emptyMessage: 'Nenhum relatório encontrado.',
      loader: (repo, tenant) => repo.reports(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'exports',
    builder: (_, _) => PlatformListPage(
      title: 'Exportações',
      emptyMessage: 'Nenhuma exportação encontrada.',
      loader: (repo, tenant) => repo.exports(tenantSlug: tenant),
    ),
  ),
  GoRoute(
    path: 'search',
    builder: (_, _) => const PlatformSearchPage(),
  ),
  GoRoute(
    path: 'filters',
    builder: (_, _) => PlatformListPage(
      title: 'Filtros',
      emptyMessage: 'Nenhum filtro disponível.',
      loader: (repo, tenant) => repo.filters(tenantSlug: tenant),
    ),
  ),
];
