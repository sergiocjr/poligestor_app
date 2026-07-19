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
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Text(
                            detail.title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
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
                          ProtocolConversationPanel(messages: detail.messages),
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
          ),
          Material(
            key: const Key('request_detail_composer_bar'),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (blocking) const LinearProgressIndicator(minHeight: 2),
                  TextField(
                    key: const Key('request_detail_composer'),
                    controller: messageCtrl,
                    enabled: !blocking,
                    minLines: 1,
                    maxLines: 4,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                  ),
                  FilledButton(
                    key: const Key('btn_enviar'),
                    onPressed: blocking ? null : onSend,
                    child: Text(blocking ? 'Enviando...' : 'Enviar'),
                  ),
                ],
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

      expect(find.byKey(const Key('request_detail_scroll')), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, -2500),
      );
      await tester.pumpAndSettle();
      final atBottom = scroll.offset;
      expect(atBottom, greaterThan(100));

      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, 2500),
      );
      await tester.pumpAndSettle();
      expect(scroll.offset, lessThan(atBottom));
      expect(scroll.offset, lessThan(80));
    });

    testWidgets('composer fora do scroll nao captura gesto vertical', (
      tester,
    ) async {
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

      expect(
        find.byKey(const Key('request_detail_composer_bar')),
        findsOneWidget,
      );

      final before = scroll.offset;
      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
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

    testWidgets('busy nao usa overlay AbsorbPointer na tela', (tester) async {
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
        find.byWidgetPredicate((w) => w is AbsorbPointer && w.absorbing),
        findsNothing,
      );
      expect(
        find.byKey(const Key('request_detail_blocking_overlay')),
        findsNothing,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('btn_enviar')))
            .onPressed,
        isNull,
      );

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
        tester
            .widget<FilledButton>(find.byKey(const Key('btn_enviar')))
            .onPressed,
        isNotNull,
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

      final userScrollables = tester
          .widgetList<Scrollable>(find.byType(Scrollable))
          .where((s) => s.physics is! NeverScrollableScrollPhysics)
          .toList();
      expect(userScrollables, hasLength(1));

      final composer = tester.widget<TextField>(
        find.byKey(const Key('request_detail_composer')),
      );
      expect(composer.scrollPhysics, isA<NeverScrollableScrollPhysics>());
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
