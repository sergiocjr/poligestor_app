import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import 'assistant_models.dart';

/// Provider HTTP do assistente (POST /v1/portal/assistant/message).
/// Sem histórico, streaming ou WebSocket.
class AssistantRepository {
  AssistantRepository(this._api);

  final ApiClient _api;

  static const path = '/v1/portal/assistant/message';
  static const maxAttempts = 2;
  static const connectTimeout = Duration(seconds: 20);
  static const sendTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 60);
  static const retryDelay = Duration(milliseconds: 500);

  Future<AssistantReply> sendMessage(String message, {String? tenantSlug}) async {
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
        if (raw is Map<String, dynamic>) {
          return AssistantReply.fromJson(raw);
        }
        if (raw is Map) {
          return AssistantReply.fromJson(Map<String, dynamic>.from(raw));
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
