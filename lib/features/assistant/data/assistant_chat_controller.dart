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
      loadedOnce = true;
    } catch (e) {
      // Não apaga histórico já carregado.
      rethrow;
    } finally {
      loading = false;
    }
  }

  void clearLocalForNewConversation() {
    conversationId = null;
    presenter.reset();
    messages
      ..clear()
      ..addAll(assistantWelcomeMessages());
    loadedOnce = true;
    loadError = null;
  }
}
