import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../shared/i18n/ui_labels.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/pg_design_system.dart';

import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import '../data/security_contracts.dart';
import '../data/security_models.dart';
import '../data/security_repository.dart';

String _tenantOf(BuildContext context) =>
    context.read<TenantController>().organization?.slug ?? 'demo';

AuthMode _modeOf(BuildContext context) => context.read<AuthController>().mode;

/// Títulos PT-BR por slug de rota (`/home/security/{slug}`).
const securitySlugTitles = <String, String>{
  'mfa-enable': 'Autenticação em duas etapas',
  'mfa-confirm': 'Confirmação em duas etapas',
  'account-recovery': 'Recuperação segura de conta',
  'sessions': 'Sessões ativas',
  'sessions-revoke': 'Encerramento remoto de sessões',
  'access-history': 'Histórico de acessos',
  'devices': 'Dispositivos conectados',
  'password-change': 'Alteração de senha',
  'password-policies': 'Políticas de senha',
  'tokens': 'Tokens e Chaves de API',
  'alerts': 'Alertas de segurança',
  'privacy': 'Privacidade',
  'consents': 'Consentimentos',
  'terms': 'Termos de uso',
  'privacy-policy': 'Política de privacidade',
  'data-request': 'Solicitação de dados',
  'data-export': 'Exportação de dados',
  'data-correction': 'Correção de dados',
  'account-deletion': 'Exclusão de conta',
  'privacy-preferences': 'Preferências de privacidade',
  'consent-history': 'Histórico de consentimentos',
  'incidents': 'Incidentes e avisos',
};

mixin _SecurityRefresh<T extends StatefulWidget> on State<T> {
  MandateRefreshController? _refresh;
  int _gen = -1;

  void bindSecurityRefresh(VoidCallback reload) {
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
  const _HubEntry(this.title, this.subtitle, this.icon, this.slug, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String slug;
  final String route;
}

const _hubEntries = <_HubEntry>[
  _HubEntry(
    'Autenticação em duas etapas',
    'Ativar autenticação em duas etapas',
    Icons.security_outlined,
    'mfa-enable',
    '/home/security/mfa-enable',
  ),
  _HubEntry(
    'Confirmação em duas etapas',
    'Confirmar código de verificação',
    Icons.verified_user_outlined,
    'mfa-confirm',
    '/home/security/mfa-confirm',
  ),
  _HubEntry(
    'Recuperação segura de conta',
    'Fluxos de recuperação',
    Icons.restore_outlined,
    'account-recovery',
    '/home/security/account-recovery',
  ),
  _HubEntry(
    'Sessões ativas',
    'Sessões autenticadas neste gabinete',
    Icons.devices_outlined,
    'sessions',
    '/home/security/sessions',
  ),
  _HubEntry(
    'Encerramento remoto de sessões',
    'Revogar sessões em outros dispositivos',
    Icons.logout_outlined,
    'sessions-revoke',
    '/home/security/sessions-revoke',
  ),
  _HubEntry(
    'Histórico de acessos',
    'Registros de acesso à conta',
    Icons.history_outlined,
    'access-history',
    '/home/security/access-history',
  ),
  _HubEntry(
    'Dispositivos conectados',
    'Aparelhos autorizados',
    Icons.phone_android_outlined,
    'devices',
    '/home/security/devices',
  ),
  _HubEntry(
    'Alteração de senha',
    'Atualizar credenciais',
    Icons.lock_outline,
    'password-change',
    '/home/security/password-change',
  ),
  _HubEntry(
    'Políticas de senha',
    'Requisitos e validações',
    Icons.policy_outlined,
    'password-policies',
    '/home/security/password-policies',
  ),
  _HubEntry(
    'Tokens e Chaves de API',
    'Tokens e chaves de API do gabinete',
    Icons.vpn_key_outlined,
    'tokens',
    '/home/security/tokens',
  ),
  _HubEntry(
    'Alertas de segurança',
    'Avisos e notificações de risco',
    Icons.warning_amber_outlined,
    'alerts',
    '/home/security/alerts',
  ),
  _HubEntry(
    'Privacidade',
    'Configurações de privacidade',
    Icons.privacy_tip_outlined,
    'privacy',
    '/home/security/privacy',
  ),
  _HubEntry(
    'Consentimentos',
    'Consentimentos ativos',
    Icons.check_circle_outline,
    'consents',
    '/home/security/consents',
  ),
  _HubEntry(
    'Termos de uso',
    'Termos vigentes',
    Icons.description_outlined,
    'terms',
    '/home/security/terms',
  ),
  _HubEntry(
    'Política de privacidade',
    'Documento de privacidade',
    Icons.article_outlined,
    'privacy-policy',
    '/home/security/privacy-policy',
  ),
  _HubEntry(
    'Solicitação de dados',
    'Solicitar informações pessoais',
    Icons.contact_page_outlined,
    'data-request',
    '/home/security/data-request',
  ),
  _HubEntry(
    'Exportação de dados',
    'Exportar dados da conta',
    Icons.download_outlined,
    'data-export',
    '/home/security/data-export',
  ),
  _HubEntry(
    'Correção de dados',
    'Retificar informações',
    Icons.edit_note_outlined,
    'data-correction',
    '/home/security/data-correction',
  ),
  _HubEntry(
    'Exclusão de conta',
    'Encerramento definitivo',
    Icons.delete_forever_outlined,
    'account-deletion',
    '/home/security/account-deletion',
  ),
  _HubEntry(
    'Preferências de privacidade',
    'Controles granulares',
    Icons.tune_outlined,
    'privacy-preferences',
    '/home/security/privacy-preferences',
  ),
  _HubEntry(
    'Histórico de consentimentos',
    'Registro de consentimentos',
    Icons.fact_check_outlined,
    'consent-history',
    '/home/security/consent-history',
  ),
  _HubEntry(
    'Incidentes e avisos',
    'Comunicados de incidentes',
    Icons.report_outlined,
    'incidents',
    '/home/security/incidents',
  ),
];

/// Hub — Segurança e Privacidade (Fase 21).
class SecurityHubPage extends StatelessWidget {
  const SecurityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Segurança e Privacidade')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final cross = wide ? (constraints.maxWidth >= 1100 ? 3 : 2) : 1;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisExtent: PgHubModuleTile.gridExtent(
                    crossAxisCount: cross,
                  ),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _hubEntries.length,
                itemBuilder: (context, i) {
                  final e = _hubEntries[i];
                  final live = securityPathLive(e.slug);
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
        },
      ),
    );
  }
}

typedef SecurityListLoader =
    Future<List<SecurityItem>> Function(
      SecurityRepository repo,
      String tenant,
      AuthMode mode,
    );

class SecurityListPage extends StatefulWidget {
  const SecurityListPage({
    super.key,
    required this.title,
    required this.loader,
    this.emptyMessage = 'Nenhum item encontrado.',
    this.extraNotice,
    this.liveSlug,
  });

  final String title;
  final SecurityListLoader loader;
  final String emptyMessage;
  final String? extraNotice;
  final String? liveSlug;

  @override
  State<SecurityListPage> createState() => _SecurityListPageState();
}

class _SecurityListPageState extends State<SecurityListPage>
    with _SecurityRefresh {
  Future<List<SecurityItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bindSecurityRefresh(() => setState(() => _future = _load()));
    _future ??= _load();
  }

  Future<List<SecurityItem>> _load() => widget.loader(
    context.read<SecurityRepository>(),
    _tenantOf(context),
    _modeOf(context),
  );

  void _openItem(SecurityItem item) {
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
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (item.code != null) Text('Referência: ${item.code}'),
                if (item.email != null) Text('E-mail: ${item.email}'),
                if (item.device != null) Text('Dispositivo: ${item.device}'),
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
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<SecurityItem>>(
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
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  AppEmptyState(message: 'Nenhum registro encontrado.'),
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
            var items = snap.data ?? const <SecurityItem>[];
            if (_query.isNotEmpty) {
              final q = _query.toLowerCase();
              items = items
                  .where(
                    (i) =>
                        i.title.toLowerCase().contains(q) ||
                        (i.summary?.toLowerCase().contains(q) ?? false),
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
                                  Icons.shield_outlined,
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

class SecurityMfaEnablePage extends StatefulWidget {
  const SecurityMfaEnablePage({super.key});

  @override
  State<SecurityMfaEnablePage> createState() => _SecurityMfaEnablePageState();
}

class _SecurityMfaEnablePageState extends State<SecurityMfaEnablePage> {
  final _passwordCtrl = TextEditingController();
  bool _sending = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _result = null;
    });
    try {
      final repo = context.read<SecurityRepository>();
      final data = await repo.enableMfa(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
        password: _passwordCtrl.text.trim().isEmpty
            ? null
            : _passwordCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _result = data);
    } on EndpointUnavailableException catch (_) {
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Não foi possível iniciar a ativação.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autenticação em duas etapas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SoftNotice(
            message:
                'Autenticação em duas etapas. Informe sua senha atual se '
                'o serviço solicitar.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Senha atual (se necessário)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.security),
            label: const Text('Iniciar ativação'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _result!['message']?.toString() ??
                      'Solicitação enviada. Siga as instruções retornadas.',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SecurityMfaConfirmPage extends StatefulWidget {
  const SecurityMfaConfirmPage({super.key});

  @override
  State<SecurityMfaConfirmPage> createState() => _SecurityMfaConfirmPageState();
}

class _SecurityMfaConfirmPageState extends State<SecurityMfaConfirmPage> {
  final _codeCtrl = TextEditingController();
  bool _sending = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _result = null;
    });
    try {
      final repo = context.read<SecurityRepository>();
      final data = await repo.confirmMfa(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
        code: code,
      );
      if (!mounted) return;
      setState(() => _result = data);
    } on EndpointUnavailableException catch (_) {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Não foi possível confirmar o código.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmação em duas etapas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SoftNotice(
            message: 'Informe o código do aplicativo autenticador.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Código de verificação',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_user_outlined),
            label: const Text('Confirmar'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _result!['message']?.toString() ??
                      'Autenticação em duas etapas confirmada.',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SecurityPasswordChangePage extends StatefulWidget {
  const SecurityPasswordChangePage({super.key});

  @override
  State<SecurityPasswordChangePage> createState() =>
      _SecurityPasswordChangePageState();
}

class _SecurityPasswordChangePageState
    extends State<SecurityPasswordChangePage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  bool _sending = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text;
    final newer = _newCtrl.text;
    if (current.isEmpty || newer.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _result = null;
    });
    try {
      final repo = context.read<SecurityRepository>();
      final data = await repo.changePassword(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
        currentPassword: current,
        newPassword: newer,
      );
      if (!mounted) return;
      setState(() {
        _result = data;
        _currentCtrl.clear();
        _newCtrl.clear();
      });
    } on EndpointUnavailableException catch (_) {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Não foi possível alterar a senha.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alteração de senha')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _currentCtrl,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Senha atual',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newCtrl,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Nova senha',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_reset),
            label: const Text('Alterar senha'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Senha atualizada com sucesso.'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SecurityDataExportPage extends StatefulWidget {
  const SecurityDataExportPage({super.key});

  @override
  State<SecurityDataExportPage> createState() => _SecurityDataExportPageState();
}

class _SecurityDataExportPageState extends State<SecurityDataExportPage> {
  final _reasonCtrl = TextEditingController();
  bool _sending = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _result = null;
    });
    try {
      final repo = context.read<SecurityRepository>();
      final data = await repo.exportData(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
        reason: _reasonCtrl.text.trim().isEmpty
            ? null
            : _reasonCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _result = data);
    } on EndpointUnavailableException catch (_) {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Não foi possível solicitar a exportação.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportação de dados')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SoftNotice(
            message:
                'Solicita exportação dos seus dados conforme a política de '
                'privacidade.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: const Text('Solicitar exportação'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _result!['message']?.toString() ??
                      'Solicitação registrada. Você será notificado quando '
                          'estiver pronta.',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SecurityAccountDeletionPage extends StatefulWidget {
  const SecurityAccountDeletionPage({super.key});

  @override
  State<SecurityAccountDeletionPage> createState() =>
      _SecurityAccountDeletionPageState();
}

class _SecurityAccountDeletionPageState
    extends State<SecurityAccountDeletionPage> {
  final _confirmCtrl = TextEditingController();
  bool _sending = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _confirmCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _result = null;
    });
    try {
      final repo = context.read<SecurityRepository>();
      final data = await repo.deleteAccount(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
        confirmation: text,
      );
      if (!mounted) return;
      setState(() => _result = data);
    } on EndpointUnavailableException catch (_) {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Não foi possível registrar a exclusão.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exclusão de conta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SoftNotice(
            message:
                'Ação irreversível. Digite EXCLUIR para confirmar a '
                'solicitação.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            decoration: const InputDecoration(
              labelText: 'Confirmação (EXCLUIR)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_forever_outlined),
            label: const Text('Solicitar exclusão'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _result!['message']?.toString() ??
                      'Solicitação registrada para análise.',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SecuritySessionsRevokePage extends StatefulWidget {
  const SecuritySessionsRevokePage({super.key});

  @override
  State<SecuritySessionsRevokePage> createState() =>
      _SecuritySessionsRevokePageState();
}

class _SecuritySessionsRevokePageState
    extends State<SecuritySessionsRevokePage> {
  bool _sending = false;
  String? _error;
  Map<String, dynamic>? _result;

  Future<void> _submit() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _result = null;
    });
    try {
      final repo = context.read<SecurityRepository>();
      final data = await repo.revokeAllSessions(
        tenantSlug: _tenantOf(context),
        mode: _modeOf(context),
      );
      if (!mounted) return;
      setState(() => _result = data);
    } on EndpointUnavailableException catch (_) {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Não foi possível encerrar as sessões.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encerramento remoto de sessões')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SoftNotice(
            message:
                'Encerra sessões ativas em outros dispositivos. A sessão '
                'atual pode permanecer ativa neste aparelho.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_outlined),
            label: const Text('Encerrar outras sessões'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _result!['message']?.toString() ??
                      'Solicitação de encerramento enviada.',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<RouteBase> buildSecurityChildRoutes() => [
  GoRoute(path: 'mfa-enable', builder: (_, _) => const SecurityMfaEnablePage()),
  GoRoute(
    path: 'mfa-confirm',
    builder: (_, _) => const SecurityMfaConfirmPage(),
  ),
  GoRoute(
    path: 'account-recovery',
    builder: (_, _) => SecurityListPage(
      title: 'Recuperação segura de conta',
      liveSlug: 'account-recovery',
      emptyMessage: 'Nenhum fluxo de recuperação disponível.',
      loader: (repo, tenant, mode) =>
          repo.accountRecovery(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'sessions',
    builder: (_, _) => SecurityListPage(
      title: 'Sessões ativas',
      liveSlug: 'sessions',
      emptyMessage: 'Nenhuma sessão registrada.',
      extraNotice: 'Para sessões da conta, use Conta → Sessões.',
      loader: (repo, tenant, mode) =>
          repo.sessions(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'sessions-revoke',
    builder: (_, _) => const SecuritySessionsRevokePage(),
  ),
  GoRoute(
    path: 'access-history',
    builder: (_, _) => SecurityListPage(
      title: 'Histórico de acessos',
      liveSlug: 'access-history',
      emptyMessage: 'Nenhum acesso registrado.',
      loader: (repo, tenant, mode) =>
          repo.accessHistory(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'devices',
    builder: (_, _) => SecurityListPage(
      title: 'Dispositivos conectados',
      liveSlug: 'devices',
      emptyMessage: 'Nenhum dispositivo encontrado.',
      loader: (repo, tenant, mode) =>
          repo.devices(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'password-change',
    builder: (_, _) => const SecurityPasswordChangePage(),
  ),
  GoRoute(
    path: 'password-policies',
    builder: (_, _) => SecurityListPage(
      title: 'Políticas de senha',
      liveSlug: 'password-policies',
      emptyMessage: 'Nenhuma política disponível.',
      loader: (repo, tenant, mode) =>
          repo.passwordPolicies(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'tokens',
    builder: (_, _) => SecurityListPage(
      title: 'Tokens e Chaves de API',
      liveSlug: 'tokens',
      emptyMessage: 'Nenhum token ou chave encontrada.',
      extraNotice: 'Tokens e chaves de API do gabinete.',
      loader: (repo, tenant, mode) async {
        final tokens = await repo.tokens(tenantSlug: tenant, mode: mode);
        try {
          final keys = await repo.apiKeys(tenantSlug: tenant, mode: mode);
          return [...tokens, ...keys];
        } catch (_) {
          return tokens;
        }
      },
    ),
  ),
  GoRoute(
    path: 'alerts',
    builder: (_, _) => SecurityListPage(
      title: 'Alertas de segurança',
      liveSlug: 'alerts',
      emptyMessage: 'Nenhum alerta ativo.',
      loader: (repo, tenant, mode) =>
          repo.alerts(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'privacy',
    builder: (_, _) => SecurityListPage(
      title: 'Privacidade',
      liveSlug: 'privacy',
      emptyMessage: 'Nenhuma configuração de privacidade.',
      loader: (repo, tenant, mode) =>
          repo.privacy(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'consents',
    builder: (_, _) => SecurityListPage(
      title: 'Consentimentos',
      liveSlug: 'consents',
      emptyMessage: 'Nenhum consentimento registrado.',
      loader: (repo, tenant, mode) =>
          repo.consents(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'terms',
    builder: (_, _) => SecurityListPage(
      title: 'Termos de uso',
      liveSlug: 'terms',
      emptyMessage: 'Nenhum termo publicado.',
      loader: (repo, tenant, mode) =>
          repo.terms(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'privacy-policy',
    builder: (_, _) => SecurityListPage(
      title: 'Política de privacidade',
      liveSlug: 'privacy-policy',
      emptyMessage: 'Nenhuma política publicada.',
      loader: (repo, tenant, mode) =>
          repo.privacyPolicy(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'data-request',
    builder: (_, _) => SecurityListPage(
      title: 'Solicitação de dados',
      liveSlug: 'data-request',
      emptyMessage: 'Nenhuma solicitação encontrada.',
      loader: (repo, tenant, mode) =>
          repo.dataRequest(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'data-export',
    builder: (_, _) => const SecurityDataExportPage(),
  ),
  GoRoute(
    path: 'data-correction',
    builder: (_, _) => SecurityListPage(
      title: 'Correção de dados',
      liveSlug: 'data-correction',
      emptyMessage: 'Nenhuma solicitação de correção.',
      loader: (repo, tenant, mode) =>
          repo.dataCorrection(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'account-deletion',
    builder: (_, _) => const SecurityAccountDeletionPage(),
  ),
  GoRoute(
    path: 'privacy-preferences',
    builder: (_, _) => SecurityListPage(
      title: 'Preferências de privacidade',
      liveSlug: 'privacy-preferences',
      emptyMessage: 'Nenhuma preferência configurada.',
      loader: (repo, tenant, mode) =>
          repo.privacyPreferences(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'consent-history',
    builder: (_, _) => SecurityListPage(
      title: 'Histórico de consentimentos',
      liveSlug: 'consent-history',
      emptyMessage: 'Nenhum histórico disponível.',
      loader: (repo, tenant, mode) =>
          repo.consentHistory(tenantSlug: tenant, mode: mode),
    ),
  ),
  GoRoute(
    path: 'incidents',
    builder: (_, _) => SecurityListPage(
      title: 'Incidentes e avisos',
      liveSlug: 'incidents',
      emptyMessage: 'Nenhum incidente registrado.',
      loader: (repo, tenant, mode) =>
          repo.incidents(tenantSlug: tenant, mode: mode),
    ),
  ),
];
