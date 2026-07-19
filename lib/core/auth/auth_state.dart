import 'auth_mode.dart';

class AuthUser {
  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.tenantName,
    this.district,
    this.city,
    this.document,
    this.raw,
  });

  final dynamic id;
  final String name;
  final String email;
  final String? role;
  final String? tenantName;
  final String? district;
  final String? city;
  final String? document;
  final Map<String, dynamic>? raw;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? 'Cidadão' : parts.first;
  }

  String get neighborhoodLabel {
    if (district != null && district!.isNotEmpty) {
      if (city != null && city!.isNotEmpty) return '$district · $city';
      return district!;
    }
    if (city != null && city!.isNotEmpty) return city!;
    return 'Meu bairro';
  }

  /// Documento mascarado para UI/cache (nunca exibir CPF completo).
  String? get maskedDocument => maskDocument(document);

  static String? maskDocument(String? document) {
    if (document == null) return null;
    final digits = document.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length < 3) return '***';
    final tail = digits.substring(digits.length - 2);
    return '***.***.***-$tail';
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final person = json['person'] is Map
        ? Map<String, dynamic>.from(json['person'] as Map)
        : null;
    final tenant = json['tenant'] is Map
        ? Map<String, dynamic>.from(json['tenant'] as Map)
        : null;

    Map<String, dynamic>? address;
    final addresses = person?['addresses'];
    if (addresses is List && addresses.isNotEmpty && addresses.first is Map) {
      address = Map<String, dynamic>.from(addresses.first as Map);
    }

    final roles = json['roles'];
    String? role;
    if (roles is List && roles.isNotEmpty) {
      role = roles.first.toString();
    } else {
      role = json['role']?.toString() ?? json['perfil']?.toString();
    }

    return AuthUser(
      id: json['id'] ?? person?['id'],
      name: (json['name'] ?? person?['name'] ?? json['nome'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: role,
      tenantName: tenant?['name']?.toString(),
      district: address?['district']?.toString(),
      city: address?['city']?.toString(),
      document: (person?['document'] ?? json['document'])?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (role != null) 'role': role,
    if (tenantName != null) 'tenant': {'name': tenantName},
    if (document != null || district != null || city != null)
      'person': {
        // Cache sem documento em claro.
        if (maskedDocument != null) 'document': maskedDocument,
        'addresses': [
          {
            if (district != null) 'district': district,
            if (city != null) 'city': city,
          },
        ],
      },
  };
}

class AuthSession {
  AuthSession({
    required this.mode,
    required this.user,
    required this.tenantSlug,
  });

  final AuthMode mode;
  final AuthUser user;
  final String tenantSlug;

  bool get isPortal => mode == AuthMode.portal;
  bool get isStaff => mode == AuthMode.staff;
}
