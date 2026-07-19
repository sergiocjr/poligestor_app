import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config.dart';
import '../../../shared/widgets/app_logo.dart';
import '../data/identity_models.dart';
import '../domain/tenant_controller.dart';
import 'widgets/identity_states.dart';

/// Primeira tela: selecionar organização (slug / código / domínio).
class OrganizationSelectPage extends StatefulWidget {
  const OrganizationSelectPage({super.key});

  @override
  State<OrganizationSelectPage> createState() => _OrganizationSelectPageState();
}

class _OrganizationSelectPageState extends State<OrganizationSelectPage> {
  final _ctrl = TextEditingController(text: AppConfig.defaultTenantSlug);
  String _mode = 'slug'; // slug | code | domain
  String? _error;
  bool _busy = false;
  bool _deepLinkHandled = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_deepLinkHandled) return;
    final slug = GoRouterState.of(context).uri.queryParameters['slug'];
    if (slug != null && slug.trim().isNotEmpty) {
      _deepLinkHandled = true;
      _ctrl.text = slug.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) => _continue());
    }
  }

  Future<void> _continue() async {
    final tenant = context.read<TenantController>();
    final value = _ctrl.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Informe a organização.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      try {
        switch (_mode) {
          case 'code':
            await tenant.selectByCode(value);
          case 'domain':
            await tenant.selectByDomain(value);
          default:
            await tenant.selectBySlug(value);
        }
      } on EndpointUnavailableException {
        // Resolve ainda 500 na VPS — segue com slug local até o backend estabilizar.
        await tenant.selectSlugLocally(value);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Resolução remota indisponível. Organização salva pelo identificador informado.',
              ),
            ),
          );
        }
      }
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = tenant.error ?? 'Não foi possível continuar.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = context.watch<TenantController>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                const AppLogo(height: 56),
                const SizedBox(height: 28),
                Text(
                  'Selecione sua organização',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use o slug, código de acesso ou domínio. '
                  'A identidade visual será carregada automaticamente.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final (id, label) in const [
                      ('slug', 'Slug'),
                      ('code', 'Código'),
                      ('domain', 'Domínio'),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _mode == id,
                        onSelected: (_) => setState(() => _mode = id),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ctrl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _continue(),
                  decoration: InputDecoration(
                    labelText: switch (_mode) {
                      'code' => 'Código da organização',
                      'domain' => 'Domínio / subdomínio',
                      _ => 'Slug (ex.: demo)',
                    },
                    prefixIcon: const Icon(Icons.apartment_outlined),
                  ),
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
                if (tenant.resolveUnavailable) ...[
                  const SizedBox(height: 12),
                  const EndpointPendingState(
                    path: '/v1/identity/tenants/resolve',
                    message:
                        'Resolução remota indisponível — usando identificador local.',
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _continue,
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continuar'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Também é possível abrir via deep link '
                  '(poligestor://org/{slug}).',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
