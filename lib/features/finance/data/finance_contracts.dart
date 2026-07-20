/// Contratos da Fase 14 — Gestão Financeira (`/v1/finance/*`).
/// Probe 2026-07-20: todos 404 → nenhum slug LIVE ainda.
library;

const kFinanceLiveSlugs = <String>{};

bool financePathLive(String slug) => kFinanceLiveSlugs.contains(slug);
