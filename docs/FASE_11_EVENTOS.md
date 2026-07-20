# Fase 11 — Gestão Institucional Completa (Painel de Eventos)

Atualizado: 2026-07-20

## Escopo

Domínio completo de eventos institucionais no Flutter, consumindo exclusivamente o namespace oficial:

`https://poligestor.onnexis.com.br/api/v1/events`

Sem aliases. Sem mocks. Sem alteração de backend.

## Hub

**Mais → Painel de Eventos** (`/home/events`)

## Contratos

| Método | Path | Status VPS | App |
|--------|------|------------|-----|
| GET | `/v1/events` | **LIVE** (200) | Lista, Agenda, Calendário, Painel (agregado), Pesquisa local, Audiências/Reuniões (filtro por `type`) |
| GET | `/v1/events/{uuid}` | **LIVE** (200) | Detalhe |
| GET | `/v1/events/dashboard` | Colide com `{id}` (500) | Fallback: agregação local da lista LIVE |
| GET | `/v1/events/agenda` | Não publicado | UI Agenda usa lista LIVE |
| GET | `/v1/events/calendar` | Não publicado | UI Calendário usa lista LIVE |
| GET | `/v1/events/audiences` | Não publicado | Fallback filtro `type=appointment` |
| GET | `/v1/events/meetings` | Não publicado | Fallback filtro `type=meeting` |
| GET | `/v1/events/participants` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/invites` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/attendance` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/check-in` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/check-out` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/qr-code` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/gallery` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/photos` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/videos` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/documents` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/certificates` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/timeline` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/reports` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/indicators` | 404 / 500 | `EndpointPendingState` |
| GET | `/v1/events/search` | 404 / 500 | Pesquisa local sobre lista LIVE |
| GET | `/v1/events/map` | 404 / 500 | `EndpointPendingState` |

## Flutter

- Feature: `lib/features/events/`
- Cache: `pg_events_{tenant}_*`
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://events|eventos|painel-eventos/...`
- UI 100% PT-BR, Material 3

## Relação com Agenda existente

A bottom-nav **Agenda** continua usando `AuthMode.eventsPath` → `/v1/events` (lista LIVE).
O Painel de Eventos é o hub institucional completo; não remove a Agenda.

## Critério de encerramento

A Fase **somente** fecha quando os **15 critérios** de `.cursor/rules/fases-completas.mdc` estiverem OK, incluindo:

1. Backend domínio completo
2. Flutter consome todos os LIVE
3. Não publicados → `EndpointPendingState`
4. APK no A10
5. Web validada
6. `flutter analyze`
7. `flutter test`
8. PHPUnit (backend)
9. Nenhum HTTP 500
10. Documentação
11. Commit
12. Push
13. Limpeza de processos
14. Sem emulador
15. Auditoria Backend ↔ Flutter

Estado atual: ver checklist em `docs/STATUS_PROJETO.md`.
