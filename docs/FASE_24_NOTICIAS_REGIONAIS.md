# Fase 24 — Notícias Regionais

Atualizado: 2026-07-20

## Escopo

Área de notícias regionais no Gabinete, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/news/*`

Sem cópia do texto integral da matéria no app — apenas metadados (imagem, título, fonte, data, resumo) e link para a origem.

## Entrega Flutter

- Card **Notícias regionais** na home do Gabinete (`/home/dashboard`) — 3 a 5 itens via menções + detalhe
- Destaque visual para menções ao político
- Hub `/home/news` com abas: Recentes · Menções ao político · Favoritos · Alertas
- Busca e filtros locais (fontes/cidades/período via `sources` + filtro client-side)
- Detalhe com abrir original, compartilhar (copiar link), favoritos
- Cache `pg_news_*` (strip de `content`/`body`), realtime via `MandateRefreshController`
- Material 3, responsivo, PT-BR, sem overflow
- Deep links: `poligestor://news|noticias|noticias-regionais|regional-news/...`

## Auditoria VPS (2026-07-20, autenticado)

**6 LIVE (HTTP 200):**

| Método | Path | Uso no app |
|--------|------|------------|
| GET | `/v1/news/dashboard` | Resumo operacional |
| GET | `/v1/news/mentions` | Recentes, menções, feed (com hidratação) |
| GET | `/v1/news/favorites` | Aba favoritos + POST/DELETE |
| GET | `/v1/news/alerts` | Aba alertas de menção |
| GET | `/v1/news/sources` | Filtros de fonte e cidade |
| GET | `/v1/news/{article_id}` | Detalhe da matéria |

**Ainda 404 → `EndpointPendingState` ou fallback local:**

| Path | Fallback app |
|------|--------------|
| `/v1/news/recent` | Menções + detalhe |
| `/v1/news/feed` | Menções + filtros locais |
| `/v1/news/search` | Busca local no feed |
| `/v1/news/filters` | Opções derivadas de `sources` |

## Status formal

**CONCLUÍDA.** Flutter sincronizado com contratos LIVE; Pending apenas em paths ainda 404.

Validação A10 (`RX8M70CLXKP`): hub + card + detalhe OK; emulador não iniciado.
