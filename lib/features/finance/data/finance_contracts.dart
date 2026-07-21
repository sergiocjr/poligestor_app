/// Contratos da Fase 14 — Gestão Financeira (`/v1/finance/*`).
/// Catálogo oficial backend c29c2ad.
/// Aliases de UI: bank-accounts→/accounts, cash-flow→/cashflow (AuthMode OK).
/// Assume os remapeamentos budget→budgets e suppliers→payees.
library;

/// Slugs do hub com path AuthMode ∈ catálogo c29c2ad.
const kFinanceLiveSlugs = <String>{
  'dashboard',
  'indicators',
  'balance',
  'revenues',
  'expenses',
  'bank-accounts',
  'categories',
  'cost-centers',
  'suppliers',
  'contracts',
  'refunds',
  'advances',
  'funds',
  'budget',
  'budget-execution',
  'accountability',
  'receipts',
  'attachments',
  'approvals',
  'reconciliation',
  'cash-flow',
  'payables',
  'receivables',
  'alerts',
  'history',
  'filters',
  'search',
  'reports',
  'exports',
  'transactions',
  'payments',
  'audit',
};

bool financePathLive(String slug) => kFinanceLiveSlugs.contains(slug);
