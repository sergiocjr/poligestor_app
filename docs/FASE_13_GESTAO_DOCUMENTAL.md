# Fase 13 — Gestão Documental

Atualizado: 2026-07-20

## Escopo

Módulo completo de Gestão Documental no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/documents/*`

Sem aliases. Sem mocks. Sem alteração de backend. Sem inventar APIs.

## Hub

**Mais → Gestão Documental** (`/home/documents`)

## Probe VPS (2026-07-20, sem token)

Todos os paths retornaram **404**. UI completa com `EndpointPendingState`.

| Path | Status |
|------|--------|
| `/v1/documents` | Preparado (404) |
| `/v1/documents/search` | Preparado (404) |
| `/v1/documents/filters` | Preparado (404) |
| `/v1/documents/categories` | Preparado (404) |
| `/v1/documents/favorites` | Preparado (404) |
| `/v1/documents/history` | Preparado (404) |
| `/v1/documents/timeline` | Preparado (404) |
| `/v1/documents/viewer` | Preparado (404) |
| `/v1/documents/signatures` | Preparado (404) |
| `/v1/documents/approvals` | Preparado (404) |
| `/v1/documents/share` | Preparado (404) |
| `/v1/documents/templates` | Preparado (404) |
| `/v1/documents/download` | Preparado (404) |
| `/v1/documents/upload` | Preparado (404) |
| `/v1/documents/attachments` | Preparado (404) |

## Flutter

- Feature: `lib/features/documents/`
- Cache: `pg_docs_{tenant}_*`
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://documents|documentos|gestao-documental/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10 1 coluna)

## Telas

Documentos · Pesquisa · Filtros · Categorias · Favoritos · Histórico · Linha do tempo · Visualizador PDF · Assinaturas · Aprovações · Compartilhamento · Modelos · Download · Upload · Anexos.

## Critério de encerramento

Ver 15 critérios em `.cursor/rules/fases-completas.mdc`. Backend ainda não publicou o namespace → Fase **não fechada formalmente**.
