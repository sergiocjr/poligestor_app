# Integrações LIVE — PoliGestor Flutter

Atualizado: 2026-07-20 (Fase 22)

Base API: `https://poligestor.onnexis.com.br/api`

Regra permanente: consumir somente contratos publicados pela VPS. Sem mocks na entrega final. Sem backend local. Ausência → `EndpointPendingState`.

## Fase 12 — `/v1/intelligence/*`

Namespace oficial da Inteligência Territorial. Probe 2026-07-20: **404 em todos os paths**. App preparado.

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/intelligence/dashboard` | Preparado (404) |
| GET | `/v1/intelligence/bi` | Preparado (404) |
| GET | `/v1/intelligence/kpis` | Preparado (404) |
| GET | `/v1/intelligence/indicators` | Preparado (404) |
| GET | `/v1/intelligence/charts` | Preparado (404) |
| GET | `/v1/intelligence/heatmap` | Preparado (404) |
| GET | `/v1/intelligence/map` | Preparado (404) |
| GET | `/v1/intelligence/neighborhoods` | Preparado (404) |
| GET | `/v1/intelligence/regions` | Preparado (404) |
| GET | `/v1/intelligence/electoral-zones` | Preparado (404) |
| GET | `/v1/intelligence/leaderships` | Preparado (404) |
| GET | `/v1/intelligence/demands` | Preparado (404) |
| GET | `/v1/intelligence/works` | Preparado (404) |
| GET | `/v1/intelligence/protocols` | Preparado (404) |
| GET | `/v1/intelligence/attendances` | Preparado (404) |
| GET | `/v1/intelligence/comparatives` | Preparado (404) |
| GET | `/v1/intelligence/evolution` | Preparado (404) |
| GET | `/v1/intelligence/trends` | Preparado (404) |
| GET | `/v1/intelligence/projections` | Preparado (404) |
| GET | `/v1/intelligence/filters` | Preparado (404) |
| GET | `/v1/intelligence/exports` | Preparado (404) |

## Fase 11 — `/v1/events`

Namespace oficial do Painel de Eventos. Sem aliases.

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/events` | **LIVE** (200) — lista |
| GET | `/v1/events/{uuid}` | **LIVE** (200) — detalhe |
| GET | `/v1/events/dashboard` | Preparado (colide com `{id}` → 500; painel usa agregação local) |
| GET | `/v1/events/agenda` | Preparado — UI Agenda usa lista LIVE |
| GET | `/v1/events/calendar` | Preparado — UI Calendário usa lista LIVE |
| GET | `/v1/events/audiences` | Preparado — fallback filtro `appointment` |
| GET | `/v1/events/meetings` | Preparado — fallback filtro `meeting` |
| GET | `/v1/events/participants` | Preparado (pending) |
| GET | `/v1/events/invites` | Preparado (pending) |
| GET | `/v1/events/attendance` | Preparado (pending) |
| GET | `/v1/events/check-in` | Preparado (pending) |
| GET | `/v1/events/check-out` | Preparado (pending) |
| GET | `/v1/events/qr-code` | Preparado (pending) |
| GET | `/v1/events/gallery` | Preparado (pending) |
| GET | `/v1/events/photos` | Preparado (pending) |
| GET | `/v1/events/videos` | Preparado (pending) |
| GET | `/v1/events/documents` | Preparado (pending) |
| GET | `/v1/events/certificates` | Preparado (pending) |
| GET | `/v1/events/timeline` | Preparado (pending) |
| GET | `/v1/events/reports` | Preparado (pending) |
| GET | `/v1/events/indicators` | Preparado (pending) |
| GET | `/v1/events/search` | Preparado — pesquisa local na lista LIVE |
| GET | `/v1/events/map` | Preparado (pending) |

## Sprint 11.0 — `/v1/grants/*`

Namespace oficial publicado na VPS. App sincronizado; `EndpointPendingState` apenas onde o path ainda retorna 404.

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/grants/dashboard` | **LIVE** (200) |
| GET | `/v1/grants/agreements` (+ `/{id}`) | **LIVE** (200) |
| GET | `/v1/grants/resources` | Preparado (404) |
| GET | `/v1/grants/projects` | **LIVE** (200) |
| GET | `/v1/grants/execution` | **LIVE** (200) |
| GET | `/v1/grants/accountability` | **LIVE** (200) |
| GET | `/v1/grants/schedule` | Preparado (404) |
| GET | `/v1/grants/timeline` | **LIVE** (200) |
| GET | `/v1/grants/documents` | **LIVE** (200) |
| GET | `/v1/grants/attachments` | Preparado (404) |
| GET | `/v1/grants/indicators` | Preparado (404) |
| GET | `/v1/grants/reports` | **LIVE** (200) |
| GET | `/v1/grants/search` | Preparado (404) — filtros locais nas listas |

> Paths legados `/v1/agreements/*` e `/v1/convenios/*` retornam 404 — não utilizar.

## Sprint 10.9 — `/v1/works/*`

Namespace dedicado **ainda não publicado** na VPS (probe 404 em todos os paths abaixo). App preparado com Models/Repo/UI/Cache e `EndpointPendingState`.

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/works/dashboard` | Preparado (404) |
| GET | `/v1/works/projects` (+ `/{id}`) | Preparado (404) |
| GET | `/v1/works/demands` | Preparado (404) |
| GET | `/v1/works/inspections` | Preparado (404) |
| GET | `/v1/works/schedule` | Preparado (404) |
| GET | `/v1/works/map` | Preparado (404) — reuso `/v1/mandate/map` LIVE |
| GET | `/v1/works/timeline` | Preparado (404) |
| GET | `/v1/works/photos` | Preparado (404) |
| GET | `/v1/works/attachments` | Preparado (404) |
| GET | `/v1/works/checklist` | Preparado (404) |
| GET | `/v1/works/indicators` | Preparado (404) |
| GET | `/v1/works/reports` | Preparado (404) |
| GET | `/v1/works/search` | Preparado (404) — filtros locais nas listas |
| GET | `/v1/mandate/map` | LIVE (reuso mapa) |

## Sprint 10.8 — `/v1/parliament/*`

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/parliament/dashboard` | LIVE |
| GET | `/v1/parliament/bills` (+ `/{id}`) | LIVE |
| GET | `/v1/parliament/projects` | LIVE |
| GET | `/v1/parliament/indications` | LIVE |
| GET | `/v1/parliament/requests` | LIVE |
| GET | `/v1/parliament/motions` | LIVE |
| GET | `/v1/parliament/amendments` | LIVE |
| GET | `/v1/parliament/agenda` | LIVE |
| GET | `/v1/parliament/sessions` | LIVE |
| GET | `/v1/parliament/votes` | LIVE |
| GET | `/v1/parliament/support-base` | LIVE |
| GET | `/v1/parliament/demands` | LIVE |
| GET | `/v1/parliament/promises` | Preparado (404) |
| GET | `/v1/parliament/search` | Preparado (404) — busca local nas listas |
| GET | `/v1/parliament/timeline` | Preparado (404) |
| GET | `/v1/parliament/history` | Preparado (404) |
| GET | `/v1/parliament/attachments` | Preparado (404) |

## Sprint 10.7 — `/v1/strategy/*`

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/strategy/kpis` | LIVE — KPIs / dashboard (fallback) |
| GET | `/v1/strategy/heatmap` | LIVE |
| GET | `/v1/strategy/trends` | LIVE |
| GET | `/v1/strategy/alerts` | LIVE |
| GET | `/v1/strategy/regions` | LIVE |
| GET | `/v1/strategy/neighborhoods` | LIVE |
| GET | `/v1/strategy/forecasts` | LIVE |
| GET | `/v1/strategy/reports` | LIVE (lista pode vir vazia) |
| GET | `/v1/strategy/dashboard` | Instável (500) → fallback KPIs |
| GET | `/v1/strategy/goals` | Preparado (404/500) |
| GET | `/v1/strategy/compare` | Preparado (404) |
| GET | `/v1/strategy/map` | Preparado → reuse `/v1/mandate/map` |
| GET | `/v1/strategy/indicators` | Preparado (404) |
| GET | `/v1/strategy/predictions` | Preparado (404) |

## Fase 17 — `/v1/elections/*`

Auditoria autenticada 2026-07-20: **14 LIVE (HTTP 200)**; **31** ainda 404 → `EndpointPendingState`.

LIVE: `dashboard`, `campaigns`, `candidates`, `teams`, `goals`, `regions`, `neighborhoods`, `map`, `events`, `material-requests`, `projections`, `accountability`, `receipts`, `reports`.

## Fase 22 — `/v1/integrations/*`

Namespace oficial da Central de Integrações. Sync autenticado 2026-07-20: **LIVE** na maioria dos paths; `search`/`filters` ainda 404.

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/integrations/dashboard` | **LIVE** (200) |
| GET | `/v1/integrations/catalog` | **LIVE** (200) |
| GET | `/v1/integrations/health` | **LIVE** (200) — Status na UI |
| GET | `/v1/integrations/providers` | **LIVE** (200) |
| GET/PUT | `/v1/integrations/settings` | **LIVE** (200) — Configuração na UI |
| GET/POST | `/v1/integrations/sync` | **LIVE** (200/202) |
| GET | `/v1/integrations/history` | **LIVE** (200) |
| GET | `/v1/integrations/logs` | **LIVE** (200) |
| GET | `/v1/integrations/govbr` | **LIVE** (200) |
| GET | `/v1/integrations/camara-municipal` | **LIVE** (200) |
| GET | `/v1/integrations/assembleia-legislativa` | **LIVE** (200) |
| GET | `/v1/integrations/camara-deputados` | **LIVE** (200) |
| GET | `/v1/integrations/senado` | **LIVE** (200) — Senado na UI |
| GET | `/v1/integrations/diario-oficial` | **LIVE** (200) |
| GET | `/v1/integrations/portal-transparencia` | **LIVE** (200) |
| GET | `/v1/integrations/esic` | **LIVE** (200) — e-SIC na UI |
| GET | `/v1/integrations/ouvidoria` | **LIVE** (200) |
| GET | `/v1/integrations/google-calendar` | **LIVE** (200) |
| GET | `/v1/integrations/outlook` | **LIVE** (200) — Outlook na UI |
| GET | `/v1/integrations/gmail` | **LIVE** (200) |
| GET | `/v1/integrations/whatsapp` | **LIVE** (200) |
| GET | `/v1/integrations/telegram` | **LIVE** (200) |
| GET | `/v1/integrations/firebase-push` | **LIVE** (200) |
| GET | `/v1/integrations/external-apis` | **LIVE** (200) |
| GET | `/v1/integrations/webhooks` | **LIVE** (200) |
| GET | `/v1/integrations/search` | Preparado (404) |
| GET | `/v1/integrations/filters` | Preparado (404) |

Doc: [FASE_22_INTEGRACOES.md](FASE_22_INTEGRACOES.md).

## Fase 24 — `/v1/news/*`

Namespace oficial de Notícias Regionais. Probe autenticado 2026-07-20: **404 em todos**. App preparado (`kNewsLiveSlugs` vazio).

| Método | Path | Status app |
|--------|------|------------|
| GET | `/v1/news/recent` | Preparado (404) |
| GET | `/v1/news/feed` | Preparado (404) |
| GET | `/v1/news/search` | Preparado (404) |
| GET | `/v1/news/filters` | Preparado (404) |
| GET | `/v1/news/mentions` | Preparado (404) |
| GET | `/v1/news/favorites` | Preparado (404) |
| GET | `/v1/news/alerts` | Preparado (404) |
| GET | `/v1/news/{id}` | Preparado (404) |

Doc: [FASE_24_NOTICIAS_REGIONAIS.md](FASE_24_NOTICIAS_REGIONAIS.md).

## Reuso mandato / inteligência

| Path | Uso no Painel |
|------|----------------|
| `/v1/mandate/map` | Tela Mapa |
| `/v1/mandate/neighborhoods` | Atalho Bairros |
| `/v1/mandate/reports` | Atalho Relatórios |
| `/v1/mandate/trends` / insights | Atalhos Inteligência |

## Outras sprints (resumo)

- 10.4 Comunicação: `/v1/channels`, templates, campaigns, omnichannel
- 10.5 Assistente: `/v1/ai/chat`, conversations, briefing(s), insights
- 10.6 Automação: operação via `/v1/virtual-team/*`; `/v1/automations*` pending
