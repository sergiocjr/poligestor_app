/// Contratos Sprint 10.9 — Painel Obras (`/v1/works/*`).
/// Catálogo oficial backend c29c2ad: root/attachments/dashboard/demands/
/// inspections/map/photos/reports/schedule/timeline/visits/{id}.
/// `list` assume o remapeamento de `worksListPath` para a raiz `/v1/works`.
library;

/// Slugs do hub com path AuthMode ∈ catálogo c29c2ad.
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
  'checklist',
  'indicators',
  'reports',
  'search',
};

bool worksPathLive(String slug) => kWorksLiveSlugs.contains(slug);
