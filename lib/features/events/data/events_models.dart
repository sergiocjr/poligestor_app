/// Fase 11 — modelos do Painel de Eventos (namespace LIVE `/v1/events`).
library;

Map<String, dynamic> asEventsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asEventsMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final v =
        raw['data'] ??
        raw['items'] ??
        raw['results'] ??
        raw['events'] ??
        raw['appointments'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

int asEventsInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

double asEventsDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

String? asEventsString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class EventsDashboard {
  const EventsDashboard({
    this.total = 0,
    this.scheduled = 0,
    this.completed = 0,
    this.cancelled = 0,
    this.meetings = 0,
    this.audiences = 0,
    this.today = 0,
    this.upcoming = 0,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final int total;
  final int scheduled;
  final int completed;
  final int cancelled;
  final int meetings;
  final int audiences;
  final int today;
  final int upcoming;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory EventsDashboard.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asEventsMap(root['data'] ?? root);
    final counts = asEventsMap(data['counts'] ?? data['kpis'] ?? data);
    return EventsDashboard(
      total: asEventsInt(counts['total'] ?? counts['events_total']),
      scheduled: asEventsInt(
        counts['scheduled'] ?? counts['events_scheduled'],
      ),
      completed: asEventsInt(
        counts['completed'] ?? counts['events_completed'],
      ),
      cancelled: asEventsInt(
        counts['cancelled'] ?? counts['events_cancelled'],
      ),
      meetings: asEventsInt(counts['meetings'] ?? counts['meetings_count']),
      audiences: asEventsInt(
        counts['audiences'] ?? counts['appointments'] ?? counts['audiences_count'],
      ),
      today: asEventsInt(counts['today'] ?? counts['events_today']),
      upcoming: asEventsInt(counts['upcoming'] ?? counts['events_upcoming']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }

  factory EventsDashboard.fromItems(
    List<EventsItem> items, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    var scheduled = 0;
    var completed = 0;
    var cancelled = 0;
    var meetings = 0;
    var audiences = 0;
    var today = 0;
    var upcoming = 0;
    for (final e in items) {
      final status = (e.status ?? '').toLowerCase();
      if (status == 'scheduled' || status == 'agendado') scheduled++;
      if (status == 'completed' || status == 'concluido' || status == 'concluído') {
        completed++;
      }
      if (status == 'cancelled' || status == 'canceled' || status == 'cancelado') {
        cancelled++;
      }
      final kind = (e.kind ?? '').toLowerCase();
      if (kind == 'meeting' || kind == 'reuniao' || kind == 'reunião') {
        meetings++;
      }
      if (kind == 'appointment' ||
          kind == 'audience' ||
          kind == 'audiencia' ||
          kind == 'audiência') {
        audiences++;
      }
      final start = e.startsAt;
      if (start != null) {
        if (!start.isBefore(startOfDay) && start.isBefore(endOfDay)) today++;
        if (start.isAfter(now.subtract(const Duration(hours: 1)))) upcoming++;
      }
    }
    return EventsDashboard(
      total: items.length,
      scheduled: scheduled,
      completed: completed,
      cancelled: cancelled,
      meetings: meetings,
      audiences: audiences,
      today: today,
      upcoming: upcoming,
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class EventsItem {
  const EventsItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.location,
    this.priority,
    this.startsAt,
    this.endsAt,
    this.allDay = false,
    this.personName,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? location;
  final String? priority;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool allDay;
  final String? personName;
  final Map<String, dynamic> raw;

  factory EventsItem.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) {
      final s = asEventsString(v);
      return s == null ? null : DateTime.tryParse(s);
    }

    final person = asEventsMap(json['person']);
    return EventsItem(
      id: asEventsString(json['id'] ?? json['uuid']) ?? '',
      title:
          asEventsString(json['title'] ?? json['name'] ?? json['label']) ??
          'Evento',
      code: asEventsString(json['code'] ?? json['number']),
      status: asEventsString(json['status']),
      kind: asEventsString(json['kind'] ?? json['type'] ?? json['category']),
      summary: asEventsString(
        json['summary'] ?? json['description'] ?? json['body'],
      ),
      location: asEventsString(json['location'] ?? json['place'] ?? json['local']),
      priority: asEventsString(json['priority']),
      startsAt: dt(
        json['starts_at'] ?? json['start_at'] ?? json['startsAt'] ?? json['occurred_at'],
      ),
      endsAt: dt(json['ends_at'] ?? json['end_at'] ?? json['endsAt']),
      allDay: json['all_day'] == true || json['allDay'] == true,
      personName: asEventsString(person['name'] ?? json['person_name']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
