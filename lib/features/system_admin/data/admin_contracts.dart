/// Contratos da Fase 19 — Administração do Sistema (`/v1/admin/*`).
/// Catálogo oficial backend c29c2ad.
/// Slugs usam os cards atuais e assumem os remapeamentos oficiais:
/// offices→cabinets, settings→settings/general, licensing→licenses,
/// backup→backups, notification-settings→config/notifications,
/// storage-settings→config/storage e exports→export.
library;

/// Slugs do hub com path AuthMode ∈ catálogo c29c2ad.
const kAdminLiveSlugs = <String>{
  'dashboard',
  'companies',
  'offices',
  'users',
  'profiles',
  'roles',
  'permissions',
  'teams',
  'departments',
  'settings',
  'settings-cabinet',
  'themes',
  'preferences',
  'licensing',
  'subscriptions',
  'logs',
  'audit',
  'sessions',
  'tokens',
  'api-keys',
  'integrations',
  'webhooks',
  'backup',
  'monitoring',
  'health',
  'email-settings',
  'notification-settings',
  'storage-settings',
  'reports',
  'exports',
  'search',
  'filters',
  'access-history',
  'metrics',
};

bool adminPathLive(String slug) => kAdminLiveSlugs.contains(slug);
