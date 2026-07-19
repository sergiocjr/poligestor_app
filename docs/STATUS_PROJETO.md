# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 10.9 — Painel Obras CONCLUÍDA)

## Resumo

| Área | Status |
|------|--------|
| Auth dual (staff / portal) | Concluído |
| Portal do cidadão / Protocolos | Concluído + auditoria/hardening |
| Assistente IA (via Laravel) | Concluído |
| Fase 7 — FCM + Reverb + deep links | CONCLUÍDA |
| Fase 8 — Mandato (staff) | CONCLUÍDA |
| Fase 9 — Inteligência do mandato | CONCLUÍDA |
| Sprint 9.5 — Hardening produção | CONCLUÍDA |
| Sprint 10.1 — Equipe Virtual | CONCLUÍDA (Final) |
| Sprint 10.2 — Identidade / Auth / Multi-tenant | **FECHADA** |
| Sprint 10.4 — Central de Comunicação | **CONCLUÍDA** |
| Sprint 10.5 — Assistente Inteligente | **CONCLUÍDA** |
| Sprint 10.6 — Automação Inteligente | **CONCLUÍDA** |
| Sprint 10.7 — Painel Estratégico | **CONCLUÍDA** |
| Sprint 10.8 — Painel Parlamentar | **CONCLUÍDA** |
| Sprint 10.9 — Painel Obras | **CONCLUÍDA** |
| Sprint 11.0 | **Não iniciada** |

## Sprint 10.9 — Painel Obras

Hub próprio em **Mais → Painel Obras** (`/home/works`).

Namespace preparado `/v1/works/*` (ainda não publicado na VPS). Mapa territorial reusa mandato LIVE (`/v1/mandate/map`). Interface em PT-BR.

### Telas

Painel · Lista · Detalhes · Mapa · Linha do tempo · Fotos · Relatórios · Pesquisa · Filtros (locais nas listas).

### Domínios cobertos (UI + Models + Repo + Cache + EndpointPending)

| Recurso | Contrato preparado | Rota |
|---------|--------------------|------|
| Painel / Indicadores | `/v1/works/dashboard` | `/home/works/dashboard` |
| Obras | `/v1/works/projects` (+ `/{id}`) | `/home/works/list` |
| Demandas | `/v1/works/demands` | `/home/works/demands` |
| Fiscalizações | `/v1/works/inspections` | `/home/works/inspections` |
| Cronograma | `/v1/works/schedule` | `/home/works/schedule` |
| Mapa dedicado | `/v1/works/map` | `/home/works/map` (+ mandate map LIVE) |
| Linha do tempo | `/v1/works/timeline` | `/home/works/timeline` |
| Fotos | `/v1/works/photos` | `/home/works/photos` |
| Anexos | `/v1/works/attachments` | `/home/works/attachments` |
| Checklist | `/v1/works/checklist` | `/home/works/checklist` |
| Indicadores | `/v1/works/indicators` | `/home/works/indicators` |
| Relatórios | `/v1/works/reports` | `/home/works/reports` |
| Pesquisa | `/v1/works/search` | `/home/works/search` |

Cache: `pg_works_{tenant}_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://works|obras|painel-obras/...` (redirect GoRouter → `/home/works/...`).

**Nota:** não há tela dedicada “Visitas”; cobertura via **Fiscalizações**. Filtros são locais nas listas (query + status).

## Idioma (regra permanente)

Interface exclusivamente em **Português do Brasil**. Ver `.cursor/rules/pt-br-ui.mdc`.

## Qualidade

- `flutter analyze` / `flutter test` / APK + web + SM-A105M
- Nenhum emulador
- Sprint 11.0 não iniciada

## Repositório

- https://github.com/sergiocjr/poligestor_app
