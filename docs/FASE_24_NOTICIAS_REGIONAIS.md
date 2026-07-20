# Fase 24 — Notícias Regionais

Atualizado: 2026-07-20

## Escopo

Área de notícias regionais no Gabinete, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/news/*`

Sem cópia do texto integral da matéria no app — apenas metadados (imagem, título, fonte, data, resumo) e link para a origem.

## Entrega Flutter

- Card **Notícias regionais** na home do Gabinete (`/home/dashboard`) — 3 a 5 itens quando LIVE; Pending honesto enquanto 404
- Destaque visual para menções ao político
- Hub `/home/news` com abas: Recentes · Menções ao político · Favoritos · Alertas
- Busca, filtros (cidade, fonte, período, assunto), pull-to-refresh
- Detalhe com abrir original, compartilhar (copiar link), favoritos
- Cache `pg_news_*` (strip de `content`/`body`), realtime via `MandateRefreshController`
- Material 3, responsivo, PT-BR, sem overflow
- Deep links: `poligestor://news|noticias|noticias-regionais|regional-news/...`

## Auditoria VPS (2026-07-20, autenticado)

**Todos os paths `/v1/news/*` retornaram HTTP 404.**

`kNewsLiveSlugs` permanece **vazio**. UI com `EndpointPendingState`.

Paths preparados: `recent`, `feed`, `search`, `filters`, `mentions`, `favorites`, `alerts`, `/{id}`.

## Status formal

**EM ANDAMENTO** (Flutter entregue; backend 100% 404 → Pending).

Validação A10 (`RX8M70CLXKP`): hub + Pending OK; emulador não iniciado.
