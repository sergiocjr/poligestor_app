import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../core/config.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../data/identity_cache.dart';
import '../data/identity_models.dart';
import '../data/identity_repository.dart';

/// Estado global da organização selecionada + branding (Sprint 10.2).
class TenantController extends ChangeNotifier {
  TenantController({
    required IdentityRepository repository,
    required IdentityCache cache,
    required TokenStorage storage,
    required ApiClient api,
  }) : _repository = repository,
       _cache = cache,
       _storage = storage,
       _api = api;

  final IdentityRepository _repository;
  final IdentityCache _cache;
  final TokenStorage _storage;
  final ApiClient _api;

  TenantOrganization? _organization;
  TenantBranding? _branding;
  bool _ready = false;
  bool _busy = false;
  String? _error;
  bool _brandingUnavailable = false;
  bool _resolveUnavailable = false;

  TenantOrganization? get organization => _organization;
  TenantBranding? get branding => _branding;
  bool get ready => _ready;
  bool get busy => _busy;
  String? get error => _error;
  bool get hasOrganization =>
      _organization != null && _organization!.slug.isNotEmpty;
  bool get brandingUnavailable => _brandingUnavailable;
  bool get resolveUnavailable => _resolveUnavailable;
  bool get registrationEnabled => _organization?.registrationEnabled ?? true;

  String get displayName =>
      _branding?.tenantName ?? _organization?.name ?? AppConfig.appName;

  ThemeData get theme => AppTheme.lightFromBranding(_branding);

  Future<void> bootstrap() async {
    _busy = true;
    notifyListeners();
    try {
      _organization = await _cache.getOrganization();
      if (hasOrganization) {
        _branding = await _cache.getBranding(slug: _organization!.slug);
      }

      if (kIsWeb && !hasOrganization) {
        await _tryResolveWebHost();
      }

      if (hasOrganization) {
        final slug = _organization!.slug;
        final mode = await _storage.getAuthMode() ?? AuthMode.staff;
        await _storage.saveSessionMeta(mode: mode, tenantSlug: slug);
        _api.setSessionContext(mode: mode, tenantSlug: slug);
        await _refreshBrandingQuiet();
      }
    } finally {
      _ready = true;
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _tryResolveWebHost() async {
    try {
      final host = Uri.base.host.toLowerCase();
      if (host.isEmpty ||
          host == 'localhost' ||
          host.startsWith('127.') ||
          host == 'poligestor.onnexis.com.br' ||
          host == 'www.poligestor.onnexis.com.br') {
        return;
      }
      await selectByDomain(host);
    } catch (_) {}
  }

  Future<void> selectBySlug(String slug) =>
      _commitResolve(() => _repository.resolve(slug: slug));

  Future<void> selectByCode(String code) =>
      _commitResolve(() => _repository.resolve(code: code));

  Future<void> selectByDomain(String domain) =>
      _commitResolve(() => _repository.resolve(domain: domain));

  Future<void> selectByQuery(String query) =>
      _commitResolve(() => _repository.resolve(query: query));

  /// Fallback local apenas se o resolve remoto estiver indisponível (404/5xx).
  Future<void> selectSlugLocally(String slug, {String? displayName}) async {
    final s = slug.trim().toLowerCase();
    if (s.isEmpty) {
      _error = 'Informe o código ou slug da organização.';
      notifyListeners();
      return;
    }
    _organization = TenantOrganization(
      id: s,
      name: (displayName?.trim().isNotEmpty == true) ? displayName!.trim() : s,
      slug: s,
    );
    await _cache.saveOrganization(_organization!);
    final mode = await _storage.getAuthMode() ?? AuthMode.staff;
    await _storage.saveSessionMeta(mode: mode, tenantSlug: s);
    _api.setSessionContext(mode: mode, tenantSlug: s);
    await _refreshBrandingQuiet();
    _error = null;
    _resolveUnavailable = true;
    notifyListeners();
  }

  Future<void> _commitResolve(Future<TenantOrganization> Function() run) async {
    _busy = true;
    _error = null;
    _resolveUnavailable = false;
    notifyListeners();
    try {
      final org = await run();
      if (org.slug.isEmpty) {
        throw StateError('Organização sem slug');
      }
      if (!org.isActive) {
        throw StateError('Organização inativa');
      }
      _organization = org;
      final embedded = org.embeddedBranding;
      if (embedded != null) {
        _branding = embedded;
        _brandingUnavailable = false;
        await _cache.saveBranding(embedded, slug: org.slug);
      }
      await _cache.saveOrganization(org);
      final mode = await _storage.getAuthMode() ?? AuthMode.staff;
      await _storage.saveSessionMeta(mode: mode, tenantSlug: org.slug);
      _api.setSessionContext(mode: mode, tenantSlug: org.slug);
      await _refreshBrandingQuiet();
    } on EndpointUnavailableException {
      _resolveUnavailable = true;
      _error =
          'A resolução de organização ainda não está disponível no servidor.';
      rethrow;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _refreshBrandingQuiet() async {
    if (!hasOrganization) return;
    try {
      final branding = await _repository.branding(
        tenantSlug: _organization!.slug,
      );
      _branding = branding;
      _brandingUnavailable = false;
      await _cache.saveBranding(branding, slug: _organization!.slug);
    } on EndpointUnavailableException {
      _brandingUnavailable = _branding == null;
    } catch (_) {
      _brandingUnavailable = _branding == null;
    }
  }

  /// Troca de organização: limpa tokens, perfil e caches identity.
  Future<void> clearOrganization() async {
    await _storage.clearSessionAndTenant();
    await _cache.purgeAllTenantData();
    _organization = null;
    _branding = null;
    _brandingUnavailable = false;
    _resolveUnavailable = false;
    _api.setSessionContext(mode: null, tenantSlug: null);
    notifyListeners();
  }
}
