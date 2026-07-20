/// Contratos da Fase 16 — CRM Político (`/v1/crm/*`).
/// Probe 2026-07-20 (sem token): todos HTTP 404 → nenhum slug LIVE ainda.
/// EndpointPendingState só se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS (401/200).
const kCrmLiveSlugs = <String>{};

bool crmPathLive(String slug) => kCrmLiveSlugs.contains(slug);
