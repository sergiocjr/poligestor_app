import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../account/data/account_repository.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/data/identity_repository.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  AuthMode _mode = AuthMode.staff;
  bool _obscure = true;
  String? _error;
  List<AuthProviderInfo>? _providers;
  String? _providersPath;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _emailCtrl.text = 'admin@demo.local';
      _passwordCtrl.text = 'password';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrefs();
      _loadProviders();
    });
  }

  Future<void> _loadPrefs() async {
    if (!mounted) return;
    final storage = context.read<TokenStorage>();
    final email = await storage.getLastEmail();
    final mode = await storage.getAuthMode();
    if (!mounted) return;
    setState(() {
      if (email != null) _emailCtrl.text = email;
      if (mode != null) {
        _mode = mode;
        if (kDebugMode &&
            mode == AuthMode.portal &&
            _emailCtrl.text.contains('admin')) {
          _emailCtrl.text = 'cidadao@demo.local';
        }
      }
    });
  }

  Future<void> _loadProviders() async {
    final tenant = context.read<TenantController>();
    final slug = tenant.organization?.slug;
    if (slug == null || slug.isEmpty) return;
    try {
      final list = await context.read<IdentityRepository>().providers(
        mode: _mode,
        tenantSlug: slug,
      );
      if (!mounted) return;
      setState(() {
        _providers = list;
        _providersPath = null;
      });
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      setState(() {
        _providers = const [];
        _providersPath = e.path;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _providers = const [];
        _providersPath = _mode.authProvidersPath;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final auth = context.read<AuthController>();
    final tenant = context.read<TenantController>();
    try {
      await auth.login(
        mode: _mode,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        tenantSlug: tenant.organization?.slug,
      );
      if (!mounted) return;
      context.go(
        _mode == AuthMode.portal ? '/citizen/home' : '/home/dashboard',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = UserMessages.fromAuthError(e));
    }
  }

  Future<void> _social(String provider) async {
    final tenant = context.read<TenantController>();
    final auth = context.read<AuthController>();
    final slug = tenant.organization?.slug ?? '';
    if (slug.isEmpty) {
      setState(() => _error = 'Selecione a organização antes de continuar.');
      return;
    }
    setState(() => _error = null);
    try {
      final tokens = await context.read<AccountRepository>().oauthSignIn(
        mode: _mode,
        provider: provider,
        tenantSlug: slug,
        payload: {'provider': provider, 'device_name': 'flutter'},
      );
      await auth.applyTokenSession(mode: _mode, tenantSlug: slug, data: tokens);
      if (!mounted) return;
      context.go(
        _mode == AuthMode.portal ? '/citizen/home' : '/home/dashboard',
      );
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Provedor de autenticação indisponível.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = UserMessages.fromAuthError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final tenant = context.watch<TenantController>();
    final orgName = tenant.displayName;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Row(
                  children: [
                    AppLogo(
                      height: 44,
                      networkUrl: tenant.branding?.logoUrl,
                      semanticLabel: tenant.displayName,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        await tenant.clearOrganization();
                        if (context.mounted) context.go('/org');
                      },
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Trocar org.'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  orgName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (tenant.branding?.tagline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tenant.branding!.tagline!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (tenant.brandingUnavailable)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Branding remoto ainda indisponível — usando identidade salva.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 20),
                SegmentedButton<AuthMode>(
                  segments: const [
                    ButtonSegment(
                      value: AuthMode.staff,
                      label: Text('Operador'),
                      icon: Icon(Icons.badge_outlined),
                    ),
                    ButtonSegment(
                      value: AuthMode.portal,
                      label: Text('Cidadão'),
                      icon: Icon(Icons.person_outline),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) {
                    setState(() => _mode = s.first);
                    _loadProviders();
                  },
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail ou CPF',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Obrigatório' : null,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/login/forgot'),
                    child: const Text('Recuperar senha'),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                FilledButton(
                  onPressed: auth.isBusy ? null : _submit,
                  child: auth.isBusy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),
                if (tenant.registrationEnabled) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/login/register'),
                    child: const Text('Criar conta'),
                  ),
                ],
                const SizedBox(height: 20),
                Builder(
                  builder: (context) {
                    final socials = (_providers ?? const <AuthProviderInfo>[])
                        .where((p) => p.canUse)
                        .toList();
                    if (_providersPath != null) {
                      return const SizedBox.shrink();
                    }
                    if (_providers == null) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    if (socials.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Outras formas de entrada',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        for (final p in socials)
                          _SocialButton(
                            icon: switch (p.id) {
                              'apple' => Icons.apple,
                              'govbr' ||
                              'gov.br' => Icons.account_balance_outlined,
                              _ => Icons.g_mobiledata,
                            },
                            label: 'Entrar com ${p.label}',
                            onTap: () => _social(p.id),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
