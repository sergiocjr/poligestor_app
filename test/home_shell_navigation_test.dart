import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poligestor_app/features/home/presentation/home_shell.dart';

void main() {
  testWidgets('HomeShell bottom labels stay single-line and include Gabinete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1280); // ~A10 logical width
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/home/dashboard',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return HomeShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/dashboard',
                  builder: (_, _) => const Scaffold(body: Text('DASH')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/protocols',
                  builder: (_, _) => const Scaffold(body: Text('PROT')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/agenda',
                  builder: (_, _) => const Scaffold(body: Text('AGE')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/mandate',
                  builder: (_, _) => const Scaffold(body: Text('MAN')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/more',
                  builder: (_, _) => const Scaffold(body: Text('MORE')),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('DASH'), findsOneWidget);
    expect(find.text('Gabinete'), findsOneWidget);
    expect(find.text('Protocolos'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Mandato'), findsOneWidget);
    expect(find.text('Mais'), findsOneWidget);
    expect(find.text('Inteligência'), findsNothing);

    await tester.tap(find.text('Protocolos'));
    await tester.pumpAndSettle();
    expect(find.text('PROT'), findsOneWidget);

    final exceptions = tester.takeException();
    expect(exceptions, isNull);
  });

  testWidgets('HomeShell at A10 width does not overflow NavigationBar', (
    tester,
  ) async {
    // SM-A105M ~720x1480 @ ~2.0 ≈ 360 logical width
    tester.view.physicalSize = const Size(720, 1480);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) {
        fail(details.toString());
      }
      FlutterError.presentError(details);
    };

    final router = GoRouter(
      initialLocation: '/home/dashboard',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return HomeShell(navigationShell: navigationShell);
          },
          branches: [
            for (final path in [
              '/home/dashboard',
              '/home/protocols',
              '/home/agenda',
              '/home/mandate',
              '/home/more',
            ])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: path,
                    builder: (_, _) => Scaffold(body: Text(path)),
                  ),
                ],
              ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Gabinete'), findsOneWidget);
    expect(find.text('Protocolos'), findsOneWidget);
  });
}
