/// Contratos Fase 11 — Painel de Eventos (`/v1/events/*`).
/// Catálogo oficial backend c29c2ad.
/// Nunca consumir `/v1/events/viewer`.
/// Assume os remapeamentos: list→events, invites→invitations,
/// audiences→hearings e indicators→statistics.
/// check-in / check-out / qr-code / photos / videos / map / search ∉ catálogo.
library;

/// Slugs com GET AuthMode ∈ catálogo c29c2ad.
const kEventsLiveSlugs = <String>{
  'dashboard',
  'list',
  'events',
  'agenda',
  'calendar',
  'meetings',
  'audiences',
  'participants',
  'invites',
  'attendance',
  'check-in',
  'check-out',
  'qr-code',
  'gallery',
  'photos',
  'videos',
  'documents',
  'certificates',
  'timeline',
  'map',
  'reports',
  'indicators',
  'search',
};

bool eventsPathLive(String slug) => kEventsLiveSlugs.contains(slug);
