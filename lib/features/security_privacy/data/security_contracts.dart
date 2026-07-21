/// Contratos da Fase 21 — Segurança e Privacidade (`/v1/security/*`).
/// Catálogo oficial backend c29c2ad.
/// Assume os remapeamentos:
/// password-policies→password-policy, account-recovery→recovery,
/// data-export→export-me, data-request→data-subject-requests,
/// mfa-enable|mfa-confirm→mfa.
library;

/// Slugs do hub com path AuthMode ∈ catálogo c29c2ad.
const kSecurityLiveSlugs = <String>{
  'dashboard',
  'mfa-enable',
  'mfa-confirm',
  'account-recovery',
  'sessions-revoke',
  'devices',
  'password-change',
  'access-history',
  'password-policies',
  'alerts',
  'consents',
  'data-request',
  'data-export',
  'incidents',
  'sessions',
  'tokens',
  'api-keys',
  'privacy',
  'terms',
  'privacy-policy',
  'data-correction',
  'account-deletion',
  'privacy-preferences',
  'consent-history',
  'protections',
  'recovery',
  'password-policy',
  'login-attempts',
  'lockouts',
  'upload-policy',
  'keys',
  'audit',
  'immutable-logs',
  'suspicious',
  'legal-bases',
  'policies',
  'export-me',
  'retention',
  'backups',
  'continuity',
  'health',
  'monitoring',
  'metrics',
  'reports',
};

bool securityPathLive(String slug) => kSecurityLiveSlugs.contains(slug);
