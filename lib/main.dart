import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/auth/auth_controller.dart';
import 'core/config.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/agenda/data/appointments_repository.dart';
import 'features/citizen/data/portal_home_repository.dart';
import 'features/notifications/data/notifications_repository.dart';
import 'features/protocols/data/protocols_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = TokenStorage();
  final api = ApiClient(tokenStorage: storage);
  final auth = AuthController(api: api, storage: storage);
  final protocolsRepo = ProtocolsRepository(api);
  final notificationsRepo = NotificationsRepository(api);
  final appointmentsRepo = AppointmentsRepository(api);
  final portalHomeRepo = PortalHomeRepository(api);
  final router = createAppRouter(auth);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: api),
        Provider.value(value: protocolsRepo),
        Provider.value(value: notificationsRepo),
        Provider.value(value: appointmentsRepo),
        Provider.value(value: portalHomeRepo),
        ChangeNotifierProvider.value(value: auth),
      ],
      child: PoliGestorApp(router: router),
    ),
  );
}

class PoliGestorApp extends StatelessWidget {
  const PoliGestorApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
