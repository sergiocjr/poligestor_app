import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_mode.dart';
import '../../../core/ux/user_messages.dart';
import '../../account/data/account_repository.dart';
import '../../identity/data/identity_models.dart';
import '../../identity/domain/tenant_controller.dart';
import '../../identity/presentation/widgets/identity_states.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  int _step = 0; // 0 request, 1 reset
  bool _busy = false;
  String? _error;
  String? _pendingPath;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    setState(() {
      _busy = true;
      _error = null;
      _pendingPath = null;
      _info = null;
    });
    final tenant = context.read<TenantController>();
    try {
      await context.read<AccountRepository>().forgotPassword(
        mode: AuthMode.portal,
        tenantSlug: tenant.organization?.slug ?? '',
        email: _email.text,
      );
      if (!mounted) return;
      setState(() {
        _step = 1;
        _info = 'Se o e-mail existir, enviaremos um código.';
      });
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      setState(() => _pendingPath = e.path);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = UserMessages.fromError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    setState(() {
      _busy = true;
      _error = null;
      _pendingPath = null;
    });
    final tenant = context.read<TenantController>();
    try {
      await context.read<AccountRepository>().resetPassword(
        mode: AuthMode.portal,
        tenantSlug: tenant.organization?.slug ?? '',
        email: _email.text,
        code: _code.text,
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada. Faça login.')),
      );
      context.go('/login');
    } on EndpointUnavailableException catch (e) {
      if (!mounted) return;
      setState(() => _pendingPath = e.path);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = UserMessages.fromError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_pendingPath != null)
            DemoExperiencePane(path: _pendingPath!)
          else ...[
            if (_step == 0) ...[
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _request,
                child: const Text('Enviar código'),
              ),
            ] else ...[
              if (_info != null) Text(_info!),
              const SizedBox(height: 12),
              TextField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Código'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova senha'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _reset,
                child: const Text('Salvar nova senha'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
