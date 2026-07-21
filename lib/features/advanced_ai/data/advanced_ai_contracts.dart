/// Contratos da Fase 18 — IA Avançada (`/v1/ai/*`).
/// Catálogo oficial backend c29c2ad: hub, dashboard, specialists, invocations,
/// documents/generated, analyses, prioritizations, context-memory,
/// model-configs, response-audit, hub/audit, hub/metrics, hub/reports.
/// Papéis de assessoria assumem o remapeamento do catálogo legado `agents`
/// para o contrato oficial `specialists`.
library;

/// Slugs com path AuthMode ∈ catálogo c29c2ad (sem card de hub dedicado).
const kAdvancedAiLiveSlugs = <String>{
  'hub',
  'dashboard',
  'chat',
  'conversations',
  'history',
  'briefings',
  'prompts',
  'agents',
  'summary',
  'suggestions',
  'feedback',
  'secretary',
  'parliamentary-advisor',
  'political-analyst',
  'financial-analyst',
  'communication-advisor',
  'legal-advisor',
  'strategic-planning',
  'settings',
  'search',
  'specialists',
  'invocations',
  'documents-generated',
  'analyses',
  'prioritizations',
  'context-memory',
  'model-configs',
  'response-audit',
  'audit',
  'metrics',
  'reports',
};

/// Hub → `agent_slug` em `GET /v1/ai/agents` (legado; catálogo: specialists).
/// Mantido para chips de papéis; PathLive via mapa ≠ path dedicado LIVE.
const kAdvancedAiAgentRoleMap = <String, String>{
  'secretary': 'secretary',
  'parliamentary-advisor': 'parliamentary_advisor',
  'political-analyst': 'analyst',
  'financial-analyst': 'financial',
  'communication-advisor': 'communication',
  'legal-advisor': 'legal',
  'strategic-planning': 'strategy',
};

bool advancedAiPathLive(String slug) =>
    kAdvancedAiLiveSlugs.contains(slug) ||
    kAdvancedAiAgentRoleMap.containsKey(slug);

String? advancedAiAgentSlugForHub(String hubSlug) =>
    kAdvancedAiAgentRoleMap[hubSlug];
