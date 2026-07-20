/// Contratos da Fase 21 — Segurança e Privacidade (`/v1/security/*`).
/// Auditoria 2026-07-20 (auth): dashboard HTTP 200; demais paths ainda 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200 autenticado).
const kSecurityLiveSlugs = <String>{
  'dashboard', // VPS LIVE; hub Flutter ainda sem rota dedicada
};

bool securityPathLive(String slug) => kSecurityLiveSlugs.contains(slug);
