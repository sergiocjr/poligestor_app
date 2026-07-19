import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/shared/widgets/ui_kit.dart';

void main() {
  group('FeatureActionCard alinhamento', () {
    testWidgets('estrutura start + padding unico + slots fixos', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const cards = <({IconData icon, String title, String description})>[
        (
          icon: Icons.help_rounded,
          title: 'Solicitar ajuda',
          description: 'Abra um atendimento para o gabinete',
        ),
        (
          icon: Icons.report_rounded,
          title: 'Fazer denúncia',
          description: 'Relate um problema',
        ),
        (
          icon: Icons.lightbulb_rounded,
          title: 'Enviar sugestão',
          description: 'Melhorias para a cidade',
        ),
        (
          icon: Icons.event_available_rounded,
          title: 'Agendar atendimento',
          description: 'Marque um horário',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final items = cards.map(
                    (c) => (title: c.title, description: c.description),
                  );
                  final extent = FeatureActionGridMetrics.mainAxisExtentFor(
                    context: context,
                    maxWidth: constraints.maxWidth,
                    items: items,
                  );
                  return GridView.builder(
                    itemCount: cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: FeatureActionGridMetrics.spacing,
                      crossAxisSpacing: FeatureActionGridMetrics.spacing,
                      mainAxisExtent: extent,
                    ),
                    itemBuilder: (context, i) {
                      final c = cards[i];
                      return FeatureActionCard(
                        key: Key('card_$i'),
                        icon: c.icon,
                        title: c.title,
                        description: c.description,
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final columns = tester.widgetList<Column>(find.byType(Column)).where((c) {
        return c.crossAxisAlignment == CrossAxisAlignment.start &&
            c.children.length >= 5;
      });
      expect(columns.length, greaterThanOrEqualTo(4));

      // Ícones: mesma coluna compartilha o mesmo X.
      final iconXs = <double>[];
      for (var i = 0; i < 4; i++) {
        final box = tester.renderObject<RenderBox>(
          find.descendant(
            of: find.byKey(Key('card_$i')),
            matching: find.byType(Icon),
          ),
        );
        iconXs.add(box.localToGlobal(Offset.zero).dx);
      }
      expect((iconXs[0] - iconXs[2]).abs(), lessThan(1)); // col 0
      expect((iconXs[1] - iconXs[3]).abs(), lessThan(1)); // col 1

      // Títulos da mesma coluna alinhados à esquerda no mesmo eixo.
      final title0 = tester.getTopLeft(find.text('Solicitar ajuda'));
      final title2 = tester.getTopLeft(find.text('Enviar sugestão'));
      expect((title0.dx - title2.dx).abs(), lessThan(1));
      expect((title0.dx - iconXs[0]).abs(), lessThan(40));
    });

    testWidgets('360/393/412 e escalas sem overflow', (tester) async {
      for (final width in [360.0, 393.0, 412.0]) {
        for (final scale in [1.0, 1.3, 1.5]) {
          await tester.binding.setSurfaceSize(Size(width, 900));
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: Size(width, 900),
                textScaler: TextScaler.linear(scale),
              ),
              child: MaterialApp(
                home: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final extent =
                            FeatureActionGridMetrics.mainAxisExtentFor(
                              context: context,
                              maxWidth: constraints.maxWidth,
                              items: const [
                                (
                                  title: 'Agendar atendimento',
                                  description: 'Horário',
                                ),
                                (
                                  title: 'Acompanhar protocolo',
                                  description: 'Andamento',
                                ),
                              ],
                            );
                        final cross =
                            FeatureActionGridMetrics.crossAxisCountFor(
                              constraints.maxWidth,
                              textScale: scale,
                            );
                        return GridView.builder(
                          itemCount: 2,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cross,
                                mainAxisSpacing:
                                    FeatureActionGridMetrics.spacing,
                                crossAxisSpacing:
                                    FeatureActionGridMetrics.spacing,
                                mainAxisExtent: extent,
                              ),
                          itemBuilder: (_, i) => FeatureActionCard(
                            icon: Icons.help,
                            title: i == 0
                                ? 'Agendar atendimento'
                                : 'Acompanhar protocolo',
                            description: 'Texto de apoio',
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '${width}x$scale');
        }
      }
    });
  });
}
