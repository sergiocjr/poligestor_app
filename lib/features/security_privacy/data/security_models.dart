/// Fase 21 — modelos de Segurança e Privacidade (`/v1/security/*`).
library;

Map<String, dynamic> asSecurityMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asSecurityMapList(dynamic raw) {
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
        map['sessions'] ??
        map['devices'] ??
        map['tokens'] ??
        map['alerts'] ??
        map['consents'] ??
        map['incidents'] ??
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

String? asSecurityString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// Chaves sensíveis removidas antes de cache ou exibição.
const kSecuritySensitiveKeys = <String>{
  'token',
  'access_token',
  'refresh_token',
  'password',
  'secret',
  'api_key',
  'authorization',
  'current_password',
  'new_password',
  'otp_secret',
};

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  for (final s in kSecuritySensitiveKeys) {
    if (lower == s || lower.contains(s)) return true;
  }
  return false;
}

/// Remove recursivamente chaves sensíveis de mapas/listas.
dynamic stripSecuritySecrets(dynamic value) {
  if (value is Map) {
    final out = <String, dynamic>{};
    for (final e in value.entries) {
      if (_isSensitiveKey(e.key)) continue;
      out[e.key] = stripSecuritySecrets(e.value);
    }
    return out;
  }
  if (value is List) {
    return value.map(stripSecuritySecrets).toList();
  }
  return value;
}

/// Mascara e-mail para exibição (`a***@dominio.com`).
String? maskSecurityEmail(String? email) {
  if (email == null || email.isEmpty) return email;
  final at = email.indexOf('@');
  if (at <= 1) return '***${email.substring(at)}';
  return '${email[0]}***${email.substring(at)}';
}

/// Mascara CPF/documento (`***.***.***-XX`).
String? maskSecurityCpf(String? doc) {
  if (doc == null || doc.isEmpty) return doc;
  final digits = doc.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return '***';
  final tail = digits.substring(digits.length - 2);
  return '***.***.***-$tail';
}

/// Aplica mascaramento em campos conhecidos para helpers de UI.
Map<String, dynamic> maskSecuritySensitiveFields(Map<String, dynamic> json) {
  final m = Map<String, dynamic>.from(stripSecuritySecrets(json) as Map);
  for (final key in ['email', 'user_email', 'contact_email']) {
    final v = m[key];
    if (v is String) m[key] = maskSecurityEmail(v);
  }
  for (final key in ['cpf', 'document', 'tax_id', 'national_id']) {
    final v = m[key];
    if (v is String) m[key] = maskSecurityCpf(v);
  }
  return m;
}

class SecurityItem {
  const SecurityItem({
    required this.id,
    required this.title,
    this.code,
    this.status,
    this.kind,
    this.summary,
    this.email,
    this.device,
    this.date,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String? code;
  final String? status;
  final String? kind;
  final String? summary;
  final String? email;
  final String? device;
  final DateTime? date;
  final Map<String, dynamic> raw;

  factory SecurityItem.fromJson(Map<String, dynamic> json) {
    final masked = maskSecuritySensitiveFields(json);
    final m = asSecurityMap(masked);
    final id =
        asSecurityString(m['id'] ?? m['uuid'] ?? m['code'] ?? m['slug']) ??
        '${m.hashCode}';
    final title =
        asSecurityString(
          m['title'] ??
              m['name'] ??
              m['label'] ??
              m['device_name'] ??
              m['subject'],
        ) ??
        'Item $id';
    DateTime? date;
    for (final k in [
      'created_at',
      'updated_at',
      'occurred_at',
      'last_seen_at',
      'expires_at',
      'date',
    ]) {
      final raw = m[k];
      if (raw != null) {
        date = DateTime.tryParse('$raw');
        if (date != null) break;
      }
    }
    return SecurityItem(
      id: id,
      title: title,
      code: asSecurityString(m['code'] ?? m['ip'] ?? m['user_agent']),
      status: asSecurityString(m['status'] ?? m['state']),
      kind: asSecurityString(m['type'] ?? m['kind'] ?? m['category']),
      summary: asSecurityString(
        m['summary'] ?? m['description'] ?? m['notes'] ?? m['body'],
      ),
      email: asSecurityString(m['email'] ?? m['user_email']),
      device: asSecurityString(
        m['device'] ?? m['device_name'] ?? m['platform'],
      ),
      date: date,
      raw: m,
    );
  }
}
