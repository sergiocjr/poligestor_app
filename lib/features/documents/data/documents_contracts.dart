/// Contratos da Fase 13 — Gestão Documental (`/v1/documents/*`).
/// Probe 2026-07-20: todos 404 → nenhum slug LIVE ainda.
library;

const kDocumentsLiveSlugs = <String>{};

bool documentsPathLive(String slug) => kDocumentsLiveSlugs.contains(slug);
