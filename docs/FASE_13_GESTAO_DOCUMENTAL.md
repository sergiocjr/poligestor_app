# Fase 13 — Gestão Documental

Atualizado: 2026-07-20 (sync LIVE — contratos publicados)

## Escopo

Módulo completo de Gestão Documental no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/documents/*`

Sem aliases. Sem mocks. Sem alteração de backend. Sem inventar APIs.

## Hub

**Mais → Gestão Documental** (`/home/documents`)

## Probe VPS (2026-07-20, sem token)

| Path | HTTP | App |
|------|------|-----|
| `/v1/documents` | **401** LIVE | Root / detalhe por id |
| `/v1/documents/list` | **401** LIVE | Lista (chip **Ativo**) |
| `/v1/documents/search` | **401** LIVE | Ativo |
| `/v1/documents/filters` | **401** LIVE | Ativo |
| `/v1/documents/categories` | **401** LIVE | Ativo |
| `/v1/documents/favorites` | **401** LIVE | Ativo |
| `/v1/documents/history` | **401** LIVE | Ativo |
| `/v1/documents/timeline` | **401** LIVE | Ativo |
| `/v1/documents/viewer` | **401** LIVE | Ativo |
| `/v1/documents/signatures` | **401** LIVE | Ativo |
| `/v1/documents/approvals` | **401** LIVE | Ativo |
| `/v1/documents/share` | **401** LIVE | Ativo |
| `/v1/documents/templates` | **401** LIVE | Ativo |
| `/v1/documents/download` | **401** LIVE | Ativo |
| `/v1/documents/upload` | **401** LIVE | Ativo |
| `/v1/documents/attachments` | **401** LIVE | Ativo |
| `/v1/documents/dashboard` | **401** LIVE | Publicado (sem tela dedicada no hub) |

**401** = rota publicada (exige autenticação). Com sessão staff válida espera-se **HTTP 200**.

`EndpointPendingState` **não** é exibido para estes paths (só voltaria em 404/405/501/503).

## Flutter

- Feature: `lib/features/documents/`
- Cache: `pg_docs_{tenant}_*`
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://documents|documentos|gestao-documental/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)

## Sincronização Backend ↔ Flutter

Contratos do namespace `/v1/documents/*` publicados na VPS e consumidos pelo app. Chips **Ativo** no hub.
