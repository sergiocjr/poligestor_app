# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 24 — Notícias Regionais **CONCLUÍDA**)

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
| Status formal | **CONCLUÍDA** |
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
| Último commit | `048c211` — sync LIVE Fase 24 Notícias Regionais |
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
