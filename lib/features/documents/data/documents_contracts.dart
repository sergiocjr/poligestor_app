/// Contratos da Fase 13 — Gestão Documental (`/v1/documents/*`).
/// Probe 2026-07-20 (sem token): todos HTTP 401 = rotas publicadas (LIVE).
/// EndpointPendingState só se a VPS voltar a responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS.
const kDocumentsLiveSlugs = <String>{
  'list',
  'search',
  'filters',
  'categories',
  'favorites',
  'history',
  'timeline',
  'viewer',
  'signatures',
  'approvals',
  'share',
  'templates',
  'download',
  'upload',
  'attachments',
};

bool documentsPathLive(String slug) => kDocumentsLiveSlugs.contains(slug);
