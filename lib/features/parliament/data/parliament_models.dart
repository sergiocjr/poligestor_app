/// Sprint 10.8 — modelos do Painel Parlamentar (contratos LIVE `/v1/parliament/*`).
library;

Map<String, dynamic> asParlMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asParlMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final v = raw['data'] ?? raw['items'] ?? raw['results'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

int asParlInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

double asParlDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

String? asParlString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class ParliamentDashboard {
  const ParliamentDashboard({
    required this.counts,
    this.product,
    this.generatedAt,
    this.recent = const {},
    this.execution = const {},
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final ParliamentCounts counts;
  final String? product;
  final DateTime? generatedAt;
  final Map<String, dynamic> recent;
  final Map<String, dynamic> execution;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory ParliamentDashboard.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? cacheAgeLabel,
  }) {
    final data = asParlMap(root['data'] ?? root);
    final gen = asParlString(data['generated_at']);
    return ParliamentDashboard(
      counts: ParliamentCounts.fromJson(asParlMap(data['counts'])),
      product: asParlString(data['product']),
      generatedAt: gen == null ? null : DateTime.tryParse(gen),
      recent: asParlMap(data['recent']),
      execution: asParlMap(data['execution']),
      fromCache: fromCache,
      cacheAgeLabel: cacheAgeLabel,
    );
  }
}

class ParliamentCounts {
  const ParliamentCounts({
    this.bills = 0,
    this.indications = 0,
    this.requests = 0,
    this.motions = 0,
    this.amendments = 0,
    this.sessions = 0,
    this.votesOpen = 0,
    this.agendaUpcoming = 0,
    this.promises = 0,
    this.promisesAvgProgress = 0,
    this.supportBase = 0,
    this.demandsOpen = 0,
    this.commissions = 0,
  });

  final int bills;
  final int indications;
  final int requests;
  final int motions;
  final int amendments;
  final int sessions;
  final int votesOpen;
  final int agendaUpcoming;
  final int promises;
  final double promisesAvgProgress;
  final int supportBase;
  final int demandsOpen;
  final int commissions;

  factory ParliamentCounts.fromJson(Map<String, dynamic> json) {
    return ParliamentCounts(
      bills: asParlInt(json['bills']),
      indications: asParlInt(json['indications']),
      requests: asParlInt(json['requests']),
      motions: asParlInt(json['motions']),
      amendments: asParlInt(json['amendments']),
      sessions: asParlInt(json['sessions']),
      votesOpen: asParlInt(json['votes_open']),
      agendaUpcoming: asParlInt(json['agenda_upcoming']),
      promises: asParlInt(json['promises']),
      promisesAvgProgress: asParlDouble(json['promises_avg_progress']),
      supportBase: asParlInt(json['support_base']),
      demandsOpen: asParlInt(json['demands_open']),
      commissions: asParlInt(json['commissions']),
    );
  }
}

/// Item genérico de proposição / legislação / demanda (lista ou detalhe).
class ParliamentItem {
  const ParliamentItem({
    required this.id,
    required this.title,
    this.number,
    this.summary,
    this.status,
    this.kind,
    this.authors = const [],
    this.filedAt,
    this.createdAt,
    this.updatedAt,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? number;
  final String? summary;
  final String? status;
  final String? kind;
  final List<String> authors;
  final DateTime? filedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  factory ParliamentItem.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) {
      final s = asParlString(v);
      return s == null ? null : DateTime.tryParse(s);
    }

    final authorsRaw = json['authors'] ?? json['author'];
    final authors = <String>[];
    if (authorsRaw is List) {
      for (final a in authorsRaw) {
        if (a is Map) {
          final name = asParlString(a['name'] ?? a['label'] ?? a['title']);
          if (name != null) authors.add(name);
        } else {
          final s = asParlString(a);
          if (s != null) authors.add(s);
        }
      }
    } else if (authorsRaw != null) {
      final s = asParlString(authorsRaw);
      if (s != null) authors.add(s);
    }

    return ParliamentItem(
      id: asParlString(json['id'] ?? json['uuid']) ?? '',
      title:
          asParlString(json['title'] ?? json['name'] ?? json['label']) ??
          'Item',
      number: asParlString(json['number'] ?? json['code']),
      summary: asParlString(
        json['summary'] ?? json['body'] ?? json['description'],
      ),
      status: asParlString(json['status']),
      kind: asParlString(json['kind'] ?? json['type']),
      authors: authors,
      filedAt: dt(json['filed_at'] ?? json['scheduled_at'] ?? json['date']),
      createdAt: dt(json['created_at']),
      updatedAt: dt(json['updated_at']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
