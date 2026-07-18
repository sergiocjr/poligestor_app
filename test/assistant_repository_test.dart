import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/api/api_exception.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/core/ux/user_messages.dart';
import 'package:poligestor_app/features/assistant/data/assistant_models.dart';
import 'package:poligestor_app/features/assistant/data/assistant_repository.dart';

void main() {
  group('AssistantReply', () {
    test('parseia reply do envelope data', () {
      final reply = AssistantReply.fromJson({
        'reply': 'Olá! Como posso ajudar?',
        'intent': 'UNKNOWN',
        'conversation_id': 'abc',
      });
      expect(reply.reply, 'Olá! Como posso ajudar?');
    });

    test('falha quando reply está vazio', () {
      expect(
        () => AssistantReply.fromJson({'reply': '  '}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('AssistantRepository', () {
    test('path e timeouts estão definidos', () {
      expect(AssistantRepository.path, '/v1/portal/assistant/message');
      expect(AuthMode.portal.aiChatPath, AssistantRepository.path);
      expect(AssistantRepository.maxAttempts, 2);
      expect(
        AssistantRepository.receiveTimeout.inSeconds,
        greaterThanOrEqualTo(30),
      );
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
          ApiException(message: 'Sem conexão com o servidor.'),
        ),
        isTrue,
      );
      expect(
        AssistantRepository.isRetryable(
          ApiException(message: 'Erro', statusCode: 503),
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
