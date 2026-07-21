/// Contratos Sprint 10.6 — Central de Automação (`/v1/automation/*`).
/// Catálogo backend c29c2ad + probe HTTP 2026-07-21
/// (401 sem token = rota publicada exigindo autenticação).
/// `rules` = lista oficial de automações; raiz `/v1/automation`,
/// `schedule` (singular) e `autonomy` não existem (404).
library;

/// Slugs do hub com contrato publicado na VPS.
const kAutomationLiveSlugs = <String>{
  'actions',
  'agents',
  'dashboard',
  'editor',
  'rules', // GET /v1/automation/rules (lista de automações/regras)
  'rule-detail', // GET /v1/automation/rules/{id}
  'executions',
  'approvals',
  'alerts',
  'metrics',
  'logs',
  'schedules', // GET /v1/automation/schedules (plural)
  'run',
  'scan',
  'templates',
  'test',
  'timeline',
  'triggers',
  'autonomy',
  'history',
};

/// Slugs sem contrato publicado (escrita/edição de automações).
const kAutomationPendingSlugs = <String>{'autonomy-write'};

bool automationPathLive(String slug) => kAutomationLiveSlugs.contains(slug);
