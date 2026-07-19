# Changelog — PoliGestor Flutter

## [Sprint 10.1] — 2026-07-19 — CONCLUÍDA

### Added

- Feature `lib/features/virtual_team/` (models, cache, repository, dashboard, agentes, tarefas, execuções, hand-offs, eventos, memória, aprendizado, fila, audit/logs/search preparados)
- Rotas `/home/virtual-team/*` (staff) + entrada em Mais
- Deep links `poligestor://virtual-team/...`
- Paths live + reservados em `AuthMode`
- Testes `test/sprint101_virtual_team_test.dart`

### Integrated (descoberta VPS — HTTP 200)

- `GET /v1/virtual-team/dashboard`
- `GET /v1/virtual-team/agents`
- `GET /v1/virtual-team/agents/{slug}`
- `GET /v1/virtual-team/tasks`
- `GET /v1/virtual-team/executions`
- `GET /v1/virtual-team/events`
- `GET /v1/virtual-team/memory`
- `GET /v1/virtual-team/learning`
- `GET /v1/virtual-team/queue`
- `GET /v1/ai/handoffs` (hand-offs até existir path no namespace virtual-team)
- `GET /v1/ai/agents` path reservado no AuthMode (catálogo legado)

### Missing for backend (sem mock no app)

- `GET /v1/virtual-team` (raiz)
- `GET /v1/virtual-team/logs`
- `GET /v1/virtual-team/audit`
- `GET /v1/virtual-team/search`
- `GET /v1/virtual-team/metrics`
- `GET /v1/virtual-team/timeline`
- `GET /v1/virtual-team/alerts`
- `GET /v1/virtual-team/handoffs` (hoje usa `/v1/ai/handoffs`)
- `GET /v1/virtual-team/agents/{slug}/tasks|executions|…` (sub-rotas por agente)
- `GET /v1/ai/team` (500 na VPS — relation `vt_agents`)

### Notes

- Provider (não Riverpod), padrão Mandate/Intelligence
- Sem dados fictícios; listagens vazias = empty state real da API

## [Sprint 9.5] — 2026-07-19 — CONCLUÍDA

### Fixed / Improved

- Coalesce `NotificationsController.refresh` + debounce Reverb + throttle mandate bump
- AppSync resume soft (`onAuthenticated(soft: true)`) evita refresh/FCM duplicados
- Push ignora refresh de inbox quando Reverb está conectado
- Insights sem `generate=1` em refreshes passivos
- FCM token em FlutterSecureStorage; CPF mascarado no cache/perfil
- Login demo gated por `kDebugMode`
- Mais: itens órfãos “Em breve”; mapa do mandato funcional
- Semantics em indicadores/insights; dispose Push no app; remove `MandateStaleBanner`

### Tests

- `test/sprint95_hardening_test.dart`

### Validated

- `flutter test` 153 · analyze 0 errors · SM-A105M

## [Fase 9] — 2026-07-19 — CONCLUÍDA

### Added

- Feature `lib/features/intelligence/` (models, cache, repository, pages, widgets)
- Aba Inteligência no `HomeShell` + rotas `/home/intelligence/*` (staff only)
- Dashboard inteligente, briefing, insights, tendências, oportunidades, resumos e análises
- Paths `analytics` / `trends` / `insights` / `briefings` em `AuthMode`
- Testes `test/phase9_intelligence_test.dart`

### Changed

- Chat IA movido para a tela Mais (bottom bar: Protocolos, Agenda, Mandato, Inteligência, Mais)
- Documentação STATUS / ROADMAP / README / arquitetura

### Validated

- APIs Fase 9 HTTP 200; build debug no SM-A105M

### Known limitations

- Briefings históricos dependem dos jobs do backend
- Oportunidades = recorte de insights (sem rota própria na API)

## [Fase 8] — 2026-07-18 — CONCLUÍDA

### Added

- Feature `lib/features/mandate/` (models, cache, repository, pages, widgets)
- Aba Mandato no `HomeShell` + rotas `/home/mandate/*` (staff only)
- Overview executiva, briefing, pontos de atenção
- Agenda, bairros, assuntos, equipe, pesquisa (debounce), relatórios, mapa, painel TV
- `MandateRefreshController` ligado a resume (`AppSyncController`) e eventos Reverb
- Testes unitários/widget `test/phase8_mandate_test.dart`

### Changed

- Paths `/v1/mandate/*` em `AuthMode`
- Documentação STATUS / ROADMAP / README / arquitetura

### Validated

- Todos os endpoints mandato HTTP 200 na VPS
- Build debug no SM-A105M

### Known limitations

- Exportação de relatórios e mapa cartográfico dependem de campos futuros da API
- iOS não validado

## [Fase 7] — 2026-07-18 — CONCLUÍDA

### Added

- Firebase Core + Messaging (Android)
- Registro FCM em login; `DELETE …/devices/current` no logout
- Cliente Reverb/Pusher (`web_socket_channel`) + auth `/broadcasting/auth`
- Deep links `poligestor://protocols/{id}` e `poligestor://notifications`
- Preferências remotas `notification-preferences`
- Inbox: unread-count, filtros, paginação, POST read / read-all
- Polling REST 20s no detalhe do protocolo (fallback)
- Documentação de arquitetura / status / roadmap

### Validated

- Samsung SM-A105M: push real, deep link, FCM token real

### Known limitations

- iOS push não validado
