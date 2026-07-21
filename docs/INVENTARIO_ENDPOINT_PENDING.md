# Inventário de contratos — sync Flutter × VPS (2026-07-21)

Catálogo oficial: backend **c29c2ad** · commit Flutter **`a528f15`** · versão **1.0.0+6**.

| Métrica | Valor |
|---------|-------|
| `EndpointPendingState` no código | **0** |
| `/v1/events/viewer` | **não consumido** |
| Chips hub “Demonstração” / “Em preparação” | **0** |
| Injeção demo em lista LIVE vazia | **desligada** |
| Namespace automação Flutter | `/v1/automation/*` (singular) |

## Critério de conclusão do sistema

| Critério | Status |
|----------|--------|
| Zero `EndpointPendingState` | **OK** |
| Zero consumo de `/v1/events/viewer` | **OK** |
| Hubs sem UX “aguardando VPS” | **OK** (2026-07-21) |
| AuthMode alinhado ao catálogo c29c2ad | **OK** |
| Validação visual A10 de todos os hubs | **Pendente** |
| Aceite formal Fases 11–21, 24 | **Pendente** |

**Status formal:** sincronização Flutter **concluída** para catálogo c29c2ad; produto **EM ANDAMENTO** até homologação visual completa e publicação loja.

## LiveSlugs por módulo (pós-sync)

| Módulo | Slugs LIVE | Observação |
|--------|----------:|------------|
| Automação | 19 | `/v1/automation/dashboard` 200; `autonomy-write` sem POST |
| Admin | 35 | `offices` → `/cabinets` |
| Plataforma | 34 | `operators`, `usage`, `settings/global` |
| Segurança | 44 | `mfa` unificado; `export-me`, `policies` |
| CRM | 38 | vários cards → `/contacts` |
| Eleições | 48 | zones, sections, polling-places, vendors |
| Financeiro | 31 | payees, budgets, audit |
| Documentos | 29 | files, tags, tipos oficiais |
| Inteligência | 26 | heatmaps, maps, *-by-region |
| IA avançada | 31 | `/ai/dashboard` (não `/ai/hub/dashboard`) |
| Integrações | 30 | search/filters marcados LIVE |
| Eventos | 22 | hearings, invitations, statistics |
| Comunicação | 16 | schedules, audit |
| Obras | 13 | lista raiz `/v1/works` |
| Notícias | 12 | recent/feed com fallback local se 404 |

## Aliases AuthMode (UI slug → path VPS)

Exemplos validados com HTTP 200:

- `financeSuppliersPath` → `/v1/finance/payees`
- `parliamentPromisesPath` → `/v1/parliament/campaign-promises`
- `automationsRootPath` → `/v1/automation/rules`
- `advancedAiDashboardPath` → `/v1/ai/dashboard`
- `eventsListPath` → `/v1/events/events`

Lista completa: `lib/core/auth/auth_mode.dart`.

## Dados de demonstração

- **Não** preenche listas LIVE vazias.
- API com `meta.demo=true` → rótulo “Dados de referência”.
- Módulo `lib/shared/demo/*` mantido para compatibilidade; UX principal não exibe “aguardando contrato”.

## Exclusão explícita

| Endpoint | Ação Flutter |
|----------|--------------|
| `GET /v1/events/viewer` | **Proibido** |
