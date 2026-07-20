import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/auth/auth_controller.dart';
import 'core/config.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'features/account/data/account_repository.dart';
import 'features/agenda/data/appointments_repository.dart';
import 'features/assistant/data/assistant_repository.dart';
import 'features/citizen/data/portal_home_repository.dart';
import 'features/automation/data/automation_repository.dart';
import 'features/communication/data/communication_repository.dart';
import 'features/strategy/data/strategy_repository.dart';
import 'features/parliament/data/parliament_repository.dart';
import 'features/works/data/works_repository.dart';
import 'features/agreements/data/agreements_repository.dart';
import 'features/events/data/events_repository.dart';
import 'features/documents/data/documents_repository.dart';
import 'features/finance/data/finance_repository.dart';
import 'features/institutional_communication/data/institutional_communication_repository.dart';
import 'features/political_crm/data/crm_repository.dart';
import 'features/territorial_intelligence/data/territorial_intelligence_repository.dart';
import 'features/identity/data/identity_cache.dart';
import 'features/identity/data/identity_repository.dart';
import 'features/identity/domain/tenant_controller.dart';
import 'features/intelligence/data/intelligence_repository.dart';
import 'features/mandate/data/mandate_repository.dart';
import 'features/mandate/domain/mandate_refresh_controller.dart';
import 'features/notifications/data/devices_repository.dart';
import 'features/notifications/data/notification_preferences_repository.dart';
import 'features/notifications/data/notifications_repository.dart';
import 'features/notifications/domain/app_sync_controller.dart';
import 'features/notifications/domain/firebase_messaging_background.dart';
import 'features/notifications/domain/notifications_controller.dart';
import 'features/notifications/domain/push_notification_service.dart';
import 'features/notifications/domain/realtime_sync_service.dart';
import 'features/protocols/data/protocols_repository.dart';
import 'features/smart_assistant/data/smart_assistant_repository.dart';
import 'features/virtual_team/data/virtual_team_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[main] Firebase.initializeApp failed: $e');
    }
  }

  final storage = TokenStorage();
  final api = ApiClient(tokenStorage: storage);
  final auth = AuthController(api: api, storage: storage);
  final identityCache = IdentityCache();
  final identityRepo = IdentityRepository(api);
  final accountRepo = AccountRepository(api);
  final tenant = TenantController(
    repository: identityRepo,
    cache: identityCache,
    storage: storage,
    api: api,
  );
  final protocolsRepo = ProtocolsRepository(api);
  final notificationsRepo = NotificationsRepository(api);
  final devicesRepo = DevicesRepository(api);
  final prefsRepo = NotificationPreferencesRepository(api);
  final appointmentsRepo = AppointmentsRepository(api);
  final portalHomeRepo = PortalHomeRepository(api);
  final assistantRepo = AssistantRepository(api);
  final mandateRepo = MandateRepository(api);
  final intelligenceRepo = IntelligenceRepository(api);
  final virtualTeamRepo = VirtualTeamRepository(api);
  final automationRepo = AutomationRepository(api, virtualTeamRepo);
  final strategyRepo = StrategyRepository(api, mandateRepo);
  final parliamentRepo = ParliamentRepository(api);
  final worksRepo = WorksRepository(api, mandateRepo);
  final agreementsRepo = AgreementsRepository(api);
  final eventsRepo = EventsRepository(api);
  final documentsRepo = DocumentsRepository(api);
  final financeRepo = FinanceRepository(api);
  final institutionalCommunicationRepo =
      InstitutionalCommunicationRepository(api);
  final crmRepo = CrmRepository(api);
  final territorialIntelRepo = TerritorialIntelligenceRepository(api);
  final communicationRepo = CommunicationRepository(api);
  final smartAssistantRepo = SmartAssistantRepository(api);
  final mandateRefresh = MandateRefreshController();
  final notificationsController = NotificationsController(
    repository: notificationsRepo,
    auth: auth,
  );
  final realtime = RealtimeSyncService(
    api: api,
    auth: auth,
    notifications: notificationsController,
    mandateRefresh: mandateRefresh,
  );
  final push = PushNotificationService(
    devices: devicesRepo,
    auth: auth,
    notifications: notificationsController,
    realtime: realtime,
  );
  final appSync = AppSyncController(
    auth: auth,
    notifications: notificationsController,
    push: push,
    mandateRefresh: mandateRefresh,
  );
  final router = createAppRouter(auth: auth, tenant: tenant);

  await push.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: api),
        Provider.value(value: identityRepo),
        Provider.value(value: identityCache),
        Provider.value(value: accountRepo),
        Provider.value(value: protocolsRepo),
        Provider.value(value: notificationsRepo),
        Provider.value(value: devicesRepo),
        Provider.value(value: prefsRepo),
        Provider.value(value: appointmentsRepo),
        Provider.value(value: portalHomeRepo),
        Provider.value(value: assistantRepo),
        Provider.value(value: mandateRepo),
        Provider.value(value: intelligenceRepo),
        Provider.value(value: virtualTeamRepo),
        Provider.value(value: automationRepo),
        Provider.value(value: strategyRepo),
        Provider.value(value: parliamentRepo),
        Provider.value(value: worksRepo),
        Provider.value(value: agreementsRepo),
        Provider.value(value: eventsRepo),
        Provider.value(value: documentsRepo),
        Provider.value(value: financeRepo),
        Provider.value(value: institutionalCommunicationRepo),
        Provider.value(value: crmRepo),
        Provider.value(value: territorialIntelRepo),
        Provider.value(value: communicationRepo),
        Provider.value(value: smartAssistantRepo),
        Provider.value(value: realtime),
        Provider.value(value: push),
        Provider.value(value: appSync),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: tenant),
        ChangeNotifierProvider.value(value: notificationsController),
        ChangeNotifierProvider.value(value: mandateRefresh),
      ],
      child: PoliGestorApp(router: router),
    ),
  );
}

class PoliGestorApp extends StatefulWidget {
  const PoliGestorApp({super.key, required this.router});

  final GoRouter router;

  @override
  State<PoliGestorApp> createState() => _PoliGestorAppState();
}

class _PoliGestorAppState extends State<PoliGestorApp> {
  AuthController? _auth;
  PushNotificationService? _push;
  AppSyncController? _sync;
  bool? _wasAuthenticated;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthController>();
    final push = context.read<PushNotificationService>();
    final sync = context.read<AppSyncController>();
    if (!identical(_auth, auth)) {
      _auth?.removeListener(_onAuthChanged);
      _auth = auth;
      _auth!.addListener(_onAuthChanged);
    }
    _push = push;
    _sync = sync;
    _sync!.start();
    _push!.attachNavigator((location) {
      widget.router.go(location);
    });
    if (auth.isAuthenticated && _wasAuthenticated != true) {
      _wasAuthenticated = true;
      // ignore: discarded_futures
      push.onAuthenticated();
    }
  }

  void _onAuthChanged() {
    final auth = _auth;
    final push = _push;
    if (auth == null || push == null) return;
    final authed = auth.isAuthenticated;
    if (_wasAuthenticated == authed) return;
    _wasAuthenticated = authed;
    if (authed) {
      // ignore: discarded_futures
      push.onAuthenticated();
    } else {
      // DELETE do device deve ter rodado antes do logout; aqui só limpa local.
      // ignore: discarded_futures
      push.onSessionEnded();
    }
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    _sync?.stop();
    // ignore: discarded_futures
    _push?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<TenantController>().theme;
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: widget.router,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
