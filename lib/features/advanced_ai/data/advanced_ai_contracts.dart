/// Contratos da Fase 18 — IA Avançada (`/v1/ai/*`).
/// Auditoria 2026-07-20 (auth): GET 200 / POST 201|422 = LIVE.
/// Papéis de assessoria: catálogo LIVE `GET /v1/ai/agents` + `POST /v1/ai/chat`.
/// EndpointPendingState somente se a VPS responder 404/405/501/503 no path consumido.
library;

/// Slugs com endpoint dedicado LIVE na VPS.
const kAdvancedAiLiveSlugs = <String>{
  'chat',
  'conversations',
  'history',
  'briefings',
  'prompts',
  'agents',
  'summary',
  'suggestions',
  'feedback',
};

/// Hub → `agent_slug` em `GET /v1/ai/agents` (LIVE). Sem agente = Pending.
const kAdvancedAiAgentRoleMap = <String, String>{
  'secretary': 'secretary',
  'parliamentary-advisor': 'parliamentary_advisor',
  'political-analyst': 'analyst',
  'communication-advisor': 'communication',
  'legal-advisor': 'legal',
  'strategic-planning': 'strategy',
};

bool advancedAiPathLive(String slug) =>
    kAdvancedAiLiveSlugs.contains(slug) ||
    kAdvancedAiAgentRoleMap.containsKey(slug);

String? advancedAiAgentSlugForHub(String hubSlug) =>
    kAdvancedAiAgentRoleMap[hubSlug];
