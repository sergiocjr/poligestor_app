# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 22 — Integrações entregue; fechamento formal pendente)

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
| Fase | **Fase 22 — Integrações** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; `/v1/integrations/*` 100% 404 → Pending) |
| Hub | Mais → Central de Integrações (`/home/integrations`) |
| Namespace oficial | `/api/v1/integrations/*` |
| Doc da fase | [FASE_22_INTEGRACOES.md](FASE_22_INTEGRACOES.md) |
| Fase 21 | **EM ANDAMENTO** (`/v1/security/*` 404) |
| Fase 20 | **EM ANDAMENTO** (`/v1/platform/*` 404) |
| Fase 19 | **EM ANDAMENTO** (`/v1/admin/*` 404) |
| Fase 18 | **EM ANDAMENTO** (`/v1/ai/*` sync parcial) |
| Fase 17 | **CONCLUÍDA** (pendência A10 física) |
| Fase 23 | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | (atualizar após push da Fase 22) |
| Push | origin/master |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação

- Integrações: Mais → `/home/integrations` (staff)
- Segurança e Privacidade: Mais → `/home/security` (staff e portal)
- Sessões de conta (legado LIVE auth): Mais → Sessões → `/account/sessions` (`/v1/auth/sessions`)
- Portal Web: `/platform`
- Administração app: `/home/system-admin`

---

## Contratos LIVE (Fase 22)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/integrations/*` | **Nenhum LIVE** (todos 404; `kIntegrationsLiveSlugs` vazio) |

---

## Deep Links

```
poligestor://integrations/...
poligestor://integracoes/...
poligestor://integracao/...
poligestor://central-integracoes/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 22 | OK (hub + EndpointPendingState) |

---

## Pendências reais (fechamento formal)

1. Backend publicar `/v1/integrations/*`.
2. Sync LIVE + auditoria com HTTP 200/201/202.
3. Fechamento formal das Fases 11–12, 15–16, 18–21 (quando solicitado).

## Próxima Fase

**Fase 23 — não iniciar** sem pedido explícito.
