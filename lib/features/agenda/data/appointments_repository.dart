import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_mode.dart';

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
      id: json['id'],
      title: (json['title'] ?? json['titulo'] ?? 'Compromisso').toString(),
      description: (json['description'] ?? json['descricao'])?.toString(),
      location: (json['location'] ?? json['local'])?.toString(),
      status: json['status']?.toString(),
      startsAt: startRaw != null ? DateTime.tryParse(startRaw.toString()) : null,
      endsAt: endRaw != null ? DateTime.tryParse(endRaw.toString()) : null,
    );
  }
}

class AppointmentsRepository {
  AppointmentsRepository(this._api);

  final ApiClient _api;

  Future<List<AppointmentItem>> list({required AuthMode mode}) async {
    final envelope = await _api.getEnvelope<List<AppointmentItem>>(
      mode.eventsPath,
      mode: mode,
      parse: (raw) {
        final list = raw is List
            ? raw
            : (raw is Map && raw['data'] is List)
                ? raw['data'] as List
                : const [];
        return list
            .whereType<Map>()
            .map((e) => AppointmentItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return envelope.data;
  }

  Future<List<AppointmentItem>> upcoming({required AuthMode mode}) async {
    final items = await list(mode: mode);
    final now = DateTime.now();
    final upcoming = items.where((e) {
      if (e.startsAt == null) return true;
      return e.startsAt!.isAfter(now.subtract(const Duration(hours: 1)));
    }).toList();
    upcoming.sort((a, b) {
      final aa = a.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bb = b.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aa.compareTo(bb);
    });
    return upcoming.take(5).toList();
  }
}
