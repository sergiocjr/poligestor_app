# Fase 22 — Integrações

Atualizado: 2026-07-20

## Escopo

Central de integrações no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/integrations/*`

Independente das Fases 19/20 (`/v1/admin/*`, `/v1/platform/*`).

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

## Hub

**Mais → Central de Integrações** (`/home/integrations`)

Acesso: staff autenticado.

## Telas (25 + hub)

Painel · Status das integrações · Configuração · Sincronizações · Histórico · Registros · Gov.br · Câmara Municipal · Assembleia Legislativa · Câmara dos Deputados · Senado Federal · Diário Oficial · Portal da Transparência · e-SIC · Ouvidoria · Google Calendar · Outlook Calendar · Gmail · WhatsApp · Telegram · Firebase Push · APIs externas · Webhooks · Pesquisa · Filtros

## Auditoria VPS (2026-07-20, autenticado) — sync LIVE

| Método | Path publicado | Hub | Status |
|--------|----------------|-----|--------|
| GET | `/v1/integrations/dashboard` | Painel | **LIVE 200** |
| GET | `/v1/integrations/catalog` | (catálogo no painel) | **LIVE 200** |
| GET | `/v1/integrations/health` | Status | **LIVE 200** |
| GET | `/v1/integrations/providers` | Status | **LIVE 200** |
| GET/PUT | `/v1/integrations/settings` | Configuração | **LIVE 200** (PUT) |
| GET/POST | `/v1/integrations/sync` | Sincronizações | **LIVE 200/202** |
| GET | `/v1/integrations/history` | Histórico | **LIVE 200** |
| GET | `/v1/integrations/logs` | Registros | **LIVE 200** |
| GET | `/v1/integrations/govbr` | Gov.br | **LIVE 200** |
| GET | `/v1/integrations/camara-municipal` | Câmara Municipal | **LIVE 200** |
| GET | `/v1/integrations/assembleia-legislativa` | Assembleia | **LIVE 200** |
| GET | `/v1/integrations/camara-deputados` | Câmara dos Deputados | **LIVE 200** |
| GET | `/v1/integrations/senado` | Senado Federal | **LIVE 200** |
| GET | `/v1/integrations/diario-oficial` | Diário Oficial | **LIVE 200** |
| GET | `/v1/integrations/portal-transparencia` | Transparência | **LIVE 200** |
| GET | `/v1/integrations/esic` | e-SIC | **LIVE 200** |
| GET | `/v1/integrations/ouvidoria` | Ouvidoria | **LIVE 200** |
| GET | `/v1/integrations/google-calendar` | Google Calendar | **LIVE 200** |
| GET | `/v1/integrations/outlook` | Outlook Calendar | **LIVE 200** |
| GET | `/v1/integrations/gmail` | Gmail | **LIVE 200** |
| GET | `/v1/integrations/whatsapp` | WhatsApp | **LIVE 200** |
| GET | `/v1/integrations/telegram` | Telegram | **LIVE 200** |
| GET | `/v1/integrations/firebase-push` | Firebase Push | **LIVE 200** |
| GET | `/v1/integrations/external-apis` | APIs externas | **LIVE 200** |
| GET | `/v1/integrations/webhooks` | Webhooks | **LIVE 200** |
| GET | `/v1/integrations/search` | Pesquisa | Pending 404 |
| GET | `/v1/integrations/filters` | Filtros | Pending 404 |

Paths esperados na UI (`status`, `config`, `senado-federal`, `e-sic`, `outlook-calendar`) mapeados para os contratos **publicados** acima.

`kIntegrationsLiveSlugs` inclui todos os cards LIVE + `catalog`/`providers`.

## Flutter

- Feature: `lib/features/integrations/`
- Cache `pg_int_*` com strip de segredos
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://integrations|integracoes|integracao|central-integracoes/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo

## Status formal

**CONCLUÍDA** (Flutter sincronizado com contratos LIVE; Pending apenas em pesquisa/filtros).

Validação A10 (`RX8M70CLXKP`): hub + telas LIVE OK; emulador não iniciado.

**Fase 23 — não iniciada.**
