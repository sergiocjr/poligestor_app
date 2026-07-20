import '../../../core/config.dart';

/// Parsing defensivo + modelos Sprint 10.2 (identidade / conta / branding).
Map<String, dynamic> idAsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> idAsMapList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

String? idAsString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? idAsIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Converte path relativo da VPS em URL absoluta pública.
String? idAbsolutePublicUrl(String? pathOrUrl) {
  final raw = idAsString(pathOrUrl);
  if (raw == null) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  final path = raw.startsWith('/') ? raw : '/$raw';
  return 'https://${AppConfig.publicHost}$path';
}

class EndpointUnavailableException implements Exception {
  EndpointUnavailableException(this.path, {this.statusCode});
  final String path;
  final int? statusCode;
  @override
  String toString() => 'EndpointUnavailableException($path, $statusCode)';
}

class TenantOrganization {
  const TenantOrganization({
    required this.id,
    required this.name,
    required this.slug,
    this.code,
    this.domain,
    this.isActive = true,
    this.registrationEnabled = true,
    this.raw = const {},
  });

  final String id;
  final String name;
  final String slug;
  final String? code;
  final String? domain;
  final bool isActive;
  final bool registrationEnabled;
  final Map<String, dynamic> raw;

  factory TenantOrganization.fromJson(Map<String, dynamic> json) {
    // Contrato publicado: { method, organization: {...}, config, features }
    final org = json['organization'] is Map
        ? idAsMap(json['organization'])
        : (json['tenant'] is Map ? idAsMap(json['tenant']) : json);
    final config = json['config'] is Map
        ? idAsMap(json['config'])
        : (org['config'] is Map ? idAsMap(org['config']) : const {});
    return TenantOrganization(
      id: idAsString(org['id']) ?? '',
      name: idAsString(org['name'] ?? org['nome']) ?? 'Organização',
      slug: idAsString(org['slug']) ?? '',
      code: idAsString(org['code'] ?? org['access_code']),
      domain: idAsString(org['domain'] ?? org['host'] ?? json['host']),
      isActive: org['is_active'] != false,
      registrationEnabled: config['registration_enabled'] != false,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    if (code != null) 'code': code,
    if (domain != null) 'domain': domain,
    'is_active': isActive,
    'registration_enabled': registrationEnabled,
  };

  /// Branding embutido na resposta de resolve (quando presente).
  TenantBranding? get embeddedBranding {
    final org = raw['organization'] is Map ? idAsMap(raw['organization']) : raw;
    if (org['branding'] is! Map) return null;
    return TenantBranding.fromJson({
      'tenant': {'name': name, 'slug': slug},
      'branding': org['branding'],
    });
  }
}

class TenantBranding {
  const TenantBranding({
    required this.tenantName,
    this.logoUrl,
    this.bannerUrl,
    this.primaryColor,
    this.secondaryColor,
    this.iconUrl,
    this.tagline,
    this.institutionalInfo,
    this.raw = const {},
  });

  final String tenantName;
  final String? logoUrl;
  final String? bannerUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? iconUrl;
  final String? tagline;
  final String? institutionalInfo;
  final Map<String, dynamic> raw;

  factory TenantBranding.fromJson(Map<String, dynamic> json) {
    final data = json['branding'] is Map ? idAsMap(json['branding']) : json;
    final tenant = json['tenant'] is Map ? idAsMap(json['tenant']) : const {};
    return TenantBranding(
      tenantName:
          idAsString(data['name'] ?? tenant['name'] ?? json['name']) ??
          'Organização',
      logoUrl: idAbsolutePublicUrl(
        data['logo_url'] ??
            data['logo_path'] ??
            data['logo'] ??
            json['logo_url'] ??
            json['logo_path'],
      ),
      bannerUrl: idAbsolutePublicUrl(
        data['banner_url'] ??
            data['banner_path'] ??
            data['banner'] ??
            json['banner_url'],
      ),
      primaryColor: idAsString(
        data['primary_color'] ?? data['primary'] ?? data['color_primary'],
      ),
      secondaryColor: idAsString(
        data['secondary_color'] ?? data['secondary'] ?? data['color_secondary'],
      ),
      iconUrl: idAbsolutePublicUrl(
        data['icon_url'] ?? data['favicon_path'] ?? data['icon'],
      ),
      tagline: idAsString(data['tagline'] ?? data['slogan']),
      institutionalInfo: idAsString(
        data['institutional_info'] ?? data['description'] ?? data['about'],
      ),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': tenantName,
    if (logoUrl != null) 'logo_url': logoUrl,
    if (bannerUrl != null) 'banner_url': bannerUrl,
    if (primaryColor != null) 'primary_color': primaryColor,
    if (secondaryColor != null) 'secondary_color': secondaryColor,
    if (iconUrl != null) 'icon_url': iconUrl,
    if (tagline != null) 'tagline': tagline,
    if (institutionalInfo != null) 'institutional_info': institutionalInfo,
  };
}

class AuthProviderInfo {
  const AuthProviderInfo({
    required this.id,
    required this.label,
    this.enabled = false,
    this.ready = true,
    this.status,
    this.raw = const {},
  });

  final String id;
  final String label;
  final bool enabled;
  final bool ready;
  final String? status;
  final Map<String, dynamic> raw;

  bool get isPassword => id == 'password' || id == 'email';
  bool get isExternal =>
      id == 'google' || id == 'apple' || id == 'govbr' || id == 'gov.br';
  bool get canUse => enabled && ready && !isPassword;

  factory AuthProviderInfo.fromJson(Map<String, dynamic> json) {
    final id = (idAsString(json['id'] ?? json['provider'] ?? json['key']) ?? '')
        .toLowerCase();
    final label =
        idAsString(json['label'] ?? json['name']) ??
        switch (id) {
          'password' || 'email' => 'E-mail e senha',
          'google' => 'Google',
          'apple' => 'Apple',
          'govbr' || 'gov.br' => 'Gov.br',
          _ => id,
        };
    return AuthProviderInfo(
      id: id,
      label: label,
      enabled:
          json['is_enabled'] == true ||
          json['enabled'] == true ||
          json['active'] == true,
      ready: json['ready'] != false,
      status: idAsString(json['status']),
      raw: json,
    );
  }
}

class AuthSessionInfo {
  const AuthSessionInfo({
    required this.sessionId,
    required this.deviceName,
    this.createdAt,
    this.lastUsedAt,
    this.expiresAt,
    this.hasRefresh = false,
    this.ip,
    this.platform,
    this.location,
    this.isCurrent = false,
    this.raw = const {},
  });

  final String sessionId;
  final String deviceName;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
  final bool hasRefresh;
  final String? ip;
  final String? platform;
  final String? location;
  final bool isCurrent;
  final Map<String, dynamic> raw;

  factory AuthSessionInfo.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) {
      final s = idAsString(v);
      return s == null ? null : DateTime.tryParse(s);
    }

    return AuthSessionInfo(
      sessionId: idAsString(json['session_id'] ?? json['id']) ?? '',
      deviceName:
          idAsString(json['device_name'] ?? json['device'] ?? json['name']) ??
          'Dispositivo',
      createdAt: parse(json['created_at']),
      lastUsedAt: parse(json['last_used_at'] ?? json['last_access_at']),
      expiresAt: parse(json['expires_at']),
      hasRefresh: json['has_refresh'] == true,
      ip: idAsString(json['ip'] ?? json['ip_address']),
      platform: idAsString(json['platform'] ?? json['os'] ?? json['system']),
      location: idAsString(json['location'] ?? json['geo']),
      isCurrent: json['is_current'] == true || json['current'] == true,
      raw: json,
    );
  }
}

class LinkedAccount {
  const LinkedAccount({
    required this.provider,
    required this.label,
    this.email,
    this.linked = false,
    this.raw = const {},
  });

  final String provider;
  final String label;
  final String? email;
  final bool linked;
  final Map<String, dynamic> raw;

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    final provider =
        idAsString(json['provider'] ?? json['id'] ?? json['type']) ?? '';
    return LinkedAccount(
      provider: provider,
      label: idAsString(json['label'] ?? json['name']) ?? provider,
      email: idAsString(json['email']),
      linked: json['linked'] != false && json['connected'] != false,
      raw: json,
    );
  }
}
