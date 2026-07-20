/// Contratos da Fase 17 — Gestão Eleitoral (`/v1/elections/*`).
/// Probe 2026-07-20: 14 paths HTTP 401 (publicados); 31 ainda 404 → Pending.
/// EndpointPendingState só se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS (401/200).
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
