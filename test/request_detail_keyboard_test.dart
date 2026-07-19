import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/features/citizen/presentation/widgets/protocol_attendance_widgets.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';

ProtocolDetail _detail() {
  return ProtocolDetail.fromJson({
    'id': 'kb-1',
    'title': 'Teclado e composer',
    'number': 'PG-KB-001',
    'status': 'recebido',
    'description': 'Desc',
    'messages': [
      for (var i = 0; i < 4; i++)
        {
          'id': 'm$i',
          'body': 'Mensagem $i',
          'author_role': i.isEven ? 'citizen' : 'staff',
          'created_at': '2026-07-18T12:0$i:00Z',
        },
    ],
    'timeline': const [],
    'attachments': const [],
  });
}

/// Espelha a estrutura final: Column + Expanded(lista) + composer no rodapé.
Widget _keyboardHarness({
  required TextEditingController messageCtrl,
  required FocusNode focusNode,
  required ScrollController scrollController,
  double viewInsetsBottom = 0,
  VoidCallback? onSend,
}) {
  final detail = _detail();
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(360, 640),
        viewInsets: EdgeInsets.only(bottom: viewInsetsBottom),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('Detalhes da solicitação')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                key: const Key('request_detail_scroll'),
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Text(detail.title),
                  ProtocolConversationPanel(messages: detail.messages),
                  const SizedBox(height: 200),
                ],
              ),
            ),
            Material(
              key: const Key('request_detail_composer_bar'),
              elevation: 4,
              child: SafeArea(
                top: false,
                bottom: viewInsetsBottom == 0,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('request_detail_composer'),
                          controller: messageCtrl,
                          focusNode: focusNode,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Escreva uma mensagem',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton.filled(
                        key: const Key('btn_composer_send'),
                        onPressed: onSend,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('composer visível com viewInsets (teclado aberto)', (
    tester,
  ) async {
    final ctrl = TextEditingController();
    final focus = FocusNode();
    final scroll = ScrollController();
    addTearDown(() {
      ctrl.dispose();
      focus.dispose();
      scroll.dispose();
    });

    await tester.pumpWidget(
      _keyboardHarness(
        messageCtrl: ctrl,
        focusNode: focus,
        scrollController: scroll,
        viewInsetsBottom: 280,
      ),
    );
    await tester.pumpAndSettle();

    final composer = find.byKey(const Key('request_detail_composer_bar'));
    expect(composer, findsOneWidget);
    expect(find.byKey(const Key('request_detail_composer')), findsOneWidget);

    final box = tester.getRect(composer);
    // Composer deve ficar acima da área do teclado (640 - 280 = 360).
    expect(box.bottom, lessThanOrEqualTo(360.0 + 1));
    expect(box.top, lessThan(box.bottom));
  });

  testWidgets('texto multilinha não gera overflow', (tester) async {
    final ctrl = TextEditingController(
      text: 'linha 1\nlinha 2\nlinha 3\nlinha 4',
    );
    final focus = FocusNode();
    final scroll = ScrollController();
    addTearDown(() {
      ctrl.dispose();
      focus.dispose();
      scroll.dispose();
    });

    await tester.pumpWidget(
      _keyboardHarness(
        messageCtrl: ctrl,
        focusNode: focus,
        scrollController: scroll,
        viewInsetsBottom: 280,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
    final field = tester.widget<TextField>(
      find.byKey(const Key('request_detail_composer')),
    );
    expect(field.maxLines, 3);
  });

  testWidgets('envio funciona com teclado aberto', (tester) async {
    final ctrl = TextEditingController(text: 'Oi gabinete');
    final focus = FocusNode();
    final scroll = ScrollController();
    var sent = false;
    addTearDown(() {
      ctrl.dispose();
      focus.dispose();
      scroll.dispose();
    });

    await tester.pumpWidget(
      _keyboardHarness(
        messageCtrl: ctrl,
        focusNode: focus,
        scrollController: scroll,
        viewInsetsBottom: 280,
        onSend: () => sent = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('btn_composer_send')));
    await tester.pump();
    expect(sent, isTrue);
  });

  testWidgets('fechamento do teclado mantém composer e scroll', (tester) async {
    final ctrl = TextEditingController();
    final focus = FocusNode();
    final scroll = ScrollController();
    addTearDown(() {
      ctrl.dispose();
      focus.dispose();
      scroll.dispose();
    });

    await tester.pumpWidget(
      _keyboardHarness(
        messageCtrl: ctrl,
        focusNode: focus,
        scrollController: scroll,
        viewInsetsBottom: 280,
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _keyboardHarness(
        messageCtrl: ctrl,
        focusNode: focus,
        scrollController: scroll,
        viewInsetsBottom: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('request_detail_composer_bar')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('request_detail_scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const Key('request_detail_scroll')),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(0));
  });

  testWidgets('Scaffold usa resizeToAvoidBottomInset', (tester) async {
    final ctrl = TextEditingController();
    final focus = FocusNode();
    final scroll = ScrollController();
    addTearDown(() {
      ctrl.dispose();
      focus.dispose();
      scroll.dispose();
    });

    await tester.pumpWidget(
      _keyboardHarness(
        messageCtrl: ctrl,
        focusNode: focus,
        scrollController: scroll,
      ),
    );
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.resizeToAvoidBottomInset, isTrue);
    expect(scaffold.bottomNavigationBar, isNull);
  });
}
