import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/api/api_exception.dart';
import 'package:poligestor_app/features/assistant/data/assistant_chat_controller.dart';
import 'package:poligestor_app/features/assistant/data/assistant_models.dart';
import 'package:poligestor_app/features/assistant/domain/chat_message.dart';

void main() {
  group('AssistantConversation parse (contrato atual)', () {
    test('slots_filled e state como Map vazio são válidos', () {
      final conversation = AssistantConversation.fromJson({
        'conversation_id': 'c-empty-maps',
        'messages': <dynamic>[],
        'state': <String, dynamic>{},
        'slots_filled': <String, dynamic>{},
        'slots_pending': <dynamic>[],
        'pending_requests': <dynamic>[],
        'finished': false,
        'last_interaction_at': null,
      });

      expect(conversation.id, 'c-empty-maps');
      expect(conversation.state, isEmpty);
      expect(conversation.slotsFilled, isEmpty);
      expect(conversation.slotsPending, isEmpty);
      expect(conversation.pendingRequests, isEmpty);
      expect(conversation.finished, isFalse);
      expect(conversation.hasMessages, isFalse);
    });

    test('parse de pending_requests preserva lista', () {
      final conversation = AssistantConversation.fromJson({
        'conversation_id': 'c1',
        'messages': <dynamic>[],
        'state': <String, dynamic>{},
        'slots_filled': <String, dynamic>{},
        'slots_pending': <dynamic>[],
        'pending_requests': [
          {
            'intent': 'OPEN_PROTOCOL',
            'problem': 'cachorro abandonado',
            'suggested_category': 'meio-ambiente',
          },
        ],
        'finished': false,
      });

      expect(conversation.pendingRequests, hasLength(1));
      expect(
        (conversation.pendingRequests.first as Map)['problem'],
        'cachorro abandonado',
      );
      expect(conversation.finished, isFalse);
    });

    test('ordena por seq crescente e ignora created_at', () {
      final conversation = AssistantConversation.fromJson({
        'conversation_id': 'c-seq',
        'messages': [
          {
            'role': 'model',
            'text': 'terceira',
            'seq': 3,
            'created_at': '2026-07-18T01:00:00Z',
          },
          {
            'role': 'user',
            'text': 'primeira',
            'seq': 1,
            'created_at': '2026-07-18T03:00:00Z',
          },
          {
            'role': 'model',
            'text': 'segunda',
            'seq': 2,
            'created_at': '2026-07-18T02:00:00Z',
          },
        ],
        'state': <String, dynamic>{},
        'slots_filled': <String, dynamic>{},
        'pending_requests': <dynamic>[],
        'finished': false,
      });

      expect(conversation.messages.map((m) => m.text).toList(), [
        'primeira',
        'segunda',
        'terceira',
      ]);
      expect(conversation.firstSeq, 1);
      expect(conversation.lastSeq, 3);
    });

    test('histórico com role model sem saudação', () {
      final conversation = AssistantConversation.fromJson({
        'conversation_id': 'c-hist',
        'messages': [
          {
            'role': 'user',
            'text': 'poste queimado',
            'seq': 1,
            'created_at': '2026-07-18T02:11:12-03:00',
          },
          {
            'role': 'model',
            'text': 'Qual o endereço?',
            'seq': 2,
            'created_at': '2026-07-18T02:11:20-03:00',
          },
        ],
        'state': {'intent': 'CREATE_PROTOCOL'},
        'slots_filled': {'problem': 'poste'},
        'slots_pending': <dynamic>[],
        'pending_requests': <dynamic>[],
        'finished': false,
        'last_interaction_at': '2026-07-18T02:11:20-03:00',
      });

      expect(conversation.messages, hasLength(2));
      expect(conversation.messages[1].sender, ChatSender.assistant);
      expect(conversation.lastInteractionAt, isNotNull);
      final chat = conversation.toChatMessages();
      expect(chat.any((m) => m.id == 'welcome'), isFalse);
    });
  });

  group('AssistantChatController', () {
    test('histórico carregado sem saudação duplicada', () async {
      final controller = AssistantChatController(
        fetchConversation: () async => AssistantConversation.fromJson({
          'conversation_id': 'c1',
          'messages': [
            {'role': 'user', 'text': 'oi', 'seq': 1},
            {'role': 'model', 'text': 'olá', 'seq': 2},
          ],
          'state': <String, dynamic>{},
          'slots_filled': <String, dynamic>{},
          'pending_requests': <dynamic>[],
          'finished': false,
        }),
      );
      await controller.loadConversation();
      await controller.loadConversation();

      expect(controller.messages.where((m) => m.id == 'welcome'), isEmpty);
      expect(controller.messages, hasLength(2));
      expect(controller.conversationId, 'c1');
    });

    test('finished true não limpa histórico', () async {
      final controller = AssistantChatController(
        fetchConversation: () async => AssistantConversation.fromJson({
          'conversation_id': 'c-done',
          'messages': [
            {'role': 'user', 'text': 'ok', 'seq': 1},
            {'role': 'model', 'text': 'protocolo criado', 'seq': 2},
          ],
          'state': <String, dynamic>{},
          'slots_filled': <String, dynamic>{},
          'pending_requests': <dynamic>[],
          'finished': true,
        }),
      );
      await controller.loadConversation();

      expect(controller.finished, isTrue);
      expect(controller.messages, hasLength(2));
      expect(controller.messages.last.text, 'protocolo criado');
      expect(controller.messages.any((m) => m.id == 'welcome'), isFalse);
    });

    test('reentrada na tela mantém mensagens da API', () async {
      Future<AssistantConversation> fetch() async =>
          AssistantConversation.fromJson({
            'conversation_id': 'persist',
            'messages': [
              {'role': 'user', 'text': '1', 'seq': 1},
              {'role': 'model', 'text': '2', 'seq': 2},
              {'role': 'user', 'text': '3', 'seq': 3},
            ],
            'state': <String, dynamic>{},
            'slots_filled': <String, dynamic>{},
            'pending_requests': [
              {'problem': 'segunda demanda'},
            ],
            'finished': false,
          });

      final first = AssistantChatController(fetchConversation: fetch);
      await first.loadConversation();
      expect(first.pendingRequests, hasLength(1));

      final second = AssistantChatController(fetchConversation: fetch);
      await second.loadConversation();
      expect(second.messages.map((m) => m.text).toList(), ['1', '2', '3']);
      expect(second.pendingRequests, hasLength(1));
      expect(second.finished, isFalse);
    });

    test('erro de rede não apaga histórico existente', () async {
      var fail = false;
      final controller = AssistantChatController(
        fetchConversation: () async {
          if (fail) {
            throw ApiException(message: 'Sem conexão com o servidor.');
          }
          return AssistantConversation.fromJson({
            'conversation_id': 'c1',
            'messages': [
              {'role': 'user', 'text': 'ok', 'seq': 1},
              {'role': 'model', 'text': 'certo', 'seq': 2},
            ],
            'state': <String, dynamic>{},
            'slots_filled': <String, dynamic>{},
            'pending_requests': <dynamic>[],
            'finished': false,
          });
        },
      );
      await controller.loadConversation();
      expect(controller.messages, hasLength(2));

      fail = true;
      await expectLater(
        controller.loadConversation(),
        throwsA(isA<ApiException>()),
      );
      expect(controller.messages, hasLength(2));
      expect(controller.messages.first.text, 'ok');
      expect(controller.conversationId, 'c1');
    });

    test('lista vazia mostra saudação', () async {
      final controller = AssistantChatController(
        fetchConversation: () async => AssistantConversation.empty(id: 'c-new'),
      );
      await controller.loadConversation();
      expect(controller.messages.single.id, 'welcome');
      expect(controller.conversationId, 'c-new');
    });
  });
}
