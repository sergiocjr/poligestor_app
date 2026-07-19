# Integrações LIVE — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 10.7)

Base API: `https://poligestor.onnexis.com.br/api`

Regra permanente: consumir somente contratos publicados pela VPS. Sem mocks na entrega final. Sem backend local. Ausência → `EndpointPendingState`.

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
