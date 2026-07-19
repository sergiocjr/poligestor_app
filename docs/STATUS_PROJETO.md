# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19

## Resumo

| Área | Status |
|------|--------|
| Auth dual (staff / portal) | Concluído |
| Portal do cidadão | Concluído |
| Protocolos / conversa / avaliação | Concluído |
| Assistente IA (via Laravel) | Concluído |
| Fase 7 — FCM + Reverb + deep links | CONCLUÍDA |
| Fase 8 — Mandato (staff) | CONCLUÍDA |
| Fase 9 — Inteligência do mandato | CONCLUÍDA |
| Sprint 9.5 — Hardening produção | CONCLUÍDA |
| **Sprint 10.1 — Equipe Virtual** | **CONCLUÍDA (Final)** |
| Fase 10+ (restante) | Em evolução |

## Sprint 10.1 — CONCLUÍDA (Final)

**STATUS: CONCLUÍDA.** Integração completa da Equipe Virtual com todos os contratos REST da VPS.

### Entregue

- Feature `lib/features/virtual_team/` completa
- Entrada **Mais → Equipe Virtual** (`/home/virtual-team/*`)
- Dashboard (root + KPIs + alertas + hand-offs recentes)
- Agentes + detalhe com sub-rotas (`tasks|executions|logs|metrics|timeline`)
- Tarefas, execuções, hand-offs, eventos, memória, aprendizado, fila
- Timeline, alertas, métricas, auditoria, logs, pesquisa
- Refresh via `MandateRefreshController` (resume + Reverb)
- Deep links `poligestor://virtual-team/...`
- Sem mocks; sem estados “endpoint indisponível”

### APIs consumidas (HTTP 200)

- `GET /v1/virtual-team` (root)
- `GET /v1/virtual-team/dashboard|agents|agents/{slug}`
- `GET /v1/virtual-team/agents/{slug}/{tasks,executions,logs,metrics,timeline}`
- `GET /v1/virtual-team/tasks|executions|events|memory|learning|queue`
- `GET /v1/virtual-team/logs|audit|search|metrics|timeline|alerts|handoffs`

### Validação

- `flutter test` + `flutter analyze` (0 errors)
