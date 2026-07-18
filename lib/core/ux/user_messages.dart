import '../api/api_exception.dart';

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
  static const sendFailed = 'Não foi possível enviar. Tente novamente.';
  static const assistantFailed =
      'Não foi possível obter resposta do assistente. Tente novamente.';
  static const locationDenied = 'Precisamos da sua permissão de localização.';
  static const locationUnavailable = 'Não foi possível obter a localização.';

  static String fromError(Object? error) {
    if (error is ApiException) {
      if (error.isUnauthorized || error.isForbidden) return syncFailed;
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
}
