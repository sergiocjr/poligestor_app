import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_mode.dart';
import 'mandate_cache.dart';
import 'mandate_models.dart';

class MandateFilter {
  const MandateFilter({
    this.from,
    this.to,
    this.period,
    this.assigneeId,
    this.category,
    this.district,
    this.status,
    this.page,
    this.perPage,
    this.q,
    this.type,
  });

  final String? from;
  final String? to;

  /// today | 7d | month
  final String? period;
  final String? assigneeId;
  final String? category;
  final String? district;
  final String? status;
  final int? page;
  final int? perPage;
  final String? q;
  final String? type;

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      q[k] = v;
    }

    put('from', from);
    put('to', to);
    put('period', period);
    put('assignee_id', assigneeId);
    put('category', category);
    put('district', district);
    put('status', status);
    put('page', page);
    put('per_page', perPage);
    put('q', this.q);
    put('type', type);
    return q;
  }
}

class MandateRepository {
  MandateRepository(this._api, {MandateCache? cache})
    : _cache = cache ?? MandateCache();

  final ApiClient _api;
  final MandateCache _cache;

  static const _staff = AuthMode.staff;

  Future<MandateExecutive> executive({
    MandateFilter filter = const MandateFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateExecutivePath,
        mode: _staff,
        query: filter.toQuery(),
        parse: asMap,
      );
      await _cache.put('executive', envelope.data);
      return MandateExecutive.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('executive');
      if (cached != null) {
        return MandateExecutive.fromJson(
          cached.data,
          fromCache: true,
          cacheAgeLabel: cached.ageLabel,
        );
      }
      rethrow;
    }
  }

  Future<MandateBriefing> briefing({
    MandateFilter filter = const MandateFilter(),
  }) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      _staff.mandateBriefingPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: asMap,
    );
    return MandateBriefing.fromJson(envelope.data);
  }

  Future<MandateNeighborhoodsData> neighborhoods({
    MandateFilter filter = const MandateFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateNeighborhoodsPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: asMap,
      );
      await _cache.put('neighborhoods', envelope.data);
      return MandateNeighborhoodsData.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('neighborhoods');
      if (cached != null) {
        return MandateNeighborhoodsData.fromJson(cached.data);
      }
      rethrow;
    }
  }

  Future<MandateSubjectsData> subjects({
    MandateFilter filter = const MandateFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateSubjectsPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: asMap,
      );
      await _cache.put('subjects', envelope.data);
      return MandateSubjectsData.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('subjects');
      if (cached != null) {
        return MandateSubjectsData.fromJson(cached.data);
      }
      rethrow;
    }
  }

  Future<MandateTeamData> team({
    MandateFilter filter = const MandateFilter(),
  }) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      _staff.mandateTeamPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: asMap,
    );
    return MandateTeamData.fromJson(envelope.data);
  }

  Future<MandateAgendaData> agenda({
    MandateFilter filter = const MandateFilter(),
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        _staff.mandateAgendaPath,
        mode: _staff,
        query: filter.toQuery(),
        parse: asMap,
      );
      await _cache.put('agenda', envelope.data);
      return MandateAgendaData.fromJson(envelope.data);
    } catch (e) {
      if (!allowCache) rethrow;
      final cached = await _cache.get('agenda');
      if (cached != null) {
        return MandateAgendaData.fromJson(cached.data);
      }
      rethrow;
    }
  }

  Future<MandateSearchData> search({required String query}) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      _staff.mandateSearchPath,
      mode: _staff,
      query: {'q': query},
      parse: asMap,
    );
    return MandateSearchData.fromJson(envelope.data);
  }

  Future<MandateReportsData> reports({
    MandateFilter filter = const MandateFilter(),
  }) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      _staff.mandateReportsPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: asMap,
    );
    return MandateReportsData.fromJson(envelope.data);
  }

  Future<MandateTvData> tv({
    MandateFilter filter = const MandateFilter(),
  }) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      _staff.mandateTvPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: asMap,
    );
    return MandateTvData.fromJson(envelope.data);
  }

  Future<MandateMapData> map({
    MandateFilter filter = const MandateFilter(),
  }) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      _staff.mandateMapPath,
      mode: _staff,
      query: filter.toQuery(),
      parse: asMap,
    );
    return MandateMapData.fromJson(envelope.data);
  }
}
