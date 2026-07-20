# Fase 17 — Gestão Eleitoral

Atualizado: 2026-07-20 (auditoria LIVE — **CONCLUÍDA**; pendência: validação física A10)

## Escopo

Módulo completo de Gestão Eleitoral no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/elections/*`

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

## Hub

**Mais → Gestão Eleitoral** (`/home/elections`)

## Telas

Painel eleitoral · Pré-campanha · Campanhas · Candidatos · Coordenação · Equipes · Cabos eleitorais · Voluntários · Lideranças · Apoiadores · Metas eleitorais · Regiões · Bairros · Zonas eleitorais · Seções eleitorais · Colégios eleitorais · Mapa eleitoral · Agenda de campanha · Eventos · Caminhadas · Reuniões · Visitas · Comícios · Mobilizações · Materiais de campanha · Estoque · Distribuição · Solicitações de material · Pesquisas eleitorais · Cenários · Intenção de voto · Rejeição · Comparativos · Projeções · Desempenho por região · Prestação de contas · Receitas · Despesas · Doações · Fornecedores · Comprovantes · Relatórios · Exportações · Pesquisa · Filtros

## Auditoria VPS (2026-07-20, autenticado)

| Resultado | Qtde |
|-----------|------|
| HTTP **200** (LIVE) | **14** |
| HTTP **404** (Pending) | **31** |

### LIVE (`kElectionsLiveSlugs` — chip Ativo; sem `EndpointPendingState`)

| Path | Status |
|------|--------|
| `/v1/elections/dashboard` | LIVE (200) |
| `/v1/elections/campaigns` | LIVE (200) |
| `/v1/elections/candidates` | LIVE (200) |
| `/v1/elections/teams` | LIVE (200) |
| `/v1/elections/goals` | LIVE (200) |
| `/v1/elections/regions` | LIVE (200) |
| `/v1/elections/neighborhoods` | LIVE (200) |
| `/v1/elections/map` | LIVE (200) |
| `/v1/elections/events` | LIVE (200) |
| `/v1/elections/material-requests` | LIVE (200) |
| `/v1/elections/projections` | LIVE (200) |
| `/v1/elections/accountability` | LIVE (200) |
| `/v1/elections/receipts` | LIVE (200) |
| `/v1/elections/reports` | LIVE (200) |

### Em preparação (`EndpointPendingState` — HTTP 404)

`pre-campaign`, `coordination`, `canvassers`, `volunteers`, `leaders`, `supporters`, `electoral-zones`, `electoral-sections`, `polling-stations`, `campaign-agenda`, `walks`, `meetings`, `visits`, `rallies`, `mobilizations`, `campaign-materials`, `inventory`, `distribution`, `polls`, `scenarios`, `vote-intention`, `rejection`, `comparatives`, `regional-performance`, `revenues`, `expenses`, `donations`, `suppliers`, `exports`, `search`, `filters`.

## Flutter

- Feature: `lib/features/electoral_management/`
- Cache: `pg_elec_{tenant}_*`
- Offline: cache em falha de rede
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://elections|gestao-eleitoral|gestao_eleitoral|eleitoral/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)
- Painel: agregados `summary` convertidos em indicadores

## Status formal

**CONCLUÍDA** (Flutter sincronizado com contratos LIVE publicados).

Única pendência permitida: **validação física no Samsung Galaxy A10** (`RX8M70CLXKP`).

**Fase 18 — não iniciada.**
