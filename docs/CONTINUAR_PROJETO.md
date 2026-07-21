# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-21 (Sync final Flutter × VPS prioritária)

---

## Sync final Flutter (pós-auditoria VPS)

| Campo | Valor |
|-------|--------|
| Doc inventário | [INVENTARIO_ENDPOINT_PENDING.md](INVENTARIO_ENDPOINT_PENDING.md) |
| Probe | 239×200 · **0×500** · `.tmp_probe/probe_get_final.csv` |
| `EndpointPendingState` | **0** no código |
| `/v1/events/viewer` | **não consumido** |
| Versão app | **1.0.0+5** |
| Status | Sync LIVE **OK**; sistema **EM ANDAMENTO** (404 VPS remanescentes) |

---

## Auditoria UX (experiência do usuário)

| Campo | Valor |
|-------|--------|
| Doc | [AUDITORIA_UX_EXPERIENCIA.md](AUDITORIA_UX_EXPERIENCIA.md) |
| Política | Dados de demonstração rotulados até sincronização real |
| Versão | **1.0.0+5** |

---

## Ponto de restauração 1.0 (pré-auditoria)

| Campo | Valor |
|-------|--------|
| Tag Git | **`v1.0-final-pre-auditoria`** |
| Commit base | **`a20587f`** |
| Versão app | **1.0.0+2** |
| Versão APK | **1.0.0+2** |
| Versão Web | **1.0.0+2** |
| Doc | [PONTO_RESTAURACAO_1.0.md](PONTO_RESTAURACAO_1.0.md) |

> Snapshot **antes** da auditoria final. Restaurar com `git checkout v1.0-final-pre-auditoria`.

---

## Auditoria Final (Fases 1–24)

| Campo | Valor |
|-------|--------|
| Doc | [AUDITORIA_FINAL.md](AUDITORIA_FINAL.md) |
| Tag pós-sync | `9d51d25` (pós-auditoria) |
| Fases CONCLUÍDAS (100%) | 1–9, 13, 14, 22, 23 (+ base auth/cidadão) |
| Fases EM ANDAMENTO | 11, 12, 15–21, 24, Sprints 10.5–10.9, 11.0 |

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
| Fase | **Sync final Flutter × VPS prioritária** |
| Status formal | Flutter LIVE sync **concluído**; sistema **EM ANDAMENTO** (automations + subpaths 404) |
| Versão | **1.0.0+5** |
| Próxima fase | Ampliar LiveSlugs quando VPS publicar `/v1/automations*` e restantes 404 |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Tag restauração | `v1.0-final-pre-auditoria` → commit `a20587f` |
| Versão APK / Web | **1.0.0+5** |
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
| GET | `/v1/news/dashboard` | **LIVE** (200) |
| GET | `/v1/news/mentions` | **LIVE** (200) |
| GET | `/v1/news/favorites` | **LIVE** (200) |
| GET | `/v1/news/alerts` | **LIVE** (200) |
| GET | `/v1/news/sources` | **LIVE** (200) |
| GET | `/v1/news/{article_id}` | **LIVE** (200) |
| GET | `/v1/news/recent` | 404 → fallback menções |
| GET | `/v1/news/feed` | 404 → fallback menções |
| GET | `/v1/news/search` | 404 → busca local |
| GET | `/v1/news/filters` | 404 → filtros via `sources` |

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
| Validação APK Fase 24 | OK (hub + card + detalhe LIVE) |

---

## Pendências reais

1. Paths agregados `/v1/news/recent|feed|search|filters` (404) — app usa fallback local.
2. Aceite de produção / publicação loja (pós-1.0).

## Próxima Fase

**Não iniciar** sem pedido explícito.
