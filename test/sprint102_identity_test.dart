import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/identity/data/identity_models.dart';
import 'package:poligestor_app/features/identity/domain/identity_deep_link.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';

void main() {
  group('AuthMode Sprint 10.2 paths', () {
    test('staff sessions and logout', () {
      expect(AuthMode.staff.sessionsPath, '/v1/auth/sessions');
      expect(AuthMode.staff.sessionPath('abc'), '/v1/auth/sessions/abc');
      expect(AuthMode.staff.sessionsRevokeAllPath, '/v1/auth/sessions/revoke-all');
      expect(AuthMode.staff.logoutPath, '/v1/auth/logout');
      expect(AuthMode.staff.tenantsResolvePath, '/v1/identity/tenants/resolve');
      expect(AuthMode.staff.brandingPath, '/v1/portal/branding');
    });

    test('portal mirror paths', () {
      expect(AuthMode.portal.sessionsPath, '/v1/portal/auth/sessions');
      expect(AuthMode.portal.registerPath, '/v1/portal/auth/register');
      expect(AuthMode.portal.forgotPasswordPath, '/v1/portal/auth/forgot-password');
      expect(AuthMode.portal.oauthGooglePath, '/v1/portal/auth/google');
      expect(AuthMode.portal.oauthApplePath, '/v1/portal/auth/apple');
      expect(AuthMode.portal.oauthGovBrPath, '/v1/portal/auth/govbr');
      expect(AuthMode.portal.linkedAccountsPath, '/v1/portal/auth/linked-accounts');
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

  group('TenantOrganization / Branding', () {
    test('nested tenant parse', () {
      final org = TenantOrganization.fromJson({
        'tenant': {'id': '1', 'name': 'Demo', 'slug': 'demo'},
      });
      expect(org.slug, 'demo');
      expect(org.name, 'Demo');
    });

    test('branding colors', () {
      final b = TenantBranding.fromJson({
        'name': 'Prefeitura',
        'primary_color': '#0D9488',
        'secondary_color': '#0F172A',
        'tagline': 'Mandato digital',
      });
      expect(b.tenantName, 'Prefeitura');
      expect(b.primaryColor, '#0D9488');
      expect(b.tagline, 'Mandato digital');
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
}
