/// Fase 19 — modelos da Administração do Sistema (`/v1/admin/*`).
library;

Map<String, dynamic> asAdminMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

/// Rótulos PT-BR para chaves de resumo agregadas (painel / monitoramento).
const _adminSummaryLabels = <String, String>{
  'companies': 'Empresas',
  'offices': 'Gabinetes',
  'users': 'Usuários',
  'profiles': 'Perfis',
  'roles': 'Papéis',
  'permissions': 'Permissões',
  'teams': 'Equipes',
  'departments': 'Departamentos',
  'sessions': 'Sessões',
  'integrations': 'Integrações',
  'webhooks': 'Webhooks',
  'subscriptions': 'Assinaturas',
  'licenses': 'Licenças',
  'logs': 'Registros',
  'audit_events': 'Eventos de auditoria',
  'health_status': 'Saúde do sistema',
  'storage_used': 'Armazenamento usado',
  'api_keys': 'Chaves de API',
  'reports': 'Relatórios',
  'exports': 'Exportações',
};

List<Map<String, dynamic>> _summaryAsRows(Map<String, dynamic> summary) {
  final rows = <Map<String, dynamic>>[];
  for (final e in summary.entries) {
    if (e.value is Map || e.value is List) continue;
    final label = _adminSummaryLabels[e.key] ?? e.key.replaceAll('_', ' ');
    rows.add({
      'id': e.key,
      'title': label,
      'summary': '${e.value}',
      'kind': 'indicador',
    });
  }
  return rows;
}

List<Map<String, dynamic>> asAdminMapList(dynamic raw) {
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
        map['companies'] ??
        map['offices'] ??
        map['users'] ??
        map['profiles'] ??
        map['roles'] ??
        map['permissions'] ??
        map['teams'] ??
        map['departments'] ??
        map['logs'] ??
        map['sessions'] ??
        map['integrations'] ??
        map['webhooks'] ??
        map['reports'] ??
        map['exports'] ??
        map['filters'];
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
    final metricKeys = map.keys.where(
      (k) =>
          _adminSummaryLabels.containsKey(k) &&
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

String? asAdminString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class AdminItem {
  const AdminItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.scope,
    this.email,
    this.date,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? scope;
  final String? email;
  final DateTime? date;
  final Map<String, dynamic> raw;

  factory AdminItem.fromJson(Map<String, dynamic> json) {
    final m = asAdminMap(json);
    final id =
        asAdminString(m['id'] ?? m['uuid'] ?? m['code'] ?? m['slug']) ??
        '${m.hashCode}';
    final title =
        asAdminString(
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
      'last_login_at',
      'date',
      'expires_at',
    ]) {
      final raw = m[k];
      if (raw != null) {
        date = DateTime.tryParse('$raw');
        if (date != null) break;
      }
    }
    return AdminItem(
      id: id,
      title: title,
      code: asAdminString(m['code'] ?? m['document'] ?? m['slug']),
      status: asAdminString(m['status'] ?? m['state']),
      kind: asAdminString(m['type'] ?? m['kind'] ?? m['category']),
      summary: asAdminString(
        m['summary'] ?? m['description'] ?? m['notes'] ?? m['body'],
      ),
      scope: asAdminString(
        m['scope'] ?? m['office'] ?? m['company'] ?? m['tenant'],
      ),
      email: asAdminString(m['email']),
      date: date,
      raw: m,
    );
  }
}
