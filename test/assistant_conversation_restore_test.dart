import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/api/api_exception.dart';
import 'package:poligestor_app/features/assistant/data/assistant_chat_controller.dart';
import 'package:poligestor_app/features/assistant/data/assistant_models.dart';
import 'package:poligestor_app/features/assistant/domain/chat_message.dart';

void main() {
  group('AssistantConversation parse (payload real)', () {
    test('histórico existente com role model/text e maps vazios/preenchidos', () {
      final conversation = AssistantConversation.fromJson({
        'conversation_id': '5371daf6-2bcf-4b0e-97c7-e796e08f3000',
        'messages': [
          {
            'role': 'user',
            'text': 'poste queimado',
            'created_at': '2026-07-18T02:11:12-03:00',
          },
          {
            'role': 'model',
            'text': 'Pode confirmar o endereço?',
            'created_at': '2026-07-18T02:11:20-03:00',
          },
        ],
        'state': {
          'intent': 'CREATE_PROTOCOL',
          'finished': false,
        },
        'slots_filled': {
          'problem': 'poste',
          'location': 'rua x',
        },
        'slots_pending': <dynamic>[],
        'finished': null,
      });

      expect(conversation.id, '5371daf6-2bcf-4b0e-97c7-e796e08f3000');
      expect(conversation.messages, hasLength(2));
      expect(conversation.messages[0].sender, ChatSender.user);
      expect(conversation.messages[1].sender, ChatSender.assistant);
      expect(conversation.messages[1].text, 'Pode confirmar o endereço?');
      expect(conversation.state['intent'], 'CREATE_PROTOCOL');
      expect(conversation.slotsFilled['problem'], 'poste');
      expect(conversation.slotsPending, isEmpty);
      expect(conversation.finished, isFalse);

      final chat = conversation.toChatMessages();
      expect(chat, hasLength(2));
      expect(chat.any((m) => m.id == 'welcome'), isFalse);
    });

    test('lista vazia mantém conversation_id e maps vazios', () {
      final conversation = AssistantConversation.fromJson({
        'conversation_id': 'c-empty',
        'messages': <dynamic>[],
        'state': <String, dynamic>{},
        'slots_filled': <String, dynamic>{},
        'slots_pending': <dynamic>[],
      });
      expect(conversation.id, 'c-empty');
      expect(conversation.hasMessages, isFalse);
      expect(conversation.state, isEmpty);
      expect(conversation.slotsFilled, isEmpty);
    });

    test('não trata Map de state como messages', () {
      final conversation = AssistantConversation.fromJson({
        'conversation_id': 'c1',
        'state': {'a': 1},
        'slots_filled': {'b': 2},
      });
      expect(conversation.hasMessages, isFalse);
      expect(conversation.state['a'], 1);
    });
  });

  group('AssistantChatController', () {
    test('histórico existente é carregado sem saudação', () async {
      var fetches = 0;
      final controller = AssistantChatController(
        fetchConversation: () async {
          fetches++;
          return AssistantConversation.fromJson({
            'conversation_id': 'c1',
            'messages': [
              {
                'role': 'user',
                'text': 'oi',
                'created_at': '2026-07-18T02:00:00Z',
              },
              {
                'role': 'model',
                'text': 'olá',
                'created_at': '2026-07-18T02:00:01Z',
              },
            ],
            'state': <String, dynamic>{},
            'slots_filled': <String, dynamic>{},
          });
        },
      );
      await controller.loadConversation();

      expect(fetches, 1);
      expect(controller.conversationId, 'c1');
      expect(controller.messages, hasLength(2));
      expect(controller.messages.first.text, 'oi');
      expect(
        controller.messages.any((m) => m.text?.contains('PoliGestor') == true),
        isFalse,
      );
    });

    test('lista vazia mostra saudação e preserva conversation_id', () async {
      final controller = AssistantChatController(
        fetchConversation: () async => AssistantConversation.empty(id: 'c-new'),
      );
      await controller.loadConversation();

      expect(controller.conversationId, 'c-new');
      expect(controller.messages, hasLength(1));
      expect(controller.messages.first.id, 'welcome');
    });

    test('saudação não é duplicada ao recarregar histórico', () async {
      var fetches = 0;
      final controller = AssistantChatController(
        fetchConversation: () async {
          fetches++;
          return AssistantConversation.fromJson({
            'conversation_id': 'c1',
            'messages': [
              {
                'role': 'user',
                'text': 'a',
                'created_at': '2026-07-18T02:00:00Z',
              },
              {
                'role': 'model',
                'text': 'b',
                'created_at': '2026-07-18T02:00:01Z',
              },
            ],
            'state': <String, dynamic>{},
            'slots_filled': <String, dynamic>{},
          });
        },
      );
      await controller.loadConversation();
      await controller.loadConversation();
      expect(controller.messages.where((m) => m.id == 'welcome'), isEmpty);
      expect(controller.messages, hasLength(2));
      expect(fetches, 2);
    });

    test('voltar e abrir (novo controller) mantém dados da API', () async {
      Future<AssistantConversation> fetch() async =>
          AssistantConversation.fromJson({
            'conversation_id': 'persist',
            'messages': [
              {
                'role': 'user',
                'text': '1',
                'created_at': '2026-07-18T02:00:00Z',
              },
              {
                'role': 'model',
                'text': '2',
                'created_at': '2026-07-18T02:00:01Z',
              },
              {
                'role': 'user',
                'text': '3',
                'created_at': '2026-07-18T02:00:02Z',
              },
            ],
            'state': <String, dynamic>{},
            'slots_filled': <String, dynamic>{},
          });

      final first = AssistantChatController(fetchConversation: fetch);
      await first.loadConversation();
      expect(first.messages, hasLength(3));

      final second = AssistantChatController(fetchConversation: fetch);
      await second.loadConversation();
      expect(second.conversationId, 'persist');
      expect(second.messages, hasLength(3));
      expect(second.messages.map((m) => m.text).toList(), ['1', '2', '3']);
    });

    test('reiniciar controller mantém dados vindos da API', () async {
      final payload = AssistantConversation.fromJson({
        'conversation_id': 'same',
        'messages': [
          {
            'role': 'user',
            'text': 'hist',
            'created_at': '2026-07-18T02:00:00Z',
          },
          {
            'role': 'model',
            'text': 'ok',
            'created_at': '2026-07-18T02:00:01Z',
          },
        ],
        'state': <String, dynamic>{},
        'slots_filled': <String, dynamic>{},
      });

      final a = AssistantChatController(
        fetchConversation: () async => payload,
      );
      await a.loadConversation();

      final b = AssistantChatController(
        fetchConversation: () async => payload,
      );
      await b.loadConversation();

      expect(b.conversationId, a.conversationId);
      expect(b.messages.length, a.messages.length);
      expect(b.messages.last.text, 'ok');
    });

    test('erro de rede não apaga histórico já carregado', () async {
      var fail = false;
      final controller = AssistantChatController(
        fetchConversation: () async {
          if (fail) {
            throw ApiException(message: 'Sem conexão com o servidor.');
          }
          return AssistantConversation.fromJson({
            'conversation_id': 'c1',
            'messages': [
              {
                'role': 'user',
                'text': 'ok',
                'created_at': '2026-07-18T02:00:00Z',
              },
              {
                'role': 'model',
                'text': 'certo',
                'created_at': '2026-07-18T02:00:01Z',
              },
            ],
            'state': <String, dynamic>{},
            'slots_filled': <String, dynamic>{},
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
  });
}
