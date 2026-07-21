/// Contratos da Fase 17 — Gestão Eleitoral (`/v1/elections/*`).
/// Probe auth 2026-07-21: 14 paths HTTP 200.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200 autenticado).
const kElectionsLiveSlugs = <String>{
  'dashboard',
  'campaigns',
  'candidates',
  'teams',
  'goals',
  'regions',
  'neighborhoods',
  'map',
  'events',
  'projections',
  'accountability',
  'receipts',
  'material-requests',
  'reports',
};

bool electionsPathLive(String slug) => kElectionsLiveSlugs.contains(slug);
