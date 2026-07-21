import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/demo/demo_experience_pane.dart';
import '../../../shared/widgets/pg_design_system.dart';

import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/admin_contracts.dart';
import '../data/admin_models.dart';
import '../data/admin_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

mixin _AdminRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindAdminRefresh(VoidCallback reload) {
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

/// Hub — Administração do Sistema (Fase 19).
class AdminHubPage extends StatelessWidget {
  const AdminHubPage({super.key});

  static const _entries = <_Entry>[
    _Entry(
      'Painel administrativo',
      'Visão geral da plataforma',
      Icons.dashboard_outlined,
      'dashboard',
      '/home/system-admin/dashboard',
    ),
    _Entry(
      'Empresas',
      'Cadastro de empresas',
      Icons.business_outlined,
      'companies',
      '/home/system-admin/companies',
    ),
    _Entry(
      'Gabinetes',
      'Gabinetes e mandatos',
      Icons.account_balance_outlined,
      'offices',
      '/home/system-admin/offices',
    ),
    _Entry(
      'Usuários',
      'Usuários do sistema',
      Icons.person_outline,
      'users',
      '/home/system-admin/users',
    ),
    _Entry(
      'Perfis',
      'Perfis de acesso',
      Icons.badge_outlined,
      'profiles',
      '/home/system-admin/profiles',
    ),
    _Entry(
      'Papéis',
      'Papéis e funções',
      Icons.work_outline,
      'roles',
      '/home/system-admin/roles',
    ),
    _Entry(
      'Permissões',
      'Permissões granulares',
      Icons.lock_outline,
      'permissions',
      '/home/system-admin/permissions',
    ),
    _Entry(
      'Equipes',
      'Equipes operacionais',
      Icons.groups_outlined,
      'teams',
      '/home/system-admin/teams',
    ),
    _Entry(
      'Departamentos',
      'Departamentos organizacionais',
      Icons.domain_outlined,
      'departments',
      '/home/system-admin/departments',
    ),
    _Entry(
      'Configurações',
      'Parâmetros gerais',
      Icons.settings_outlined,
      'settings',
      '/home/system-admin/settings',
    ),
    _Entry(
      'Licenciamento',
      'Licenças e planos',
      Icons.verified_outlined,
      'licensing',
      '/home/system-admin/licensing',
    ),
    _Entry(
      'Assinaturas',
      'Assinaturas ativas',
      Icons.subscriptions_outlined,
      'subscriptions',
      '/home/system-admin/subscriptions',
    ),
    _Entry(
      'Registros',
      'Registros do sistema',
      Icons.receipt_long_outlined,
      'logs',
      '/home/system-admin/logs',
    ),
    _Entry(
      'Auditoria',
      'Trilha de auditoria',
      Icons.fact_check_outlined,
      'audit',
      '/home/system-admin/audit',
    ),
    _Entry(
      'Sessões',
      'Sessões ativas',
      Icons.devices_outlined,
      'sessions',
      '/home/system-admin/sessions',
    ),
    _Entry(
      'Chaves de API',
      'Chaves de integração',
      Icons.vpn_key_outlined,
      'api-keys',
      '/home/system-admin/api-keys',
    ),
    _Entry(
      'Integrações',
      'Integrações externas',
      Icons.extension_outlined,
      'integrations',
      '/home/system-admin/integrations',
    ),
    _Entry(
      'Webhooks',
      'Webhooks configurados',
      Icons.webhook_outlined,
      'webhooks',
      '/home/system-admin/webhooks',
    ),
    _Entry(
      'Cópia de segurança',
      'Backups e restauração',
      Icons.backup_outlined,
      'backup',
      '/home/system-admin/backup',
    ),
    _Entry(
      'Monitoramento',
      'Monitoramento da plataforma',
      Icons.monitor_heart_outlined,
      'monitoring',
      '/home/system-admin/monitoring',
    ),
    _Entry(
      'Saúde do sistema',
      'Indicadores de saúde',
      Icons.health_and_safety_outlined,
      'health',
      '/home/system-admin/health',
    ),
    _Entry(
      'Configuração de e-mail',
      'Servidor e envio de e-mail',
      Icons.email_outlined,
      'email-settings',
      '/home/system-admin/email-settings',
    ),
    _Entry(
      'Configuração de notificações',
      'Canais e preferências',
      Icons.notifications_outlined,
      'notification-settings',
      '/home/system-admin/notification-settings',
    ),
    _Entry(
      'Configuração de armazenamento',
      'Armazenamento e quotas',
      Icons.storage_outlined,
      'storage-settings',
      '/home/system-admin/storage-settings',
    ),
    _Entry(
      'Relatórios',
      'Relatórios administrativos',
      Icons.summarize_outlined,
      'reports',
      '/home/system-admin/reports',
    ),
    _Entry(
      'Exportações',
      'Exportar dados',
      Icons.download_outlined,
      'exports',
      '/home/system-admin/exports',
    ),
    _Entry(
      'Pesquisa',
      'Buscar na administração',
      Icons.search_rounded,
      'search',
      '/home/system-admin/search',
    ),
    _Entry(
      'Filtros',
      'Filtros disponíveis',
      Icons.filter_list,
      'filters',
      '/home/system-admin/filters',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Administração do Sistema')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          final body = ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              SoftNotice(
                message:
                    'Chip Ativo = contrato publicado; Demonstração = conteúdo ilustrativo. '
                    'contrato Ativo = contrato publicado; Demonstração = conteúdo ilustrativo.',
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisExtent: PgHubModuleTile.gridExtent(crossAxisCount: cross),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  final live = adminPathLive(e.slug);
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
                                    maxLines: 3,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    e.subtitle,
                                    maxLines: 3,
                                    softWrap: true,
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

typedef AdminListLoader =
    Future<List<AdminItem>> Function(AdminRepository repo, String tenant);

class AdminListPage extends StatefulWidget {
  const AdminListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
  });

  final String title;
  final AdminListLoader loader;
  final String emptyMessage;

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> with _AdminRefresh {
  Future<List<AdminItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAdminRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<AdminItem>> _load() =>
      widget.loader(context.read<AdminRepository>(), _tenantOf(context));

  void _openItem(AdminItem item) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 2, softWrap: true),
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
        child: FutureBuilder<List<AdminItem>>(
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
              return DemoExperiencePane(path: err.path);
            }
            if (snap.hasError) {
              return AppErrorState(
                error: snap.error,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            var items = snap.data ?? const <AdminItem>[];
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
      ),
    );
  }
}

class AdminSearchPage extends StatefulWidget {
  const AdminSearchPage({super.key});

  @override
  State<AdminSearchPage> createState() => _AdminSearchPageState();
}

class _AdminSearchPageState extends State<AdminSearchPage> with _AdminRefresh {
  final _ctrl = TextEditingController();
  Future<List<AdminItem>>? _future;
  String _last = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindAdminRefresh(() {
      if (_last.length >= 2) {
        setState(() => _future = _search(_last));
      }
    });
  }

  Future<List<AdminItem>> _search(String q) => context
      .read<AdminRepository>()
      .search(tenantSlug: _tenantOf(context), query: q);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa')),
      body: Column(
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
                : FutureBuilder<List<AdminItem>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.error is EndpointUnavailableException) {
                        final err =
                            snap.error! as EndpointUnavailableException;
                        return DemoExperiencePane(path: err.path);
                      }
                      if (snap.hasError) {
                        return AppErrorState(
                          error: snap.error,
                          onRetry: () =>
                              setState(() => _future = _search(_last)),
                        );
                      }
                      final items = snap.data ?? const <AdminItem>[];
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
                              onTap: () =>
                                  context.push('/home/system-admin/users'),
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
