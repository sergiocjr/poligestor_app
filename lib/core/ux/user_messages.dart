import '../api/api_exception.dart';
import '../../features/protocols/data/protocols_repository.dart';

/// Mensagens amigáveis para a interface — nunca expor detalhes técnicos.
class UserMessages {
  UserMessages._();

  static const syncFailed = 'Não foi possível sincronizar seus dados.';
  static const homeUpdateFailed = 'Não foi possível atualizar seus dados.';
  static const offline = 'Você parece estar offline. Verifique a conexão.';
  static const emptyRequests = 'Você ainda não tem solicitações.';
  static const emptyNotifications = 'Nenhuma notificação por enquanto.';
  static const emptyAgenda = 'Nenhum compromisso agendado.';
  static const generic = 'Algo deu errado. Tente novamente em instantes.';
  static const uploadFailed =
      'Não foi possível enviar o arquivo. Tente novamente.';
  static const uploadCanceled = 'Envio cancelado.';
  static const messageSent = 'Mensagem enviada.';
  static const ratingSent = 'Obrigado! Sua avaliação foi registrada.';
  static const ratingUnavailable =
      'A avaliação ainda não está disponível para esta solicitação.';
  static const openAttachmentFailed =
      'Não foi possível abrir o anexo. Tente novamente.';
  static const emptyConversation = 'Ainda não há mensagens nesta solicitação.';
  static const emptyHistory = 'Ainda não há atualizações no histórico.';
  static const assistantFailed =
      'Não foi possível obter resposta do assistente. Tente novamente.';
  static const conversationLoadFailed =
      'Não foi possível carregar a conversa anterior.';
  static const locationDenied = 'Precisamos da sua permissão de localização.';
  static const locationUnavailable = 'Não foi possível obter a localização.';
  static const protocolNotFound = 'Esta solicitação não foi encontrada.';
  static const protocolNoAccess = 'Você não tem acesso a esta solicitação.';
  static const protocolOpenFailed =
      'Não foi possível abrir a solicitação. Tente novamente.';
  static const notificationWithoutProtocol =
      'Este aviso não possui uma solicitação válida.';
  static const notificationMarkReadFailed =
      'O aviso foi aberto, mas não foi possível marcá-lo como lido.';

  /// Erros de autenticação (login / OAuth / cadastro).
  static String fromAuthError(Object? error) {
    if (error is ApiException) {
      if (error.isUnauthorized) {
        return 'Credenciais inválidas ou sessão expirada.';
      }
      if (error.isForbidden) {
        return 'Você não tem permissão para acessar esta organização.';
      }
      if (error.statusCode == 429) {
        return 'Muitas tentativas. Aguarde um momento e tente novamente.';
      }
      if (error.statusCode == 503 || error.statusCode == 501) {
        return 'Serviço de autenticação indisponível no momento.';
      }
      if (error.isValidation) {
        return error.message.isNotEmpty
            ? error.message
            : 'Revise os dados informados e tente novamente.';
      }
      if (error.statusCode == null &&
          (error.message.toLowerCase().contains('conexão') ||
              error.message.toLowerCase().contains('connection'))) {
        return offline;
      }
      if (error.message.isNotEmpty) return error.message;
    }
    return fromError(error);
  }

  /// Erros da Home/sessão — mantém mensagem genérica de sincronização.
  static String fromError(Object? error) {
    if (error is ProtocolFeatureUnavailable) {
      return error.message;
    }
    if (error is ApiException) {
      if (error.isUnauthorized) {
        return 'Sessão expirada. Entre novamente para continuar.';
      }
      if (error.isForbidden) {
        return 'Você não tem permissão para este recurso.';
      }
      if (error.message.toLowerCase().contains('tempo esgotado') ||
          error.message.toLowerCase().contains('timeout')) {
        return assistantFailed;
      }
      if (error.statusCode == null &&
          (error.message.toLowerCase().contains('conexão') ||
              error.message.toLowerCase().contains('connection'))) {
        return offline;
      }
      if (error.isValidation) {
        return 'Revise os dados informados e tente novamente.';
      }
      return syncFailed;
    }
    final raw = error?.toString().toLowerCase() ?? '';
    if (raw.contains('socket') ||
        raw.contains('network') ||
        raw.contains('connection') ||
        raw.contains('offline')) {
      return offline;
    }
    if (raw.contains('401') ||
        raw.contains('unauthenticated') ||
        raw.contains('apiexception')) {
      return syncFailed;
    }
    return syncFailed;
  }

  /// Erros ao abrir detalhe/aviso de protocolo — nunca usa [syncFailed].
  static String forProtocolError(Object? error) {
    if (error is ProtocolFeatureUnavailable) {
      return error.message;
    }
    if (error is ApiException) {
      if (error.statusCode == 404) return protocolNotFound;
      if (error.isForbidden) return protocolNoAccess;
      if (error.isUnauthorized) return protocolNoAccess;
      if (error.statusCode == null &&
          (error.message.toLowerCase().contains('conexão') ||
              error.message.toLowerCase().contains('connection') ||
              error.message.toLowerCase().contains('socket'))) {
        return offline;
      }
      if (error.message.toLowerCase().contains('tempo esgotado') ||
          error.message.toLowerCase().contains('timeout')) {
        return protocolOpenFailed;
      }
      return protocolOpenFailed;
    }
    final raw = error?.toString().toLowerCase() ?? '';
    if (raw.contains('socket') ||
        raw.contains('network') ||
        raw.contains('connection') ||
        raw.contains('offline')) {
      return offline;
    }
    if (raw.contains('404') || raw.contains('not found')) {
      return protocolNotFound;
    }
    return protocolOpenFailed;
  }
}
