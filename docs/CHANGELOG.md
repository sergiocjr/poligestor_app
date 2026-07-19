# Changelog — PoliGestor Flutter

## [Unreleased]

### Fase 8 (em andamento)

- Módulo Mandato (staff) e integração com `/v1/mandate/*`

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
