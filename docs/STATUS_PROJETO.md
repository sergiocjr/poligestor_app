# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 10.6 — CONCLUÍDA)

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
| Sprint 10.7 | **Não iniciada** |

## Sprint 10.6 — Central de Automação

Hub próprio em **Mais → Central de Automação** (`/home/automation`).

Reusa contratos LIVE da Equipe Virtual para operação (dashboard/execuções/alertas/agentes/logs/métricas/timeline). Namespace dedicado `/v1/automations*` ainda 404 → UI + `EndpointPendingState`.

### LIVE (via `/v1/virtual-team/*` + `/v1/ai/team`)

| Recurso | Contrato | Rota |
|---------|----------|------|
| Dashboard KPIs | dashboard + alerts + queue | `/home/automation/dashboard` |
| Execuções | executions | `/home/automation/executions` |
| Alertas | alerts | `/home/automation/alerts` |
| Agentes | agents | `/home/automation/agents` → detalhe VT |
| Histórico | timeline | `/home/automation/history` |
| Logs | logs | `/home/automation/logs` |
| Métricas | metrics | `/home/automation/metrics` |
| Autonomia (leitura) | `/v1/ai/team` | `/home/automation/autonomy` |

### Preparado (EndpointPending)

| Recurso | Path |
|---------|------|
| Automações / editor / detalhe | `/v1/automations` |
| Aprovações | `/v1/automations/approvals` |
| Agenda | `/v1/automations/schedule` |
| Escrita autonomia | `/v1/automations/autonomy` |

Cache tenant: `pg_auto_{tenant}_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://automation|automacao|automations/...`.

## Qualidade

- `flutter analyze` / `flutter test` / APK + web + SM-A105M
- Nenhum emulador
- Sprint 10.7 não iniciada

## Repositório

- https://github.com/sergiocjr/poligestor_app
