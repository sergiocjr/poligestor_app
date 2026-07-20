/// Fase 17 — modelos da Gestão Eleitoral (`/v1/elections/*`).
library;

Map<String, dynamic> asElectionsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

/// Rótulos PT-BR para chaves de resumo agregadas (painel / projeções / contas).
const _electionsSummaryLabels = <String, String>{
  'campaigns': 'Campanhas',
  'active_campaigns': 'Campanhas ativas',
  'candidates': 'Candidatos',
  'members': 'Membros',
  'events': 'Eventos',
  'goals_open': 'Metas abertas',
  'materials': 'Materiais',
  'surveys': 'Pesquisas',
  'finance_income': 'Receitas',
  'finance_expense': 'Despesas',
  'finance_expenses': 'Despesas',
  'avg_intention': 'Intenção média',
  'avg_rejection': 'Rejeição média',
  'avg_projection': 'Projeção média',
  'income_total': 'Total de receitas',
  'expense_total': 'Total de despesas',
  'balance': 'Saldo',
  'regions': 'Regiões',
  'neighborhoods': 'Bairros',
  'zones': 'Zonas',
  'sections': 'Seções',
  'stations': 'Colégios',
};

List<Map<String, dynamic>> _summaryAsRows(Map<String, dynamic> summary) {
  final rows = <Map<String, dynamic>>[];
  for (final e in summary.entries) {
    if (e.value is Map || e.value is List) continue;
    final label = _electionsSummaryLabels[e.key] ?? e.key.replaceAll('_', ' ');
    rows.add({
      'id': e.key,
      'title': label,
      'summary': '${e.value}',
      'kind': 'indicador',
    });
  }
  return rows;
}

List<Map<String, dynamic>> asElectionsMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final nestedList =
        map['data'] ??
        map['items'] ??
        map['results'] ??
        map['rows'] ??
        map['candidates'] ??
        map['campaigns'] ??
        map['volunteers'] ??
        map['leaders'] ??
        map['supporters'] ??
        map['regions'] ??
        map['events'] ??
        map['polls'] ??
        map['reports'] ??
        map['by_scenario'] ??
        map['history'] ??
        map['receipts'] ??
        map['vendors'] ??
        map['by_kind'];
    if (nestedList is List) {
      final fromList = nestedList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (fromList.isNotEmpty) return fromList;
    }
    final summary = map['summary'];
    if (summary is Map) {
      final rows = _summaryAsRows(Map<String, dynamic>.from(summary));
      if (rows.isNotEmpty) return rows;
    }
    // Agregados tipados (projeções, prestação de contas, mapa).
    final metricKeys = map.keys.where(
      (k) =>
          _electionsSummaryLabels.containsKey(k) &&
          map[k] is! Map &&
          map[k] is! List,
    );
    if (metricKeys.isNotEmpty) {
      return _summaryAsRows({
        for (final k in metricKeys) k: map[k],
      });
    }
  }
  return const [];
}

String? asElectionsString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class ElectionsItem {
  const ElectionsItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.region,
    this.supportLevel,
    this.date,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? region;
  final String? supportLevel;
  final DateTime? date;
  final Map<String, dynamic> raw;

  factory ElectionsItem.fromJson(Map<String, dynamic> json) {
    final m = asElectionsMap(json);
    final id =
        asElectionsString(m['id'] ?? m['uuid'] ?? m['code'] ?? m['slug']) ??
        '${m.hashCode}';
    final title =
        asElectionsString(
          m['title'] ??
              m['name'] ??
              m['full_name'] ??
              m['label'] ??
              m['subject'],
        ) ??
        'Item $id';
    DateTime? date;
    for (final k in [
      'created_at',
      'updated_at',
      'occurred_at',
      'visited_at',
      'date',
      'scheduled_at',
    ]) {
      final raw = m[k];
      if (raw != null) {
        date = DateTime.tryParse('$raw');
        if (date != null) break;
      }
    }
    return ElectionsItem(
      id: id,
      title: title,
      code: asElectionsString(m['code'] ?? m['document'] ?? m['cpf']),
      status: asElectionsString(m['status'] ?? m['state']),
      kind: asElectionsString(m['type'] ?? m['kind'] ?? m['category']),
      summary: asElectionsString(
        m['summary'] ?? m['description'] ?? m['notes'] ?? m['body'],
      ),
      region: asElectionsString(
        m['region'] ?? m['neighborhood'] ?? m['district'] ?? m['zone'],
      ),
      supportLevel: asElectionsString(
        m['support_level'] ?? m['support'] ?? m['grau_apoio'],
      ),
      date: date,
      raw: m,
    );
  }
}
