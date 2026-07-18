import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../core/config.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/ux/user_messages.dart';
import '../../../shared/widgets/app_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@demo.local');
  final _passwordCtrl = TextEditingController(text: 'password');
  final _tenantCtrl = TextEditingController(text: AppConfig.defaultTenantSlug);

  AuthMode _mode = AuthMode.staff;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPrefs());
  }

  Future<void> _loadPrefs() async {
    if (!mounted) return;
    final storage = context.read<TokenStorage>();
    final email = await storage.getLastEmail();
    final tenant = await storage.getTenantSlug();
    final mode = await storage.getAuthMode();
    if (!mounted) return;
    setState(() {
      if (email != null) _emailCtrl.text = email;
      if (tenant != null) _tenantCtrl.text = tenant;
      if (mode != null) {
        _mode = mode;
        if (mode == AuthMode.portal && _emailCtrl.text.contains('admin')) {
          _emailCtrl.text = 'cidadao@demo.local';
        }
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _tenantCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final auth = context.read<AuthController>();
    try {
      await auth.login(
        mode: _mode,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        tenantSlug: _tenantCtrl.text,
      );
      if (!mounted) return;
      context.go(
        _mode == AuthMode.portal ? '/citizen/home' : '/home/protocols',
      );
    } catch (e) {
      setState(() => _error = UserMessages.fromError(e));
    }
  }

  void _onModeChanged(AuthMode mode) {
    setState(() {
      _mode = mode;
      if (mode == AuthMode.staff) {
        _emailCtrl.text = 'admin@demo.local';
      } else {
        _emailCtrl.text = 'cidadao@demo.local';
      }
      _passwordCtrl.text = 'password';
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const AppLogo(height: 150),
                    const SizedBox(height: 8),
                    Text(
                      'Entre para continuar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 28),
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
                      onSelectionChanged: (s) => _onModeChanged(s.first),
                    ),
                    const SizedBox(height: 20),
                    if (_mode == AuthMode.portal) ...[
                      TextFormField(
                        controller: _tenantCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tenant (slug)',
                          prefixIcon: Icon(Icons.domain),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Informe o tenant' : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a senha' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Material(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _error!,
                            style: TextStyle(color: scheme.onErrorContainer),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: auth.isBusy ? null : _submit,
                      child: auth.isBusy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Entrar'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Demo: admin@demo.local / cidadao@demo.local — senha: password',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
