/// Contratos da Fase 16 — CRM Político (`/v1/crm/*`).
/// Probe auth 2026-07-21: 16 paths HTTP 200.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200).
const kCrmLiveSlugs = <String>{
  'dashboard',
  'entities',
  'tags',
  'groups',
  'regions',
  'neighborhoods',
  'electoral-zones',
  'interactions',
  'visits',
  'campaigns',
  'tasks',
  'reminders',
  'relationships',
  'export',
  'search',
  'reports',
};

bool crmPathLive(String slug) => kCrmLiveSlugs.contains(slug);
