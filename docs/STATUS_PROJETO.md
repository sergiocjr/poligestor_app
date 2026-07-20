# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-20 (Fase 13 — Gestão Documental entregue no Flutter; **fechamento formal pendente**)

## Resumo

| Área | Status |
|------|--------|
| Auth dual (staff / portal) | Concluído |
| Portal do cidadão / Protocolos | Concluído + auditoria/hardening |
| Assistente IA (via Laravel) | Concluído |
| Fase 7 — FCM + Reverb + deep links | CONCLUÍDA |
| Fase 8 — Mandato (staff) | CONCLUÍDA |
| Fase 9 — Inteligência do mandato | CONCLUÍDA |
| Sprint 9.5 — Hardening produção | CONCLUÍDA |
| Sprint 10.1 — Equipe Virtual | CONCLUÍDA (Final) |
| Sprint 10.2 — Identidade / Auth / Multi-tenant | **FECHADA** |
| Sprint 10.4 — Central de Comunicação | **CONCLUÍDA** |
| Sprint 10.5 — Assistente Inteligente | **CONCLUÍDA** |
| Sprint 10.6 — Automação Inteligente | **CONCLUÍDA** |
| Sprint 10.7 — Painel Estratégico | **CONCLUÍDA** |
| Sprint 10.8 — Painel Parlamentar | **CONCLUÍDA** |
| Sprint 10.9 — Painel Obras | **CONCLUÍDA** |
| Sprint 11.0 — Painel de Convênios | **CONCLUÍDA** |
| Fase 11 — Gestão Institucional (Eventos) | **EM ANDAMENTO** (Flutter entregue; fechamento pendente) |
| **Fase 12 — Inteligência Territorial** | **EM ANDAMENTO** (7 paths LIVE 401; restante 404 → Pending) |
| **Fase 13 — Gestão Documental** | **EM ANDAMENTO** (Flutter entregue; `/v1/documents/*` 404) |
| Fase 14 | **Bloqueada** |

> Critérios de encerramento: `.cursor/rules/fases-completas.mdc`. Referência: [CONTINUAR_PROJETO.md](CONTINUAR_PROJETO.md).  
> Nota: o arquivo de status oficial é `docs/STATUS_PROJETO.md` (não existe `STATUS.md` separado).

## Fase 13 — Gestão Documental

Hub **Mais → Gestão Documental** (`/home/documents`).

Namespace `/v1/documents/*` — probe **404 em todos os paths**. UI completa com `EndpointPendingState`, cards clicáveis, PT-BR, Material 3.

Cache: `pg_docs_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://documents|documentos|gestao-documental/...`.

Doc: [FASE_13_GESTAO_DOCUMENTAL.md](FASE_13_GESTAO_DOCUMENTAL.md).

## Fase 12 — Inteligência Territorial

Hub **Mais → Inteligência Territorial** (`/home/territorial-intelligence`).

Namespace `/v1/intelligence/*`. **LIVE (401 sem token):** `dashboard`, `kpis`, `charts`, `neighborhoods`, `regions`, `trends`, `projections`. Demais → `EndpointPendingState`. PT-BR · Material 3 · cache `pg_ti_*` · realtime `MandateRefreshController`.

Doc: [FASE_12_INTELIGENCIA_TERRITORIAL.md](FASE_12_INTELIGENCIA_TERRITORIAL.md).

## Fase 11 — Painel de Eventos

Hub **Mais → Painel de Eventos** (`/home/events`). LIVE: `/v1/events` + `/{uuid}`. Fechamento formal pendente.

### Telas

Painel · Lista · Detalhes · Agenda · Calendário · Audiências · Reuniões · Participantes · Convites · Presença · Check-in · Check-out · QR Code · Galeria · Fotos · Vídeos · Documentos · Certificados · Linha do Tempo · Mapa · Indicadores · Relatórios · Pesquisa · Filtros.

### Domínios

| Recurso | Contrato | Rota | App |
|---------|----------|------|-----|
| Painel | `/v1/events` (agregado) + `/v1/events/dashboard` preparado | `/home/events/dashboard` | Ativo |
| Eventos | `/v1/events` (+ `/{id}`) | `/home/events/list` | Ativo |
| Agenda | UI sobre `/v1/events` | `/home/events/agenda` | Ativo |
| Calendário | UI sobre `/v1/events` | `/home/events/calendar` | Ativo |
| Audiências | filtro `type=appointment` / path preparado | `/home/events/audiences` | Ativo |
| Reuniões | filtro `type=meeting` / path preparado | `/home/events/meetings` | Ativo |
| Participantes | `/v1/events/participants` | `/home/events/participants` | Pending |
| Convites | `/v1/events/invites` | `/home/events/invites` | Pending |
| Presença | `/v1/events/attendance` | `/home/events/attendance` | Pending |
| Check-in / Check-out | `/v1/events/check-in` · `/check-out` | `/home/events/check-in` · `check-out` | Pending |
| QR Code | `/v1/events/qr-code` | `/home/events/qr-code` | Pending |
| Galeria / Fotos / Vídeos | `/gallery` · `/photos` · `/videos` | rotas homônimas | Pending |
| Documentos / Certificados | `/documents` · `/certificates` | rotas homônimas | Pending |
| Linha do Tempo / Mapa | `/timeline` · `/map` | rotas homônimas | Pending |
| Indicadores / Relatórios | `/indicators` · `/reports` | rotas homônimas | Pending |
| Pesquisa | local + `/v1/events/search` preparado | `/home/events/search` | Ativo (local) |

Cache: `pg_events_{tenant}_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://events|eventos|painel-eventos/...`.

Documentação detalhada: [FASE_11_EVENTOS.md](FASE_11_EVENTOS.md).

## Sprint 11.0 — Painel de Convênios

Hub **Mais → Painel de Convênios** (`/home/agreements`). Namespace LIVE `/v1/grants/*`.

## Idioma (regra permanente)

Interface exclusivamente em **Português do Brasil**. Ver `.cursor/rules/pt-br-ui.mdc`.

## Qualidade / checklist de encerramento (Fase 13)

| # | Critério | Status |
|---|----------|--------|
| 1 | Backend domínio completo | Pendente (`/v1/documents/*` 404) |
| 2 | Flutter consome LIVE disponíveis | OK (nenhum LIVE; namespace preparado) |
| 3 | Não publicados → `EndpointPendingState` | OK |
| 4 | APK no Samsung Galaxy A10 | OK nesta entrega |
| 5 | Web validada | OK (`flutter build web` nesta entrega) |
| 6 | `flutter analyze` | OK |
| 7 | `flutter test` | OK (suite Fase 13) |
| 8 | PHPUnit | N/A neste repo Flutter |
| 9 | Nenhum HTTP 500 | OK no probe (404) |
| 10 | Documentação | OK |
| 11–12 | Commit / Push | Nesta entrega |
| 13–14 | Limpeza / sem emulador | Nesta entrega |
| 15 | Auditoria Backend ↔ Flutter | Pendente até VPS publicar |

Fase 14 **bloqueada** até os 15 itens da Fase 13 estarem OK.

## Qualidade / checklist de encerramento (Fase 12)

| # | Critério | Status |
|---|----------|--------|
| 1 | Backend domínio completo | Pendente (14 paths ainda 404) |
| 2 | Flutter consome LIVE disponíveis | OK (7 paths LIVE) |
| 3 | Não publicados → `EndpointPendingState` | OK |
| 4 | APK no Samsung Galaxy A10 | OK nesta entrega |
| 5 | Web validada | OK (`flutter build web` nesta entrega) |
| 6 | `flutter analyze` | OK |
| 7 | `flutter test` | OK (suite Fase 12) |
| 8 | PHPUnit | N/A neste repo Flutter (domínio backend incompleto) |
| 9 | Nenhum HTTP 500 | OK no probe (401/404) |
| 10 | Documentação | OK |
| 11–12 | Commit / Push | Nesta entrega |
| 13–14 | Limpeza / sem emulador | Nesta entrega |
| 15 | Auditoria Backend ↔ Flutter | Pendente (payloads 200 autenticados + paths faltantes) |

Fase 13 **iniciada a pedido**; fechamento formal da Fase 12 ainda pendente.

## Repositório

- https://github.com/sergiocjr/poligestor_app
- Referência: [CONTINUAR_PROJETO.md](CONTINUAR_PROJETO.md)
