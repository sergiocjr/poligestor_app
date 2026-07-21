/// Contratos da Fase 14 — Gestão Financeira (`/v1/finance/*`).
/// Probe auth 2026-07-21: 9 paths HTTP 200 (aliases bank-accounts/cash-flow).
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
