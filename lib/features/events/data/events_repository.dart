import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'events_cache.dart';
import 'events_models.dart';

/// Painel de Eventos — namespace oficial LIVE `/v1/events`.
class EventsRepository {
  EventsRepository(this._api, {EventsCache? cache})
    : _cache = cache ?? EventsCache();

  final ApiClient _api;
  final EventsCache _cache;
  static const _staff = AuthMode.staff;

  /// 500: subpaths ainda colidem com `{id}` na VPS (não são contratos publicados).
  bool _pending(int? c) =>
      c == 404 || c == 405 || c == 501 || c == 503 || c == 500;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asEventsMap(data) : data,
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
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        path,
        mode: _staff,
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

  List<EventsItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asEventsMapList(data)
        : asEventsMapList(asEventsMap(data));
    return list.map(EventsItem.fromJson).toList(growable: false);
  }

  Future<List<EventsItem>> events({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'events', _staff.eventsListPath, allowCache);

  Future<EventsDashboard> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) async {
    try {
      return await _cachedGet(
        tenantSlug: tenantSlug,
        cacheKey: 'dashboard',
        path: _staff.eventsDashboardPath,
        allowCache: allowCache,
        parse: (root, {fromCache = false, age}) => EventsDashboard.fromJson(
          root,
          fromCache: fromCache,
          cacheAgeLabel: age,
        ),
      );
    } on EndpointUnavailableException {
      final items = await events(tenantSlug: tenantSlug, allowCache: allowCache);
      return EventsDashboard.fromItems(items);
    }
  }

  Future<List<EventsItem>> meetings({
    required String tenantSlug,
    bool allowCache = true,
  }) async {
    try {
      return await _list(
        tenantSlug,
        'meetings',
        _staff.eventsMeetingsPath,
        allowCache,
      );
    } on EndpointUnavailableException {
      final all = await events(tenantSlug: tenantSlug, allowCache: allowCache);
      return all
          .where((e) {
            final k = (e.kind ?? '').toLowerCase();
            return k == 'meeting' || k == 'reuniao' || k == 'reunião';
          })
          .toList(growable: false);
    }
  }

  Future<List<EventsItem>> audiences({
    required String tenantSlug,
    bool allowCache = true,
  }) async {
    try {
      return await _list(
        tenantSlug,
        'audiences',
        _staff.eventsAudiencesPath,
        allowCache,
      );
    } on EndpointUnavailableException {
      final all = await events(tenantSlug: tenantSlug, allowCache: allowCache);
      return all
          .where((e) {
            final k = (e.kind ?? '').toLowerCase();
            return k == 'appointment' ||
                k == 'audience' ||
                k == 'audiencia' ||
                k == 'audiência';
          })
          .toList(growable: false);
    }
  }

  Future<List<EventsItem>> participants({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'participants',
    _staff.eventsParticipantsPath,
    allowCache,
  );

  Future<List<EventsItem>> invites({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'invites', _staff.eventsInvitesPath, allowCache);

  Future<List<EventsItem>> attendance({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'attendance', _staff.eventsAttendancePath, allowCache);

  Future<List<EventsItem>> checkIn({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'check_in', _staff.eventsCheckInPath, allowCache);

  Future<List<EventsItem>> checkOut({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'check_out', _staff.eventsCheckOutPath, allowCache);

  Future<List<EventsItem>> qrCode({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'qr_code', _staff.eventsQrCodePath, allowCache);

  Future<List<EventsItem>> gallery({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'gallery', _staff.eventsGalleryPath, allowCache);

  Future<List<EventsItem>> photos({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'photos', _staff.eventsPhotosPath, allowCache);

  Future<List<EventsItem>> videos({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'videos', _staff.eventsVideosPath, allowCache);

  Future<List<EventsItem>> documents({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'documents', _staff.eventsDocumentsPath, allowCache);

  Future<List<EventsItem>> certificates({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(
    tenantSlug,
    'certificates',
    _staff.eventsCertificatesPath,
    allowCache,
  );

  Future<List<EventsItem>> timeline({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'timeline', _staff.eventsTimelinePath, allowCache);

  Future<List<EventsItem>> reports({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'reports', _staff.eventsReportsPath, allowCache);

  Future<List<EventsItem>> indicators({
    required String tenantSlug,
    bool allowCache = true,
  }) =>
      _list(tenantSlug, 'indicators', _staff.eventsIndicatorsPath, allowCache);

  Future<List<EventsItem>> map({
    required String tenantSlug,
    bool allowCache = true,
  }) => _list(tenantSlug, 'map', _staff.eventsMapPath, allowCache);

  Future<List<EventsItem>> _list(
    String tenantSlug,
    String cacheKey,
    String path,
    bool allowCache,
  ) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: cacheKey,
    path: path,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<EventsItem> eventDetail(String id) async {
    final path = _staff.eventsItemPath(id);
    try {
      final envelope = await _api.getEnvelope<Map<String, dynamic>>(
        path,
        mode: _staff,
        parse: asEventsMap,
      );
      final data = envelope.data;
      // Envelope pode trazer o item em data ou o próprio mapa.
      if (data.containsKey('id') || data.containsKey('title')) {
        return EventsItem.fromJson(data);
      }
      final nested = asEventsMap(data['data'] ?? data['event'] ?? data);
      return EventsItem.fromJson(nested.isEmpty ? data : nested);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(path, statusCode: e.statusCode);
      }
      rethrow;
    }
  }

  Future<void> assertPending(String path) async {
    try {
      await _api.getEnvelope<dynamic>(path, mode: _staff, parse: (raw) => raw);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(path, statusCode: e.statusCode);
      }
      rethrow;
    }
  }

  Future<void> search() => assertPending(_staff.eventsSearchPath);

  Future<void> agendaEndpoint() => assertPending(_staff.eventsAgendaPath);

  Future<void> calendarEndpoint() => assertPending(_staff.eventsCalendarPath);
}
