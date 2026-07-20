import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/integrations_contracts.dart';
import '../data/integrations_models.dart';
import '../data/integrations_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

AuthMode _modeOf(BuildContext context) =>
    context.read<AuthController>().mode;

/// Títulos PT-BR por slug de rota (`/home/integrations/{slug}`).
const integrationsSlugTitles = <String, String>{
  'dashboard': 'Painel',
  'status': 'Status das integrações',
  'config': 'Configuração',
  'sync': 'Sincronizações',
  'history': 'Histórico',
  'logs': 'Registros',
  'govbr': 'Gov.br',
  'camara-municipal': 'Câmara Municipal',
  'assembleia-legislativa': 'Assembleia Legislativa',
  'camara-deputados': 'Câmara dos Deputados',
  'senado-federal': 'Senado Federal',
  'diario-oficial': 'Diário Oficial',
  'portal-transparencia': 'Portal da Transparência',
  'e-sic': 'e-SIC',
  'ouvidoria': 'Ouvidoria',
  'google-calendar': 'Google Calendar',
  'outlook-calendar': 'Outlook Calendar',
  'gmail': 'Gmail',
  'whatsapp': 'WhatsApp',
  'telegram': 'Telegram',
  'firebase-push': 'Firebase Push',
  'external-apis': 'APIs externas',
  'webhooks': 'Webhooks',
  'search': 'Pesquisa',
  'filters': 'Filtros',
};

mixin _IntegrationsRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindIntegrationsRefresh(VoidCallback reload) {
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
    'Painel',
    'Visão geral das integrações',
    Icons.dashboard_outlined,
    'dashboard',
    '/home/integrations/dashboard',
  ),
  _HubEntry(
    'Status das integrações',
    'Conexões e disponibilidade',
    Icons.monitor_heart_outlined,
    'status',
    '/home/integrations/status',
  ),
  _HubEntry(
    'Configuração',
    'Parâmetros das integrações',
    Icons.settings_outlined,
    'config',
    '/home/integrations/config',
  ),
  _HubEntry(
    'Sincronizações',
    'Filas e disparos de sincronização',
    Icons.sync_outlined,
    'sync',
    '/home/integrations/sync',
  ),
  _HubEntry(
    'Histórico',
    'Eventos de integração',
    Icons.history_outlined,
    'history',
    '/home/integrations/history',
  ),
  _HubEntry(
    'Registros',
    'Registros técnicos',
    Icons.receipt_long_outlined,
    'logs',
    '/home/integrations/logs',
  ),
  _HubEntry(
    'Gov.br',
    'Integração Gov.br',
    Icons.account_balance_outlined,
    'govbr',
    '/home/integrations/govbr',
  ),
  _HubEntry(
    'Câmara Municipal',
    'Dados da Câmara Municipal',
    Icons.location_city_outlined,
    'camara-municipal',
    '/home/integrations/camara-municipal',
  ),
  _HubEntry(
    'Assembleia Legislativa',
    'Dados da Assembleia',
    Icons.account_balance,
    'assembleia-legislativa',
    '/home/integrations/assembleia-legislativa',
  ),
  _HubEntry(
    'Câmara dos Deputados',
    'Integração federal',
    Icons.gavel_outlined,
    'camara-deputados',
    '/home/integrations/camara-deputados',
  ),
  _HubEntry(
    'Senado Federal',
    'Integração Senado',
    Icons.balance_outlined,
    'senado-federal',
    '/home/integrations/senado-federal',
  ),
  _HubEntry(
    'Diário Oficial',
    'Publicações oficiais',
    Icons.menu_book_outlined,
    'diario-oficial',
    '/home/integrations/diario-oficial',
  ),
  _HubEntry(
    'Portal da Transparência',
    'Dados de transparência',
    Icons.visibility_outlined,
    'portal-transparencia',
    '/home/integrations/portal-transparencia',
  ),
  _HubEntry(
    'e-SIC',
    'Sistema de informação ao cidadão',
    Icons.info_outline,
    'e-sic',
    '/home/integrations/e-sic',
  ),
  _HubEntry(
    'Ouvidoria',
    'Canal de ouvidoria',
    Icons.record_voice_over_outlined,
    'ouvidoria',
    '/home/integrations/ouvidoria',
  ),
  _HubEntry(
    'Google Calendar',
    'Agenda Google',
    Icons.calendar_month_outlined,
    'google-calendar',
    '/home/integrations/google-calendar',
  ),
  _HubEntry(
    'Outlook Calendar',
    'Agenda Outlook',
    Icons.event_available_outlined,
    'outlook-calendar',
    '/home/integrations/outlook-calendar',
  ),
  _HubEntry(
    'Gmail',
    'Correio Gmail',
    Icons.mail_outline,
    'gmail',
    '/home/integrations/gmail',
  ),
  _HubEntry(
    'WhatsApp',
    'Canal WhatsApp',
    Icons.chat_outlined,
    'whatsapp',
    '/home/integrations/whatsapp',
  ),
  _HubEntry(
    'Telegram',
    'Canal Telegram',
    Icons.send_outlined,
    'telegram',
    '/home/integrations/telegram',
  ),
  _HubEntry(
    'Firebase Push',
    'Notificações push',
    Icons.notifications_active_outlined,
    'firebase-push',
    '/home/integrations/firebase-push',
  ),
  _HubEntry(
    'APIs externas',
    'Conectores externos',
    Icons.extension_outlined,
    'external-apis',
    '/home/integrations/external-apis',
  ),
  _HubEntry(
    'Webhooks',
    'Entrada e saída de webhooks',
    Icons.webhook_outlined,
    'webhooks',
    '/home/integrations/webhooks',
  ),
  _HubEntry(
    'Pesquisa',
    'Buscar integrações',
    Icons.search,
    'search',
    '/home/integrations/search',
  ),
  _HubEntry(
    'Filtros',
    'Filtros disponíveis',
    Icons.filter_list_outlined,
    'filters',
    '/home/integrations/filters',
  ),
];

/// Hub — Central de Integrações (Fase 22).
class IntegrationsHubPage extends StatelessWidget {
  const IntegrationsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Central de Integrações')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              const SoftNotice(
                message:
                    'Namespace /v1/integrations/* sincronizado com a VPS. '
                    'Chip Ativo = contrato publicado; Em preparação = ainda 404 '
                    '(pesquisa e filtros).',
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
                  final live = integrationsPathLive(e.slug);
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
      ),
    );
  }
}

typedef IntegrationsListLoader =
    Future<List<IntegrationItem>> Function(
      IntegrationsRepository repo,
      String tenant,
      AuthMode mode,
    );

class IntegrationsListPage extends StatefulWidget {
  const IntegrationsListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
    this.extraNotice,
    this.liveSlug,
    this.showSyncAction = false,
  });

  final String title;
  final IntegrationsListLoader loader;
  final String emptyMessage;
  final String? extraNotice;
  final String? liveSlug;
  final bool showSyncAction;

  @override
  State<IntegrationsListPage> createState() => _IntegrationsListPageState();
}

class _IntegrationsListPageState extends State<IntegrationsListPage>
    with _IntegrationsRefresh {
  Future<List<IntegrationItem>>? _future;
  String _query = '';
  bool _syncing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindIntegrationsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<IntegrationItem>> _load() => widget.loader(
    context.read<IntegrationsRepository>(),
    _tenantOf(context),
    _modeOf(context),
  );

  Future<void> _triggerSync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      await context.read<IntegrationsRepository>().triggerSync(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronização solicitada.')),
      );
      setState(() => _future = _load());
    } on EndpointUnavailableException {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível sincronizar.')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  void _openItem(IntegrationItem item) {
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
                if (item.code != null) Text('Referência: ${item.code}'),
                if (item.provider != null) Text('Provedor: ${item.provider}'),
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
    final slug = widget.liveSlug;
    if (slug != null && !integrationsPathLive(slug)) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: EndpointPendingState(
          path: _pathForSlug(slug),
          message:
              '${widget.title} preparado. Aguardando contrato ativo em '
              '/v1/integrations.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.showSyncAction)
            IconButton(
              tooltip: 'Sincronizar',
              onPressed: _syncing ? null : _triggerSync,
              icon: _syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<IntegrationItem>>(
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
                        'em /v1/integrations.',
                  ),
                ],
              );
            }
            if (snap.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  AppErrorState(
                    message: 'Não foi possível carregar ${widget.title}.',
                    onRetry: () => setState(() => _future = _load()),
                  ),
                ],
              );
            }
            var items = snap.data ?? const <IntegrationItem>[];
            if (_query.isNotEmpty) {
              final q = _query.toLowerCase();
              items = items
                  .where(
                    (i) =>
                        i.title.toLowerCase().contains(q) ||
                        (i.summary?.toLowerCase().contains(q) ?? false) ||
                        (i.provider?.toLowerCase().contains(q) ?? false),
                  )
                  .toList(growable: false);
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                if (widget.extraNotice != null) ...[
                  SoftNotice(message: widget.extraNotice!),
                  const SizedBox(height: 8),
                ],
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Filtrar nesta lista',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  AppEmptyState(message: widget.emptyMessage)
                else
                  ...items.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _openItem(item),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: scheme.primaryContainer,
                                child: Icon(
                                  Icons.hub_outlined,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (item.summary != null)
                                      Text(
                                        item.summary!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    if (item.status != null)
                                      Text(
                                        uiStatusLabel(item.status),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: scheme.primary,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
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

String _pathForSlug(String slug) {
  const m = AuthMode.staff;
  return switch (slug) {
    'dashboard' => m.integrationsDashboardPath,
    'status' => m.integrationsStatusPath,
    'config' => m.integrationsConfigPath,
    'sync' => m.integrationsSyncPath,
    'history' => m.integrationsHistoryPath,
    'logs' => m.integrationsLogsPath,
    'govbr' => m.integrationsGovbrPath,
    'camara-municipal' => m.integrationsCamaraMunicipalPath,
    'assembleia-legislativa' => m.integrationsAssembleiaLegislativaPath,
    'camara-deputados' => m.integrationsCamaraDeputadosPath,
    'senado-federal' => m.integrationsSenadoFederalPath,
    'diario-oficial' => m.integrationsDiarioOficialPath,
    'portal-transparencia' => m.integrationsPortalTransparenciaPath,
    'e-sic' => m.integrationsESicPath,
    'ouvidoria' => m.integrationsOuvidoriaPath,
    'google-calendar' => m.integrationsGoogleCalendarPath,
    'outlook-calendar' => m.integrationsOutlookCalendarPath,
    'gmail' => m.integrationsGmailPath,
    'whatsapp' => m.integrationsWhatsappPath,
    'telegram' => m.integrationsTelegramPath,
    'firebase-push' => m.integrationsFirebasePushPath,
    'external-apis' => m.integrationsExternalApisPath,
    'webhooks' => m.integrationsWebhooksPath,
    'search' => m.integrationsSearchPath,
    'filters' => m.integrationsFiltersPath,
    _ => '/v1/integrations/$slug',
  };
}

class IntegrationsConfigPage extends StatefulWidget {
  const IntegrationsConfigPage({super.key});

  @override
  State<IntegrationsConfigPage> createState() => _IntegrationsConfigPageState();
}

class _IntegrationsConfigPageState extends State<IntegrationsConfigPage>
    with _IntegrationsRefresh {
  Future<List<IntegrationItem>>? _future;
  bool _autoSync = true;
  int _retryMax = 3;
  bool _cabinetIsolation = true;
  bool _sending = false;
  String? _error;
  String? _success;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindIntegrationsRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<IntegrationItem>> _load() async {
    final items = await context.read<IntegrationsRepository>().config(
      tenantSlug: _tenantOf(context),
      mode: _modeOf(context),
    );
    for (final item in items) {
      if (item.id == 'auto_sync') {
        _autoSync = item.summary?.toLowerCase() == 'true';
      } else if (item.id == 'retry_max') {
        _retryMax = int.tryParse(item.summary ?? '') ?? _retryMax;
      } else if (item.id == 'cabinet_isolation') {
        _cabinetIsolation = item.summary?.toLowerCase() != 'false';
      }
    }
    return items;
  }

  Future<void> _submit() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _success = null;
    });
    try {
      await context.read<IntegrationsRepository>().saveConfig(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
        body: {
          'auto_sync': _autoSync,
          'retry_max': _retryMax,
          'default_mode': 'prepared',
          'cabinet_isolation': _cabinetIsolation,
        },
      );
      if (!mounted) return;
      setState(() {
        _success = 'Configuração salva com sucesso.';
        _future = _load();
      });
    } on EndpointUnavailableException {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Não foi possível salvar a configuração.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const slug = 'config';
    if (!integrationsPathLive(slug)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configuração')),
        body: EndpointPendingState(path: _pathForSlug(slug)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Configuração')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<IntegrationItem>>(
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
                children: [EndpointPendingState(path: err.path)],
              );
            }
            if (snap.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  AppErrorState(
                    message: 'Não foi possível carregar a configuração.',
                    onRetry: () => setState(() => _future = _load()),
                  ),
                ],
              );
            }
            final items = snap.data ?? const <IntegrationItem>[];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                SoftNotice(
                  message:
                      'Configuração publicada: ${_pathForSlug(slug)}.',
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Sincronização automática'),
                  value: _autoSync,
                  onChanged: (v) => setState(() => _autoSync = v),
                ),
                SwitchListTile(
                  title: const Text('Isolamento por gabinete'),
                  value: _cabinetIsolation,
                  onChanged: (v) => setState(() => _cabinetIsolation = v),
                ),
                ListTile(
                  title: const Text('Tentativas máximas'),
                  subtitle: Text('$_retryMax'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _retryMax <= 1
                            ? null
                            : () => setState(() => _retryMax--),
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton(
                        onPressed: _retryMax >= 10
                            ? null
                            : () => setState(() => _retryMax++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Salvar configuração'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (_success != null) ...[
                  const SizedBox(height: 12),
                  Text(_success!),
                ],
                const SizedBox(height: 16),
                Text(
                  'Parâmetros atuais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const AppEmptyState(message: 'Nenhuma configuração.')
                else
                  ...items.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: item.summary == null
                            ? null
                            : Text(
                                item.summary!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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

class IntegrationsSearchPage extends StatefulWidget {
  const IntegrationsSearchPage({super.key});

  @override
  State<IntegrationsSearchPage> createState() => _IntegrationsSearchPageState();
}

class _IntegrationsSearchPageState extends State<IntegrationsSearchPage>
    with _IntegrationsRefresh {
  final _ctrl = TextEditingController();
  Future<List<IntegrationItem>>? _future;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindIntegrationsRefresh(() {
      if (_ctrl.text.trim().isNotEmpty) {
        setState(() => _future = _load(_ctrl.text.trim()));
      }
    });
  }

  Future<List<IntegrationItem>> _load(String q) =>
      context.read<IntegrationsRepository>().search(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
        q: q,
      );

  @override
  Widget build(BuildContext context) {
    const slug = 'search';
    if (!integrationsPathLive(slug)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pesquisa')),
        body: EndpointPendingState(path: _pathForSlug(slug)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Pesquisar integrações',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    final q = _ctrl.text.trim();
                    if (q.isEmpty) return;
                    setState(() => _future = _load(q));
                  },
                ),
              ),
              onSubmitted: (v) {
                final q = v.trim();
                if (q.isEmpty) return;
                setState(() => _future = _load(q));
              },
            ),
          ),
          Expanded(
            child: _future == null
                ? const AppEmptyState(
                    message: 'Informe um termo para pesquisar.',
                  )
                : FutureBuilder<List<IntegrationItem>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.error is EndpointUnavailableException) {
                        final err =
                            snap.error! as EndpointUnavailableException;
                        return EndpointPendingState(path: err.path);
                      }
                      if (snap.hasError) {
                        return AppErrorState(
                          message: 'Não foi possível pesquisar.',
                          onRetry: () => setState(
                            () => _future = _load(_ctrl.text.trim()),
                          ),
                        );
                      }
                      final items = snap.data ?? const <IntegrationItem>[];
                      if (items.isEmpty) {
                        return const AppEmptyState(
                          message: 'Nenhum resultado encontrado.',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return Card(
                            child: ListTile(
                              title: Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: item.summary == null
                                  ? null
                                  : Text(
                                      item.summary!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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

List<RouteBase> buildIntegrationsChildRoutes() => [
  GoRoute(
    path: 'dashboard',
    builder: (_, _) => IntegrationsListPage(
      title: 'Painel',
      liveSlug: 'dashboard',
      emptyMessage: 'Nenhum indicador de integração.',
      extraNotice:
          'Painel e catálogo publicados (/v1/integrations/dashboard e /catalog).',
      loader: (repo, tenant, mode) =>
          repo.dashboard(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'status',
    builder: (_, _) => IntegrationsListPage(
      title: 'Status das integrações',
      liveSlug: 'status',
      emptyMessage: 'Nenhum status disponível.',
      extraNotice:
          'Status via /v1/integrations/health e /providers.',
      loader: (repo, tenant, mode) =>
          repo.status(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'config',
    builder: (_, _) => const IntegrationsConfigPage(),
  ),
  GoRoute(
    path: 'sync',
    builder: (_, _) => IntegrationsListPage(
      title: 'Sincronizações',
      liveSlug: 'sync',
      emptyMessage: 'Nenhuma sincronização registrada.',
      showSyncAction: true,
      loader: (repo, tenant, mode) =>
          repo.sync(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'history',
    builder: (_, _) => IntegrationsListPage(
      title: 'Histórico',
      liveSlug: 'history',
      emptyMessage: 'Nenhum histórico encontrado.',
      loader: (repo, tenant, mode) =>
          repo.history(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'logs',
    builder: (_, _) => IntegrationsListPage(
      title: 'Registros',
      liveSlug: 'logs',
      emptyMessage: 'Nenhum registro encontrado.',
      loader: (repo, tenant, mode) =>
          repo.logs(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'govbr',
    builder: (_, _) => IntegrationsListPage(
      title: 'Gov.br',
      liveSlug: 'govbr',
      emptyMessage: 'Nenhuma conexão Gov.br.',
      loader: (repo, tenant, mode) =>
          repo.govbr(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'camara-municipal',
    builder: (_, _) => IntegrationsListPage(
      title: 'Câmara Municipal',
      liveSlug: 'camara-municipal',
      emptyMessage: 'Nenhum dado da Câmara Municipal.',
      loader: (repo, tenant, mode) =>
          repo.camaraMunicipal(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'assembleia-legislativa',
    builder: (_, _) => IntegrationsListPage(
      title: 'Assembleia Legislativa',
      liveSlug: 'assembleia-legislativa',
      emptyMessage: 'Nenhum dado da Assembleia.',
      loader: (repo, tenant, mode) =>
          repo.assembleiaLegislativa(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'camara-deputados',
    builder: (_, _) => IntegrationsListPage(
      title: 'Câmara dos Deputados',
      liveSlug: 'camara-deputados',
      emptyMessage: 'Nenhum dado da Câmara dos Deputados.',
      loader: (repo, tenant, mode) =>
          repo.camaraDeputados(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'senado-federal',
    builder: (_, _) => IntegrationsListPage(
      title: 'Senado Federal',
      liveSlug: 'senado-federal',
      emptyMessage: 'Nenhum dado do Senado.',
      loader: (repo, tenant, mode) =>
          repo.senadoFederal(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'diario-oficial',
    builder: (_, _) => IntegrationsListPage(
      title: 'Diário Oficial',
      liveSlug: 'diario-oficial',
      emptyMessage: 'Nenhuma publicação encontrada.',
      loader: (repo, tenant, mode) =>
          repo.diarioOficial(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'portal-transparencia',
    builder: (_, _) => IntegrationsListPage(
      title: 'Portal da Transparência',
      liveSlug: 'portal-transparencia',
      emptyMessage: 'Nenhum dado de transparência.',
      loader: (repo, tenant, mode) =>
          repo.portalTransparencia(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'e-sic',
    builder: (_, _) => IntegrationsListPage(
      title: 'e-SIC',
      liveSlug: 'e-sic',
      emptyMessage: 'Nenhuma solicitação e-SIC.',
      loader: (repo, tenant, mode) =>
          repo.eSic(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'ouvidoria',
    builder: (_, _) => IntegrationsListPage(
      title: 'Ouvidoria',
      liveSlug: 'ouvidoria',
      emptyMessage: 'Nenhum registro de ouvidoria.',
      loader: (repo, tenant, mode) =>
          repo.ouvidoria(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'google-calendar',
    builder: (_, _) => IntegrationsListPage(
      title: 'Google Calendar',
      liveSlug: 'google-calendar',
      emptyMessage: 'Nenhuma agenda Google conectada.',
      loader: (repo, tenant, mode) =>
          repo.googleCalendar(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'outlook-calendar',
    builder: (_, _) => IntegrationsListPage(
      title: 'Outlook Calendar',
      liveSlug: 'outlook-calendar',
      emptyMessage: 'Nenhuma agenda Outlook conectada.',
      loader: (repo, tenant, mode) =>
          repo.outlookCalendar(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'gmail',
    builder: (_, _) => IntegrationsListPage(
      title: 'Gmail',
      liveSlug: 'gmail',
      emptyMessage: 'Nenhuma conta Gmail conectada.',
      loader: (repo, tenant, mode) =>
          repo.gmail(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'whatsapp',
    builder: (_, _) => IntegrationsListPage(
      title: 'WhatsApp',
      liveSlug: 'whatsapp',
      emptyMessage: 'Nenhum canal WhatsApp.',
      loader: (repo, tenant, mode) =>
          repo.whatsapp(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'telegram',
    builder: (_, _) => IntegrationsListPage(
      title: 'Telegram',
      liveSlug: 'telegram',
      emptyMessage: 'Nenhum canal Telegram.',
      loader: (repo, tenant, mode) =>
          repo.telegram(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'firebase-push',
    builder: (_, _) => IntegrationsListPage(
      title: 'Firebase Push',
      liveSlug: 'firebase-push',
      emptyMessage: 'Nenhuma configuração Firebase Push.',
      loader: (repo, tenant, mode) =>
          repo.firebasePush(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'external-apis',
    builder: (_, _) => IntegrationsListPage(
      title: 'APIs externas',
      liveSlug: 'external-apis',
      emptyMessage: 'Nenhuma API externa configurada.',
      loader: (repo, tenant, mode) =>
          repo.externalApis(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'webhooks',
    builder: (_, _) => IntegrationsListPage(
      title: 'Webhooks',
      liveSlug: 'webhooks',
      emptyMessage: 'Nenhum webhook configurado.',
      loader: (repo, tenant, mode) =>
          repo.webhooks(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'search',
    builder: (_, _) => const IntegrationsSearchPage(),
  ),
  GoRoute(
    path: 'filters',
    builder: (_, _) => IntegrationsListPage(
      title: 'Filtros',
      liveSlug: 'filters',
      emptyMessage: 'Nenhum filtro disponível.',
      loader: (repo, tenant, mode) =>
          repo.filters(tenantSlug: tenant, mode: mode),
    ),
  ),
];
