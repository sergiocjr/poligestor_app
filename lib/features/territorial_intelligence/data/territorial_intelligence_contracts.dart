/// Contratos da Fase 12 — Inteligência Territorial (`/v1/intelligence/*`).
/// Catálogo oficial backend c29c2ad.
/// Assume os remapeamentos: heatmap→heatmaps, map→maps,
/// electoral-zones→zones, leaderships→leaders,
/// demands→demands-by-region, works→works-by-region,
/// protocols→protocols-by-region, attendances→attendances-by-region,
/// comparatives→comparison, exports→exports/pdf|excel.
library;

/// Paths sob `/v1/intelligence/*` com AuthMode ∈ catálogo c29c2ad.
const kTerritorialIntelligenceLiveSlugs = <String>{
  'dashboard',
  'bi',
  'kpis',
  'indicators',
  'charts',
  'heatmap',
  'map',
  'neighborhoods',
  'regions',
  'electoral-zones',
  'leaderships',
  'demands',
  'works',
  'protocols',
  'attendances',
  'comparatives',
  'evolution',
  'trends',
  'projections',
  'filters',
  'exports',
  'influencers',
  'goals',
  'dashboards',
  'audit',
  'reports',
};

bool territorialIntelligencePathLive(String slug) =>
    kTerritorialIntelligenceLiveSlugs.contains(slug);
