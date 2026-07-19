# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (fechamento Sprint 10.2 — APK + OAuth coerente)

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
| **Sprint 10.2 — Identidade / Auth / Multi-tenant** | **FECHADA (Flutter)** — APK no SM-A105M + OAuth coerente |
| Fase 10+ (restante) | Em evolução |

## Sprint 10.2 — fechamento (APK + OAuth)

### Build Android — causa e correção

**Causa:** com Flutter 3.44 + AGP 9, `android.builtInKotlin=false` estava ativo sem aplicar `org.jetbrains.kotlin.android` no módulo `app`, enquanto `kotlin { compilerOptions { … } }` dependia do KGP → `Unresolved reference: compilerOptions` / `flutter` / falha em cascata.

**Correção (sem projeto novo):**

| Item | Valor final |
|------|-------------|
| Flutter | 3.44.6 (Dart 3.12.2) |
| Java (JDK build) | OpenJDK 21 (Android Studio JBR); `jvmTarget` / `sourceCompatibility` **17** |
| Gradle | 9.1.0 |
| AGP | 9.0.1 |
| Kotlin plugin | 2.3.20 (`org.jetbrains.kotlin.android` no `:app`) |
| Bypasses | `android.builtInKotlin=false` + `android.newDsl=false` (plugins pub.dev ainda aplicam KGP) |

Arquivos: `android/gradle.properties`, `android/settings.gradle.kts`, `android/app/build.gradle.kts`.

`flutter build apk --debug` e `flutter build web` OK. APK instalado no **SM-A105M** (`RX8M70CLXKP`). Nenhum emulador.

### OAuth / providers (pós-correção VPS)

Tokens da rodada anterior **não** foram reutilizados (`pm clear` + logout).

| Check | Resultado |
|-------|-----------|
| `GET /v1/portal/auth/providers` | password enabled/ready/ok; google/apple/govbr **disabled**, ready=false, `provider_disabled` |
| `GET /v1/auth/providers` | idem |
| `POST …/google\|apple\|govbr` | **HTTP 501** `provider_disabled` — sem tokens |
| UI | botões sociais ocultos (`canUse` = enabled && ready && !password) |

### Exercício no SM-A105M (ADB, sem digitar senha)

Senha **não** enviada via `adb input text` (autofill de debug no form). Validado:

- Abrir app; seleção org `demo` (deep link + Continuar); branding **Gabinete Ana Souza**
- Login operador; Protocolos LIVE; Mais → Meu perfil; Sessões (`flutter-android`, `api`)
- Trocar organização → `/org`; re-login; Sair → `/login`; reopen pós-logout permanece deslogado
- Providers: nenhum botão Google/Apple/Gov.br utilizável

### Matriz API autenticada (códigos)

| Fluxo | Resultado |
|-------|-----------|
| register (dados inválidos) | 422 |
| forgot-password | 200 |
| reset-password (token inválido) | 422 |
| staff login / me / sessions / logout | 200 |
| staff profile / linked-accounts | **403** portal-only |
| portal login / me / profile / PUT profile / sessions / linked-accounts / logout | 200 |
| portal linked-accounts | 200 `[]` |
| login CPF (sem CPF demo válido) | 422 |
| OAuth POST | 501 |

### Qualidade

- `dart format` / `flutter analyze` (infos ok) / `flutter test` 172 passed
- `flutter build apk --debug` √ / `flutter build web` √

### Pendências reais

- Credenciais reais Google/Apple/Gov.br + SDKs nativos quando a VPS habilitar
- Staff UI de perfil chama espelhos portal → 403 em linked-accounts (mensagem “Não foi possível sincronizar”)
- Login por CPF: falta CPF de usuário demo válido conhecido
- Revoke de sessão individual no device (ícone) não exercitado neste roteiro ADB
- APNs / Apple iOS não validado
- Bypass `builtInKotlin=false` é temporário até plugins pub.dev migrarem

### Repositório

- GitHub: https://github.com/sergiocjr/poligestor_app
- Commits Sprint 10.2: `0acb2ba` → `fc4c585` → `007c658` → (este fechamento APK/OAuth)
