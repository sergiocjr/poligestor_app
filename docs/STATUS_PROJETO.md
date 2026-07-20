# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-20 (Fase 15 — Comunicação Institucional entregue no Flutter; **fechamento formal pendente**)

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
| **Fase 13 — Gestão Documental** | **CONCLUÍDA** (namespace `/v1/documents/*` LIVE; Flutter sincronizado) |
| **Fase 14 — Gestão Financeira** | **CONCLUÍDA** (namespace `/v1/finance/*` LIVE sincronizado; A10 OK) |
| **Fase 15 — Comunicação Institucional** | **EM ANDAMENTO** (Flutter entregue; `/v1/communication/*` 404) |
| Fase 16 | **Não iniciada** |

> Critérios de encerramento: `.cursor/rules/fases-completas.mdc`. Referência: [CONTINUAR_PROJETO.md](CONTINUAR_PROJETO.md).  
> Nota: o arquivo de status oficial é `docs/STATUS_PROJETO.md` (não existe `STATUS.md` separado).

## Fase 14 — Gestão Financeira do Mandato

Hub **Mais → Gestão Financeira** (`/home/finance`).

Namespace `/v1/finance/*` — **CONCLUÍDA**. LIVE sincronizados: `dashboard`, `categories`, `cost-centers`, `alerts`, `reports`, `accounts` (contas bancárias), `cashflow` (fluxo de caixa), `transactions`, `payments`. Demais entradas do hub ainda 404 → `EndpointPendingState`.

Cache: `pg_fin_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://finance|financeiro|gestao-financeira|financas/...`.

Validação A10 (`RX8M70CLXKP`): OK. Doc: [FASE_14_GESTAO_FINANCEIRA.md](FASE_14_GESTAO_FINANCEIRA.md).

**Fase 15 — Comunicação Institucional: EM ANDAMENTO** (Flutter entregue).

## Fase 15 — Comunicação Institucional

Hub **Mais → Comunicação Institucional** (`/home/institutional-communication`).

Namespace `/v1/communication/*` — probe **404 em todos os paths**. UI completa com `EndpointPendingState`, cards clicáveis, PT-BR, Material 3. Cache `pg_ic_*`. Realtime: `MandateRefreshController`.

Independente da Central de Comunicação (Sprint 10.4). Doc: [FASE_15_COMUNICACAO_INSTITUCIONAL.md](FASE_15_COMUNICACAO_INSTITUCIONAL.md).

## Encerramento do dia (2026-07-20)

| Item | Resultado |
|------|-----------|
| Continuidade | `docs/CONTINUAR_PROJETO.md` atualizado (leitura obrigatória antes de qualquer implementação) |
| `flutter analyze` | OK — 0 errors / 0 warnings / 37 infos |
| `flutter test` (F13+F14) | OK — 15/15 |
| `flutter build web --release` | OK — `build/web` |
| APK debug | OK — instalado e validado no A10 |
| A10 `RX8M70CLXKP` | OK — login + hub financeiro + chips Ativo |
| Push | `origin/master` |
| Próxima | Fase 15 — Comunicação Institucional (**não iniciar** sem pedido) |

## Fase 13 — Gestão Documental

Hub **Mais → Gestão Documental** (`/home/documents`).

Namespace `/v1/documents/*` — probe **401 em todos os paths do hub** (LIVE; exige auth). Chips **Ativo**. `EndpointPendingState` removido do fluxo normal (só fallback 404/405/501/503).

Lista: `GET /v1/documents/list`. Cache: `pg_docs_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://documents|documentos|gestao-documental/...`.

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

## Qualidade / checklist de encerramento (Fase 15)

| # | Critério | Status |
|---|----------|--------|
| 1 | Backend domínio completo | Pendente (`/v1/communication/*` 404) |
| 2 | Flutter consome LIVE disponíveis | OK (nenhum LIVE; namespace preparado) |
| 3 | Não publicados → `EndpointPendingState` | OK |
| 4 | APK no Samsung Galaxy A10 | OK (install `-r` Success); UI hub pendente de revalidação (ADB offline pós-reboot) |
| 5 | Web validada | OK (`flutter build web --release`) |
| 6 | `flutter analyze` | OK (feature Fase 15 sem issues) |
| 7 | `flutter test` | OK (suite Fase 15, 6/6) |
| 8 | PHPUnit | N/A neste repo Flutter |
| 9 | Nenhum HTTP 500 | OK no probe (404) |
| 10 | Documentação | OK |
| 11–12 | Commit / Push | Nesta entrega |
| 13–14 | Limpeza / sem emulador | Nesta entrega |
| 15 | Auditoria Backend ↔ Flutter | Pendente até VPS publicar |

Fase 16 **não iniciada**.

## Qualidade / checklist de encerramento (Fase 14)

| # | Critério | Status |
|---|----------|--------|
| 1 | Backend domínio completo | OK (domínio concluído e sincronizado) |
| 2 | Flutter consome LIVE disponíveis | OK (9 contratos LIVE no hub) |
| 3 | Não publicados → `EndpointPendingState` | OK |
| 4 | APK no Samsung Galaxy A10 | OK |
| 5 | Web validada | OK (`flutter build web`) |
| 6 | `flutter analyze` | OK |
| 7 | `flutter test` | OK (suite Fase 14) |
| 8 | PHPUnit | N/A neste repo Flutter (domínio no backend) |
| 9 | Nenhum HTTP 500 | OK no probe (401/404) |
| 10 | Documentação | OK |
| 11–12 | Commit / Push | Nesta entrega |
| 13–14 | Limpeza / sem emulador | Nesta entrega |
| 15 | Auditoria Backend ↔ Flutter | OK (paths LIVE sincronizados; Pending no restante) |

**Fase 14 concluída.** Fase 15 **não iniciada**.

## Qualidade / checklist de encerramento (Fase 13)

| # | Critério | Status |
|---|----------|--------|
| 1 | Backend domínio completo | OK (rotas `/v1/documents/*` publicadas — probe 401) |
| 2 | Flutter consome LIVE disponíveis | OK (15 telas do hub) |
| 3 | Não publicados → `EndpointPendingState` | OK (nenhum path do hub pendente) |
| 4 | APK no Samsung Galaxy A10 | OK nesta entrega |
| 5 | Web validada | OK (`flutter build web`) |
| 6 | `flutter analyze` | OK |
| 7 | `flutter test` | OK (suite Fase 13) |
| 8 | PHPUnit | N/A neste repo Flutter (domínio no backend) |
| 9 | Nenhum HTTP 500 | OK no probe (401, sem 500) |
| 10 | Documentação | OK |
| 11–12 | Commit / Push | Nesta entrega |
| 13–14 | Limpeza / sem emulador | Nesta entrega |
| 15 | Auditoria Backend ↔ Flutter | OK (contratos sincronizados; 401→LIVE; parsing flexível) |

**Fase 13 concluída** neste repositório Flutter com contratos LIVE sincronizados.

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
