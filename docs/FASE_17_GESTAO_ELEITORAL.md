# Fase 17 — Gestão Eleitoral

Atualizado: 2026-07-20

## Escopo

Módulo completo de Gestão Eleitoral no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/elections/*`

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

## Hub

**Mais → Gestão Eleitoral** (`/home/elections`)

## Telas

Painel eleitoral · Pré-campanha · Campanhas · Candidatos · Coordenação · Equipes · Cabos eleitorais · Voluntários · Lideranças · Apoiadores · Metas eleitorais · Regiões · Bairros · Zonas eleitorais · Seções eleitorais · Colégios eleitorais · Mapa eleitoral · Agenda de campanha · Eventos · Caminhadas · Reuniões · Visitas · Comícios · Mobilizações · Materiais de campanha · Estoque · Distribuição · Solicitações de material · Pesquisas eleitorais · Cenários · Intenção de voto · Rejeição · Comparativos · Projeções · Desempenho por região · Prestação de contas · Receitas · Despesas · Doações · Fornecedores · Comprovantes · Relatórios · Exportações · Pesquisa · Filtros

## Probe VPS (2026-07-20, sem token)

| Resultado | Qtde |
|-----------|------|
| HTTP **401** (contrato publicado) | **14** |
| HTTP **404** (Pending) | **31** |

### LIVE (`kElectionsLiveSlugs` — chip Ativo)

| Path | Status |
|------|--------|
| `/v1/elections/dashboard` | LIVE (401) |
| `/v1/elections/campaigns` | LIVE (401) |
| `/v1/elections/candidates` | LIVE (401) |
| `/v1/elections/teams` | LIVE (401) |
| `/v1/elections/goals` | LIVE (401) |
| `/v1/elections/regions` | LIVE (401) |
| `/v1/elections/neighborhoods` | LIVE (401) |
| `/v1/elections/map` | LIVE (401) |
| `/v1/elections/events` | LIVE (401) |
| `/v1/elections/material-requests` | LIVE (401) |
| `/v1/elections/projections` | LIVE (401) |
| `/v1/elections/accountability` | LIVE (401) |
| `/v1/elections/receipts` | LIVE (401) |
| `/v1/elections/reports` | LIVE (401) |

### Em preparação (`EndpointPendingState` em 404)

`pre-campaign`, `coordination`, `canvassers`, `volunteers`, `leaders`, `supporters`, `electoral-zones`, `electoral-sections`, `polling-stations`, `campaign-agenda`, `walks`, `meetings`, `visits`, `rallies`, `mobilizations`, `campaign-materials`, `inventory`, `distribution`, `polls`, `scenarios`, `vote-intention`, `rejection`, `comparatives`, `regional-performance`, `revenues`, `expenses`, `donations`, `suppliers`, `exports`, `search`, `filters`.

Quando a VPS publicar os restantes (401/200), acrescentar em `kElectionsLiveSlugs`. Remover Pending do fluxo normal somente após HTTP 200 autenticado com payload válido.

## Flutter

- Feature: `lib/features/electoral_management/`
- Cache: `pg_elec_{tenant}_*`
- Offline: cache em falha de rede
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://elections|gestao-eleitoral|gestao_eleitoral|eleitoral/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)

## Validação A10

- APK debug instalado em `RX8M70CLXKP`
- Deep link `poligestor://elections` → hub com chips Ativo/Em preparação
- Painel eleitoral (LIVE): lista vazia autenticada OK
- Sem overflow; emulador não iniciado

## Critério de encerramento

Ver 15 critérios em `.cursor/rules/fases-completas.mdc`. Backend ainda parcial (31 paths 404) → Fase **não fechada formalmente** até sync total LIVE.
