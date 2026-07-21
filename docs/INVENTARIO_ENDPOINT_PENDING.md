# Inventário de contratos — sync final Flutter (2026-07-21)

Probe autenticado: `admin@demo.local` · tenant `demo` · artefato `.tmp_probe/probe_get_final.csv`.

| Métrica | Valor |
|---------|-------|
| Paths sondados | 502 |
| HTTP 200 | 239 |
| HTTP 404 | 221 |
| HTTP 405 | 29 |
| HTTP 403 | 11 |
| HTTP 422 | 2 |
| HTTP 500 | **0** |
| `EndpointPendingState` no código | **0** (substituído por `DemoExperiencePane`) |

## Critério de conclusão do sistema

| Critério | Status |
|----------|--------|
| Zero `EndpointPendingState` | **OK** |
| Zero HTTP 500 nos contratos sondados | **OK** |
| Zero consumo de `/v1/events/viewer` | **OK** (ausente em `lib/`; probe = 404) |
| Contratos LIVE (HTTP 200) consumidos via `k*LiveSlugs` | **OK** |
| Paths 404 restantes | Demonstração local **sem** HTTP (gate `*PathLive`) — **não** CONCLUÍDO global enquanto restarem 404 na VPS (ex.: `/v1/automations/*`) |

**Status formal:** sincronização Flutter **concluída** para contratos prioritários LIVE; sistema geral **EM ANDAMENTO** enquanto a VPS mantiver namespaces 404 (automações e subpaths).

## Exclusão explícita

| Método | Endpoint | HTTP | Ação Flutter |
|--------|----------|------|--------------|
| GET | `/v1/events/viewer` | 404 | **Não consumir** (colisão/rota indevida) |

## LiveSlugs (probe final)

| Módulo | LIVE | Observação |
|--------|-----:|------------|
| Works | 10 | Novo `works_contracts.dart` |
| Events | 11 | Sem `list` root; sem `viewer` |
| Documents | 4 | list/favorites/templates/search |
| Finance | 9 | |
| Communication | 5 | |
| CRM | 16 | |
| Elections | 14 | |
| Advanced AI | 13 | +405 POST-only |
| Admin | 19 | |
| Platform | 23 | |
| Security | 6 | |
| Integrations | 25 | |
| News | 6 | |
| Territorial | 7 | |
| Automations | 0 | Tudo 404 — demo sem HTTP |

## SoftNotice / UX

Namespaces `/v1/...` removidos dos SoftNotice dos hubs. Cards abrem telas (`onTap` / rotas). Telas 404 usam `DemoExperiencePane` (nunca brancas).
