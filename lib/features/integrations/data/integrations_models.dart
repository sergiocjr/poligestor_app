/// Fase 22 — modelos de Integrações (`/v1/integrations/*`).
library;

Map<String, dynamic> asIntegrationsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

const _integrationsNestedListKeys = <String>[
  'data',
  'items',
  'results',
  'rows',
  'integrations',
  'webhooks',
  'logs',
  'syncs',
  'sync_runs',
  'jobs',
  'audits',
  'history',
  'providers',
  'catalog',
  'live_providers',
  'recent_logs',
  'recent_audits',
  'capabilities',
];

const _integrationsSummaryLabels = <String, String>{
  'providers': 'Provedores',
  'live_contracts': 'Contratos ativos',
  'connectors_active': 'Conectores ativos',
  'oauth_active': 'OAuth ativos',
  'api_keys_active': 'Chaves de API ativas',
  'webhooks_active': 'Webhooks ativos',
  'sync_running': 'Sincronizações em execução',
  'jobs_failed': 'Filas com falha',
  'legacy_connections': 'Conexões legadas',
  'failed_jobs': 'Tarefas com falha',
  'connectors_error': 'Conectores com erro',
  'status': 'Situação',
  'queue': 'Fila',
  'engine': 'Motor',
  'checked_at': 'Verificado em',
  'auto_sync': 'Sincronização automática',
  'retry_max': 'Tentativas máximas',
  'default_mode': 'Modo padrão',
  'cabinet_isolation': 'Isolamento por gabinete',
};

List<Map<String, dynamic>> _summaryAsRows(Map<String, dynamic> summary) {
  final rows = <Map<String, dynamic>>[];
  for (final e in summary.entries) {
    if (e.value is Map || e.value is List) continue;
    final label = _integrationsSummaryLabels[e.key] ?? e.key;
    rows.add({
      'id': e.key,
      'title': label,
      'name': label,
      'summary': '${e.value}',
      'status': e.key == 'status' ? '${e.value}' : null,
      'kind': 'metric',
    });
  }
  return rows;
}

List<Map<String, dynamic>> asIntegrationsMapList(dynamic raw) {
  if (raw is List) {
    if (raw.isEmpty) return const [];
    if (raw.every((e) => e is String || e is num || e is bool)) {
      return raw
          .map(
            (e) => <String, dynamic>{
              'id': '$e',
              'title': '$e',
              'name': '$e',
              'slug': '$e',
              'status': 'active',
            },
          )
          .toList(growable: false);
    }
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);

    // Agregados: unir várias listas conhecidas (histórico).
    final merged = <Map<String, dynamic>>[];
    for (final key in [
      'sync_runs',
      'jobs',
      'audits',
      'logs',
      'recent_logs',
      'recent_audits',
    ]) {
      final nested = map[key];
      if (nested is List) {
        for (final e in nested.whereType<Map>()) {
          final m = Map<String, dynamic>.from(e);
          m.putIfAbsent('kind', () => key);
          merged.add(m);
        }
      }
    }
    if (merged.isNotEmpty) return merged;

    for (final key in _integrationsNestedListKeys) {
      final nestedList = map[key];
      if (nestedList is List && nestedList.isNotEmpty) {
        final fromList = asIntegrationsMapList(nestedList);
        if (fromList.isNotEmpty) return fromList;
      }
    }

    final summary = map['summary'];
    if (summary is Map) {
      final rows = _summaryAsRows(Map<String, dynamic>.from(summary));
      if (rows.isNotEmpty) return rows;
    }

    // Health / settings / provider único.
    if (map.containsKey('name') ||
        map.containsKey('slug') ||
        map.containsKey('provider_code') ||
        map.containsKey('key') ||
        map.containsKey('status') ||
        map.containsKey('value')) {
      if (map['value'] is Map) {
        final valueRows = _summaryAsRows(
          Map<String, dynamic>.from(map['value'] as Map),
        );
        if (valueRows.isNotEmpty) {
          return [
            {
              'id': asIntegrationsString(map['id'] ?? map['key']) ?? 'settings',
              'title': asIntegrationsString(map['key']) ?? 'Configuração',
              'name': asIntegrationsString(map['key']) ?? 'Configuração',
              'status': 'active',
              'summary': 'Parâmetros do hub de integrações',
              'kind': 'settings',
            },
            ...valueRows,
          ];
        }
      }
      return [map];
    }

    final metricKeys = map.keys.where(
      (k) =>
          _integrationsSummaryLabels.containsKey(k) &&
          map[k] is! Map &&
          map[k] is! List,
    );
    if (metricKeys.isNotEmpty) {
      return _summaryAsRows({for (final k in metricKeys) k: map[k]});
    }
  }
  return const [];
}

String? asIntegrationsString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// Chaves sensíveis removidas antes de cache ou exibição.
const kIntegrationsSensitiveKeys = <String>{
  'token',
  'access_token',
  'refresh_token',
  'password',
  'secret',
  'api_key',
  'client_secret',
  'webhook_secret',
  'authorization',
  'private_key',
};

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  for (final s in kIntegrationsSensitiveKeys) {
    if (lower == s || lower.contains(s)) return true;
  }
  return false;
}

/// Remove recursivamente chaves sensíveis de mapas/listas.
dynamic stripIntegrationsSecrets(dynamic value) {
  if (value is Map) {
    final out = <String, dynamic>{};
    for (final e in value.entries) {
      if (_isSensitiveKey(e.key)) continue;
      out[e.key] = stripIntegrationsSecrets(e.value);
    }
    return out;
  }
  if (value is List) {
    return value.map(stripIntegrationsSecrets).toList();
  }
  return value;
}

class IntegrationItem {
  const IntegrationItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.provider,
    this.date,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? provider;
  final DateTime? date;
  final Map<String, dynamic> raw;

  factory IntegrationItem.fromJson(Map<String, dynamic> json) {
    final m = asIntegrationsMap(stripIntegrationsSecrets(json));
    final id =
        asIntegrationsString(m['id'] ?? m['uuid'] ?? m['code'] ?? m['slug']) ??
        '${m.hashCode}';
    final title =
        asIntegrationsString(
          m['title'] ??
              m['name'] ??
              m['label'] ??
              m['provider'] ??
              m['integration'] ??
              m['service'],
        ) ??
        'Integração';
    final status = asIntegrationsString(
      m['status'] ?? m['state'] ?? m['connection_status'],
    );
    final kind = asIntegrationsString(
      m['type'] ?? m['kind'] ?? m['category'],
    );
    final summary = asIntegrationsString(
      m['summary'] ?? m['description'] ?? m['message'] ?? m['detail'],
    );
    final provider = asIntegrationsString(
      m['provider'] ?? m['channel'] ?? m['source'],
    );
    final code = asIntegrationsString(m['code'] ?? m['slug'] ?? m['key']);
    DateTime? date;
    for (final key in [
      'updated_at',
      'synced_at',
      'created_at',
      'timestamp',
      'date',
    ]) {
      final raw = m[key];
      if (raw != null) {
        date = DateTime.tryParse(raw.toString());
        if (date != null) break;
      }
    }
    return IntegrationItem(
      id: id,
      title: title,
      code: code,
      status: status,
      kind: kind,
      summary: summary,
      provider: provider,
      date: date,
      raw: m,
    );
  }
}
