import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/api/api_exception.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/core/ux/user_messages.dart';
import 'package:poligestor_app/features/assistant/data/assistant_models.dart';
import 'package:poligestor_app/features/assistant/data/assistant_repository.dart';
import 'package:poligestor_app/features/assistant/domain/chat_message.dart';
import 'package:poligestor_app/features/assistant/presentation/widgets/protocol_created_card.dart';

void main() {
  group('AssistantReply protocol parse', () {
    test('parseia protocolo opcional completo', () {
      final reply = AssistantReply.fromJson({
        'reply': 'Protocolo criado com sucesso.',
        'intent': 'CREATE_PROTOCOL',
        'next_action': 'PROTOCOL_CREATED',
        'finished': true,
        'conversation_id': 'c1',
        'protocol': {
          'id': 'p-123',
          'number': 'PG-2026-000099',
          'status': 'aberto',
        },
      });

      expect(reply.reply, 'Protocolo criado com sucesso.');
      expect(reply.intent, 'CREATE_PROTOCOL');
      expect(reply.nextAction, 'PROTOCOL_CREATED');
      expect(reply.finished, isTrue);
      expect(reply.conversationId, 'c1');
      expect(reply.shouldShowProtocolCard, isTrue);
      expect(reply.protocol!.id, 'p-123');
      expect(reply.protocol!.number, 'PG-2026-000099');
      expect(reply.protocol!.status, 'aberto');
    });

    test('resposta sem protocolo não exibe card mesmo com PROTOCOL_CREATED', () {
      final reply = AssistantReply.fromJson({
        'reply': 'Quase lá.',
        'next_action': 'PROTOCOL_CREATED',
      });
      expect(reply.isProtocolCreated, isTrue);
      expect(reply.protocol, isNull);
      expect(reply.shouldShowProtocolCard, isFalse);
    });

    test('protocolo inválido/vazio é ignorado', () {
      final reply = AssistantReply.fromJson({
        'reply': 'Ok',
        'next_action': 'PROTOCOL_CREATED',
        'protocol': {'id': '', 'number': ''},
      });
      expect(reply.shouldShowProtocolCard, isFalse);
      expect(reply.protocol, isNull);
    });
  });

  group('AssistantReplyPresenter', () {
    test('cria card de sucesso e não duplica na reprocessamento', () {
      final presenter = AssistantReplyPresenter();
      var seq = 0;
      String nextId() => 'id-${seq++}';

      final reply = AssistantReply.fromJson({
        'reply': 'Pronto!',
        'next_action': 'PROTOCOL_CREATED',
        'protocol': {
          'id': 'p1',
          'number': 'PG-1',
          'status': 'aberto',
        },
      });

      final first = presenter.present(reply, nextId: nextId);
      expect(first, hasLength(2));
      expect(first.first.text, 'Pronto!');
      expect(first.last.isProtocolCard, isTrue);
      expect(first.last.protocol!.number, 'PG-1');

      final second = presenter.present(reply, nextId: nextId);
      expect(second, hasLength(1));
      expect(second.single.isProtocolCard, isFalse);
      expect(second.single.text, 'Pronto!');
    });

    test('atalhos de confirmação quando next_action pede confirmação', () {
      final presenter = AssistantReplyPresenter();
      final reply = AssistantReply.fromJson({
        'reply': 'Confirma os dados?',
        'next_action': 'ASK_CONFIRMATION',
      });
      final messages = presenter.present(reply, nextId: () => 'a1');
      expect(messages, hasLength(1));
      expect(messages.single.showConfirmShortcuts, isTrue);
      expect(messages.single.isProtocolCard, isFalse);
    });
  });

  group('ProtocolCreatedCard', () {
    testWidgets('exibe número, copia e navega ao acompanhar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      ChatProtocolInfo? tracked;
      var copied = false;
      String? copiedText;
      const protocol = ChatProtocolInfo(
        id: 'uuid-1',
        number: 'PG-2026-000042',
        status: 'aberto',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCreatedCard(
              protocol: protocol,
              onTrack: (p) => tracked = p,
              onCopied: () => copied = true,
              copyText: (value) async => copiedText = value,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('protocol-created-card')), findsOneWidget);
      expect(find.byKey(const Key('protocol-number')), findsOneWidget);
      expect(find.text('PG-2026-000042'), findsOneWidget);
      expect(find.text('Acompanhar solicitação'), findsOneWidget);

      await tester.tap(find.byKey(const Key('copy-protocol')));
      await tester.pump();
      expect(copied, isTrue);
      expect(copiedText, 'PG-2026-000042');
      expect(find.text('Número do protocolo copiado.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('track-request')));
      await tester.pump();
      expect(tracked?.id, 'uuid-1');
      expect(tracked?.number, 'PG-2026-000042');
    });

    testWidgets('não assume sucesso sem dados válidos no presenter', (tester) async {
      final presenter = AssistantReplyPresenter();
      final reply = AssistantReply.fromJson({
        'reply': 'Sem protocolo anexado.',
        'next_action': 'PROTOCOL_CREATED',
      });
      final messages = presenter.present(reply, nextId: () => 'x');
      expect(messages.where((m) => m.isProtocolCard), isEmpty);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SizedBox.shrink()),
        ),
      );
      expect(find.byKey(const Key('protocol-created-card')), findsNothing);
    });
  });

  group('AssistantRepository paths', () {
    test('paths e timeouts estão definidos', () {
      expect(AssistantRepository.path, '/v1/portal/assistant/message');
      expect(
        AssistantRepository.conversationPath,
        '/v1/portal/assistant/conversation',
      );
      expect(AuthMode.portal.aiChatPath, AssistantRepository.path);
    });

    test('retry só em erros transitórios', () {
      expect(
        AssistantRepository.isRetryable(
          ApiException(message: 'Tempo esgotado. Verifique sua conexão.'),
        ),
        isTrue,
      );
      expect(
        AssistantRepository.isRetryable(
          ApiException(message: 'Validação', statusCode: 422),
        ),
        isFalse,
      );
    });
  });

  group('UserMessages assistant', () {
    test('mapeia timeout para mensagem amigável do assistente', () {
      final msg = UserMessages.fromError(
        ApiException(message: 'Tempo esgotado. Verifique sua conexão.'),
      );
      expect(msg, UserMessages.assistantFailed);
    });
  });
}
