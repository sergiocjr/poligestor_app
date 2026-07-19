import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import 'assistant_models.dart';

/// Provider HTTP do assistente portal.
class AssistantRepository {
  AssistantRepository(this._api);

  final ApiClient _api;

  static const path = '/v1/portal/assistant/message';
  static const conversationPath = '/v1/portal/assistant/conversation';
  static const maxAttempts = 2;
  static const connectTimeout = Duration(seconds: 20);
  static const sendTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 60);
  static const retryDelay = Duration(milliseconds: 500);

  /// Carrega a conversa ativa.
  ///
  /// - 200 com mensagens → conversa completa
  /// - 200 sem mensagens → conversa vazia (mantém conversation_id)
  /// - 404 → conversa vazia
  Future<AssistantConversation> fetchConversation({String? tenantSlug}) async {
    try {
      final envelope = await _api.getEnvelope<AssistantConversation>(
        conversationPath,
        mode: AuthMode.portal,
        tenantSlug: tenantSlug,
        parse: (raw) {
          if (raw == null) return AssistantConversation.empty();
          if (raw is Map) {
            return AssistantConversation.fromJson(
              AssistantReply.asStringKeyMap(raw),
            );
          }
          throw const FormatException(
            'Resposta inválida de /v1/portal/assistant/conversation',
          );
        },
      );
      final conversation = envelope.data;
      _debugLogFetch(status: 200, conversation: conversation);
      return conversation;
    } on ApiException catch (e) {
      _debugLogFetch(status: e.statusCode, conversation: null, error: e);
      if (e.statusCode == 404) return AssistantConversation.empty();
      rethrow;
    }
  }

  void _debugLogFetch({
    int? status,
    AssistantConversation? conversation,
    Object? error,
  }) {
    if (!kDebugMode) return;
    if (conversation != null) {
      conversation.debugLogMeta(httpStatus: status);
      return;
    }
    debugPrint(
      '[assistant.conversation] status=${status ?? '-'} '
      'error=${error is ApiException ? error.statusCode : error.runtimeType} '
      'conversation_id=- messages_count=- finished=-',
    );
  }

  /// Limpa o histórico no servidor para iniciar uma nova conversa.
  Future<void> clearConversation({String? tenantSlug}) async {
    try {
      await _api.deleteEnvelope<bool>(
        conversationPath,
        mode: AuthMode.portal,
        tenantSlug: tenantSlug,
        parse: (_) => true,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405) {
        await _api.postEnvelope<bool>(
          '$conversationPath/new',
          data: const <String, dynamic>{},
          mode: AuthMode.portal,
          tenantSlug: tenantSlug,
          parse: (_) => true,
        );
        return;
      }
      rethrow;
    }
  }

  Future<AssistantReply> sendMessage(
    String message, {
    String? tenantSlug,
  }) async {
    final text = message.trim();
    if (text.isEmpty) {
      throw ApiException(message: 'Mensagem vazia.', statusCode: 422);
    }

    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await _sendOnce(text, tenantSlug: tenantSlug);
      } catch (e) {
        lastError = e;
        final canRetry = attempt < maxAttempts && isRetryable(e);
        if (!canRetry) rethrow;
        await Future<void>.delayed(retryDelay);
      }
    }
    throw lastError ?? ApiException(message: 'Falha ao contatar o assistente.');
  }

  Future<AssistantReply> _sendOnce(String message, {String? tenantSlug}) async {
    final envelope = await _api.postEnvelope<AssistantReply>(
      path,
      data: {'message': message},
      mode: AuthMode.portal,
      tenantSlug: tenantSlug,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      parse: (raw) {
        if (raw is Map) {
          return AssistantReply.fromJson(AssistantReply.asStringKeyMap(raw));
        }
        throw const FormatException(
          'Resposta inválida de /v1/portal/assistant/message',
        );
      },
    );
    return envelope.data;
  }

  @visibleForTesting
  static bool isRetryable(Object error) {
    if (error is! ApiException) return false;
    final status = error.statusCode;
    if (status != null && status >= 500) return true;
    final msg = error.message.toLowerCase();
    return status == null ||
        msg.contains('tempo esgotado') ||
        msg.contains('conexão') ||
        msg.contains('connection') ||
        msg.contains('timeout');
  }
}
