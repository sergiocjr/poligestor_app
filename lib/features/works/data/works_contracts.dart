/// Contratos Sprint 10.9 — Painel Obras (`/v1/works/*`).
/// Probe auth 2026-07-21: root + 9 subpaths HTTP 200;
/// checklist/indicators/projects/search = 404.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200 autenticado).
/// `list` = GET `/v1/works` (raiz).
const kWorksLiveSlugs = <String>{
  'list',
  'dashboard',
  'demands',
  'inspections',
  'schedule',
  'map',
  'timeline',
  'photos',
  'attachments',
  'reports',
};

bool worksPathLive(String slug) => kWorksLiveSlugs.contains(slug);
