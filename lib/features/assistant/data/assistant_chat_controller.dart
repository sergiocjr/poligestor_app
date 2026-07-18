import '../domain/chat_message.dart';
import 'assistant_models.dart';
import 'assistant_repository.dart';

typedef FetchConversation = Future<AssistantConversation> Function();

/// Estado de carregamento/restauração da conversa (testável sem UI).
class AssistantChatController {
  AssistantChatController({
    AssistantRepository? repository,
    FetchConversation? fetchConversation,
    AssistantReplyPresenter? presenter,
  })  : _repository = repository,
        _fetchConversation = fetchConversation,
        presenter = presenter ?? AssistantReplyPresenter() {
    assert(
      repository != null || fetchConversation != null,
      'Informe repository ou fetchConversation',
    );
  }

  final AssistantRepository? _repository;
  final FetchConversation? _fetchConversation;
  final AssistantReplyPresenter presenter;

  final List<ChatMessage> messages = [];
  String? conversationId;
  bool finished = false;
  List<dynamic> pendingRequests = const [];
  bool loading = false;
  bool loadedOnce = false;
  String? loadError;

  Future<AssistantConversation> _fetch() {
    final custom = _fetchConversation;
    if (custom != null) return custom();
    return _repository!.fetchConversation();
  }

  Future<void> loadConversation() async {
    loading = true;
    loadError = null;

    try {
      final conversation = await _fetch();
      conversationId = conversation.id ?? conversationId;
      finished = conversation.finished;
      pendingRequests = conversation.pendingRequests;
      // Deduplicação de cards de protocolo ao recarregar histórico.
      // Não limpa a conversa no servidor nem cria conversa nova.
      presenter.reset();

      if (conversation.hasMessages) {
        messages
          ..clear()
          ..addAll(conversation.toChatMessages(presenter: presenter));
      } else {
        messages
          ..clear()
          ..addAll(assistantWelcomeMessages());
      }
      // finished == true NÃO limpa o histórico — só indica fim do fluxo.
      loadedOnce = true;
    } catch (e) {
      // Não apaga histórico já carregado.
      rethrow;
    } finally {
      loading = false;
    }
  }

  /// Única ação local que limpa histórico (após confirmação + API clear).
  void clearLocalForNewConversation() {
    conversationId = null;
    finished = false;
    pendingRequests = const [];
    presenter.reset();
    messages
      ..clear()
      ..addAll(assistantWelcomeMessages());
    loadedOnce = true;
    loadError = null;
  }
}
