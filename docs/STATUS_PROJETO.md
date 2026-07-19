# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 11.0 — Painel de Convênios CONCLUÍDA)

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
| Sprint 11.0 — Painel de Convênios | **CONCLUÍDA** |
| Sprint 11.1 | **Não iniciada** |

## Sprint 11.0 — Painel de Convênios

Hub próprio em **Mais → Painel de Convênios** (`/home/agreements`).

Namespace preparado `/v1/agreements/*` (ainda não publicado na VPS — probe 404). Interface em PT-BR.

### Telas

Painel · Lista · Detalhes · Pesquisa · Filtros (locais) · Linha do tempo · Anexos · Indicadores · Relatórios · Documentos · Recursos · Projetos · Execução · Prestação de Contas · Cronograma.

### Domínios (UI + Models + Repo + Cache + EndpointPending)

| Recurso | Contrato preparado | Rota |
|---------|--------------------|------|
| Painel / Indicadores | `/v1/agreements/dashboard` | `/home/agreements/dashboard` |
| Convênios | `/v1/agreements/agreements` (+ `/{id}`) | `/home/agreements/list` |
| Recursos | `/v1/agreements/resources` | `/home/agreements/resources` |
| Projetos | `/v1/agreements/projects` | `/home/agreements/projects` |
| Execução | `/v1/agreements/execution` | `/home/agreements/execution` |
| Prestação de Contas | `/v1/agreements/accountability` | `/home/agreements/accountability` |
| Cronograma | `/v1/agreements/schedule` | `/home/agreements/schedule` |
| Linha do tempo | `/v1/agreements/timeline` | `/home/agreements/timeline` |
| Documentos | `/v1/agreements/documents` | `/home/agreements/documents` |
| Anexos | `/v1/agreements/attachments` | `/home/agreements/attachments` |
| Indicadores | `/v1/agreements/indicators` | `/home/agreements/indicators` |
| Relatórios | `/v1/agreements/reports` | `/home/agreements/reports` |
| Pesquisa | `/v1/agreements/search` | `/home/agreements/search` |

Cache: `pg_agree_{tenant}_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://agreements|convenios|painel-convenios/...`.

## Idioma (regra permanente)

Interface exclusivamente em **Português do Brasil**. Ver `.cursor/rules/pt-br-ui.mdc`.

## Qualidade

- `flutter analyze` / `flutter test` / APK + web + SM-A105M
- Nenhum emulador
- Sprint 11.1 não iniciada

## Repositório

- https://github.com/sergiocjr/poligestor_app
