/// Contratos da Fase 14 — Gestão Financeira (`/v1/finance/*`).
/// Probe 2026-07-20 (sem token): HTTP 401 = LIVE; demais do hub 404 → Pending.
/// EndpointPendingState só se a VPS voltar a responder 404/405/501/503.
library;

/// Slugs do hub com contrato publicado na VPS.
const kFinanceLiveSlugs = <String>{
  'dashboard',
  'categories',
  'cost-centers',
  'alerts',
  'reports',
  'bank-accounts', // GET /v1/finance/accounts
  'cash-flow', // GET /v1/finance/cashflow
  'transactions',
  'payments',
};

bool financePathLive(String slug) => kFinanceLiveSlugs.contains(slug);
