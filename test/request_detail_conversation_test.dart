import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/ux/user_messages.dart';
import 'package:poligestor_app/features/citizen/presentation/widgets/protocol_attendance_widgets.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';

ProtocolDetail _sampleDetail({
  int messageCount = 6,
  int historyCount = 4,
  int attachmentCount = 1,
}) {
  return ProtocolDetail.fromJson({
    'id': 'detail-conv-1',
    'title': 'Protocolo conversa/anexos',
    'number': 'PG-TEST-CONV',
    'status': 'recebido',
    'description': 'Descrição ' * 12,
    'created_at': '2026-07-18T10:00:00Z',
    'updated_at': '2026-07-18T15:00:00Z',
    'can_rate': false,
    'messages': [
      for (var i = 0; i < messageCount; i++)
        {
          'id': 'm$i',
          'body': 'Mensagem $i',
          'author': i.isEven ? 'you' : 'Gabinete',
          'author_role': i.isEven ? 'citizen' : 'staff',
          'created_at': '2026-07-18T12:0$i:00Z',
        },
    ],
    'timeline': [
      for (var i = 0; i < historyCount; i++)
        {
          'id': 'h$i',
          'type': 'created',
          'title': 'Evento $i',
          'created_at': '2026-07-18T11:0$i:00Z',
        },
    ],
    'attachments': [
      for (var i = 0; i < attachmentCount; i++)
        {
          'id': 'a$i',
          'name': 'arquivo_$i.jpg',
          'url': 'https://example.com/a$i.jpg',
          'mime_type': 'image/jpeg',
        },
    ],
    'links': {'read': '/v1/portal/protocols/1/read'},
  });
}

/// Arquitetura corrigida: scroll principal sem TextField; composer fora.
Widget _buildHarness({
  required ScrollController scrollController,
  required ProtocolDetail detail,
  required TextEditingController messageCtrl,
  bool composerBusy = false,
  bool conversationLoading = false,
  String? conversationError,
  VoidCallback? onRetryConversation,
  VoidCallback? onCancelPending,
  bool withPending = false,
  VoidCallback? onSend,
  VoidCallback? onPhoto,
}) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Detalhes da solicitação')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              key: const Key('request_detail_scroll'),
              controller: scrollController,
              primary: false,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(detail.title),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const Key('btn_anexo_foto'),
                        onPressed: composerBusy ? null : onPhoto,
                        child: const Text('Foto'),
                      ),
                      ...detail.attachments.map(
                        (a) => ProtocolAttachmentTile(attachment: a),
                      ),
                      if (withPending)
                        ProtocolAttachmentTile(
                          attachment: ProtocolAttachment(
                            id: 'pending-1',
                            name: 'pendente.jpg',
                          ),
                          progress: 0.4,
                          onCancel: onCancelPending,
                        ),
                      const SizedBox(height: 12),
                      ProtocolConversationPanel(
                        key: const Key('request_detail_conversation'),
                        messages: detail.messages,
                        loading: conversationLoading,
                        errorMessage: conversationError,
                        onRetry: onRetryConversation,
                      ),
                      ProtocolHistorySection(events: detail.history),
                      const SizedBox(height: 400),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Material(
            key: const Key('request_detail_composer_bar'),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (composerBusy)
                      const LinearProgressIndicator(minHeight: 2),
                    TextField(
                      key: const Key('request_detail_composer'),
                      controller: messageCtrl,
                      enabled: !composerBusy,
                      minLines: 1,
                      maxLines: 4,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                    ),
                    FilledButton(
                      key: const Key('btn_composer_send'),
                      onPressed: composerBusy ? null : onSend,
                      child: Text(composerBusy ? 'Enviando...' : 'Enviar'),
                    ),
                  ],
                ),
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

  group('Conversa/anexos anti-freeze', () {
    testWidgets('comments vazio mostra estado amigavel', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProtocolConversationPanel(messages: [])),
        ),
      );
      expect(find.text(UserMessages.emptyConversation), findsOneWidget);
    });

    testWidgets('comments carregado renderiza bolhas sem ListView', (
      tester,
    ) async {
      final detail = _sampleDetail(messageCount: 3);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolConversationPanel(messages: detail.messages),
          ),
        ),
      );
      expect(find.text('Mensagem 0'), findsOneWidget);
      expect(find.text('Mensagem 2'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(
        find.byKey(const Key('protocol_conversation_column')),
        findsOneWidget,
      );
    });

    testWidgets('erro da API fica no bloco com retry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolConversationPanel(
              messages: const [],
              errorMessage: 'Não foi possível carregar a conversa.',
              onRetry: () => retries++,
            ),
          ),
        ),
      );
      expect(
        find.text('Não foi possível carregar a conversa.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('conversation_retry')));
      expect(retries, 1);
    });

    testWidgets('loading da conversa nao usa AbsorbPointer global', (
      tester,
    ) async {
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildHarness(
          scrollController: scroll,
          detail: _sampleDetail(messageCount: 0),
          messageCtrl: message,
          conversationLoading: true,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is AbsorbPointer && w.absorbing),
        findsNothing,
      );
      expect(
        find.byKey(const Key('request_detail_blocking_overlay')),
        findsNothing,
      );
      // Composer continua presente (não coberto).
      expect(find.byKey(const Key('request_detail_composer')), findsOneWidget);
    });

    testWidgets('loading finaliza e libera interacao', (tester) async {
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildHarness(
          scrollController: scroll,
          detail: _sampleDetail(),
          messageCtrl: message,
          composerBusy: true,
        ),
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('btn_composer_send')))
            .onPressed,
        isNull,
      );

      await tester.pumpWidget(
        _buildHarness(
          scrollController: scroll,
          detail: _sampleDetail(),
          messageCtrl: message,
          composerBusy: false,
          onSend: () {},
        ),
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('btn_composer_send')))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('lista interna sem scroll proprio + composer fora', (
      tester,
    ) async {
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildHarness(
          scrollController: scroll,
          detail: _sampleDetail(),
          messageCtrl: message,
        ),
      );
      await tester.pumpAndSettle();

      final userScrollables = tester
          .widgetList<Scrollable>(find.byType(Scrollable))
          .where((s) => s.physics is! NeverScrollableScrollPhysics)
          .toList();
      expect(userScrollables, hasLength(1));

      // Composer está fora do CustomScrollView.
      expect(
        find.byKey(const Key('request_detail_composer_bar')),
        findsOneWidget,
      );

      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, -1800),
      );
      await tester.pumpAndSettle();
      final bottom = scroll.offset;
      expect(bottom, greaterThan(80));

      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, 1800),
      );
      await tester.pumpAndSettle();
      expect(scroll.offset, lessThan(bottom));
    });

    testWidgets('cancelar anexo libera interacao', (tester) async {
      var cancelled = false;
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildHarness(
          scrollController: scroll,
          detail: _sampleDetail(attachmentCount: 0),
          messageCtrl: message,
          withPending: true,
          onCancelPending: () => cancelled = true,
          onPhoto: () {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cancelar'));
      await tester.pump();
      expect(cancelled, isTrue);

      await tester.tap(find.byKey(const Key('btn_anexo_foto')));
      await tester.pump();
    });

    testWidgets('clique apos rolar ate conversa/anexos', (tester) async {
      var taps = 0;
      final scroll = ScrollController();
      final message = TextEditingController();
      addTearDown(() {
        scroll.dispose();
        message.dispose();
      });

      await tester.pumpWidget(
        _buildHarness(
          scrollController: scroll,
          detail: _sampleDetail(),
          messageCtrl: message,
          onPhoto: () => taps++,
          onSend: () => taps += 10,
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, -1600),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('request_detail_scroll')),
        const Offset(0, 1600),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_anexo_foto')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('btn_composer_send')));
      await tester.pump();
      expect(taps, 11);
    });

    testWidgets('comments vazios nao sao erro', (tester) async {
      final empty = ProtocolDetail.fromJson({
        'id': 1,
        'title': 'T',
        'comments': <dynamic>[],
        'timeline': <dynamic>[],
        'attachments': <dynamic>[],
      });
      expect(empty.messages, isEmpty);
      expect(empty.attachments, isEmpty);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolConversationPanel(messages: empty.messages),
          ),
        ),
      );
      expect(find.text(UserMessages.emptyConversation), findsOneWidget);
      expect(find.byKey(const Key('conversation_retry')), findsNothing);
    });
  });
}
