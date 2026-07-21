/// Contratos da Fase 18 — IA Avançada (`/v1/ai/*`).
/// Probe auth 2026-07-21: GET 200 / POST-only 405 = LIVE.
library;

/// Slugs com endpoint dedicado LIVE na VPS.
const kAdvancedAiLiveSlugs = <String>{
  'chat', // POST (GET 405)
  'conversations',
  'history',
  'briefings',
  'prompts',
  'agents',
  'summary', // POST (GET 405)
  'suggestions', // POST (GET 405)
  'feedback', // POST (GET 405)
  'hub',
  'team',
  'handoffs',
  'dashboard',
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
