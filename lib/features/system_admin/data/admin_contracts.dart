/// Contratos da Fase 19 — Administração do Sistema (`/v1/admin/*`).
/// Probe auth 2026-07-21: 19 paths HTTP 200.
library;

/// Slugs do hub com contrato publicado na VPS (HTTP 200 autenticado).
const kAdminLiveSlugs = <String>{
  'dashboard',
  'companies',
  'users',
  'profiles',
  'roles',
  'permissions',
  'teams',
  'departments',
  'subscriptions',
  'logs',
  'audit',
  'sessions',
  'api-keys',
  'integrations',
  'webhooks',
  'monitoring',
  'health',
  'email-settings',
  'reports',
};

bool adminPathLive(String slug) => kAdminLiveSlugs.contains(slug);
