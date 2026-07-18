import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/features/citizen/presentation/widgets/protocol_attendance_widgets.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';

ProtocolDetail _sampleDetail({int messageCount = 8, int historyCount = 6}) {
  return ProtocolDetail.fromJson({
    'id': 'detail-scroll-1',
    'title': 'Protocolo para teste de scroll',
    'number': 'PG-TEST-001',
    'status': 'recebido',
    'description': 'Descrição longa ' * 20,
    'created_at': '2026-07-18T10:00:00Z',
    'updated_at': '2026-07-18T15:00:00Z',
    'can_rate': true,
    'messages': [
      for (var i = 0; i < messageCount; i++)
        {
          'id': 'm$i',
          'body': 'Mensagem de conversa número $i com texto suficiente.',
          'author': i.isEven ? 'you' : 'Gabinete',
          'author_role': i.isEven ? 'citizen' : 'staff',
          'created_at': '2026-07-18T1${i % 10}:00:00Z',
        },
    ],
    'timeline': [
      for (var i = 0; i < historyCount; i++)
        {
          'id': 'h$i',
          'type': i == 0 ? 'created' : 'status_changed',
          'title': 'Evento histórico $i',
          'description': 'Detalhe do evento $i',
          'created_at': '2026-07-18T1${i % 10}:30:00Z',
        },
    ],
    'attachments': [
      {
        'id': 'a1',
        'name': 'foto.jpg',
        'url': 'https://example.com/foto.jpg',
        'mime_type': 'image/jpeg',
      },
    ],
    'links': {'read': '/v1/portal/protocols/1/read'},
  });
}

/// Replica a arquitetura corrigida da tela de detalhes (um scroll + TextFields
/// sem physics própria) para validar o contrato anti-freeze.
Widget _buildDetailScrollHarness({
  required ScrollController scrollController,
  required ProtocolDetail detail,
  required TextEditingController messageCtrl,
  bool blocking = false,
  VoidCallback? onSend,
  VoidCallback? onPhoto,
}) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Detalhes da solicitação')),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification && n.dragDetails != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {},
              child: CustomScrollView(
                key: const Key('request_detail_scroll'),
                controller: scrollController,
                primary: false,
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(detail.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Text(detail.description ?? ''),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          key: const Key('btn_foto'),
                          onPressed: blocking ? null : onPhoto,
                          child: const Text('Foto'),
                        ),
                        ...detail.attachments.map(
                          (a) => ProtocolAttachmentTile(attachment: a),
                        ),
                        const SizedBox(height: 12),
                        ProtocolConversationPanel(
                          messages: detail.messages,
                          composer: TextField(
                            key: const Key('request_detail_composer'),
                            controller: messageCtrl,
                            minLines: 2,
                            maxLines: 5,
                            scrollPhysics:
                                const NeverScrollableScrollPhysics(),
                            decoration: const InputDecoration(
                              labelText: 'Escreva uma mensagem',
                            ),
                          ),
                        ),
                        FilledButton(
                          key: const Key('btn_enviar'),
                          onPressed: blocking ? null : onSend,
                          child: Text(blocking ? 'Enviando...' : 'Enviar'),
                        ),
                        const SizedBox(height: 12),
                        ProtocolHistorySection(events: detail.history),
                        const SizedBox(height: 12),
                        ProtocolRatingCard(
                          canRate: true,
                          canEdit: false,
                          existing: null,
                          busy: blocking,
                          onSubmit: (stars, resolved, comment) async {},
                        ),
                        const SizedBox(height: 400),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (blocking)
            const Positioned.fill(
              key: Key('request_detail_blocking_overlay'),
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RequestDetail scroll anti-freeze', () {
    testWidgets('consegue rolar até o fim e voltar ao topo', (tester) async {
      final scroll = ScrollController();
      final message = TextEditingController();
      final detail = _sampleDetail();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildDetailScrollHarness(
          scrollController: scroll,
          detail: detail,
          messageCtrl: message,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('request_detail_scroll')), findsOneWidget);

      // Desce até o final.
      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, -2500),
      );
      await tester.pumpAndSettle();
      final atBottom = scroll.offset;
      expect(atBottom, greaterThan(100));

      // Sobe de volta.
      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, 2500),
      );
      await tester.pumpAndSettle();
      expect(scroll.offset, lessThan(atBottom));
      expect(scroll.offset, lessThan(80));
    });

    testWidgets('TextField interno nao impede scroll do pai', (tester) async {
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildDetailScrollHarness(
          scrollController: scroll,
          detail: _sampleDetail(),
          messageCtrl: message,
        ),
      );
      await tester.pumpAndSettle();

      // Garante composer visível e arrasta a partir dele.
      await tester.ensureVisible(find.byKey(const Key('request_detail_composer')));
      await tester.pumpAndSettle();
      final before = scroll.offset;

      await tester.drag(
        find.byKey(const Key('request_detail_composer')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      expect(scroll.offset, greaterThan(before));
    });

    testWidgets('clique apos scroll continua funcionando', (tester) async {
      var taps = 0;
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildDetailScrollHarness(
          scrollController: scroll,
          detail: _sampleDetail(),
          messageCtrl: message,
          onPhoto: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, -1800),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, 1800),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_foto')));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('overlay de loading bloqueia e some depois', (tester) async {
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildDetailScrollHarness(
          scrollController: scroll,
          detail: _sampleDetail(),
          messageCtrl: message,
          blocking: true,
          onSend: () {},
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('request_detail_blocking_overlay')),
        findsOneWidget,
      );
      expect(find.byType(AbsorbPointer), findsWidgets);

      // Rebuild sem blocking.
      await tester.pumpWidget(
        _buildDetailScrollHarness(
          scrollController: scroll,
          detail: _sampleDetail(),
          messageCtrl: message,
          blocking: false,
          onSend: () {},
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('request_detail_blocking_overlay')),
        findsNothing,
      );
    });

    testWidgets('listas internas nao criam Scrollable proprio', (tester) async {
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildDetailScrollHarness(
          scrollController: scroll,
          detail: _sampleDetail(messageCount: 5, historyCount: 4),
          messageCtrl: message,
        ),
      );
      await tester.pumpAndSettle();

      // Só o CustomScrollView principal deve aceitar gesto vertical do usuário.
      // TextFields ainda têm Scrollable interno, mas com NeverScrollableScrollPhysics.
      final scrollables = tester.widgetList<Scrollable>(find.byType(Scrollable));
      final userScrollables = scrollables.where((s) {
        return s.physics is! NeverScrollableScrollPhysics;
      }).toList();
      expect(userScrollables, hasLength(1));
      expect(
        userScrollables.single.physics,
        isA<AlwaysScrollableScrollPhysics>(),
      );

      final composer = tester.widget<TextField>(
        find.byKey(
          const Key('request_detail_composer'),
          skipOffstage: false,
        ),
      );
      expect(composer.scrollPhysics, isA<NeverScrollableScrollPhysics>());

      // Avaliar physics do campo de avaliação em isolation (evita offstage no sliver).
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolRatingCard(
              canRate: true,
              canEdit: false,
              existing: null,
              busy: false,
              onSubmit: (stars, resolved, comment) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final ratingComment = tester.widget<TextField>(
        find.byKey(const Key('protocol_rating_comment')),
      );
      expect(
        ratingComment.scrollPhysics,
        isA<NeverScrollableScrollPhysics>(),
      );
    });

    testWidgets('reentrada na tela mantem scroll funcional', (tester) async {
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      Widget buildOnce() => _buildDetailScrollHarness(
            scrollController: scroll,
            detail: _sampleDetail(),
            messageCtrl: message,
          );

      await tester.pumpWidget(buildOnce());
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();

      // Simula sair/voltar.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(buildOnce());
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();
      expect(scroll.hasClients, isTrue);
      expect(scroll.offset, greaterThan(0));
    });
  });
}
