/// Contratos da Fase 24 — Notícias Regionais (`/v1/news/*`).
/// Probe auth 2026-07-21: 6 LIVE (HTTP 200); recent/feed/search/filters 404.
library;

/// Slugs com contrato publicado na VPS (HTTP 200 autenticado).
const kNewsLiveSlugs = <String>{
  'dashboard',
  'mentions',
  'favorites',
  'alerts',
  'sources',
  'detail', // GET /v1/news/{article_id}
};

bool newsPathLive(String slug) => kNewsLiveSlugs.contains(slug);
