import 'package:flutter/material.dart';
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
