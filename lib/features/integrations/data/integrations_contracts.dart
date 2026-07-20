/// Contratos da Fase 22 — Integrações (`/v1/integrations/*`).
/// Auditoria 2026-07-20 (auth): 23 LIVE (HTTP 200/202); search/filters 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs do hub com contrato LIVE na VPS (HTTP 200/201/202 autenticado).
const kIntegrationsLiveSlugs = <String>{
  'dashboard',
  'status', // GET /v1/integrations/health
  'config', // GET/PUT /v1/integrations/settings
  'sync',
  'history',
  'logs',
  'govbr',
  'camara-municipal',
  'assembleia-legislativa',
  'camara-deputados',
  'senado-federal', // GET /v1/integrations/senado
  'diario-oficial',
  'portal-transparencia',
  'e-sic', // GET /v1/integrations/esic
  'ouvidoria',
  'google-calendar',
  'outlook-calendar', // GET /v1/integrations/outlook
  'gmail',
  'whatsapp',
  'telegram',
  'firebase-push',
  'external-apis',
  'webhooks',
  // Catálogo auxiliar (não é card dedicado; usado no painel)
  'catalog',
  'providers',
};

bool integrationsPathLive(String slug) =>
    kIntegrationsLiveSlugs.contains(slug);
