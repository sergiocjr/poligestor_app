# PoliGestor App (Flutter)

Aplicativo mobile do **PoliGestor** — operação em campo (staff) e portal do cidadão.

API de produção: `https://poligestor.onnexis.com.br/api`

> No emulador Android, **nunca** use `localhost`. Se a API estiver neste PC, use `10.0.2.2`.
> Com a API na VPS, use o domínio HTTPS público (padrão do app).
> Validação de dispositivo: usar o aparelho físico **Samsung SM-A105M** (não abrir emulador nas rotinas oficiais).

## Rodar (dispositivo físico)

```powershell
$env:PATH = "C:\src\flutter\bin;$env:PATH"
cd C:\src\poligestor_app
flutter pub get
flutter devices
flutter run -d RX8M70CLXKP
```

Contas demo (podem variar conforme o tenant ativo na VPS):

| Persona  | E-mail               | Senha    | Tenant |
|----------|----------------------|----------|--------|
| Operador | `admin@demo.local`   | password | —      |
| Cidadão  | `cidadao@demo.local` | password | `demo` |

## Fases

| Fase | Tema | Status |
|------|------|--------|
| 1–6 | Auth, cidadão, protocolos, assistente | Concluídas |
| **7** | Push FCM, notificações, Reverb, deep links | **CONCLUÍDA** |
| **8** | Módulo Mandato (gestão staff) | **CONCLUÍDA** |
| **9** | Inteligência do mandato | **CONCLUÍDA** |
| 10+ | — | Não iniciada |

## Fase 7 — comunicação em tempo real (CONCLUÍDA)

Validado no **Samsung SM-A105M**:

- Firebase Android + `google-services.json` (não versionado)
- Token FCM real e registro em `POST /v1/.../devices/register`
- Remoção em logout: `DELETE /v1/.../devices/current`
- Push foreground / background / encerrado
- Deep links `poligestor://protocols/{id}` e `poligestor://notifications`
- WebSocket Reverb (`wss://…/app/{key}`) + auth `/broadcasting/auth`
- Fallback REST + polling 20s na tela de detalhe
- Preferências remotas, unread-count, marcar lidas / ler todas

### Limitações iOS

- Push iOS / APNs **não** validados nesta fase
- `GoogleService-Info.plist` e fluxo APNs ficam para configuração futura
- O código Flutter usa `firebase_messaging` de forma multiplataforma, mas o build/teste oficial foi só Android

## Fase 8 — Mandato (CONCLUÍDA)

Staff only — aba **Mandato** no bottom nav:

- Visão geral (`/v1/mandate/executive` + `briefing`)
- Agenda, bairros, assuntos, equipe, pesquisa, relatórios, mapa, painel TV
- Cache offline carimbado; refresh no resume e em eventos realtime
- Validado: endpoints HTTP 200 na VPS; APK debug no SM-A105M

**FASE 8 — STATUS: CONCLUÍDA.** Não iniciar Fase 9 neste app até o contrato de inteligência ser integrado.

## Fase 9 — Inteligência (CONCLUÍDA)

Staff only — aba **Inteligência**:

- Dashboard + briefing + insights (`?generate=1`) + tendências + analytics + briefings (daily/weekly/monthly)
- Cache local; refresh no resume/realtime
- Validado: APIs HTTP 200; APK debug no SM-A105M

**FASE 9 — STATUS: CONCLUÍDA.**

## Estrutura

```
lib/
  core/           # config, api, auth, storage, theme, router, realtime
  features/
    auth/
    citizen/
    protocols/
    agenda/
    notifications/  # FCM, prefs, Reverb sync
    mandate/        # Fase 8 — gestão do mandato (staff)
    intelligence/   # Fase 9 — inteligência do mandato (staff)
    home/           # shell staff
    more/
    assistant/
  shared/widgets/
docs/             # STATUS, CHANGELOG, ROADMAP, arquitetura
```

## Documentação

- [STATUS do projeto](docs/STATUS_PROJETO.md)
- [CHANGELOG](docs/CHANGELOG.md)
- [ROADMAP](docs/ROADMAP.md)
- [Arquitetura Flutter](docs/ARQUITETURA_FLUTTER.md)
