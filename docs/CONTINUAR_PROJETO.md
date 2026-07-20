# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 21 — Segurança e Privacidade entregue; fechamento formal pendente)

---

## Leitura obrigatória ao iniciar qualquer tarefa

1. **`docs/CONTINUAR_PROJETO.md`** (este arquivo) — **sempre primeiro**
2. `docs/STATUS_PROJETO.md`
3. `docs/CHANGELOG.md`
4. Últimos commits: `git log -5 --oneline`
5. Regras: `.cursor/rules/live-only-apis.mdc`, `fases-completas.mdc`, `flutter-device-a10.mdc`, `pt-br-ui.mdc`

---

## Fase atual

| Campo | Valor |
|-------|--------|
| Fase | **Fase 21 — Segurança e Privacidade** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; `/v1/security/*` 100% 404 → Pending) |
| Hub | Mais → Segurança e Privacidade (`/home/security`) |
| Namespace oficial | `/api/v1/security/*` |
| Doc da fase | [FASE_21_SEGURANCA_PRIVACIDADE.md](FASE_21_SEGURANCA_PRIVACIDADE.md) |
| Fase 20 | **EM ANDAMENTO** (`/v1/platform/*` 404) |
| Fase 19 | **EM ANDAMENTO** (`/v1/admin/*` 404) |
| Fase 18 | **EM ANDAMENTO** (`/v1/ai/*` sync parcial) |
| Fase 17 | **CONCLUÍDA** (pendência A10 física) |
| Fase 22 | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | (pendente — entrega Fase 21) |
| Push | Pendente |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação

- Segurança e Privacidade: Mais → `/home/security` (staff e portal)
- Sessões de conta (legado LIVE auth): Mais → Sessões → `/account/sessions` (`/v1/auth/sessions`)
- Portal Web: `/platform`
- Administração app: `/home/system-admin`

---

## Contratos LIVE (Fase 21)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/security/*` | **Nenhum LIVE** (todos 404; `kSecurityLiveSlugs` vazio) |

Tokens de sessão: `FlutterSecureStorage` (já existente).

---

## Deep Links

```
poligestor://security/...
poligestor://seguranca/...
poligestor://privacidade/...
poligestor://security-privacy/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 21 | OK (hub + EndpointPendingState; sem tokens em logcat) |

---

## Pendências reais (fechamento formal)

1. Backend publicar `/v1/security/*`.
2. Sync LIVE + auditoria MFA/sessões/privacidade com HTTP 200/201/202.
3. Fechamento formal das Fases 11–12, 15–16, 18–20 (quando solicitado).

## Próxima Fase

**Fase 22 — não iniciar** sem pedido explícito.
