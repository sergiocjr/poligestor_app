# Changelog — PoliGestor Flutter

## [Unreleased]

### Docs

- Encerramento oficial da Fase 8 (STATUS: CONCLUÍDA) antes do início da Fase 9

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

### Changed

- Paths de dispositivos e notificações alinhados ao contrato VPS
- Shell e sync de ciclo de vida com Reverb + REST

### Security

- `android/app/google-services.json` no `.gitignore`
- Tokens FCM mascarados em logs de debug

### Validated

- Samsung SM-A105M: push real, deep link, FCM token real

### Known limitations

- iOS push não validado
