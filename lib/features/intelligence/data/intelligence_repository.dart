import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_mode.dart';
import 'intelligence_cache.dart';
import 'intelligence_models.dart';

class IntelligenceRepository {
  IntelligenceRepository(this._api, {IntelligenceCache? cache})
      : _cache = cache ?? IntelligenceCache();

  final ApiClient _api;
  final IntelligenceCache _cache;

  static const _staff = AuthMode.staff;

  Future<IntelligenceBriefingView> briefing({
    IntelligenceFilter filter = const IntelligenceFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateBriefingPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: asMap,
      );
      await _cache.put('briefing', envelope.data);
      return IntelligenceBriefingView(
        briefing: MandateBriefing.fromJson(envelope.data),
      );
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('briefing');
      if (cached != null) {
        return IntelligenceBriefingView(
          briefing: MandateBriefing.fromJson(cached.data),
          fromCache: true,
          cacheAgeLabel: cached.ageLabel,
        );
      }
      rethrow;
    }
  }

  Future<IntelligenceAnalyticsData> analytics({
    IntelligenceFilter filter = const IntelligenceFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateAnalyticsPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: asMap,
      );
      await _cache.put('analytics', envelope.data);
      return IntelligenceAnalyticsData.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('analytics');
      if (cached != null) {
        return IntelligenceAnalyticsData.fromJson(
          cached.data,
          fromCache: true,
          cacheAgeLabel: cached.ageLabel,
        );
      }
      rethrow;
    }
  }

  Future<IntelligenceTrendsData> trends({
    IntelligenceFilter filter = const IntelligenceFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateTrendsPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: asMap,
      );
      await _cache.put('trends', envelope.data);
      return IntelligenceTrendsData.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('trends');
      if (cached != null) {
        return IntelligenceTrendsData.fromJson(
          cached.data,
          fromCache: true,
          cacheAgeLabel: cached.ageLabel,
        );
      }
      rethrow;
    }
  }

  Future<IntelligenceInsightsData> insights({
    IntelligenceFilter filter = const IntelligenceFilter(),
    bool generate = false,
    bool allowCache = true,
  }) async {
    final q = IntelligenceFilter(
      period: filter.period,
      from: filter.from,
      to: filter.to,
      district: filter.district,
      category: filter.category,
      assigneeId: filter.assigneeId,
      generate: generate ? true : null,
    );
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateInsightsPath,
        mode: _staff,
        query: q.toQuery(),
        parse: asMap,
      );
      await _cache.put('insights', envelope.data);
      return IntelligenceInsightsData.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('insights');
      if (cached != null) {
        return IntelligenceInsightsData.fromJson(
          cached.data,
          fromCache: true,
          cacheAgeLabel: cached.ageLabel,
        );
      }
      rethrow;
    }
  }

  Future<IntelligenceBriefingsHistory> briefings({
    required String scope,
    IntelligenceFilter filter = const IntelligenceFilter(),
    bool allowCache = true,
  }) async {
    final q = IntelligenceFilter(
      period: filter.period,
      from: filter.from,
      to: filter.to,
      district: filter.district,
      category: filter.category,
      assigneeId: filter.assigneeId,
      scope: scope,
    );
    final cacheKey = 'briefings_$scope';
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateBriefingsPath,
        mode: _staff,
        query: q.toQuery(),
        parse: asMap,
      );
      await _cache.put(cacheKey, envelope.data);
      return IntelligenceBriefingsHistory.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get(cacheKey);
      if (cached != null) {
        return IntelligenceBriefingsHistory.fromJson(
          cached.data,
          fromCache: true,
          cacheAgeLabel: cached.ageLabel,
        );
      }
      rethrow;
    }
  }
}
