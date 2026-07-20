# Fase 12 — Inteligência Territorial

Atualizado: 2026-07-20 (probe VPS revalidado)

## Escopo

Módulo completo de Inteligência Territorial no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/intelligence/*`

Sem aliases. Sem mocks. Sem alteração de backend. Sem inventar APIs.

## Hub

**Mais → Inteligência Territorial** (`/home/territorial-intelligence`)

> A aba **Inteligência** (Fase 9) em `/home/intelligence` continua usando `/v1/mandate/*`. A Fase 12 é o hub territorial dedicado a `/v1/intelligence/*`.

## Probe VPS (2026-07-20, sem token)

| Path | HTTP | App |
|------|------|-----|
| `/v1/intelligence/dashboard` | **401** (LIVE) | Consome; chip **Ativo** |
| `/v1/intelligence/bi` | 404 | `EndpointPendingState` |
| `/v1/intelligence/kpis` | **401** (LIVE) | Consome; chip **Ativo** |
| `/v1/intelligence/indicators` | 404 | `EndpointPendingState` |
| `/v1/intelligence/charts` | **401** (LIVE) | Consome; chip **Ativo** |
| `/v1/intelligence/heatmap` | 404 | `EndpointPendingState` |
| `/v1/intelligence/map` | 404 | `EndpointPendingState` |
| `/v1/intelligence/neighborhoods` | **401** (LIVE) | Consome; chip **Ativo** |
| `/v1/intelligence/regions` | **401** (LIVE) | Consome; chip **Ativo** |
| `/v1/intelligence/electoral-zones` | 404 | `EndpointPendingState` |
| `/v1/intelligence/leaderships` | 404 | `EndpointPendingState` |
| `/v1/intelligence/demands` | 404 | `EndpointPendingState` |
| `/v1/intelligence/works` | 404 | `EndpointPendingState` |
| `/v1/intelligence/protocols` | 404 | `EndpointPendingState` |
| `/v1/intelligence/attendances` | 404 | `EndpointPendingState` |
| `/v1/intelligence/comparatives` | 404 | `EndpointPendingState` |
| `/v1/intelligence/evolution` | 404 | `EndpointPendingState` |
| `/v1/intelligence/trends` | **401** (LIVE) | Consome; chip **Ativo** |
| `/v1/intelligence/projections` | **401** (LIVE) | Consome; chip **Ativo** |
| `/v1/intelligence/filters` | 404 | `EndpointPendingState` |
| `/v1/intelligence/exports` | 404 | `EndpointPendingState` |

**401** = rota publicada (exige autenticação). **404** = contrato ainda não publicado.

## Flutter

- Feature: `lib/features/territorial_intelligence/`
- Contratos LIVE: `territorial_intelligence_contracts.dart`
- Cache: `pg_ti_{tenant}_*`
- Offline: fallback de cache em falha de rede (quando houver payload)
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://territorial-intelligence|inteligencia-territorial|...`
- UI 100% PT-BR, Material 3, responsivo (A10 1 coluna)

## Telas

Painel BI · Painel Analítico · Indicadores-chave · Indicadores · Gráficos · Mapas de calor · Mapa territorial · Bairros · Regiões · Zonas eleitorais · Lideranças · Demandas · Obras · Protocolos · Atendimentos · Comparativos · Evolução · Tendências · Projeções · Filtros · Exportações.

## Critério de encerramento

Ver 15 critérios em `.cursor/rules/fases-completas.mdc`. Backend ainda incompleto → Fase **não fechada formalmente**, Flutter entregue e sincronizado com o probe.
