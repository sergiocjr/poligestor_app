/// Contratos da Fase 19 — Administração do Sistema (`/v1/admin/*`).
/// Auditoria 2026-07-20 (auth admin@demo.local): todos os paths HTTP 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato LIVE na VPS (HTTP 200 autenticado).
const kAdminLiveSlugs = <String>{};

bool adminPathLive(String slug) => kAdminLiveSlugs.contains(slug);
