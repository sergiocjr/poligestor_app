/// Contratos da Fase 17 — Gestão Eleitoral (`/v1/elections/*`).
/// Auditoria 2026-07-20 (auth admin@demo.local): 14 paths HTTP 200; 31 ainda 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato LIVE na VPS (HTTP 200 autenticado).
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
  'material-requests',
  'projections',
  'accountability',
  'receipts',
  'reports',
};

bool electionsPathLive(String slug) => kElectionsLiveSlugs.contains(slug);
