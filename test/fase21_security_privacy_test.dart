import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/security_privacy/data/security_cache.dart';
import 'package:poligestor_app/features/security_privacy/data/security_contracts.dart';
import 'package:poligestor_app/features/security_privacy/data/security_models.dart';
import 'package:poligestor_app/features/security_privacy/presentation/security_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 21 Security paths', () {
    test('exposes official /v1/security namespace', () {
      const m = AuthMode.staff;
      expect(m.securityRootPath, '/v1/security');
      expect(m.securityMfaEnablePath, '/v1/security/mfa/enable');
      expect(m.securityMfaConfirmPath, '/v1/security/mfa/confirm');
      expect(m.securityAccountRecoveryPath, '/v1/security/account-recovery');
      expect(m.securitySessionsPath, '/v1/security/sessions');
      expect(
        m.securitySessionsRevokeAllPath,
        '/v1/security/sessions/revoke-all',
      );
      expect(m.securityAccessHistoryPath, '/v1/security/access-history');
      expect(m.securityDevicesPath, '/v1/security/devices');
      expect(m.securityPasswordChangePath, '/v1/security/password-change');
      expect(
        m.securityPasswordPoliciesPath,
        '/v1/security/password-policies',
      );
      expect(m.securityTokensPath, '/v1/security/tokens');
      expect(m.securityApiKeysPath, '/v1/security/api-keys');
      expect(m.securityAlertsPath, '/v1/security/alerts');
      expect(m.securityPrivacyPath, '/v1/security/privacy');
      expect(m.securityConsentsPath, '/v1/security/consents');
      expect(m.securityTermsPath, '/v1/security/terms');
      expect(m.securityPrivacyPolicyPath, '/v1/security/privacy-policy');
      expect(m.securityDataRequestPath, '/v1/security/data-request');
      expect(m.securityDataExportPath, '/v1/security/data-export');
      expect(m.securityDataCorrectionPath, '/v1/security/data-correction');
      expect(m.securityAccountDeletionPath, '/v1/security/account-deletion');
      expect(
        m.securityPrivacyPreferencesPath,
        '/v1/security/privacy-preferences',
      );
      expect(m.securityConsentHistoryPath, '/v1/security/consent-history');
      expect(m.securityIncidentsPath, '/v1/security/incidents');
    });

    test('paths are identical for portal mode', () {
      const staff = AuthMode.staff;
      const portal = AuthMode.portal;
      expect(portal.securityRootPath, staff.securityRootPath);
      expect(portal.securityMfaEnablePath, staff.securityMfaEnablePath);
      expect(portal.securityApiKeysPath, staff.securityApiKeysPath);
    });
  });

  group('Security LIVE contracts', () {
    test('kSecurityLiveSlugs sync probe auth 2026-07-21', () {
      expect(securityPathLive('sessions'), isTrue);
      expect(securityPathLive('alerts'), isTrue);
      expect(securityPathLive('dashboard'), isFalse);
      expect(securityPathLive('mfa-enable'), isFalse);
      expect(kSecurityLiveSlugs.length, 6);
    });
  });

  group('Security hub', () {
    test('defines 22 hub cards', () {
      expect(securitySlugTitles.length, 22);
    });
  });

  group('Security models', () {
    test('parses item with masked email', () {
      final item = SecurityItem.fromJson({
        'id': '1',
        'name': 'Sessão Chrome',
        'email': 'usuario@demo.local',
        'status': 'active',
      });
      expect(item.title, 'Sessão Chrome');
      expect(item.email, 'u***@demo.local');
    });

    test('stripSecuritySecrets removes tokens from map', () {
      final cleaned = stripSecuritySecrets({
        'id': '1',
        'title': 'Token app',
        'access_token': 'secret-value',
        'password': '123456',
        'nested': {
          'api_key': 'key-abc',
          'label': 'ok',
        },
      }) as Map<String, dynamic>;
      expect(cleaned.containsKey('access_token'), isFalse);
      expect(cleaned.containsKey('password'), isFalse);
      expect((cleaned['nested'] as Map).containsKey('api_key'), isFalse);
      expect((cleaned['nested'] as Map)['label'], 'ok');
    });

    test('maskSecurityCpf hides middle digits', () {
      expect(maskSecurityCpf('12345678901'), '***.***.***-01');
    });
  });

  group('Security cache', () {
    test('strips secrets before save', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = SecurityCache();
      await cache.putMap('demo', 'sessions', {
        'data': [
          {
            'id': '1',
            'title': 'Web',
            'refresh_token': 'must-not-persist',
          },
        ],
      });
      final stored = await cache.getMap('demo', 'sessions');
      expect(stored, isNotNull);
      final list = stored!.data['data'] as List;
      expect((list.first as Map).containsKey('refresh_token'), isFalse);
    });

    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = SecurityCache();
      await cache.putMap('demo', 'devices', {
        'data': [
          {'id': '1', 'title': 'A'},
        ],
      });
      expect(await cache.getMap('other', 'devices'), isNull);
      expect(await cache.getMap('demo', 'devices'), isNotNull);
    });
  });

  group('deep links Security', () {
    test('poligestor://security resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://security',
        ),
      );
      expect(target?.location, '/home/security');
    });

    test('poligestor://seguranca/password-change', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://seguranca/password-change',
        ),
      );
      expect(target?.location, '/home/security/password-change');
    });

    test('poligestor://privacidade/consents', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://privacidade/consents',
        ),
      );
      expect(target?.location, '/home/security/consents');
    });

    test('poligestor://security-privacy/data-export', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://security-privacy/data-export',
        ),
      );
      expect(target?.location, '/home/security/data-export');
    });
  });
}
