/// Contratos da Fase 13 — Gestão Documental (`/v1/documents/*`).
/// Catálogo oficial backend c29c2ad: dashboard, root, search, audit, favorites,
/// files, templates, tags, tipos documentais + detalhes.
/// `list` usa a raiz e `attachments` assume o remapeamento para `/files`.
library;

/// Slugs do hub com path AuthMode ∈ catálogo c29c2ad.
const kDocumentsLiveSlugs = <String>{
  'dashboard',
  'root',
  'favorites',
  'templates',
  'list',
  'search',
  'filters',
  'categories',
  'history',
  'timeline',
  'viewer',
  'signatures',
  'approvals',
  'share',
  'download',
  'upload',
  'attachments',
  'files',
  'tags',
  'oficios',
  'memorandos',
  'requerimentos',
  'indicacoes',
  'projetos',
  'decretos',
  'portarias',
  'mocoes',
  'audit',
};

bool documentsPathLive(String slug) => kDocumentsLiveSlugs.contains(slug);
