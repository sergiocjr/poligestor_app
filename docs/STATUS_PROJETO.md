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

Namespace oficial `/v1/grants/*` (probe 200 nos domínios principais; 404 em recursos, cronograma, anexos, indicadores e pesquisa). Interface em PT-BR.

### Telas

Painel · Lista · Detalhes · Pesquisa · Filtros (locais) · Linha do tempo · Anexos · Indicadores · Relatórios · Documentos · Recursos · Projetos · Execução · Prestação de Contas · Cronograma.

### Domínios (UI + Models + Repo + Cache)

| Recurso | Contrato LIVE | Rota | App |
|---------|---------------|------|-----|
| Painel / Indicadores | `/v1/grants/dashboard` | `/home/agreements/dashboard` | Ativo |
| Convênios | `/v1/grants/agreements` (+ `/{id}`) | `/home/agreements/list` | Ativo |
| Recursos | `/v1/grants/resources` | `/home/agreements/resources` | Pending |
| Projetos | `/v1/grants/projects` | `/home/agreements/projects` | Ativo |
| Execução | `/v1/grants/execution` | `/home/agreements/execution` | Ativo |
| Prestação de Contas | `/v1/grants/accountability` | `/home/agreements/accountability` | Ativo |
| Cronograma | `/v1/grants/schedule` | `/home/agreements/schedule` | Pending |
| Linha do tempo | `/v1/grants/timeline` | `/home/agreements/timeline` | Ativo |
| Documentos | `/v1/grants/documents` | `/home/agreements/documents` | Ativo |
| Anexos | `/v1/grants/attachments` | `/home/agreements/attachments` | Pending |
| Indicadores | `/v1/grants/indicators` | `/home/agreements/indicators` | Pending |
| Relatórios | `/v1/grants/reports` | `/home/agreements/reports` | Ativo |
| Pesquisa | `/v1/grants/search` | `/home/agreements/search` | Pending |

Cache: `pg_agree_{tenant}_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://agreements|convenios|painel-convenios/...`.

## Idioma (regra permanente)

Interface exclusivamente em **Português do Brasil**. Ver `.cursor/rules/pt-br-ui.mdc`.

## Qualidade

- `flutter analyze` / `flutter test` / APK + web + SM-A105M
- Nenhum emulador
- Sprint 11.1 não iniciada

## Repositório

- https://github.com/sergiocjr/poligestor_app
