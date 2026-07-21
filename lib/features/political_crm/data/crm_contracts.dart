/// Contratos da Fase 16 — CRM Político (`/v1/crm/*`).
/// Catálogo oficial backend c29c2ad.
/// `indicators` assume o remapeamento oficial para `/metrics`.
library;

/// Slugs do hub com path AuthMode ∈ catálogo c29c2ad.
const kCrmLiveSlugs = <String>{
  'dashboard',
  'leaders',
  'supporters',
  'voters',
  'volunteers',
  'team',
  'entities',
  'associations',
  'churches',
  'companies',
  'influencers',
  'segmentation',
  'tags',
  'groups',
  'regions',
  'neighborhoods',
  'electoral-zones',
  'relationship-history',
  'interactions',
  'visits',
  'calls',
  'messages',
  'meetings',
  'linked-demands',
  'linked-protocols',
  'campaigns',
  'tasks',
  'reminders',
  'support-level',
  'influence-potential',
  'relationships',
  'import',
  'export',
  'search',
  'filters',
  'indicators',
  'reports',
  'audit',
};

bool crmPathLive(String slug) => kCrmLiveSlugs.contains(slug);
