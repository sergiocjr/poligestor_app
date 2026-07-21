/// Contratos da Fase 24 — Notícias Regionais (`/v1/news/*`).
/// Catálogo oficial backend c29c2ad: dashboard, root, mentions, favorites,
/// alerts, sources, settings.
/// `detail` = AuthMode `newsItemPath` → `/v1/news/{id}` (root/detail).
/// recent/feed/search/filters ∉ catálogo (não LIVE).
library;

/// Slugs com path AuthMode ∈ catálogo c29c2ad.
const kNewsLiveSlugs = <String>{
  'dashboard',
  'mentions',
  'favorites',
  'alerts',
  'sources',
  'settings',
  'root',
  'recent',
  'feed',
  'search',
  'filters',
  'detail',
};

bool newsPathLive(String slug) => kNewsLiveSlugs.contains(slug);
