# Fase 12 — Inteligência Territorial

Atualizado: 2026-07-20

## Escopo

Módulo completo de Inteligência Territorial no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/intelligence/*`

Sem aliases. Sem mocks. Sem alteração de backend. Sem inventar APIs.

## Hub

**Mais → Inteligência Territorial** (`/home/territorial-intelligence`)

> A aba **Inteligência** (Fase 9) em `/home/intelligence` continua usando `/v1/mandate/*` (resumo, percepções, tendências do mandato). A Fase 12 é o hub territorial dedicado ao namespace `/v1/intelligence/*`.

## Probe VPS (2026-07-20)

Todos os paths `/v1/intelligence/*` retornaram **404**. App preparado com Models / Repo / Cache / UI / `EndpointPendingState`.

| Path | Status |
|------|--------|
| `/v1/intelligence/dashboard` | Preparado (404) |
| `/v1/intelligence/bi` | Preparado (404) |
| `/v1/intelligence/kpis` | Preparado (404) |
| `/v1/intelligence/indicators` | Preparado (404) |
| `/v1/intelligence/charts` | Preparado (404) |
| `/v1/intelligence/heatmap` | Preparado (404) |
| `/v1/intelligence/map` | Preparado (404) |
| `/v1/intelligence/neighborhoods` | Preparado (404) |
| `/v1/intelligence/regions` | Preparado (404) |
| `/v1/intelligence/electoral-zones` | Preparado (404) |
| `/v1/intelligence/leaderships` | Preparado (404) |
| `/v1/intelligence/demands` | Preparado (404) |
| `/v1/intelligence/works` | Preparado (404) |
| `/v1/intelligence/protocols` | Preparado (404) |
| `/v1/intelligence/attendances` | Preparado (404) |
| `/v1/intelligence/comparatives` | Preparado (404) |
| `/v1/intelligence/evolution` | Preparado (404) |
| `/v1/intelligence/trends` | Preparado (404) |
| `/v1/intelligence/projections` | Preparado (404) |
| `/v1/intelligence/filters` | Preparado (404) |
| `/v1/intelligence/exports` | Preparado (404) |

## Flutter

- Feature: `lib/features/territorial_intelligence/`
- Cache: `pg_ti_{tenant}_*`
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://territorial-intelligence|inteligencia-territorial|...`
- UI 100% PT-BR, Material 3, responsivo (A10 1 coluna)

## Critério de encerramento

Ver 15 critérios em `.cursor/rules/fases-completas.mdc` e checklist em `STATUS_PROJETO.md` / `CONTINUAR_PROJETO.md`.
