# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 10.7 — Painel Estratégico CONCLUÍDA)

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
| Sprint 10.8 | **Não iniciada** |

## Sprint 10.7 — Painel Estratégico

Hub próprio em **Mais → Painel Estratégico** (`/home/strategy`).

Namespace LIVE `/v1/strategy/*`. Reuso de mapa/bairros/relatórios do Mandato e atalhos para Inteligência, sem duplicar regra de negócio.

### LIVE

| Recurso | Contrato | Rota |
|---------|----------|------|
| Dashboard / KPIs | `/v1/strategy/kpis` (+ fallback se dashboard 500) | `/home/strategy/dashboard`, `/kpis` |
| Heatmap | `/v1/strategy/heatmap` | `/home/strategy/heatmap` |
| Tendências | `/v1/strategy/trends` | `/home/strategy/trends` |
| Alertas | `/v1/strategy/alerts` | `/home/strategy/alerts` |
| Regiões | `/v1/strategy/regions` | `/home/strategy/regions` |
| Bairros | `/v1/strategy/neighborhoods` | `/home/strategy/neighborhoods` |
| Previsões | `/v1/strategy/forecasts` | `/home/strategy/forecasts` |
| Relatórios | `/v1/strategy/reports` | `/home/strategy/reports` |
| Mapa (reuse) | `/v1/mandate/map` | `/home/strategy/map` → mapa mandato |

### Preparado (EndpointPending)

| Recurso | Path |
|---------|------|
| Metas | `/v1/strategy/goals` (404/500) |
| Comparativos | `/v1/strategy/compare` |
| Indicadores dedicados | `/v1/strategy/indicators` |
| Predições | `/v1/strategy/predictions` |
| Mapa dedicado | `/v1/strategy/map` |

Cache tenant: `pg_strategy_{tenant}_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://strategy|estrategia|strategic|painel-estrategico/...`.

## Qualidade

- `flutter analyze` / `flutter test` / APK + web + SM-A105M
- Nenhum emulador
- Sprint 10.8 não iniciada

## Repositório

- https://github.com/sergiocjr/poligestor_app
