/// Contratos da Fase 21 — Segurança e Privacidade (`/v1/security/*`).
/// Auditoria 2026-07-20 (auth): todos os paths HTTP 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato LIVE na VPS (HTTP 200 autenticado).
const kSecurityLiveSlugs = <String>{};

bool securityPathLive(String slug) => kSecurityLiveSlugs.contains(slug);
