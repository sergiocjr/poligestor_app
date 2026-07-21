/// Contratos da Fase 20 — Portal Administrativo Web (`/v1/platform/*`).
/// Probe auth 2026-07-21: 23 paths HTTP 200; profiles/search-sem-query 404/422.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200 autenticado).
const kPlatformLiveSlugs = <String>{
  'dashboard',
  'companies',
  'users',
  'permissions',
  'plans',
  'subscriptions',
  'charges',
  'invoices',
  'payments',
  'plan-limits',
  'metrics',
  'logs',
  'audit',
  'sessions',
  'integrations',
  'webhooks',
  'tickets',
  'announcements',
  'releases',
  'maintenances',
  'monitoring',
  'health',
  'reports',
};

bool platformPathLive(String slug) => kPlatformLiveSlugs.contains(slug);
