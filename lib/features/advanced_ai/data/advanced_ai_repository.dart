import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'advanced_ai_cache.dart';
import 'advanced_ai_models.dart';

/// IA Avançada — namespace oficial `/v1/ai/*` (Fase 18).
class AdvancedAiRepository {
  AdvancedAiRepository(this._api, {AdvancedAiCache? cache})
    : _cache = cache ?? AdvancedAiCache();

  final ApiClient _api;
  final AdvancedAiCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asAdvancedAiMap(data) : data,
    };
    if (meta != null) root['meta'] = meta;
    return root;
  }

  Future<T> _cachedGet<T>({
    required String tenantSlug,
    required String cacheKey,
    required String path,
    required T Function(
      Map<String, dynamic> root, {
      bool fromCache,
      String? age,
    })
    parse,
    Map<String, dynamic>? query,
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        path,
        mode: _staff,
        query: query,
        parse: (raw) => raw,
      );
      final root = _rootOf(envelope.data, envelope.meta);
      await _cache.putMap(tenantSlug, cacheKey, root);
      return parse(root, fromCache: false, age: null);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(path, statusCode: e.statusCode);
      }
      if (allowCache) {
        final cached = await _cache.getMap(tenantSlug, cacheKey);
        if (cached != null) {
          return parse(cached.data, fromCache: true, age: cached.ageLabel);
        }
      }
      rethrow;
    } catch (e) {
      if (e is EndpointUnavailableException) rethrow;
      if (allowCache) {
        final cached = await _cache.getMap(tenantSlug, cacheKey);
        if (cached != null) {
          return parse(cached.data, fromCache: true, age: cached.ageLabel);
        }
      }
      rethrow;
    }
  }

  List<AdvancedAiItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asAdvancedAiMapList(data)
        : asAdvancedAiMapList(asAdvancedAiMap(data));
    return list.map(AdvancedAiItem.fromJson).toList(growable: false);
  }

  Future<List<AdvancedAiItem>> _list(
    String tenantSlug,
    String cacheKey,
    String path, {
    Map<String, dynamic>? query,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: cacheKey,
    path: path,
    query: query,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<AaiChatReply> sendChatMessage(
    String message, {
    String? agentSlug,
  }) async {
    final text = message.trim();
    if (text.isEmpty) {
      throw ApiException(message: 'Mensagem vazia.', statusCode: 422);
    }
    try {
      final data = <String, dynamic>{'message': text};
      if (agentSlug != null && agentSlug.isNotEmpty) {
        data['agent_slug'] = agentSlug;
      }
      final envelope = await _api.postEnvelope<AaiChatReply>(
        _staff.aiChatPath,
        mode: _staff,
        data: data,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
        parse: (raw) => AaiChatReply.fromJson(asAdvancedAiMap(raw)),
      );
      return envelope.data;
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.aiChatPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  /// Papel via catálogo LIVE `/v1/ai/agents` (não inventa path dedicado).
  Future<AdvancedAiItem?> agentRole({
    required String tenantSlug,
    required String agentSlug,
  }) async {
    final items = await agents(tenantSlug: tenantSlug);
    for (final item in items) {
      final slug = asAdvancedAiString(item.raw['slug']) ?? item.id;
      if (slug == agentSlug) return item;
    }
    return null;
  }

  Future<Map<String, dynamic>> postSummary({
    required Map<String, dynamic> body,
  }) async {
    try {
      final envelope = await _api.postEnvelope<Map<String, dynamic>>(
        _staff.advancedAiSummaryPath,
        mode: _staff,
        data: body,
        parse: (raw) => asAdvancedAiMap(raw),
      );
      return envelope.data;
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.advancedAiSummaryPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postSuggestions({
    required Map<String, dynamic> body,
  }) async {
    try {
      final envelope = await _api.postEnvelope<Map<String, dynamic>>(
        _staff.advancedAiSuggestionsPath,
        mode: _staff,
        data: body,
        parse: (raw) => asAdvancedAiMap(raw),
      );
      return envelope.data;
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.advancedAiSuggestionsPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postFeedback({
    required Map<String, dynamic> body,
  }) async {
    try {
      final envelope = await _api.postEnvelope<Map<String, dynamic>>(
        _staff.advancedAiFeedbackPath,
        mode: _staff,
        data: body,
        parse: (raw) => asAdvancedAiMap(raw),
      );
      return envelope.data;
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.advancedAiFeedbackPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<List<AdvancedAiItem>> conversations({required String tenantSlug}) =>
      _list(tenantSlug, 'conversations', _staff.aiConversationsPath);

  Future<List<AdvancedAiItem>> history({required String tenantSlug}) =>
      _list(tenantSlug, 'history', _staff.aiHistoryPath);

  Future<List<AdvancedAiItem>> briefings({required String tenantSlug}) =>
      _list(tenantSlug, 'briefings', _staff.advancedAiBriefingsPath);

  Future<List<AdvancedAiItem>> prompts({required String tenantSlug}) =>
      _list(tenantSlug, 'prompts', _staff.advancedAiPromptsPath);

  Future<List<AdvancedAiItem>> agents({required String tenantSlug}) =>
      _list(tenantSlug, 'agents', _staff.aiAgentsCatalogPath);

  Future<List<AdvancedAiItem>> secretary({required String tenantSlug}) =>
      _list(tenantSlug, 'secretary', _staff.advancedAiSecretaryPath);

  Future<List<AdvancedAiItem>> virtualSecretary({required String tenantSlug}) =>
      _list(tenantSlug, 'virtual_secretary', _staff.advancedAiVirtualSecretaryPath);

  Future<List<AdvancedAiItem>> parliamentaryAdvisor({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'parliamentary_advisor',
    _staff.advancedAiParliamentaryAdvisorPath,
  );

  Future<List<AdvancedAiItem>> politicalAnalyst({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'political_analyst',
        _staff.advancedAiPoliticalAnalystPath,
      );

  Future<List<AdvancedAiItem>> financialAnalyst({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'financial_analyst',
        _staff.advancedAiFinancialAnalystPath,
      );

  Future<List<AdvancedAiItem>> communicationAdvisor({
    required String tenantSlug,
  }) => _list(
    tenantSlug,
    'communication_advisor',
    _staff.advancedAiCommunicationAdvisorPath,
  );

  Future<List<AdvancedAiItem>> legalAdvisor({required String tenantSlug}) =>
      _list(tenantSlug, 'legal_advisor', _staff.advancedAiLegalAdvisorPath);

  Future<List<AdvancedAiItem>> strategicPlanning({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'strategic_planning',
        _staff.advancedAiStrategicPlanningPath,
      );

  Future<List<AdvancedAiItem>> settings({required String tenantSlug}) =>
      _list(tenantSlug, 'settings', _staff.advancedAiSettingsPath);

  Future<List<AdvancedAiItem>> search({
    required String tenantSlug,
    required String query,
  }) => _list(
    tenantSlug,
    'search_${query.hashCode}',
    _staff.advancedAiSearchPath,
    query: {'q': query},
  );
}
