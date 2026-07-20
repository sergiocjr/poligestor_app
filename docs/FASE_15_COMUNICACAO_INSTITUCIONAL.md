# Fase 15 — Comunicação Institucional

Atualizado: 2026-07-20

## Escopo

Módulo completo de Comunicação Institucional no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/communication/*`

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

A **Central de Comunicação** (Sprint 10.4, `/v1/channels|templates|campaigns` + omnichannel) permanece separada.

## Hub

**Mais → Comunicação Institucional** (`/home/institutional-communication`)

## Telas

Feed de notícias · Comunicados · Campanhas · Biblioteca de mídia · Publicações · Agenda de publicações · Notificação push · E-mail · WhatsApp · Histórico · Pesquisa · Filtros · Compartilhamento · Relatórios

## Probe VPS (2026-07-20, sem token)

Todos os paths `/v1/communication/*` do hub retornaram **404**. UI completa com chips **Em preparação** e `EndpointPendingState`.

| Path | Status |
|------|--------|
| `/v1/communication/feed` | Preparado (404) |
| `/v1/communication/announcements` | Preparado (404) |
| `/v1/communication/campaigns` | Preparado (404) |
| `/v1/communication/media` | Preparado (404) |
| `/v1/communication/publications` | Preparado (404) |
| `/v1/communication/schedule` | Preparado (404) |
| `/v1/communication/push` | Preparado (404) |
| `/v1/communication/email` | Preparado (404) |
| `/v1/communication/whatsapp` | Preparado (404) |
| `/v1/communication/history` | Preparado (404) |
| `/v1/communication/search` | Preparado (404) |
| `/v1/communication/filters` | Preparado (404) |
| `/v1/communication/share` | Preparado (404) |
| `/v1/communication/reports` | Preparado (404) |

Quando a VPS publicar (HTTP 401 sem token ou 200 autenticado), marcar chips **Ativo** em `kInstitutionalCommunicationLiveSlugs` e retirar `EndpointPendingState` do fluxo normal.

## Flutter

- Feature: `lib/features/institutional_communication/`
- Cache: `pg_ic_{tenant}_*`
- Offline: cache em falha de rede
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://institutional-communication|comunicacao-institucional|comunicacao_institucional/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)

## Critério de encerramento

Ver 15 critérios em `.cursor/rules/fases-completas.mdc`. Backend ainda 404 → Fase **não fechada formalmente** até sync LIVE.