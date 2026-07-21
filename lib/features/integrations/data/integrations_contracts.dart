/// Contratos da Fase 22 — Integrações (`/v1/integrations/*`).
/// Probe auth 2026-07-21: 25 hub slugs LIVE; search/filters 404.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200 autenticado).
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
  'catalog',
  'providers',
};

bool integrationsPathLive(String slug) =>
    kIntegrationsLiveSlugs.contains(slug);
