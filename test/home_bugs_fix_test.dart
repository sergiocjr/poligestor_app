import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/features/citizen/data/mock_news.dart';
import 'package:poligestor_app/features/citizen/presentation/citizen_content_pages.dart';
import 'package:poligestor_app/features/citizen/presentation/new_request_page.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';
import 'package:poligestor_app/shared/widgets/ui_kit.dart';

void main() {
  group('RequestCategory dropdown safety', () {
    test('normalizeId mapeia agenda → atendimento e visita estável', () {
      expect(RequestCategory.normalizeId('agenda'), 'atendimento');
      expect(RequestCategory.normalizeId('agendamento'), 'atendimento');
      expect(RequestCategory.normalizeId('visita'), 'visita');
      expect(RequestCategory.normalizeId('visit'), 'visita');
    });

    test('uniqueById remove duplicados', () {
      final items = RequestCategory.uniqueById([
        RequestCategory.appointment,
        const RequestCategory(
          id: 'agenda',
          label: 'Agenda duplicada',
          iconName: 'event',
          description: 'dup',
        ),
        RequestCategory.visit,
        const RequestCategory(
          id: 'visita',
          label: 'Visita duplicada',
          iconName: 'home',
          description: 'dup',
        ),
      ]);
      final ids = items.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, containsAll(['atendimento', 'visita']));
      expect(ids.where((e) => e == 'atendimento').length, 1);
      expect(ids.where((e) => e == 'visita').length, 1);
    });

    test('sanitizeDropdownValue aceita valor válido', () {
      expect(
        RequestCategory.sanitizeDropdownValue('atendimento'),
        'atendimento',
      );
      expect(RequestCategory.sanitizeDropdownValue('visita'), 'visita');
      expect(RequestCategory.sanitizeDropdownValue('agenda'), 'atendimento');
    });

    test('sanitizeDropdownValue retorna null para valor inexistente', () {
      expect(RequestCategory.sanitizeDropdownValue('xyz_inexistente'), isNull);
      expect(RequestCategory.sanitizeDropdownValue(''), isNull);
      expect(RequestCategory.sanitizeDropdownValue(null), isNull);
    });

    test('sanitizeDropdownValue com lista vazia retorna null', () {
      expect(
        RequestCategory.sanitizeDropdownValue(
          'atendimento',
          source: const [],
        ),
        isNull,
      );
    });

    test('dropdownCategories tem ids únicos', () {
      final items = RequestCategory.dropdownCategories();
      final ids = items.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, contains('atendimento'));
      expect(ids, contains('visita'));
      expect(ids, isNot(contains('agenda')));
    });
  });

  group('RequestStatusFilter', () {
    test('tryParse e matches cobrem os três cards do resumo', () {
      expect(RequestStatusFilter.tryParse('open'), RequestStatusFilter.open);
      expect(
        RequestStatusFilter.tryParse('in_progress'),
        RequestStatusFilter.inProgress,
      );
      expect(
        RequestStatusFilter.tryParse('resolved'),
        RequestStatusFilter.resolved,
      );

      final open = ProtocolSummary(id: 1, title: 'A', status: 'recebido');
      final andamento =
          ProtocolSummary(id: 2, title: 'B', status: 'encaminhado');
      final resolvida =
          ProtocolSummary(id: 3, title: 'C', status: 'encerrado');

      expect(RequestStatusFilter.open.matches(open), isTrue);
      expect(RequestStatusFilter.inProgress.matches(andamento), isTrue);
      expect(RequestStatusFilter.resolved.matches(resolvida), isTrue);
      expect(RequestStatusFilter.open.matches(resolvida), isFalse);
    });
  });

  group('NewRequestPage dropdown', () {
    testWidgets('agenda não crasha e normaliza para atendimento', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NewRequestPage(initialCategory: 'agenda'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nova solicitação'), findsOneWidget);
      expect(find.text('Agendamento de atendimento'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('visita não crasha o DropdownButton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NewRequestPage(initialCategory: 'visita'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nova solicitação'), findsOneWidget);
      expect(find.text('Solicitação de visita'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('valor inexistente usa placeholder sem crash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NewRequestPage(initialCategory: 'valor_inexistente'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nova solicitação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Navegação Home — conteúdo', () {
    testWidgets('notícias abrem detalhe', (tester) async {
      final item = MockNewsCatalog.items.first;
      await tester.pumpWidget(
        MaterialApp(
          home: CitizenNewsDetailPage(newsId: item.id),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(item.title), findsOneWidget);
      expect(find.text(item.category), findsOneWidget);
      expect(find.text('Voltar'), findsOneWidget);
    });

    testWidgets('lista de notícias mock renderiza', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CitizenNewsListPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Notícias'), findsOneWidget);
      expect(find.text(MockNewsCatalog.items.first.title), findsOneWidget);
    });

    testWidgets('Meu Bairro abre resumo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CitizenNeighborhoodPage(
            neighborhoodLabel: 'Taquaral · Campinas',
            unreadNotifications: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Taquaral'), findsOneWidget);
      expect(find.text('Campinas'), findsOneWidget);
      expect(find.textContaining('Nenhum aviso'), findsOneWidget);
    });

    testWidgets('detalhe de compromisso renderiza sem overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CitizenAppointmentDetailPage(
            title: 'Atendimento presencial com título bem longo para layout',
            when: '19/07 · 14:30',
            location: 'Gabinete do vereador — sala 2',
            status: 'scheduled',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Compromisso'), findsOneWidget);
    });
  });

  group('Widgets principais sem overflow', () {
    Future<void> pumpActionGrid(
      WidgetTester tester, {
      required Size size,
      required double textScale,
      required List<({IconData icon, String title, String description})> cards,
      double? legacyAspectRatio,
    }) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C5C)),
            ),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final items = cards.map(
                      (c) => (title: c.title, description: c.description),
                    );
                    final cross = FeatureActionGridMetrics.crossAxisCountFor(
                      constraints.maxWidth,
                      textScale: MediaQuery.textScalerOf(context).scale(1),
                    );
                    final aspect = legacyAspectRatio ??
                        FeatureActionGridMetrics.childAspectRatioFor(
                          context: context,
                          maxWidth: constraints.maxWidth,
                          items: items,
                        );
                    return GridView.count(
                      crossAxisCount: cross,
                      mainAxisSpacing: FeatureActionGridMetrics.spacing,
                      crossAxisSpacing: FeatureActionGridMetrics.spacing,
                      childAspectRatio: aspect,
                      children: [
                        for (final c in cards)
                          FeatureActionCard(
                            icon: c.icon,
                            title: c.title,
                            description: c.description,
                            onTap: () {},
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    const criticalCards = <({IconData icon, String title, String description})>[
      (
        icon: Icons.report_rounded,
        title: 'Fazer denúncia',
        description: 'Relate um problema',
      ),
      (
        icon: Icons.event_available_rounded,
        title: 'Agendar atendimento',
        description: 'Marque um horário',
      ),
      (
        icon: Icons.travel_explore_rounded,
        title: 'Acompanhar protocolo',
        description: 'Veja o andamento',
      ),
      (
        icon: Icons.upload_file_rounded,
        title: 'Enviar documento',
        description: 'Anexe arquivos',
      ),
      (
        icon: Icons.forum_rounded,
        title: 'Falar com o assistente',
        description: 'Tire dúvidas em tempo real',
      ),
    ];

    for (final width in [360.0, 393.0, 412.0, 800.0]) {
      for (final scale in [1.0, 1.3, 1.5]) {
        testWidgets(
          'FeatureActionCard ${width.toInt()}dp scale $scale sem overflow',
          (tester) async {
            await pumpActionGrid(
              tester,
              size: Size(width, 900),
              textScale: scale,
              cards: criticalCards,
            );
            expect(tester.takeException(), isNull);
            for (final card in criticalCards) {
              expect(find.text(card.title), findsOneWidget);
            }
          },
        );
      }
    }

    testWidgets('FeatureActionCard no grid do telefone não estoura', (tester) async {
      await pumpActionGrid(
        tester,
        size: const Size(360, 640),
        textScale: 1.3,
        cards: const [
          (
            icon: Icons.report_problem_outlined,
            title: 'Registrar reclamação',
            description:
                'Relate problemas e acompanhe o protocolo com detalhes longos',
          ),
          (
            icon: Icons.event_available_outlined,
            title: 'Agendar atendimento presencial',
            description: 'Marque visita ou horário no gabinete do vereador',
          ),
        ],
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Registrar reclamação'), findsOneWidget);
      expect(find.text('Agendar atendimento presencial'), findsOneWidget);
    });

    testWidgets('FeatureActionCard resiste a aspect ratio legado 1.05', (tester) async {
      await pumpActionGrid(
        tester,
        size: const Size(360, 640),
        textScale: 1.3,
        legacyAspectRatio: 1.05,
        cards: const [
          (
            icon: Icons.help_outline,
            title: 'Título longo de ação rápida do cidadão',
            description:
                'Descrição longa que antes estourava o grid da Home',
          ),
        ],
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('títulos críticos cabem em 360dp sem reticências forçadas', (tester) async {
      await pumpActionGrid(
        tester,
        size: const Size(360, 900),
        textScale: 1.0,
        cards: criticalCards,
      );

      for (final card in criticalCards) {
        final text = tester.widget<Text>(find.text(card.title));
        expect(text.maxLines, FeatureActionCard.titleMaxLines);
        final render = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: find.widgetWithText(FeatureActionCard, card.title),
            matching: find.text(card.title),
          ),
        );
        expect(
          render.didExceedMaxLines,
          isFalse,
          reason: 'Título "${card.title}" não deveria precisar de ellipsis',
        );
      }
    });

    testWidgets('AgendaMiniCard e NewsCard não estourom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  AgendaMiniCard(
                    title: 'Compromisso com texto extremamente longo para overflow',
                    when: '18/07 · 10:00',
                    location: 'Localização também bem longa para testar ellipsis',
                    onTap: () {},
                  ),
                  NewsCard(
                    item: NewsItem(
                      id: 't1',
                      title: 'Título de notícia muito longo para forçar ellipsis no card',
                      summary:
                          'Resumo igualmente longo para garantir que o layout não estoure a altura fixa do card horizontal.',
                      category: 'Bairro',
                      publishedAt: DateTime(2026, 7, 18),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('SectionHeader Agenda/Notícias são clicáveis', (tester) async {
      var agenda = 0;
      var news = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SectionHeader(
                  title: 'Agenda',
                  actionLabel: 'Ver todos',
                  onAction: () => agenda++,
                  onTitleTap: () => agenda++,
                ),
                SectionHeader(
                  title: 'Últimas notícias',
                  actionLabel: 'Ver todas',
                  onAction: () => news++,
                  onTitleTap: () => news++,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ver todos'));
      await tester.tap(find.text('Ver todas'));
      await tester.pump();
      expect(agenda, 1);
      expect(news, 1);
    });
  });

  group('CitizenRequestsPage filtro', () {
    test('queryValue dos três cards do resumo', () {
      expect(RequestStatusFilter.open.queryValue, 'open');
      expect(RequestStatusFilter.inProgress.queryValue, 'in_progress');
      expect(RequestStatusFilter.resolved.queryValue, 'resolved');
    });
  });
}
