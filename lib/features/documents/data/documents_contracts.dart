/// Contratos da Fase 13 — Gestão Documental (`/v1/documents/*`).
/// Probe auth 2026-07-21: list/favorites/templates = 200;
/// search = 422 (LIVE com query); approvals/attachments/etc. = 404.
library;

/// Slugs do hub com contrato HTTP 200 autenticado (ou 422 com query).
const kDocumentsLiveSlugs = <String>{
  'favorites',
  'templates',
  // root GET /v1/documents — usado como lista principal
  'list',
  'search', // 422 sem query = rota publicada
};

bool documentsPathLive(String slug) => kDocumentsLiveSlugs.contains(slug);
