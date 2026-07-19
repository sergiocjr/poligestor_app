# Arquitetura Flutter — PoliGestor

## Camadas

```
presentation (pages/widgets)
    → domain (ChangeNotifier controllers, services)
        → data (repositories, models, cache)
            → core/api (ApiClient / Dio)
```

DI: **Provider** (+ `ChangeNotifierProvider`). Não usamos Riverpod neste projeto.

## Core

| Peça | Papel |
|------|--------|
| `ApiClient` | Dio, Bearer, refresh, `X-Tenant-Slug`, envelopes |
| `AuthController` / `AuthMode` | Sessão staff vs portal + paths |
| `TokenStorage` | Tokens seguros + meta de sessão |
| `TenantController` | Organização selecionada + branding (Sprint 10.2) |
| `AppConfig` | API base, Reverb, polling |
| `AppTheme.lightFromBranding` | Tema dinâmico por tenant |
| `pusher_reverb_client` | WSS Pusher-compatible |
| `go_router` | Org → login → shells staff (`/home/*`) e cidadão (`/citizen/*`) + `/account/*` |

## Features relevantes

- **identity** (Sprint 10.2) — resolve org, cache, branding, deep links
- **account** (Sprint 10.2) — perfil, sessões, logout remoto, register/forgot/OAuth preparados
- **auth** — splash, login, register, forgot
- **notifications** — FCM, prefs, inbox, `RealtimeSyncService`, `AppSyncController`
- **protocols** — modelos/repositório staff+cidadão (search/sort LIVE, timeline agrupada, rating fallback, anexos tipados)
- **agenda** — compromissos (staff events / portal appointments)
- **mandate** (Fase 8) — gestão do mandato, só staff
- **intelligence** (Fase 9) — briefing, insights, trends, analytics, só staff
- **virtual_team** (Sprint 10.1) — Equipe Virtual operational center
- **communication** (Sprint 10.4) — Central de Comunicação (channels/templates/campaigns LIVE)
- **smart_assistant** (Sprint 10.5) — Hub Assistente Inteligente (`/home/chat`)
- **automation** (Sprint 10.6) — Central de Automação (`/home/automation`)
- **strategy** (Sprint 10.7) — Painel Estratégico (`/home/strategy`)
- **parliament** (Sprint 10.8) — Painel Parlamentar (`/home/parliament`)
- **works** (Sprint 10.9) — Painel Obras (`/home/works`)
- **agreements** (Sprint 11.0) — Painel de Convênios (`/home/agreements`)
- **citizen** — portal (lista com pesquisa/ordenação, detalhe, conversa, anexos, avaliação/NPS preparado)
- **home** — `HomeShell` (bottom nav staff)
- **more** / **assistant**

## Navegação (GoRouter)

1. Bootstrap: `/splash` → `TenantController.bootstrap` + `AuthController.bootstrap`
2. Sem org → `/org`
3. Com org, sem sessão → `/login` (+ register/forgot)
4. Staff autenticado → `/home/*` (+ `/home/virtual-team/*`, `/home/communication/*`, `/home/automation/*`, `/home/strategy/*`, `/home/parliament/*`, `/account/*`)
5. Portal autenticado → `/citizen/*` (+ `/account/*`)
6. Deep links: `poligestor://protocols|notifications|virtual-team|communication|assistant|automation|strategy|parliament|org|tenant/...`

## Estado

- `provider` + `ChangeNotifier` para sessão, tenant e controllers compartilhados
- Telas frequentemente usam `FutureBuilder` / estado local quando o escopo é a página
- Endpoints ainda 404/500: `EndpointUnavailableException` → UI “indisponível” (sem mock)

## Tempo real (Fase 7)

1. Login → FCM register + `RealtimeSyncService.start()`
2. Canal `private-user.{id}` (staff) / `private-portal-user.{id}` (cidadão)
3. Detalhe de protocolo → `private-protocol.{id}`
4. Evento `protocol.realtime` → refresh inbox / soft refresh
5. Queda WSS → REST + polling na tela aberta + sync no resume
6. Staff: `MandateRefreshController.bump` no resume e em `protocol.realtime`

## Mandato (Fase 8)

- Paths em `AuthMode` → `MandateRepository` → páginas em `features/mandate/presentation`
- Cache SharedPreferences com `saved_at` (`MandateCache`)
- Rotas só sob `/home/mandate/*` (redirect se não for staff)

### Encerramento Fase 8

**STATUS: CONCLUÍDA.**

## Inteligência (Fase 9)

- Paths: `/v1/mandate/{briefing,analytics,trends,insights,briefings}`
- `IntelligenceRepository` + `IntelligenceCache` + páginas em `features/intelligence/`
- Rotas `/home/intelligence/*` (staff); refresh compartilhado com `MandateRefreshController`

### Encerramento Fase 9

**STATUS: CONCLUÍDA.**

## Sprint 9.5 — Hardening

- Inbox refresh coalescida; Reverb debounced; mandate bump throttled
- FCM em secure storage; documento mascarado em `AuthUser.toJson` / perfil
- `generate=1` só sob demanda explícita

### Encerramento Sprint 9.5

**STATUS: CONCLUÍDA.**

## Sprint 10.1 — Equipe Virtual

- `VirtualTeamRepository` + cache + páginas `/home/virtual-team/*`
- Contratos REST `/v1/virtual-team/*` LIVE
- Deep links `poligestor://virtual-team/...`

### Encerramento Sprint 10.1

**STATUS: CONCLUÍDA (Final).**

## Sprint 10.2 — Identidade / multi-tenant

- `IdentityRepository` / `IdentityCache` (por tenant) / `TenantController`
- `AccountRepository` (sessions LIVE; register/forgot/OAuth/profile)
- Contratos LIVE: resolve, branding, providers, OAuth token session
- UI org-first; branding dinâmico; providers só se `enabled`+`ready`

### Encerramento Sprint 10.2 (validação final Flutter)

**STATUS: VALIDADA** com APIs VPS 200. Pendências: SDKs nativos OAuth/Apple iOS, QR camera, validação visual em device.

## Sprint 10.4 — Central de Comunicação

- Feature isolada `lib/features/communication/` (somente PoliGestor)
- LIVE: `/v1/channels`, `/v1/templates`, `/v1/campaigns` (+ detalhe)
- LIVE omnichannel: `/v1/omnichannel/conversations`, `/queue`, `/operators`
- Cache `pg_comms_*`; refresh via `MandateRefreshController`
- Sem integração com NexChat / NexISP / GestFin

**STATUS: CONCLUÍDA.**

## Sprint 10.5 — Assistente Inteligente

- Feature `lib/features/smart_assistant/` (hub em rota legada `/home/chat`)
- LIVE: `POST /v1/ai/chat`, `GET /v1/ai/conversations`, briefing/briefings/insights
- Pending preparado: summary/weekly, suggestions, priorities, questions, favorites, share
- Deep links `poligestor://assistant|assistente|chat|ai/...`
- Regra permanente: `.cursor/rules/live-only-apis.mdc`

## Sprint 10.6 — Central de Automação

- Feature `lib/features/automation/` — hub próprio
- LIVE operacional via `VirtualTeamRepository` (sem duplicar regra VT)
- Pending: `/v1/automations*` (lista, aprovações, agenda, editor, escrita autonomia)
- Cache `pg_auto_{tenant}_*`; realtime via `MandateRefreshController`

## Sprint 10.7 — Painel Estratégico

- Feature `lib/features/strategy/` — hub próprio
- LIVE `/v1/strategy/{kpis,heatmap,trends,alerts,regions,neighborhoods,forecasts,reports}`
- Reuse mapa mandato; pending goals/compare/indicators/predictions/map
- Cache `pg_strategy_{tenant}_*`; docs `docs/INTEGRACOES.md`

## Sprint 10.8 — Painel Parlamentar

- Feature `lib/features/parliament/` — hub próprio
- LIVE `/v1/parliament/{dashboard,bills,projects,indications,requests,motions,amendments,agenda,sessions,votes,support-base,demands}`
- Pending: promises, search, timeline, history, attachments
- Cache `pg_parl_{tenant}_*`

## Sprint 10.9 — Painel Obras

- Feature `lib/features/works/` — hub próprio
- Namespace preparado `/v1/works/{dashboard,projects,demands,inspections,schedule,map,timeline,photos,attachments,checklist,indicators,reports,search}`
- Reuse mapa mandato LIVE; `EndpointPendingState` até a VPS publicar o namespace
- Cache `pg_works_{tenant}_*`

## Sprint 11.0 — Painel de Convênios

- Feature `lib/features/agreements/` — hub próprio
- Namespace preparado `/v1/agreements/{dashboard,agreements,resources,projects,execution,accountability,schedule,timeline,documents,attachments,indicators,reports,search}`
- `EndpointPendingState` até a VPS publicar o namespace
- Cache `pg_agree_{tenant}_*`

## Segurança

- Não versionar `google-services.json`
- Não logar tokens/CPF completos
- RBAC fino no servidor; app oculta superfícies por `AuthMode` (Mandato / Inteligência / Equipe Virtual / Comunicação = staff)
