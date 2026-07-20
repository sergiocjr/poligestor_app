# Changelog — PoliGestor Flutter

## [Fase 12 — Inteligência Territorial] — 2026-07-20

### Added

- Hub `/home/territorial-intelligence` (painel BI, painel analítico, KPIs, indicadores, gráficos, mapas de calor, mapa, bairros, regiões, zonas eleitorais, lideranças, demandas, obras, protocolos, atendimentos, comparativos, evolução, tendências, projeções, filtros, exportações)
- Namespace oficial `/v1/intelligence/*` com `EndpointPendingState` (probe VPS 404 em todos os paths)
- Cache `pg_ti_*`, realtime via `MandateRefreshController`, filtros locais
- Deep links `poligestor://territorial-intelligence|inteligencia-territorial|...`
- Testes `test/fase12_territorial_intelligence_test.dart`
- Documentação `docs/FASE_12_INTELIGENCIA_TERRITORIAL.md` + `docs/CONTINUAR_PROJETO.md`

### Notes

- Aba Inteligência (Fase 9) em `/home/intelligence` permanece em `/v1/mandate/*`
- Fase 13 não iniciada; fechamento formal da Fase 12 pendente dos 15 critérios

## [Fase 11 — Gestão Institucional / Painel de Eventos] — 2026-07-20

### Added

- Hub `/home/events` (painel, eventos, agenda, calendário, audiências, reuniões, participantes, convites, presença, check-in/out, QR Code, galeria, fotos, vídeos, documentos, certificados, linha do tempo, mapa, indicadores, relatórios, pesquisa)
- Namespace oficial `/v1/events` — lista e detalhe LIVE; demais paths preparados com `EndpointPendingState` ou fallback local
- Cache `pg_events_*`, realtime via `MandateRefreshController`, filtros locais
- Deep links `poligestor://events|eventos|painel-eventos`
- Testes `test/fase11_events_test.dart`
- Documentação `docs/FASE_11_EVENTOS.md`
- Modelo de entrega por **Fases completas** (sem subdivisão em 11.1/11.2/…)

### Not started

- Fase 12

## [Sprint 11.0 — sync VPS `/v1/grants/*`] — 2026-07-19

### Changed

- Sincronização do namespace oficial `/v1/grants/*` (substitui paths legados `/v1/agreements/*` e `/v1/convenios/*`)
- `EndpointPendingState` removido dos domínios com HTTP 200 (painel, convênios, projetos, execução, prestação de contas, linha do tempo, documentos, relatórios)
- Hub com chips **Ativo** / **Em preparação** conforme probe LIVE
- Parsers ajustados para payload `kpis`/`summary` do painel e campos LIVE de convênios/linha do tempo

## [Sprint 11.0 — Painel de Convênios] — 2026-07-19

### Added

- Hub `/home/agreements` (painel, convênios, recursos, projetos, execução, prestação de contas, cronograma, linha do tempo, documentos, anexos, indicadores, relatórios, pesquisa)
- Contratos preparados `/v1/agreements/*` com `EndpointPendingState` honesto (namespace ainda ausente na VPS)
- Cache `pg_agree_*`, realtime via `MandateRefreshController`, filtros locais nas listas
- Deep links `poligestor://agreements|convenios|painel-convenios`
- Testes `test/sprint110_agreements_test.dart`

### Not started

- Sprint 11.1

## [Sprint 10.9 — Painel Obras] — 2026-07-19

### Added

- Hub `/home/works` (painel, obras, demandas, fiscalizações, cronograma, mapa, linha do tempo, fotos, anexos, checklist, indicadores, relatórios, pesquisa)
- Contratos preparados `/v1/works/*` com `EndpointPendingState` honesto (namespace ainda ausente na VPS)
- Reuso do mapa do mandato LIVE (`/v1/mandate/map`) na tela de mapa
- Cache `pg_works_*`, realtime via `MandateRefreshController`, filtros locais nas listas
- Deep links `poligestor://works|obras|painel-obras`
- Testes `test/sprint109_works_test.dart`

### Fixed

- Redirect do `GoRouter` para converter intents `poligestor://…` em rotas internas (`/home/works/…`), evitando `Page Not Found` no deep link Android
- Hub Painel Obras: 1 coluna no telefone (A10) e títulos com ellipsis — elimina `BOTTOM OVERFLOWED` nos cards

### Not started

- Sprint 11.0

## [Sprint 10.8 — Painel Parlamentar] — 2026-07-19

### Added

- Hub `/home/parliament` (painel, projetos de lei, indicações, requerimentos, moções, emendas, agenda, sessões, votações, base de apoio, demandas, pesquisa)
- Contratos LIVE `/v1/parliament/*` com cache `pg_parl_*` e realtime
- Pending: promessas, pesquisa dedicada, linha do tempo, histórico, anexos
- Deep links `poligestor://parliament|parlamentar|legislativo|painel-parlamentar`
- Testes `test/sprint108_parliament_test.dart`

### Not started

- Sprint 10.9

## [Idioma PT-BR na interface] — 2026-07-19

### Changed

- Regra permanente `.cursor/rules/pt-br-ui.mdc`: UI só em Português do Brasil
- Helpers `lib/shared/i18n/ui_labels.dart` (severidade, status, prioridade, tendência, chips)
- Textos de Estratégia, Automação, Assistente, Equipe Virtual, Inteligência, Comunicação, Mais e Conta traduzidos (ex.: Painel, Mapa de calor, Análises, Resumos, Registros, Linha do tempo, Transferências, Modelos, Ativo/Em preparação)

## [Sprint 10.7 — Painel Estratégico] — 2026-07-19

### Added

- Hub `/home/strategy` (dashboard, KPIs, heatmap, tendências, alertas, regiões, bairros, previsões, relatórios, mapa)
- Contratos LIVE `/v1/strategy/*` com cache `pg_strategy_*` e realtime via `MandateRefreshController`
- Pending honesto: metas, comparativos, indicadores, predições, mapa dedicado
- Reuso do mapa/bairros/relatórios do Mandato (sem duplicar regra)
- Deep links `poligestor://strategy|estrategia|strategic|painel-estrategico`
- Docs `docs/INTEGRACOES.md`; testes `test/sprint107_strategy_test.dart`

### Not started

- Sprint 10.8

## [Sprint 10.6 — Central de Automação] — 2026-07-19

### Added

- Hub `/home/automation` (dashboard, execuções, alertas, agentes, logs, métricas, histórico, autonomia)
- Reuso LIVE Equipe Virtual + `/v1/ai/team` sem duplicar regra de negócio
- Pending honesto: `/v1/automations*`, aprovações, agenda, editor (10 passos), escrita de autonomia com confirmação
- Cache por tenant `pg_auto_*`; deep links `poligestor://automation|automacao|automations`
- Testes `test/sprint106_automation_test.dart`

### Not started

- Sprint 10.7

## [Sprint 10.5 — Assistente Inteligente] — 2026-07-19

### Added

- Hub IA em `/home/chat` (rota legada Mais → Assistente Inteligente)
- LIVE: chat gabinete (`POST /v1/ai/chat`), conversas, briefing/briefings, insights
- Prepared + `EndpointPendingState`: resumo semanal, sugestões, prioridades, perguntas, favoritos, compartilhar
- Cache `pg_sa_*`, deep links `poligestor://assistant|assistente|chat|ai`
- Regra permanente LIVE-only em `.cursor/rules/live-only-apis.mdc`
- Testes `test/sprint105_smart_assistant_test.dart`

## [Sprint 10.4 — CONCLUÍDA] — 2026-07-19

### Status

- Sprint 10.4 marcada como **CONCLUÍDA** (canais, templates, campanhas + omnichannel conversations/queue/operators LIVE)

## [Sprint 10.4 sync — omnichannel LIVE] — 2026-07-19

### Changed

- Conversas / fila / operadores passam a consumir `GET /v1/omnichannel/conversations|queue|operators` (HTTP 200)
- Removido `EndpointPendingState` dessas três rotas; aba Conversas lista KPIs, operadores e conversas

## [Sprint 10.4 — Central de Comunicação] — 2026-07-19

### Added

- Feature `communication/` (PoliGestor only): modelos, cache, repository, hub Material 3
- LIVE: `GET /v1/channels`, `/v1/templates` (+ detalhe), `/v1/campaigns` (+ detalhe)
- Filtros `search` / `status` / `channel_type` / `sort` conforme contrato VPS
- Entrada staff em Mais; rotas `/home/communication/*`; deep links `poligestor://communication|comunicacao|comms`
- Testes `test/sprint104_communication_test.dart`

### Pending (VPS — sem mock)

- Conversas `/v1/conversations`, fila `/v1/queue`, operadores `/v1/operators`
- Preview/métricas de campanha quando publicados na API deste produto

### Isolation

- Nenhum código, API, DB, Redis, Reverb ou módulo de NexChat / NexISP / GestFin

## [Portal/Protocolos — auditoria] — 2026-07-19

### Improved

- Status: `status_label` LIVE + rótulos Novo / Em execução / Aguardando cidadão / Arquivado
- Timeline agrupada por data (cards)
- Lista cidadão: search + sort nos contratos LIVE
- Rating: fallback `/rating` e `/rate` quando `can_rate` sem link
- Anexos: PDF/áudio/vídeo + thumbnail; NPS UI preparada

### Pending

- 500 intermitente na listagem portal (VPS)
- Share nativo; filtros período na UI; paridade staff list

## [Sprint 10.2 Fechamento APK/OAuth] — 2026-07-19

### Fixed

- Build Android (AGP 9 + Flutter 3.44): aplicar `org.jetbrains.kotlin.android` no `:app` com `android.builtInKotlin=false` / `android.newDsl=false`
- OAuth POST trata 501/503 como indisponível; providers desabilitados não geram sessão

### Validated

- `flutter build apk --debug` + install SM-A105M; org → branding → login → perfil → sessões → troca org → logout
- Providers LIVE coerentes: password ok; google/apple/govbr disabled/ready=false; POST 501
- Portal profile/sessions/linked-accounts 200; staff profile/linked 403 (portal-only)

### Pending

- Credenciais OAuth reais + SDKs nativos; APNs; CPF demo válido; sync linked em modo staff

## [Sprint 10.2 Validação Final] — 2026-07-19

### Changed / Completed

- Revalidação VPS: resolve, branding e providers agora LIVE (HTTP 200)
- Parsing do contrato real (`organization`, `logo_path`, `is_enabled`/`ready`)
- Branding dinâmico (cores + logo de rede) na UX de login
- Providers externos só quando `enabled` + `ready`; OAuth aplica tokens na sessão
- Cache identity isolado por tenant; troca de org limpa tokens e caches
- Cadastro exige organização; respeita `registration_enabled`
- Testes de contrato LIVE em `test/sprint102_identity_test.dart`
- STATUS atualizado com classificação integrado / aguardando / iOS

### Pending (histórico — parcialmente resolvido no fechamento APK/OAuth)

- Apple/Google SDKs nativos + APNs (credenciais externas)
- QR camera nativo (deep link já funciona)

## [Sprint 10.2] — 2026-07-19 — CONCLUÍDA (Flutter)

### Added

- Fluxo org-first: `/org` → branding → `/login` (staff/portal)
- `lib/features/identity/` (models, cache, repository, TenantController, UI)
- `lib/features/account/` (sessions LIVE, perfil, linked accounts preparados)
- Cadastro, recuperação de senha, OAuth Google/Apple/Gov.br — estrutura + estados reais
- Branding dinâmico (`AppTheme.lightFromBranding`)
- Deep links `poligestor://org|tenant/{slug}`; intent-filters Android; URL scheme iOS
- Testes `test/sprint102_identity_test.dart`

### Integrated (HTTP 200)

- `/v1/auth/me`, `/v1/auth/sessions`, `DELETE /v1/auth/sessions/{id}`
- Login/refresh existentes

### Pending backend

- Resolve/branding/providers/register/forgot e espelhos portal ainda 500/404 — app conecta automaticamente quando HTTP 200

## [Sprint 10.1 Final] — 2026-07-19 — CONCLUÍDA

### Added / Completed

- Integração completa dos contratos REST da Equipe Virtual disponibilizados na VPS
- Telas: root/dashboard, agentes (+ sub-rotas), tarefas, execuções, hand-offs, timeline, alertas, métricas, auditoria, logs, pesquisa, memória, aprendizado, fila, eventos
- Remoção de estados “Endpoint indisponível” e de stubs 404
- Hand-offs via `GET /v1/virtual-team/handoffs`
- Refresh em tempo real via Reverb → `MandateRefreshController`
- Testes atualizados em `test/sprint101_virtual_team_test.dart`

### APIs (todas HTTP 200 na VPS)

- `/v1/virtual-team` e `/dashboard|/agents|/agents/{slug}`
- `/v1/virtual-team/agents/{slug}/tasks|executions|logs|metrics|timeline`
- `/v1/virtual-team/tasks|executions|events|memory|learning|queue`
- `/v1/virtual-team/logs|audit|search|metrics|timeline|alerts|handoffs`

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
