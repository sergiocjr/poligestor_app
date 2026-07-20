import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';

class AppointmentItem {
  AppointmentItem({
    required this.id,
    required this.title,
    this.description,
    this.startsAt,
    this.endsAt,
    this.location,
    this.status,
  });

  final dynamic id;
  final String title;
  final String? description;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? location;
  final String? status;

  factory AppointmentItem.fromJson(Map<String, dynamic> json) {
    final startRaw = json['starts_at'] ?? json['start_at'] ?? json['startsAt'];
    final endRaw = json['ends_at'] ?? json['end_at'] ?? json['endsAt'];
    return AppointmentItem(
      id: json['id'] ?? json['uuid'],
      title: (json['title'] ?? json['titulo'] ?? 'Compromisso').toString(),
      description: (json['description'] ?? json['descricao'])?.toString(),
      location: (json['location'] ?? json['local'])?.toString(),
      status: (json['status'] ?? json['type_label'] ?? json['event_type_label'])
          ?.toString(),
      startsAt: startRaw != null
          ? DateTime.tryParse(startRaw.toString())
          : null,
      endsAt: endRaw != null ? DateTime.tryParse(endRaw.toString()) : null,
    );
  }
}

class AppointmentsRepository {
  AppointmentsRepository(this._api);

  final ApiClient _api;

  /// Staff: agenda do mandato (`/v1/mandate/agenda` — LIVE).
  /// Portal: compromissos do cidadão (`/v1/portal/appointments`).
  String _pathFor(AuthMode mode) => switch (mode) {
    AuthMode.staff => mode.mandateAgendaPath,
    AuthMode.portal => mode.eventsPath,
  };

  List<AppointmentItem> _parseList(dynamic raw) {
    List list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      final events = raw['events'] ?? raw['data'] ?? raw['items'] ?? raw['appointments'];
      list = events is List ? events : const [];
    } else {
      list = const [];
    }
    return list
        .whereType<Map>()
        .map((e) => AppointmentItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<AppointmentItem>> list({required AuthMode mode}) async {
    final path = _pathFor(mode);
    try {
      final envelope = await _api.getEnvelope<List<AppointmentItem>>(
        path,
        mode: mode,
        parse: _parseList,
      );
      final items = [...envelope.data];
      items.sort((a, b) {
        final aa = a.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bb = b.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aa.compareTo(bb);
      });
      return items;
    } on ApiException catch (e) {
      final code = e.statusCode;
      if (code == 404 || code == 405 || code == 501 || code == 503) {
        throw EndpointUnavailableException(path, statusCode: code);
      }
      rethrow;
    }
  }

  Future<List<AppointmentItem>> upcoming({required AuthMode mode}) async {
    final items = await list(mode: mode);
    final now = DateTime.now();
    final upcoming = items.where((e) {
      if (e.startsAt == null) return true;
      return e.startsAt!.isAfter(now.subtract(const Duration(hours: 1)));
    }).toList();
    return upcoming.take(5).toList();
  }
}
