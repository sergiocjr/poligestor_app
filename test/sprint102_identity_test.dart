import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/core/config.dart';
import 'package:poligestor_app/features/identity/data/identity_models.dart';
import 'package:poligestor_app/features/identity/domain/identity_deep_link.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';

void main() {
  group('AuthMode Sprint 10.2 paths', () {
    test('staff sessions and logout', () {
      expect(AuthMode.staff.sessionsPath, '/v1/auth/sessions');
      expect(AuthMode.staff.sessionPath('abc'), '/v1/auth/sessions/abc');
      expect(
        AuthMode.staff.sessionsRevokeAllPath,
        '/v1/auth/sessions/revoke-all',
      );
      expect(AuthMode.staff.logoutPath, '/v1/auth/logout');
      expect(AuthMode.staff.tenantsResolvePath, '/v1/identity/tenants/resolve');
      expect(AuthMode.staff.brandingPath, '/v1/portal/branding');
    });

    test('portal mirror paths', () {
      expect(AuthMode.portal.sessionsPath, '/v1/portal/auth/sessions');
      expect(AuthMode.portal.registerPath, '/v1/portal/auth/register');
      expect(
        AuthMode.portal.forgotPasswordPath,
        '/v1/portal/auth/forgot-password',
      );
      expect(AuthMode.portal.oauthGooglePath, '/v1/portal/auth/google');
      expect(AuthMode.portal.oauthApplePath, '/v1/portal/auth/apple');
      expect(AuthMode.portal.oauthGovBrPath, '/v1/portal/auth/govbr');
      expect(
        AuthMode.portal.linkedAccountsPath,
        '/v1/portal/auth/linked-accounts',
      );
      expect(AuthMode.portal.authProvidersPath, '/v1/portal/auth/providers');
    });
  });

  group('LIVE resolve contract parsing', () {
    test('parses organization nested payload', () {
      final org = TenantOrganization.fromJson({
        'method': 'slug',
        'organization': {
          'id': '019f6c8d',
          'name': 'Organização Demo',
          'slug': 'demo',
          'access_code': 'DEMO',
          'is_active': true,
          'domain': 'demo',
          'branding': {
            'name': 'Gabinete Ana Souza',
            'tagline': 'Portal do Cidadão',
            'logo_path': '/img/logo-sm.png',
            'primary_color': '#0f766e',
            'secondary_color': '#0369a1',
          },
        },
        'config': {'registration_enabled': true},
      });
      expect(org.slug, 'demo');
      expect(org.name, 'Organização Demo');
      expect(org.code, 'DEMO');
      expect(org.isActive, isTrue);
      expect(org.registrationEnabled, isTrue);
      final branding = org.embeddedBranding!;
      expect(branding.tenantName, 'Gabinete Ana Souza');
      expect(branding.primaryColor, '#0f766e');
      expect(
        branding.logoUrl,
        'https://${AppConfig.publicHost}/img/logo-sm.png',
      );
    });
  });

  group('LIVE branding contract', () {
    test('parses logo_path and colors', () {
      final b = TenantBranding.fromJson({
        'tenant': {'name': 'Organização Demo', 'slug': 'demo'},
        'branding': {
          'name': 'Gabinete Ana Souza',
          'tagline': 'Portal do Cidadão',
          'logo_path': '/img/logo-sm.png',
          'favicon_path': '/favicon.ico',
          'primary_color': '#0f766e',
          'secondary_color': '#0369a1',
        },
      });
      expect(b.tenantName, 'Gabinete Ana Souza');
      expect(b.tagline, 'Portal do Cidadão');
      expect(b.logoUrl, contains('/img/logo-sm.png'));
      expect(b.iconUrl, contains('/favicon.ico'));
    });
  });

  group('LIVE providers contract', () {
    test('parses is_enabled and ready', () {
      final list = [
        {'provider': 'password', 'is_enabled': true, 'ready': true},
        {'provider': 'google', 'is_enabled': true, 'ready': true},
        {'provider': 'apple', 'is_enabled': false, 'ready': true},
        {'provider': 'govbr', 'is_enabled': true, 'ready': false},
      ].map(AuthProviderInfo.fromJson).toList();

      expect(list.first.isPassword, isTrue);
      expect(list.first.canUse, isFalse);
      expect(list[1].canUse, isTrue);
      expect(list[2].canUse, isFalse);
      expect(list[3].canUse, isFalse);
      expect(list[1].label, 'Google');
    });

    test('VPS corrected providers are not usable', () {
      final list = [
        {
          'provider': 'password',
          'is_enabled': true,
          'ready': true,
          'status': 'ok',
        },
        {
          'provider': 'google',
          'is_enabled': false,
          'ready': false,
          'status': 'provider_disabled',
        },
        {
          'provider': 'apple',
          'is_enabled': false,
          'ready': false,
          'status': 'provider_disabled',
        },
        {
          'provider': 'govbr',
          'is_enabled': false,
          'ready': false,
          'status': 'provider_disabled',
        },
      ].map(AuthProviderInfo.fromJson).toList();
      expect(list.where((p) => p.canUse), isEmpty);
    });
  });

  group('AuthSessionInfo parsing', () {
    test('parses live contract fields', () {
      final s = AuthSessionInfo.fromJson({
        'session_id': 'sess-1',
        'device_name': 'Android SM-A105M',
        'created_at': '2026-07-01T10:00:00Z',
        'last_used_at': '2026-07-18T12:00:00Z',
        'expires_at': '2026-08-01T10:00:00Z',
        'has_refresh': true,
      });
      expect(s.sessionId, 'sess-1');
      expect(s.deviceName, 'Android SM-A105M');
      expect(s.hasRefresh, isTrue);
      expect(s.createdAt, isNotNull);
      expect(s.lastUsedAt, isNotNull);
    });
  });

  group('IdentityDeepLink', () {
    test('poligestor://org/demo', () {
      final uri = Uri.parse('poligestor://org/demo');
      expect(IdentityDeepLink.isIdentityUri(uri), isTrue);
      expect(IdentityDeepLink.slugFrom(uri), 'demo');
      expect(IdentityDeepLink.toOrgLocation(uri), '/org?slug=demo');
    });

    test('poligestor://tenant/acme', () {
      final uri = Uri.parse('poligestor://tenant/acme');
      expect(IdentityDeepLink.slugFrom(uri), 'acme');
    });
  });

  group('NotificationRouter org deep links', () {
    test('resolves org link', () {
      final target = const NotificationRouter().resolve(
        const PushPayload(
          type: PushEventType.unknown,
          deepLink: 'poligestor://org/demo',
        ),
      );
      expect(target?.location, '/org?slug=demo');
    });
  });

  group('absolute public URL helper', () {
    test('keeps absolute and prefixes relative', () {
      expect(
        idAbsolutePublicUrl('https://cdn.example/a.png'),
        'https://cdn.example/a.png',
      );
      expect(
        idAbsolutePublicUrl('/img/logo-sm.png'),
        'https://${AppConfig.publicHost}/img/logo-sm.png',
      );
    });
  });
}
