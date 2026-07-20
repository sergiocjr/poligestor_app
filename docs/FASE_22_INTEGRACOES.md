# Fase 22 — Integrações

Atualizado: 2026-07-20

## Escopo

Central de integrações no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/integrations/*`

Independente das Fases 19/20 (`/v1/admin/*`, `/v1/platform/*`) e da comunicação institucional.

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

## Hub

**Mais → Central de Integrações** (`/home/integrations`)

Acesso: staff autenticado.

## Telas (25 + hub)

Painel · Status das integrações · Configuração · Sincronizações · Histórico · Registros · Gov.br · Câmara Municipal · Assembleia Legislativa · Câmara dos Deputados · Senado Federal · Diário Oficial · Portal da Transparência · e-SIC · Ouvidoria · Google Calendar · Outlook Calendar · Gmail · WhatsApp · Telegram · Firebase Push · APIs externas · Webhooks · Pesquisa · Filtros

## Auditoria VPS (2026-07-20, autenticado)

**Todos os paths `/v1/integrations/*` do hub retornaram HTTP 404** (GET).

`kIntegrationsLiveSlugs` permanece **vazio**. UI com chips **Em preparação** e `EndpointPendingState` (short-circuit local).

## Flutter

- Feature: `lib/features/integrations/`
- Cache `pg_int_*` com strip de segredos
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://integrations|integracoes|integracao|central-integracoes/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo
- Offline: leitura de cache quando o contrato estiver LIVE e a rede falhar

## Status formal

**EM ANDAMENTO** (Flutter entregue; backend 100% 404 → Pending).

Validação A10 (`RX8M70CLXKP`): hub + Pending OK; emulador não iniciado.

**Fase 23 — não iniciada.**
