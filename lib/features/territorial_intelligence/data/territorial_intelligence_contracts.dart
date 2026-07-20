/// Contratos da Fase 12 — status VPS (probe sem token: 401 = rota LIVE; 404 = pendente).
library;

/// Paths sob `/v1/intelligence/*` que respondem na VPS (401 sem auth = contrato publicado).
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
