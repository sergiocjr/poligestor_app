/// Contratos Fase 11 — Painel de Eventos (`/v1/events/*`).
/// Probe auth 2026-07-21.
library;

/// Slugs com GET HTTP 200 autenticado.
const kEventsLiveSlugs = <String>{
  'dashboard',
  'agenda',
  'calendar',
  'meetings',
  'participants',
  'attendance',
  'gallery',
  'documents',
  'certificates',
  'timeline',
  'reports',
};

bool eventsPathLive(String slug) => kEventsLiveSlugs.contains(slug);
