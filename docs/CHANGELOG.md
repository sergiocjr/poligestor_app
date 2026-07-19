# Changelog — PoliGestor Flutter

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
