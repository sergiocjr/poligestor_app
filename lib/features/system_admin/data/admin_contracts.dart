/// Contratos da Fase 19 — Administração do Sistema (`/v1/admin/*`).
/// Auditoria 2026-07-20 (auth): dashboard HTTP 200; demais paths ainda 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200 autenticado).
const kAdminLiveSlugs = <String>{
  'dashboard',
};

bool adminPathLive(String slug) => kAdminLiveSlugs.contains(slug);
