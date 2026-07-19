# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (encerramento do dia)

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
| **Sprint 10.2 — Identidade / Auth / Multi-tenant** | **CONCLUÍDA (Flutter)** |
| Branding / resolve / OAuth / cadastro (backend) | Pendente na VPS |
| Fase 10+ (restante) | Em evolução |

## Encerramento do dia (2026-07-19)

### Implementado hoje

1. **Sprint 10.1 Final** — Equipe Virtual 100% integrada aos contratos LIVE `/v1/virtual-team/*`
2. **Sprint 10.2** — Identidade, autenticação e multi-tenant no Flutter:
   - Fluxo org-first (`/org` → login)
   - Branding dinâmico (`TenantController` + tema)
   - Cadastro / recuperação / OAuth (estrutura + estados honestos)
   - Perfil, sessões LIVE, troca de organização
   - Deep links `poligestor://org|tenant/{slug}`
3. Documentação alinhada (README, STATUS, CHANGELOG, ROADMAP, arquitetura)
4. Ícones / logo do app atualizados (Android, iOS, Web)
5. Remote GitHub: `https://github.com/sergiocjr/poligestor_app`

### Ponto de retomada amanhã

Continuar pela **estabilização backend da Sprint 10.2** (lista abaixo). No app Flutter, assim que um endpoint passar a HTTP 200, a integração já está plugada — basta validar UX no SM-A105M.

## Sprint 10.2 — CONCLUÍDA (Flutter)

Fluxo org-first, branding dinâmico, autenticação, perfil, sessões e recuperação de senha. Integra apenas contratos HTTP 200; demais rotas com estrutura pronta e estados honestos (carregando / indisponível / erro / vazio) — **sem mocks**.

### Entregue

- Features `lib/features/identity/` e `lib/features/account/`
- Rotas `/org`, `/login`, `/login/register`, `/login/forgot`, `/account/profile`, `/account/sessions`
- Branding via `TenantController` + `AppTheme.lightFromBranding`
- Deep links `poligestor://org|tenant/{slug}` + resolução de host Web
- Sessões LIVE (`GET/DELETE /v1/auth/sessions`)
- Entradas: Mais → Perfil / Sessões / Trocar organização

### APIs HTTP 200 (integradas)

- `POST /v1/auth/login` · `POST /v1/auth/refresh` · `GET /v1/auth/me`
- `GET /v1/auth/sessions` · `DELETE /v1/auth/sessions/{id}`
- Login portal existente (quando estável)

### Pendências reais (somente backend / VPS)

**500 (rota existe; migrations / branding):**

- `GET|POST /v1/identity/tenants/resolve`
- `GET /v1/portal/branding`
- `GET /v1/portal/auth/providers`
- `POST /v1/portal/auth/register`
- `POST /v1/portal/auth/forgot-password`
- `POST /v1/portal/auth/reset-password`
- `GET /v1/portal/auth/sessions` · `GET /v1/portal/auth/me`
- `GET /v1/portal/auth/linked-accounts`

**404 (ainda não implementados):**

- Staff: providers, register, forgot/reset-password, linked-accounts, profile, google/apple/govbr
- Portal: `POST …/auth/google|apple|govbr`, `PUT …/auth/profile`

**OK quando autenticado (app já chama):**

- `POST /v1/auth/logout`
- `DELETE /v1/auth/sessions/revoke-all`

### Validação

- `flutter test` · `flutter analyze` (0 errors / 0 warnings)
