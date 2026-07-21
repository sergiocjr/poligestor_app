/// Contratos da Fase 15 — Comunicação Institucional (`/v1/communication/*`).
/// Catálogo oficial backend c29c2ad.
/// `schedule` assume o remapeamento oficial para `/schedules`.
library;

/// Slugs do hub com path AuthMode ∈ catálogo c29c2ad.
const kInstitutionalCommunicationLiveSlugs = <String>{
  'dashboard',
  'feed',
  'announcements',
  'campaigns',
  'media',
  'publications',
  'schedule',
  'push',
  'email',
  'whatsapp',
  'history',
  'search',
  'filters',
  'share',
  'reports',
  'audit',
};

bool institutionalCommunicationPathLive(String slug) =>
    kInstitutionalCommunicationLiveSlugs.contains(slug);
