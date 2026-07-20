/// Contratos da Fase 24 — Notícias Regionais (`/v1/news/*`).
/// Auditoria 2026-07-20 (auth): todos os paths HTTP 404.
/// EndpointPendingState somente se a VPS responder 404/405/501/503.
library;

/// Slugs com contrato publicado na VPS (HTTP 200/201/202 autenticado).
const kNewsLiveSlugs = <String>{};

bool newsPathLive(String slug) => kNewsLiveSlugs.contains(slug);
