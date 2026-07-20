# Fase 16 — CRM Político

Atualizado: 2026-07-20

## Escopo

Módulo completo de CRM Político no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/crm/*`

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

## Hub

**Mais → CRM Político** (`/home/crm`)

## Telas

Painel · Líderes · Apoiadores · Eleitores · Voluntários · Equipe · Entidades · Associações · Igrejas · Empresas · Influenciadores · Segmentação · Etiquetas · Grupos · Regiões · Bairros · Zonas eleitorais · Histórico de relacionamento · Interações · Visitas · Ligações · Mensagens · Reuniões · Demandas vinculadas · Protocolos vinculados · Campanhas · Tarefas · Lembretes · Nível de apoio · Potencial de influência · Relacionamentos · Importação · Exportação · Pesquisa · Filtros · Indicadores · Relatórios

## Probe VPS (2026-07-20, sem token)

Todos os paths `/v1/crm/*` do hub retornaram **404**. UI completa com chips **Em preparação** e `EndpointPendingState`.

| Path | Status |
|------|--------|
| `/v1/crm/dashboard` | Preparado (404) |
| `/v1/crm/leaders` | Preparado (404) |
| `/v1/crm/supporters` | Preparado (404) |
| `/v1/crm/voters` | Preparado (404) |
| `/v1/crm/volunteers` | Preparado (404) |
| `/v1/crm/team` | Preparado (404) |
| `/v1/crm/entities` | Preparado (404) |
| `/v1/crm/associations` | Preparado (404) |
| `/v1/crm/churches` | Preparado (404) |
| `/v1/crm/companies` | Preparado (404) |
| `/v1/crm/influencers` | Preparado (404) |
| `/v1/crm/segmentation` | Preparado (404) |
| `/v1/crm/tags` | Preparado (404) |
| `/v1/crm/groups` | Preparado (404) |
| `/v1/crm/regions` | Preparado (404) |
| `/v1/crm/neighborhoods` | Preparado (404) |
| `/v1/crm/electoral-zones` | Preparado (404) |
| `/v1/crm/relationship-history` | Preparado (404) |
| `/v1/crm/interactions` | Preparado (404) |
| `/v1/crm/visits` | Preparado (404) |
| `/v1/crm/calls` | Preparado (404) |
| `/v1/crm/messages` | Preparado (404) |
| `/v1/crm/meetings` | Preparado (404) |
| `/v1/crm/linked-demands` | Preparado (404) |
| `/v1/crm/linked-protocols` | Preparado (404) |
| `/v1/crm/campaigns` | Preparado (404) |
| `/v1/crm/tasks` | Preparado (404) |
| `/v1/crm/reminders` | Preparado (404) |
| `/v1/crm/support-level` | Preparado (404) |
| `/v1/crm/influence-potential` | Preparado (404) |
| `/v1/crm/relationships` | Preparado (404) |
| `/v1/crm/import` | Preparado (404) |
| `/v1/crm/export` | Preparado (404) |
| `/v1/crm/search` | Preparado (404) |
| `/v1/crm/filters` | Preparado (404) |
| `/v1/crm/indicators` | Preparado (404) |
| `/v1/crm/reports` | Preparado (404) |

Quando a VPS publicar (HTTP 401 sem token ou 200 autenticado), marcar chips **Ativo** em `kCrmLiveSlugs` e retirar `EndpointPendingState` do fluxo normal.

## Flutter

- Feature: `lib/features/political_crm/`
- Cache: `pg_crm_{tenant}_*`
- Offline: cache em falha de rede
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://crm|crm-politico|crm_politico/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)

## Critério de encerramento

Ver 15 critérios em `.cursor/rules/fases-completas.mdc`. Backend ainda 404 → Fase **não fechada formalmente** até sync LIVE.