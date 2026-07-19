# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (validação final Sprint 10.2)

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
| **Sprint 10.2 — Identidade / Auth / Multi-tenant** | **VALIDAÇÃO FINAL (Flutter + contratos LIVE)** |
| Fase 10+ (restante) | Em evolução |

## Sprint 10.2 — validação final

Fluxo org-first com contratos reais da VPS. Sem mocks. UI não conhece aliases — compatibilidade no repository.

### Integrado e validado (HTTP 200 / contrato LIVE)

| Endpoint | Status HTTP | Uso no app |
|----------|-------------|------------|
| `GET /v1/identity/tenants/resolve` | 200 | Seleção por slug/código/domínio |
| `GET /v1/portal/branding` | 200 | Nome, cores, logo, tagline |
| `GET /v1/portal/auth/providers` | 200 | Botões sociais conforme `is_enabled`+`ready` |
| `GET /v1/auth/providers` | 200 | Alias staff |
| `POST /v1/portal/auth/google\|apple\|govbr` | 200 | Tokens → `AuthController.applyTokenSession` |
| `POST /v1/auth/google` | 200 | Alias staff |
| `POST /v1/auth/login` · refresh · `GET /v1/auth/me` | 200 | Login staff |
| `GET/DELETE /v1/auth/sessions` | 200 com Bearer | Sessões staff |
| `POST /v1/auth/logout` · `DELETE …/revoke-all` | 401 sem Bearer (rota existe) | Logout |

### Implementado, aguardando dados de usuário autenticado (401 sem token = rota LIVE)

- `GET /v1/portal/auth/sessions|me|linked-accounts|profile`
- `PUT /v1/portal/auth/profile`
- Espelhos staff `linked-accounts` / `profile`

### Implementado com validação de formulário (422 = contrato ativo)

- `POST /v1/portal/auth/register`
- `POST /v1/portal/auth/forgot-password`
- `POST /v1/portal/auth/reset-password`
- Aliases staff equivalentes

### Aguardando credenciais externas / não validado em device SDK

- Google / Apple / Gov.br via **SDK nativo** (Sign in with Apple, Google Sign-In, Gov.br oficial) — VPS aceita POST e devolve token; integração Flutter consome o token. **Apple no iOS** permanece **preparado, não validado** sem certificados APNs/assinatura.
- QR scanner nativo: deep link suportado; câmera QR ainda “Em breve” na Mais.

### Preparado para iOS

- URL scheme `poligestor`
- Fluxos idênticos Android/Web
- Push APNs **não** validado

### Estados de indisponibilidade

- **Removidos** para resolve, branding e providers (agora LIVE).
- **Mantidos** apenas se a API voltar a 404/501/503 (`EndpointUnavailableException`).
- Fallback `selectSlugLocally` só quando resolve estiver indisponível.

### Isolamento multi-tenant

- Cache identity por slug (`identity_*_$slug`)
- Troca de org: `purgeAllTenantData` + `clearSessionAndTenant` (tokens, perfil, e-mail, tenant)

### Validação qualidade

- `flutter analyze` — 0 errors / 0 warnings
- `flutter test` — ver relatório final
- Builds: APK debug / web — ver relatório final

### Repositório

- GitHub: https://github.com/sergiocjr/poligestor_app
- Commit base Sprint 10.2: `0acb2ba`
