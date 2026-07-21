/// Contratos da Fase 20 — Portal Administrativo Web (`/v1/platform/*`).
/// Catálogo oficial backend c29c2ad.
/// Assume os remapeamentos: offices→cabinets, licensing→licenses,
/// consumption→usage, global-settings→settings/global,
/// tenant-settings→settings/tenant, knowledge-base→knowledge, exports→export.
library;

/// Slugs com path AuthMode ∈ catálogo (hub card ou rota de repositório).
const kPlatformLiveSlugs = <String>{
  'dashboard',
  'companies',
  'offices',
  'users',
  'profiles',
  'permissions',
  'plans',
  'licensing',
  'subscriptions',
  'charges',
  'invoices',
  'payments',
  'consumption',
  'plan-limits',
  'metrics',
  'logs',
  'audit',
  'sessions',
  'integrations',
  'webhooks',
  'global-settings',
  'tenant-settings',
  'tickets',
  'knowledge-base',
  'announcements',
  'releases',
  'maintenances',
  'monitoring',
  'health',
  'reports',
  'exports',
  'search',
  'filters',
  'operators',
};

bool platformPathLive(String slug) => kPlatformLiveSlugs.contains(slug);
