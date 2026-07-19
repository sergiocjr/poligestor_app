# Arquitetura Flutter — PoliGestor

## Camadas

```
presentation (pages/widgets)
    → domain (ChangeNotifier controllers, services)
        → data (repositories, models, cache)
            → core/api (ApiClient / Dio)
```

## Core

| Peça | Papel |
|------|--------|
| `ApiClient` | Dio, Bearer, refresh, `X-Tenant-Slug`, envelopes |
| `AuthController` / `AuthMode` | Sessão staff vs portal + paths |
| `TokenStorage` | Tokens seguros + meta de sessão |
| `AppConfig` | API base, Reverb, polling |
| `pusher_reverb_client` | WSS Pusher-compatible |
| `go_router` | Shells staff (`/home/*`) e cidadão (`/citizen/*`) |

## Features relevantes

- **notifications** — FCM, prefs, inbox, `RealtimeSyncService`, `AppSyncController`
- **protocols** — modelos e repositório compartilhados staff/cidadão
- **agenda** — compromissos (staff events / portal appointments)
- **mandate** (Fase 8) — gestão do mandato, só staff
- **citizen** — portal
- **home** — `HomeShell` (bottom nav staff)

## Estado

- `provider` + `ChangeNotifier` para sessão e controllers compartilhados
- Telas frequentemente usam `FutureBuilder` / estado local quando o escopo é a página

## Tempo real (Fase 7)

1. Login → FCM register + `RealtimeSyncService.start()`
2. Canal `private-user.{id}` (staff) / `private-portal-user.{id}` (cidadão)
3. Detalhe de protocolo → `private-protocol.{id}`
4. Evento `protocol.realtime` → refresh inbox / soft refresh
5. Queda WSS → REST + polling na tela aberta + sync no resume
6. Staff: `MandateRefreshController.bump` no resume e em `protocol.realtime`

## Mandato (Fase 8)

- Paths em `AuthMode` → `MandateRepository` → páginas em `features/mandate/presentation`
- Cache SharedPreferences com `saved_at` (`MandateCache`)
- Rotas só sob `/home/mandate/*` (redirect se não for staff)

## Segurança

- Não versionar `google-services.json`
- Não logar tokens/CPF completos
- RBAC fino no servidor; app oculta superfícies por `AuthMode` (Mandato = staff)
