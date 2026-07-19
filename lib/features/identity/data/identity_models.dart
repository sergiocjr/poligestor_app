/// Parsing defensivo + modelos Sprint 10.2 (identidade / conta / branding).
Map<String, dynamic> idAsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> idAsMapList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
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
    this.raw = const {},
  });

  final String id;
  final String name;
  final String slug;
  final String? code;
  final String? domain;
  final Map<String, dynamic> raw;

  factory TenantOrganization.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] is Map ? idAsMap(json['tenant']) : json;
    return TenantOrganization(
      id: idAsString(tenant['id']) ?? '',
      name: idAsString(tenant['name'] ?? tenant['nome']) ?? 'Organização',
      slug: idAsString(tenant['slug']) ?? '',
      code: idAsString(tenant['code'] ?? tenant['access_code']),
      domain: idAsString(tenant['domain'] ?? tenant['host'] ?? json['host']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        if (code != null) 'code': code,
        if (domain != null) 'domain': domain,
      };
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
    String? colorOf(dynamic v) => idAsString(v);
    return TenantBranding(
      tenantName: idAsString(data['name'] ?? tenant['name'] ?? json['name']) ??
          'Organização',
      logoUrl: idAsString(data['logo_url'] ?? data['logo'] ?? json['logo_url']),
      bannerUrl:
          idAsString(data['banner_url'] ?? data['banner'] ?? json['banner_url']),
      primaryColor: colorOf(
        data['primary_color'] ?? data['primary'] ?? data['color_primary'],
      ),
      secondaryColor: colorOf(
        data['secondary_color'] ?? data['secondary'] ?? data['color_secondary'],
      ),
      iconUrl: idAsString(data['icon_url'] ?? data['icon']),
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

typedef ColorHex = String;

class AuthProviderInfo {
  const AuthProviderInfo({
    required this.id,
    required this.label,
    this.enabled = false,
    this.raw = const {},
  });

  final String id;
  final String label;
  final bool enabled;
  final Map<String, dynamic> raw;

  factory AuthProviderInfo.fromJson(Map<String, dynamic> json) {
    final id = idAsString(json['id'] ?? json['provider'] ?? json['key']) ?? '';
    return AuthProviderInfo(
      id: id,
      label: idAsString(json['label'] ?? json['name']) ?? id,
      enabled: json['enabled'] == true || json['active'] == true,
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
