import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'smart_assistant_cache.dart';
import 'smart_assistant_models.dart';

/// Repositório Sprint 10.5 — contratos LIVE + pending honesto.
class SmartAssistantRepository {
  SmartAssistantRepository(this._api, {SmartAssistantCache? cache})
    : _cache = cache ?? SmartAssistantCache();

  final ApiClient _api;
  final SmartAssistantCache _cache;

  static const _staff = AuthMode.staff;

  Future<SaChatReply> sendGabineteMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty) {
      throw ApiException(message: 'Mensagem vazia.', statusCode: 422);
    }
    try {
      final envelope = await _api.postEnvelope<SaChatReply>(
        _staff.aiChatPath,
        mode: _staff,
        data: {'message': text},
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
        parse: (raw) => SaChatReply.fromJson(asMap(raw)),
      );
      return envelope.data;
    } on ApiException catch (e) {
      if (_isPending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.aiChatPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<List<SaConversationItem>> conversations({
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<List<SaConversationItem>>(
        _staff.aiConversationsPath,
        mode: _staff,
        parse: (raw) => asMapList(
          raw,
        ).map(SaConversationItem.fromJson).toList(growable: false),
      );
      await _cache.saveConversations(envelope.data);
      return envelope.data;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getConversations();
        if (cached != null) return cached;
      }
      if (e is ApiException && _isPending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.aiConversationsPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<SaBriefingView> daySummary({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<SaBriefingView>(
        _staff.mandateBriefingPath,
        mode: _staff,
        parse: (raw) => SaBriefingView.fromJson(asMap(raw)),
      );
      await _cache.saveBriefing(envelope.data);
      return envelope.data;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getBriefing();
        if (cached != null) return cached;
      }
      if (e is ApiException && _isPending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.mandateBriefingPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<SaBriefingView> briefings({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<SaBriefingView>(
        _staff.mandateBriefingsPath,
        mode: _staff,
        parse: (raw) => SaBriefingView.fromJson(asMap(raw)),
      );
      await _cache.saveBriefings(envelope.data);
      return envelope.data;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getBriefings();
        if (cached != null) return cached;
      }
      if (e is ApiException && _isPending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.mandateBriefingsPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<List<SaInsightItem>> insights({bool allowCache = true}) async {
    try {
      final envelope = await _api.getEnvelope<List<SaInsightItem>>(
        _staff.mandateInsightsPath,
        mode: _staff,
        parse: (raw) {
          final map = asMap(raw);
          final items = map['items'] ?? raw;
          return asMapList(
            items,
          ).map(SaInsightItem.fromJson).toList(growable: false);
        },
      );
      await _cache.saveInsights(envelope.data);
      return envelope.data;
    } catch (e) {
      if (allowCache) {
        final cached = await _cache.getInsights();
        if (cached != null) return cached;
      }
      if (e is ApiException && _isPending(e.statusCode)) {
        throw EndpointUnavailableException(
          _staff.mandateInsightsPath,
          statusCode: e.statusCode,
        );
      }
      rethrow;
    }
  }

  /// Paths ainda sem contrato publicado — UI usa pending após esta chamada.
  Future<void> assertPending(String path) async {
    try {
      await _api.getEnvelope<dynamic>(path, mode: _staff, parse: (raw) => raw);
    } on ApiException catch (e) {
      if (_isPending(e.statusCode)) {
        throw EndpointUnavailableException(path, statusCode: e.statusCode);
      }
      rethrow;
    }
  }

  Future<void> weeklySummary() =>
      assertPending(_staff.mandateSummaryWeeklyPath);
  Future<void> suggestions() => assertPending(_staff.mandateSuggestionsPath);
  Future<void> priorities() => assertPending(_staff.mandatePrioritiesPath);
  Future<void> questions() => assertPending(_staff.aiQuestionsPath);
  Future<void> favorites() => assertPending(_staff.aiFavoritesPath);
  Future<void> share() => assertPending(_staff.aiSharePath);
  Future<void> historyLegacy() => assertPending(_staff.aiHistoryPath);

  bool _isPending(int? code) =>
      code == 404 || code == 405 || code == 501 || code == 503;
}
