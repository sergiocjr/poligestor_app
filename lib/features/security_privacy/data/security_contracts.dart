/// Contratos da Fase 21 — Segurança e Privacidade (`/v1/security/*`).
/// Probe auth 2026-07-21: 6 paths HTTP 200.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200 autenticado).
const kSecurityLiveSlugs = <String>{
  'access-history',
  'alerts',
  'consents',
  'incidents',
  'sessions',
  'tokens',
};

bool securityPathLive(String slug) => kSecurityLiveSlugs.contains(slug);
