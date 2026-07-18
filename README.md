# PoliGestor App (Flutter)

Aplicativo mobile do **PoliGestor** — operação em campo (staff) e portal do cidadão.

API de produção: `https://poligestor.onnexis.com.br/api`

> No emulador Android, **nunca** use `localhost`. Se a API estiver neste PC, use `10.0.2.2`.
> Com a API na VPS, use o domínio HTTPS público (padrão do app).

## Rodar

```powershell
$env:PATH = "C:\src\flutter\bin;$env:PATH"
cd C:\src\poligestor_app
flutter pub get
flutter run -d emulator-5554
```

Contas demo:

| Persona  | E-mail               | Senha    | Tenant |
|----------|----------------------|----------|--------|
| Operador | `admin@demo.local`   | password | —      |
| Cidadão  | `cidadao@demo.local` | password | `demo` |

## Sprint 1 — base

- Auth dual (staff/portal), secure storage, refresh, splash, logout
- Shell staff com protocolos reais da API

## Sprint 2 — app do cidadão

- Home moderna (saudação, ações rápidas, resumo, recentes, compromissos, Meu Bairro, FAB chat)
- Nova solicitação (categoria, descrição, localização)
- Minhas solicitações + detalhe + linha do tempo + anexos (foto/galeria)
- Notificações, perfil, logout
- Chat assistente (endpoint real)

### Pendência crítica (backend)

Login portal retorna token, mas rotas protegidas (`/v1/portal/auth/me`, `/v1/portal/protocols`, etc.) respondem **401 Unauthenticated**.
Staff auth funciona normalmente. O app trata isso com banner + erros tipados.

## Estrutura

```
lib/
  core/           # config/env, api, auth, storage, theme, router
  features/
    auth/
    citizen/      # home, requests, notifications, profile, chat
    protocols/
    agenda/
    notifications/
    home/         # shell staff
    more/
  shared/widgets/
```
