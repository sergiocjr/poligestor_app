/// Contratos da Fase 20 — Portal Administrativo Web (`/v1/platform/*`).
/// Auditoria 2026-07-20 (auth admin@demo.local): todos os paths HTTP 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato LIVE na VPS (HTTP 200 autenticado).
const kPlatformLiveSlugs = <String>{};

bool platformPathLive(String slug) => kPlatformLiveSlugs.contains(slug);
