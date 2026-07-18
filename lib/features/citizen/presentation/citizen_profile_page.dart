import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../notifications/domain/notification_prefs.dart';
import '../../notifications/domain/push_notification_service.dart';

class CitizenProfilePage extends StatefulWidget {
  const CitizenProfilePage({super.key});

  @override
  State<CitizenProfilePage> createState() => _CitizenProfilePageState();
}

class _CitizenProfilePageState extends State<CitizenProfilePage> {
  final _prefs = NotificationPrefs();
  bool _prefsReady = false;

  @override
  void initState() {
    super.initState();
    _prefs.load().then((_) {
      if (mounted) setState(() => _prefsReady = true);
    });
  }

  Future<void> _savePrefs() async {
    await _prefs.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Preferências salvas neste aparelho. '
          'Sincronização com o servidor aguarda o contrato da Fase 7.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final session = auth.session;
    final user = session?.user;
    final scheme = Theme.of(context).colorScheme;
    final push = context.read<PushNotificationService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.2),
                    scheme.secondary.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Icon(Icons.person_rounded, size: 44, color: scheme.primary),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.name ?? 'Cidadão',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.domain_rounded),
                  title: const Text('Organização'),
                  subtitle:
                      Text(user?.tenantName ?? session?.tenantSlug ?? '—'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_city_outlined),
                  title: const Text('Meu bairro'),
                  subtitle: Text(user?.neighborhoodLabel ?? '—'),
                ),
                if (user?.document != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Documento'),
                    subtitle: Text(user!.document!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          NeighborhoodCard(
            neighborhoodLabel: user?.neighborhoodLabel ?? 'Sua região',
          ),
          const SizedBox(height: 16),
          Text(
            'Notificações',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          if (_prefsReady)
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Receber notificações'),
                    value: _prefs.enabled,
                    onChanged: (v) {
                      setState(() => _prefs.enabled = v);
                      _savePrefs();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Mensagens da solicitação'),
                    value: _prefs.messages,
                    onChanged: !_prefs.enabled
                        ? null
                        : (v) {
                            setState(() => _prefs.messages = v);
                            _savePrefs();
                          },
                  ),
                  SwitchListTile(
                    title: const Text('Mudanças importantes'),
                    value: _prefs.importantUpdates,
                    onChanged: !_prefs.enabled
                        ? null
                        : (v) {
                            setState(() => _prefs.importantUpdates = v);
                            _savePrefs();
                          },
                  ),
                  SwitchListTile(
                    title: const Text('Somente avisos importantes'),
                    value: _prefs.importantOnly,
                    onChanged: !_prefs.enabled
                        ? null
                        : (v) {
                            setState(() => _prefs.importantOnly = v);
                            _savePrefs();
                          },
                  ),
                  ListTile(
                    leading: Icon(
                      push.firebaseReady
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                    ),
                    title: const Text('Push neste aparelho'),
                    subtitle: Text(
                      push.firebaseReady
                          ? 'Firebase habilitado'
                          : 'Aguardando contrato Fase 7 e Firebase',
                    ),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () async {
              await context.read<PushNotificationService>().onLogout();
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair'),
          ),
          const SizedBox(height: 12),
          Text(
            AppConfig.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
