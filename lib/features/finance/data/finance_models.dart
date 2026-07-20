/// Fase 14 — modelos da Gestão Financeira (`/v1/finance/*`).
library;

Map<String, dynamic> asFinanceMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asFinanceMapList(dynamic raw) {
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
        raw['rows'] ??
        raw['indicators'] ??
        raw['revenues'] ??
        raw['expenses'] ??
        raw['accounts'] ??
        raw['categories'] ??
        raw['suppliers'] ??
        raw['contracts'] ??
        raw['alerts'] ??
        raw['reports'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}

int asFinanceInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

double asFinanceDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

String? asFinanceString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class FinanceDashboard {
  const FinanceDashboard({
    this.balance = 0,
    this.revenues = 0,
    this.expenses = 0,
    this.payables = 0,
    this.receivables = 0,
    this.alerts = 0,
    this.fromCache = false,
    this.cacheAgeLabel,
  });

  final double balance;
  final double revenues;
  final double expenses;
  final double payables;
  final double receivables;
  final int alerts;
  final bool fromCache;
  final String? cacheAgeLabel;

  factory FinanceDashboard.fromJson(
    Map<String, dynamic> root, {
    bool fromCache = false,
    String? ageLabel,
  }) {
    final data = asFinanceMap(root['data'] ?? root);
    final counts = asFinanceMap(
      data['summary'] ?? data['kpis'] ?? data['counts'] ?? data,
    );
    return FinanceDashboard(
      balance: asFinanceDouble(
        counts['balance'] ?? counts['saldo'] ?? counts['current_balance'],
      ),
      revenues: asFinanceDouble(
        counts['revenues'] ?? counts['income'] ?? counts['receitas'],
      ),
      expenses: asFinanceDouble(
        counts['expenses'] ?? counts['despesas'],
      ),
      payables: asFinanceDouble(
        counts['payables'] ?? counts['accounts_payable'],
      ),
      receivables: asFinanceDouble(
        counts['receivables'] ?? counts['accounts_receivable'],
      ),
      alerts: asFinanceInt(counts['alerts'] ?? counts['alertas']),
      fromCache: fromCache,
      cacheAgeLabel: ageLabel,
    );
  }
}

class FinanceItem {
  const FinanceItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.amount,
    this.category,
    this.date,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final double? amount;
  final String? category;
  final DateTime? date;
  final Map<String, dynamic> raw;

  factory FinanceItem.fromJson(Map<String, dynamic> json) {
    final dateRaw =
        json['date'] ?? json['due_date'] ?? json['created_at'] ?? json['updated_at'];
    return FinanceItem(
      id: asFinanceString(json['id'] ?? json['uuid'] ?? json['code']) ?? '',
      title:
          asFinanceString(
            json['title'] ??
                json['name'] ??
                json['label'] ??
                json['description'] ??
                json['supplier'] ??
                json['category'],
          ) ??
          'Item',
      code: asFinanceString(json['code'] ?? json['number']),
      status: asFinanceString(json['status']),
      kind: asFinanceString(json['kind'] ?? json['type']),
      summary: asFinanceString(
        json['summary'] ?? json['description'] ?? json['notes'],
      ),
      amount: json['amount'] == null && json['value'] == null
          ? null
          : asFinanceDouble(json['amount'] ?? json['value']),
      category: asFinanceString(
        json['category'] ?? json['category_name'] ?? json['cost_center'],
      ),
      date: dateRaw == null ? null : DateTime.tryParse(dateRaw.toString()),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
