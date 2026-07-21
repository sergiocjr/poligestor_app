/// Contratos da Fase 15 — Comunicação Institucional (`/v1/communication/*`).
/// Probe auth 2026-07-21: 5 paths HTTP 200; demais subpaths 404.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200).
const kInstitutionalCommunicationLiveSlugs = <String>{
  'announcements',
  'campaigns',
  'media',
  'publications',
  'reports',
};

bool institutionalCommunicationPathLive(String slug) =>
    kInstitutionalCommunicationLiveSlugs.contains(slug);
