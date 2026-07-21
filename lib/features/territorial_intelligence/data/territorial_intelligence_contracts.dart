/// Contratos da Fase 12 — Inteligência Territorial (`/v1/intelligence/*`).
/// Probe auth 2026-07-21: 7 paths HTTP 200.
library;

/// Paths sob `/v1/intelligence/*` que respondem na VPS (HTTP 200 autenticado).
const kTerritorialIntelligenceLiveSlugs = <String>{
  'dashboard',
  'kpis',
  'charts',
  'neighborhoods',
  'regions',
  'trends',
  'projections',
};

bool territorialIntelligencePathLive(String slug) =>
    kTerritorialIntelligenceLiveSlugs.contains(slug);
