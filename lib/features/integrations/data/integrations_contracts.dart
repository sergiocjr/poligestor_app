/// Contratos da Fase 22 — Integrações (`/v1/integrations/*`).
/// Catálogo oficial backend c29c2ad: dashboard/history/sync/webhooks/logs/
/// settings/catalog/audit/monitoring/health/metrics + providers.
/// Aliases AuthMode: status→health, config→settings, senado-federal→senado,
/// e-sic→esic, outlook-calendar→outlook.
/// search/filters ∉ catálogo (não LIVE).
library;

/// Slugs do hub / rotas de repositório com path ∈ catálogo c29c2ad.
const kIntegrationsLiveSlugs = <String>{
  'dashboard',
  'status',
  'config',
  'sync',
  'history',
  'logs',
  'govbr',
  'camara-municipal',
  'assembleia-legislativa',
  'camara-deputados',
  'senado-federal',
  'diario-oficial',
  'portal-transparencia',
  'e-sic',
  'ouvidoria',
  'google-calendar',
  'outlook-calendar',
  'gmail',
  'whatsapp',
  'telegram',
  'firebase-push',
  'external-apis',
  'webhooks',
  'catalog',
  'providers',
  'audit',
  'monitoring',
  'metrics',
  'search',
  'filters',
};

bool integrationsPathLive(String slug) => kIntegrationsLiveSlugs.contains(slug);
