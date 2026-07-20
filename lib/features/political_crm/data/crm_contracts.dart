/// Contratos da Fase 16 — CRM Político (`/v1/crm/*`).
/// Auditoria 2026-07-20 (auth): dashboard HTTP 200; demais paths ainda 404.
/// EndpointPendingState só se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS (401/200).
const kCrmLiveSlugs = <String>{
  'dashboard',
};

bool crmPathLive(String slug) => kCrmLiveSlugs.contains(slug);
