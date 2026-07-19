# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19

## Resumo

| Área | Status |
|------|--------|
| Auth dual (staff / portal) | Concluído |
| Portal do cidadão | Concluído |
| Protocolos / conversa / avaliação | Concluído |
| Assistente IA (via Laravel) | Concluído |
| Fase 7 — FCM + Reverb + deep links | CONCLUÍDA |
| Fase 8 — Mandato (staff) | CONCLUÍDA |
| Fase 9 — Inteligência do mandato | CONCLUÍDA |
| Sprint 9.5 — Hardening produção | CONCLUÍDA |
| Sprint 10.1 — Equipe Virtual | CONCLUÍDA (Final) |
| **Sprint 10.2 — Identidade / Auth / Multi-tenant** | **CONCLUÍDA (estrutura + APIs 200)** |
| Fase 10+ (restante) | Em evolução |

## Sprint 10.2 — CONCLUÍDA (Flutter)

Fluxo org-first, branding dinâmico, autenticação, perfil, sessões e recuperação de senha. Integra apenas contratos HTTP 200; demais rotas com estrutura pronta e estados honestos (carregando / indisponível / erro / vazio) — sem mocks.

### Entregue

- Features `lib/features/identity/` e `lib/features/account/`
- Rotas `/org`, `/login`, `/login/register`, `/login/forgot`, `/account/profile`, `/account/sessions`
- Branding via `TenantController` + `AppTheme.lightFromBranding`
- Deep links `poligestor://org|tenant/{slug}` + subdomínio Web
- Sessões LIVE (`GET/DELETE /v1/auth/sessions`)
- Entradas: Mais → Perfil / Sessões / Trocar organização

### APIs HTTP 200 (integradas)

- `POST /v1/auth/login` · `POST /v1/auth/refresh` · `GET /v1/auth/me`
- `GET /v1/auth/sessions` · `DELETE /v1/auth/sessions/{id}`
- Login portal existente (quando estável)

### Preparadas (endpoint existe mas 500 / 404 — UI desacoplada)

Ver relatório “endpoints ausentes” no fechamento da sprint para a VPS.

### Validação

- `flutter test` · `flutter analyze` (0 errors)
