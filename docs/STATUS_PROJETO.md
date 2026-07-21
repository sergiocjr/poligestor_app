# Status do projeto — PoliGestor Flutter

Atualizado: **2026-07-21** (sync catálogo LIVE c29c2ad · versão **1.0.0+6**)

## Resumo

> **Sync VPS c29c2ad:** hubs sem “Demonstração” / “Em preparação” · `EndpointPendingState` **0** · `/v1/events/viewer` **não consumido** · automação **`/v1/automation/*`**.  
> Sistema **EM ANDAMENTO** — homologação visual A10 completa e aceite loja pendentes. Ver [CONTINUAR_PROJETO.md](CONTINUAR_PROJETO.md).

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
| Sprint 10.5 — Assistente Inteligente | **CONCLUÍDA** (Flutter LIVE; mandate/ai legado mapeado) |
| Sprint 10.6 — Automação Inteligente | **EM ANDAMENTO** formal · Flutter **LIVE** `/v1/automation/*` |
| Sprint 10.7 — Painel Estratégico | **EM ANDAMENTO** formal · comparativos LIVE |
| Sprint 10.8 — Painel Parlamentar | **EM ANDAMENTO** formal · promessas LIVE |
| Sprint 10.9 — Painel Obras | **EM ANDAMENTO** formal · **13 LIVE** |
| Sprint 11.0 — Painel de Convênios | **EM ANDAMENTO** formal · grants LIVE |
| Fase 11 — Gestão Institucional (Eventos) | **EM ANDAMENTO** formal · **22 LIVE** |
| **Fase 12 — Inteligência Territorial** | **EM ANDAMENTO** formal · **26 LIVE** |
| **Fase 13 — Gestão Documental** | **EM ANDAMENTO** formal · **29 LIVE** |
| **Fase 14 — Gestão Financeira** | **EM ANDAMENTO** formal · **31 LIVE** |
| **Fase 15 — Comunicação Institucional** | **EM ANDAMENTO** formal · **16 LIVE** |
| **Fase 16 — CRM Político** | **EM ANDAMENTO** formal · **38 LIVE** |
| **Fase 17 — Gestão Eleitoral** | **EM ANDAMENTO** formal · **48 LIVE** |
| **Fase 18 — IA Avançada** | **EM ANDAMENTO** formal · **31 LIVE** |
| **Fase 19 — Administração do Sistema** | **EM ANDAMENTO** formal · **35 LIVE** |
| **Fase 20 — Portal Administrativo Web** | **EM ANDAMENTO** formal · **34 LIVE** |
| **Fase 21 — Segurança e Privacidade** | **EM ANDAMENTO** formal · **44 LIVE** |
| **Fase 22 — Integrações** | **CONCLUÍDA** · **30 LIVE** |
| **Fase 23 — Homologação Final** | **CONCLUÍDA** (processo 1.0) |
| **Fase 24 — Notícias Regionais** | **EM ANDAMENTO** formal · **12 LIVE** |

> Auditoria: [AUDITORIA_FINAL.md](AUDITORIA_FINAL.md). Inventário: [INVENTARIO_ENDPOINT_PENDING.md](INVENTARIO_ENDPOINT_PENDING.md).

## Validação 2026-07-21 (encerramento do dia)

| Item | Resultado |
|------|-----------|
| Commit | `a528f15` — sync catálogo LIVE c29c2ad |
| Versão | **1.0.0+6** |
| `flutter analyze` (arquivos tocados) | 0 erros |
| Testes de contrato (fases 11–22 + sprints) | **142** OK |
| `flutter test` suíte completa | Pendente reexecução pós-+6 |
| APK debug A10 `RX8M70CLXKP` | Instalado + launch OK |
| Web release `1.0.0+6` | Pendente build |
| Emulador | Nenhum |
| UX hubs | Sem chip “Demonstração” / “Em preparação” |

## Fase 17 — Gestão Eleitoral

Hub **Mais → Gestão Eleitoral** (`/home/elections`).

**Status: EM ANDAMENTO.** Namespace `/v1/elections/*` — **14 LIVE (HTTP 200)**; **31** ainda 404 → `EndpointPendingState`.

Doc: [FASE_17_GESTAO_ELEITORAL.md](FASE_17_GESTAO_ELEITORAL.md).

## Fase 24 — Notícias Regionais

Hub **Mais → Notícias regionais** (`/home/news`) + card na home do Gabinete.

**Status: EM ANDAMENTO.** Namespace `/v1/news/*` — **6 LIVE (HTTP 200)**; recent/feed/search/filters **404** → fallback local.

Doc: [FASE_24_NOTICIAS_REGIONAIS.md](FASE_24_NOTICIAS_REGIONAIS.md).

## Fase 23 — Homologação Final

**Status: CONCLUÍDA.** Versão **1.0.0+2**. Sem novos módulos. Auditoria completa (navegação, PT-BR, overflow, código morto, segurança, estados, APIs LIVE-only). `flutter analyze` sem errors/warnings; **333** testes; APK release + Web release; A10 `RX8M70CLXKP` OK; emulador não iniciado.

Docs: [FASE_23_HOMOLOGACAO_FINAL.md](FASE_23_HOMOLOGACAO_FINAL.md) · [RELEASE_NOTES.md](RELEASE_NOTES.md) · [CHECKLIST_HOMOLOGACAO.md](CHECKLIST_HOMOLOGACAO.md).

## Fase 22 — Integrações

Hub **Mais → Central de Integrações** (`/home/integrations`).

**Status: CONCLUÍDA.** Namespace `/v1/integrations/*` sincronizado — dashboard, catalog, health, providers, settings, sync (POST 202), history, logs, provedores gov/calendário/comms, webhooks **LIVE**. Paths UI mapeados aos publicados (`health`, `settings`, `senado`, `esic`, `outlook`). **Pending:** search, filters (404). Cache `pg_int_*`. Deep links: `poligestor://integrations|integracoes|integracao|central-integracoes/...`.

Doc: [FASE_22_INTEGRACOES.md](FASE_22_INTEGRACOES.md).

## Fase 21 — Segurança e Privacidade

Hub **Mais → Segurança e Privacidade** (`/home/security`). Namespace `/v1/security/*` — **`dashboard` LIVE (200)**; demais paths **404**. Tokens em `FlutterSecureStorage`; cache `pg_sec_*` sem segredos.

Doc: [FASE_21_SEGURANCA_PRIVACIDADE.md](FASE_21_SEGURANCA_PRIVACIDADE.md).

## Fase 20 — Portal Administrativo Web

Rota dedicada **`/platform`** (shell Web). Namespace `/v1/platform/*` — **`dashboard` LIVE (200)**; demais **404**.

Doc: [FASE_20_PORTAL_ADMINISTRATIVO_WEB.md](FASE_20_PORTAL_ADMINISTRATIVO_WEB.md).

## Fase 19 — Administração do Sistema

Hub **Mais → Administração do Sistema** (`/home/system-admin`).

Namespace `/v1/admin/*` — **`dashboard` LIVE (200)**; demais paths **404**. UI com `EndpointPendingState` nos subpaths pendentes.

Doc: [FASE_19_ADMINISTRACAO_SISTEMA.md](FASE_19_ADMINISTRACAO_SISTEMA.md).

## Fase 18 — IA Avançada

Hub **Mais → IA Avançada** (`/home/advanced-ai`), separado do Assistente Inteligente (`/home/chat`).

Namespace `/v1/ai/*` — LIVE: chat (POST), conversations, history, briefings, prompts, agents, summary, suggestions, feedback. Papéis Ativo via catálogo `/v1/ai/agents`. Pending: financial-analyst, settings, search. Cache `pg_aai_*`. Deep links: `poligestor://advanced-ai|ia-avancada|ia_avancada/...`.

Doc: [FASE_18_IA_AVANCADA.md](FASE_18_IA_AVANCADA.md).

## Fase 16 — CRM Político

Hub **Mais → CRM Político** (`/home/crm`).

Namespace `/v1/crm/*` — **`dashboard` LIVE (200)**; demais **404** → `EndpointPendingState`.

Doc: [FASE_16_CRM_POLITICO.md](FASE_16_CRM_POLITICO.md).

## Fase 15 — Comunicação Institucional

Hub **Mais → Comunicação Institucional** (`/home/institutional-communication`).

Namespace `/v1/communication/*` — **`dashboard` LIVE (200)**; demais **404** → `EndpointPendingState`.

Independente da Central de Comunicação (Sprint 10.4). Doc: [FASE_15_COMUNICACAO_INSTITUCIONAL.md](FASE_15_COMUNICACAO_INSTITUCIONAL.md).

## Fase 14 — Gestão Financeira do Mandato

Hub **Mais → Gestão Financeira** (`/home/finance`).

Namespace `/v1/finance/*` — **CONCLUÍDA**. LIVE sincronizados: `dashboard`, `categories`, `cost-centers`, `alerts`, `reports`, `accounts` (contas bancárias), `cashflow` (fluxo de caixa), `transactions`, `payments`. Demais entradas do hub ainda 404 → `EndpointPendingState`.

Cache: `pg_fin_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://finance|financeiro|gestao-financeira|financas/...`.

Validação A10 (`RX8M70CLXKP`): OK. Doc: [FASE_14_GESTAO_FINANCEIRA.md](FASE_14_GESTAO_FINANCEIRA.md).

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
| Próxima | Fase 18 (**não iniciar** sem pedido) |

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

## Qualidade / checklist de encerramento (Fase 16)

| # | Critério | Status |
|---|----------|--------|
| 1 | Backend domínio completo | Pendente (`/v1/crm/*` 404) |
| 2 | Flutter consome LIVE disponíveis | OK (nenhum LIVE; namespace preparado) |
| 3 | Não publicados → `EndpointPendingState` | OK |
| 4 | APK no Samsung Galaxy A10 | Pendente nesta entrega de wiring |
| 5 | Web validada | Pendente nesta entrega de wiring |
| 6 | `flutter analyze` | Nesta entrega |
| 7 | `flutter test` | Nesta entrega (suite Fase 16) |
| 8 | PHPUnit | N/A neste repo Flutter |
| 9 | Nenhum HTTP 500 | OK no probe (404) |
| 10 | Documentação | OK |
| 11–12 | Commit / Push | Pendente (só sob pedido) |
| 13–14 | Limpeza / sem emulador | Nesta entrega |
| 15 | Auditoria Backend ↔ Flutter | Pendente (domínio parcial) |

Doc: [AUDITORIA_FINAL.md](AUDITORIA_FINAL.md).

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
| 11–12 | Commit / Push | OK |
| 13–14 | Limpeza / sem emulador | OK |
| 15 | Auditoria Backend ↔ Flutter | OK |
