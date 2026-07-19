# PoliGestor App (Flutter)

Aplicativo mobile do **PoliGestor** — operação em campo (staff) e portal do cidadão.

- **API:** `https://poligestor.onnexis.com.br/api`
- **Repositório:** [github.com/sergiocjr/poligestor_app](https://github.com/sergiocjr/poligestor_app)

> No emulador Android, **nunca** use `localhost`. Se a API estiver neste PC, use `10.0.2.2`.
> Com a API na VPS, use o domínio HTTPS público (padrão do app).
> Validação de dispositivo: usar o aparelho físico **Samsung SM-A105M** (não abrir emulador nas rotinas oficiais).

## Rodar (dispositivo físico)

```powershell
$env:PATH = "C:\src\flutter\bin;$env:PATH"
cd C:\src\poligestor_app
flutter pub get
flutter devices
# Preferir o wrapper (cleanup ao parar):
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_run_a10.ps1
# Ou direto:
flutter run -d RX8M70CLXKP
```

Contas demo (após selecionar organização, ex.: `demo`):

| Persona  | E-mail               | Senha    | Modo    |
|----------|----------------------|----------|---------|
| Operador | `admin@demo.local`   | password | Staff   |
| Cidadão  | `cidadao@demo.local` | password | Portal  |

## Fases / Sprints

| Fase | Tema | Status |
|------|------|--------|
| 1–6 | Auth, cidadão, protocolos, assistente | Concluídas |
| **7** | Push FCM, notificações, Reverb, deep links | **CONCLUÍDA** |
| **8** | Módulo Mandato (gestão staff) | **CONCLUÍDA** |
| **9** | Inteligência do mandato | **CONCLUÍDA** |
| **9.5** | Hardening produção | **CONCLUÍDA** |
| **10.1** | Equipe Virtual | **CONCLUÍDA** |
| **10.2** | Identidade / Auth / Multi-tenant | **FECHADA (Flutter + APK SM-A105M)** |
| 10+ | Evolução + credenciais OAuth reais | Em andamento |

## Sprint 10.2 — Identidade (FECHADA)

Fluxo **org-first** (`/org` → branding → `/login`) com contratos LIVE da VPS:

- Resolve / branding / providers LIVE
- OAuth externos **desabilitados** na VPS (`ready=false`; POST 501) — UI sem botões sociais
- Cadastro / forgot / reset / perfil / sessões / linked accounts (portal 200; staff profile/linked 403)
- APK debug no **SM-A105M**; toolchain AGP 9.0.1 / Gradle 9.1.0 / Kotlin 2.3.20 / Java target 17
- Cache por tenant; deep links `poligestor://org/{slug}`

Detalhes: [STATUS](docs/STATUS_PROJETO.md).

## Sprint 10.1 — Equipe Virtual (CONCLUÍDA Final)

Staff — **Mais → Equipe Virtual** (`/home/virtual-team/*`):

- Dashboard, agentes + sub-rotas, tarefas, execuções, hand-offs, timeline, alertas, métricas, auditoria, logs, pesquisa, memória, aprendizado, fila, eventos
- Integração completa dos contratos VPS; refresh via Reverb/MandateRefresh
- Deep links `poligestor://virtual-team/...`

## Fase 7 — comunicação em tempo real (CONCLUÍDA)

Validado no **Samsung SM-A105M**:

- Firebase Android + `google-services.json` (não versionado)
- Token FCM real e registro em `POST /v1/.../devices/register`
- Remoção em logout: `DELETE /v1/.../devices/current`
- Push foreground / background / encerrado
- Deep links `poligestor://protocols/{id}` e `poligestor://notifications`
- WebSocket Reverb (`wss://…/app/{key}`) + auth `/broadcasting/auth`
- Fallback REST + polling 20s na tela de detalhe

### Limitações iOS

- Push iOS / APNs **não** validados nesta fase
- `GoogleService-Info.plist` e fluxo APNs ficam para configuração futura

## Fase 8 — Mandato (CONCLUÍDA)

Staff only — aba **Mandato**: visão geral, agenda, bairros, assuntos, equipe, pesquisa, relatórios, mapa, TV.

## Fase 9 — Inteligência (CONCLUÍDA)

Staff only — aba **Inteligência**: dashboard, briefing, insights, tendências, analytics, briefings.

## Sprint 9.5 — Hardening (CONCLUÍDA)

Produção: sync coalescido, FCM seguro, CPF mascarado, UX Mais, a11y básica, dispose.

## Estrutura

```
lib/
  core/           # config, api, auth, storage, theme, router, realtime
  features/
    identity/       # Sprint 10.2 — org + branding
    account/        # Sprint 10.2 — perfil / sessões
    auth/
    citizen/
    protocols/
    agenda/
    notifications/
    mandate/        # Fase 8
    intelligence/   # Fase 9
    virtual_team/   # Sprint 10.1
    home/
    more/
    assistant/
  shared/widgets/
docs/             # STATUS, CHANGELOG, ROADMAP, arquitetura
scripts/          # flutter_run_a10.ps1, flutter_cleanup.ps1
```

## Documentação

- [STATUS do projeto](docs/STATUS_PROJETO.md)
- [CHANGELOG](docs/CHANGELOG.md)
- [ROADMAP](docs/ROADMAP.md)
- [Arquitetura Flutter](docs/ARQUITETURA_FLUTTER.md)

## Retomada amanhã

1. Acompanhar estabilização VPS dos endpoints 10.2 (500/404 → 200)
2. Validar branding real + resolve remoto no SM-A105M
3. Validar cadastro / forgot / providers sociais quando publicados
