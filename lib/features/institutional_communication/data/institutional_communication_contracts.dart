/// Contratos da Fase 15 — Comunicação Institucional (`/v1/communication/*`).
/// Probe 2026-07-20 (sem token): todos HTTP 404 → nenhum slug LIVE ainda.
/// EndpointPendingState só se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS (401/200).
const kInstitutionalCommunicationLiveSlugs = <String>{};

bool institutionalCommunicationPathLive(String slug) =>
    kInstitutionalCommunicationLiveSlugs.contains(slug);
