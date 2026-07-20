/// Contratos da Fase 15 — Comunicação Institucional (`/v1/communication/*`).
/// Auditoria 2026-07-20 (auth): dashboard HTTP 200; demais paths ainda 404.
/// EndpointPendingState só se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS (401/200).
const kInstitutionalCommunicationLiveSlugs = <String>{
  'dashboard', // GET /v1/communication/dashboard (hub ainda sem card dedicado)
};

bool institutionalCommunicationPathLive(String slug) =>
    kInstitutionalCommunicationLiveSlugs.contains(slug);
