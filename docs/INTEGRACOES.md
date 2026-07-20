# Integrações LIVE — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 11.0)

Base API: `https://poligestor.onnexis.com.br/api`

Regra permanente: consumir somente contratos publicados pela VPS. Sem mocks na entrega final. Sem backend local. Ausência → `EndpointPendingState`.

## Sprint 11.0 — `/v1/grants/*`

Namespace oficial publicado na VPS. App sincronizado; `EndpointPendingState` apenas onde o path ainda retorna 404.

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/grants/dashboard` | **LIVE** (200) |
| GET | `/v1/grants/agreements` (+ `/{id}`) | **LIVE** (200) |
| GET | `/v1/grants/resources` | Preparado (404) |
| GET | `/v1/grants/projects` | **LIVE** (200) |
| GET | `/v1/grants/execution` | **LIVE** (200) |
| GET | `/v1/grants/accountability` | **LIVE** (200) |
| GET | `/v1/grants/schedule` | Preparado (404) |
| GET | `/v1/grants/timeline` | **LIVE** (200) |
| GET | `/v1/grants/documents` | **LIVE** (200) |
| GET | `/v1/grants/attachments` | Preparado (404) |
| GET | `/v1/grants/indicators` | Preparado (404) |
| GET | `/v1/grants/reports` | **LIVE** (200) |
| GET | `/v1/grants/search` | Preparado (404) — filtros locais nas listas |

> Paths legados `/v1/agreements/*` e `/v1/convenios/*` retornam 404 — não utilizar.

## Sprint 10.9 — `/v1/works/*`

Namespace dedicado **ainda não publicado** na VPS (probe 404 em todos os paths abaixo). App preparado com Models/Repo/UI/Cache e `EndpointPendingState`.

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/works/dashboard` | Preparado (404) |
| GET | `/v1/works/projects` (+ `/{id}`) | Preparado (404) |
| GET | `/v1/works/demands` | Preparado (404) |
| GET | `/v1/works/inspections` | Preparado (404) |
| GET | `/v1/works/schedule` | Preparado (404) |
| GET | `/v1/works/map` | Preparado (404) — reuso `/v1/mandate/map` LIVE |
| GET | `/v1/works/timeline` | Preparado (404) |
| GET | `/v1/works/photos` | Preparado (404) |
| GET | `/v1/works/attachments` | Preparado (404) |
| GET | `/v1/works/checklist` | Preparado (404) |
| GET | `/v1/works/indicators` | Preparado (404) |
| GET | `/v1/works/reports` | Preparado (404) |
| GET | `/v1/works/search` | Preparado (404) — filtros locais nas listas |
| GET | `/v1/mandate/map` | LIVE (reuso mapa) |

## Sprint 10.8 — `/v1/parliament/*`

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/parliament/dashboard` | LIVE |
| GET | `/v1/parliament/bills` (+ `/{id}`) | LIVE |
| GET | `/v1/parliament/projects` | LIVE |
| GET | `/v1/parliament/indications` | LIVE |
| GET | `/v1/parliament/requests` | LIVE |
| GET | `/v1/parliament/motions` | LIVE |
| GET | `/v1/parliament/amendments` | LIVE |
| GET | `/v1/parliament/agenda` | LIVE |
| GET | `/v1/parliament/sessions` | LIVE |
| GET | `/v1/parliament/votes` | LIVE |
| GET | `/v1/parliament/support-base` | LIVE |
| GET | `/v1/parliament/demands` | LIVE |
| GET | `/v1/parliament/promises` | Preparado (404) |
| GET | `/v1/parliament/search` | Preparado (404) — busca local nas listas |
| GET | `/v1/parliament/timeline` | Preparado (404) |
| GET | `/v1/parliament/history` | Preparado (404) |
| GET | `/v1/parliament/attachments` | Preparado (404) |

## Sprint 10.7 — `/v1/strategy/*`

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/strategy/kpis` | LIVE — KPIs / dashboard (fallback) |
| GET | `/v1/strategy/heatmap` | LIVE |
| GET | `/v1/strategy/trends` | LIVE |
| GET | `/v1/strategy/alerts` | LIVE |
| GET | `/v1/strategy/regions` | LIVE |
| GET | `/v1/strategy/neighborhoods` | LIVE |
| GET | `/v1/strategy/forecasts` | LIVE |
| GET | `/v1/strategy/reports` | LIVE (lista pode vir vazia) |
| GET | `/v1/strategy/dashboard` | Instável (500) → fallback KPIs |
| GET | `/v1/strategy/goals` | Preparado (404/500) |
| GET | `/v1/strategy/compare` | Preparado (404) |
| GET | `/v1/strategy/map` | Preparado → reuse `/v1/mandate/map` |
| GET | `/v1/strategy/indicators` | Preparado (404) |
| GET | `/v1/strategy/predictions` | Preparado (404) |

## Reuso mandato / inteligência

| Path | Uso no Painel |
|------|----------------|
| `/v1/mandate/map` | Tela Mapa |
| `/v1/mandate/neighborhoods` | Atalho Bairros |
| `/v1/mandate/reports` | Atalho Relatórios |
| `/v1/mandate/trends` / insights | Atalhos Inteligência |

## Outras sprints (resumo)

- 10.4 Comunicação: `/v1/channels`, templates, campaigns, omnichannel
- 10.5 Assistente: `/v1/ai/chat`, conversations, briefing(s), insights
- 10.6 Automação: operação via `/v1/virtual-team/*`; `/v1/automations*` pending
