import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../notifications/data/notification_preferences_repository.dart';
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
  bool _saving = false;
  String? _prefsError;

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    await _prefs.loadLocal();
    if (!mounted) return;
    setState(() => _prefsReady = true);

    try {
      final auth = context.read<AuthController>();
      final repo = context.read<NotificationPreferencesRepository>();
      final remote = await repo.get(mode: auth.mode);
      _prefs.copyFrom(remote);
      await _prefs.saveLocal();
      if (!mounted) return;
      setState(() => _prefsError = null);
    } catch (e) {
      if (!mounted) return;
      setState(() => _prefsError = 'Usando preferências locais (sync pendente).');
    }
  }

  Future<void> _savePrefs() async {
    if (_saving) return;
    setState(() => _saving = true);
    await _prefs.saveLocal();
    if (!mounted) return;
    try {
      final auth = context.read<AuthController>();
      final repo = context.read<NotificationPreferencesRepository>();
      final saved = await repo.save(mode: auth.mode, prefs: _prefs);
      _prefs.copyFrom(saved);
      await _prefs.saveLocal();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferências sincronizadas.')),
      );
      setState(() => _prefsError = null);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Salvo neste aparelho. Não foi possível sincronizar agora.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                if (user?.maskedDocument != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Documento'),
                    subtitle: Text(user!.maskedDocument!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: const Text('Conta e sessão'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/account/profile'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.devices_outlined),
                  title: const Text('Sessões ativas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/account/sessions'),
                ),
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
          if (_prefsError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _prefsError!,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (_prefsReady)
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Receber notificações'),
                    value: _prefs.pushEnabled,
                    onChanged: _saving
                        ? null
                        : (v) {
                            setState(() => _prefs.pushEnabled = v);
                            _savePrefs();
                          },
                  ),
                  SwitchListTile(
                    title: const Text('Mensagens da solicitação'),
                    value: _prefs.protocolMessagesEnabled,
                    onChanged: !_prefs.pushEnabled || _saving
                        ? null
                        : (v) {
                            setState(
                              () => _prefs.protocolMessagesEnabled = v,
                            );
                            _savePrefs();
                          },
                  ),
                  SwitchListTile(
                    title: const Text('Mudanças de status'),
                    value: _prefs.protocolStatusEnabled,
                    onChanged: !_prefs.pushEnabled || _saving
                        ? null
                        : (v) {
                            setState(
                              () => _prefs.protocolStatusEnabled = v,
                            );
                            _savePrefs();
                          },
                  ),
                  SwitchListTile(
                    title: const Text('Somente avisos importantes'),
                    value: _prefs.importantOnly,
                    onChanged: !_prefs.pushEnabled || _saving
                        ? null
                        : (v) {
                            setState(() => _prefs.importantOnly = v);
                            _savePrefs();
                          },
                  ),
                  ListTile(
                    leading: Icon(
                      push.firebaseReady
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                    ),
                    title: const Text('Push (FCM)'),
                    subtitle: Text(
                      push.firebaseReady
                          ? 'Firebase ativo${push.maskedFcmToken != null ? ' · ${push.maskedFcmToken}' : ''}'
                          : 'Firebase indisponível neste build',
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      push.realtimeConnected
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_queue_outlined,
                    ),
                    title: const Text('Tempo real'),
                    subtitle: Text(
                      push.realtimeConnected
                          ? 'WebSocket conectado'
                          : 'REST + polling (reconectando)',
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
