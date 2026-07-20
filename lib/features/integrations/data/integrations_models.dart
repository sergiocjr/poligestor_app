/// Fase 22 — modelos de Integrações (`/v1/integrations/*`).
library;

Map<String, dynamic> asIntegrationsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asIntegrationsMapList(dynamic raw) {
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
        map['integrations'] ??
        map['webhooks'] ??
        map['logs'] ??
        map['syncs'] ??
        map['history'];
    if (nestedList is List) {
      final fromList = nestedList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (fromList.isNotEmpty) return fromList;
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
