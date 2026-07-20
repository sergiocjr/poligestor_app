# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 24 — Notícias Regionais entregue; backend 404)

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
| Fase | **Fase 24 — Notícias Regionais** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; `/v1/news/*` 100% 404 → Pending) |
| Hub | Mais → Notícias regionais (`/home/news`) + card no Gabinete |
| Namespace oficial | `/api/v1/news/*` |
| Doc da fase | [FASE_24_NOTICIAS_REGIONAIS.md](FASE_24_NOTICIAS_REGIONAIS.md) |
| Fase 23 | **CONCLUÍDA** (1.0.0+2) |
| Fase 22 | **CONCLUÍDA** |
| Próxima fase | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | `a14a023` — feat Fase 24 Notícias Regionais |
| Push | origin/master |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação

- Notícias: Gabinete (card) + Mais → `/home/news`
- Integrações: `/home/integrations`
- Segurança: `/home/security`

---

## Contratos LIVE (Fase 24)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/news/*` | **Nenhum LIVE** (todos 404; `kNewsLiveSlugs` vazio) |

---

## Deep Links

```
poligestor://news/...
poligestor://noticias/...
poligestor://noticias-regionais/...
poligestor://regional-news/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 24 | OK (hub + EndpointPendingState) |

---

## Pendências reais

1. Backend publicar `/v1/news/*`.
2. Sync LIVE + auditoria HTTP 200/201/202.
3. Aceite de produção / publicação loja (pós-1.0).

## Próxima Fase

**Não iniciar** sem pedido explícito.
