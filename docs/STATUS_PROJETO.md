# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 10.8 — Painel Parlamentar CONCLUÍDA)

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
| Sprint 10.9 | **Não iniciada** |

## Sprint 10.8 — Painel Parlamentar

Hub próprio em **Mais → Painel Parlamentar** (`/home/parliament`).

Namespace LIVE `/v1/parliament/*`. Interface em PT-BR.

### LIVE

| Recurso | Contrato | Rota |
|---------|----------|------|
| Painel | `/v1/parliament/dashboard` | `/home/parliament/dashboard` |
| Projetos de Lei | `/v1/parliament/bills` (+ detalhe) | `/home/parliament/bills` |
| Projetos | `/v1/parliament/projects` | `/home/parliament/projects` |
| Indicações | `/v1/parliament/indications` | `/home/parliament/indications` |
| Requerimentos | `/v1/parliament/requests` | `/home/parliament/requests` |
| Moções | `/v1/parliament/motions` | `/home/parliament/motions` |
| Emendas | `/v1/parliament/amendments` | `/home/parliament/amendments` |
| Agenda / Sessões / Votações | agenda, sessions, votes | rotas correspondentes |
| Base de Apoio / Demandas | support-base, demands | rotas correspondentes |
| Pesquisa | busca local + pending `/search` | `/home/parliament/search` |

### Preparado (EndpointPending)

| Recurso | Path |
|---------|------|
| Promessas | `/v1/parliament/promises` |
| Pesquisa dedicada | `/v1/parliament/search` |
| Linha do tempo | `/v1/parliament/timeline` |
| Histórico | `/v1/parliament/history` |
| Anexos | `/v1/parliament/attachments` |

Cache: `pg_parl_{tenant}_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://parliament|parlamentar|legislativo|painel-parlamentar/...`.

## Idioma (regra permanente)

Interface exclusivamente em **Português do Brasil**. Ver `.cursor/rules/pt-br-ui.mdc`.

## Qualidade

- `flutter analyze` / `flutter test` / APK + web + SM-A105M
- Nenhum emulador
- Sprint 10.9 não iniciada

## Repositório

- https://github.com/sergiocjr/poligestor_app
