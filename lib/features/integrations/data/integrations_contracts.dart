/// Contratos da Fase 22 — Integrações (`/v1/integrations/*`).
/// Auditoria 2026-07-20 (auth): todos os paths HTTP 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato LIVE na VPS (HTTP 200/201/202 autenticado).
const kIntegrationsLiveSlugs = <String>{};

bool integrationsPathLive(String slug) =>
    kIntegrationsLiveSlugs.contains(slug);
