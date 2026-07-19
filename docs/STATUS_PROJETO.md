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
| **Sprint 10.1 — Equipe Virtual** | **CONCLUÍDA** |
| Fase 10+ (restante) | Em evolução |

## Sprint 10.1 — CONCLUÍDA

**STATUS: CONCLUÍDA.** Centro operacional da Equipe Virtual (staff).

### Entregue

- Feature `lib/features/virtual_team/` (models, cache, repository, telas)
- Entrada em **Mais → Equipe Virtual** (`/home/virtual-team/*`)
- Dashboard com KPIs; agentes (lista + detalhe por slug); tarefas; execuções; hand-offs (`/v1/ai/handoffs`); eventos; memória; aprendizado; fila
- Audit / logs / search preparados: UI honesta em 404 (`EndpointUnavailableException`), sem mocks
- Deep links `poligestor://virtual-team/...`
- Refresh via `MandateRefreshController` (resume/realtime)
- Paths em `AuthMode` (live + reservados)

### APIs integradas (HTTP 200 na VPS)

- `GET /v1/virtual-team/dashboard|agents|agents/{slug}|tasks|executions|events|memory|learning|queue`
- `GET /v1/ai/handoffs` (hand-offs — `/v1/virtual-team/handoffs` ainda ausente)

### Endpoints ausentes (backend)

Lista no CHANGELOG. Flutter já possui repository + telas prontas.

### Validação

- `flutter test` + `flutter analyze` (0 errors)

## Sprint 9.5 — CONCLUÍDA

**STATUS: CONCLUÍDA** (2026-07-19). Hardening de produção sem novas funcionalidades.

### Otimizações

- Refresh de inbox coalescida (in-flight)
- Debounce de eventos Reverb (450 ms) + throttle de `MandateRefreshController` (3 s)
- AppSync soft: sem segunda refresh / sem force FCM no resume
- Push não refresha inbox se Reverb estiver conectado
- Insights `generate=1` só no pull/primeiro load (não em every bump)

### Segurança / UX

- Token FCM em secure storage (migra prefs legado)
- CPF mascarado em cache e perfil
- Credenciais demo só em `kDebugMode`
- Itens mortos em Mais marcados “Em breve”; mapa wired
- Semantics em KPI/insights; dispose de push no teardown do app

### Validação

- `flutter test` 153 ok · analyze 0 errors · SM-A105M APK debug

## Fase 9 — CONCLUÍDA

### Entregue

- Aba **Inteligência** (staff) em `/home/intelligence/*`
- Dashboard: briefing, insights, tendências, oportunidades, alertas, prioridades
- Telas: briefing diário, insights, tendências, oportunidades, resumos (daily/weekly/monthly), análises (bairros/assuntos/equipe/produtividade)
- APIs exatas: `briefing`, `analytics`, `trends`, `insights(?generate=1)`, `briefings(?scope=)`
- Cache local carimbado; refresh no resume/realtime (via `MandateRefreshController`)
- Chat IA acessível em **Mais** (mantém bottom bar com 5 destinos)

### Validação

- Endpoints Fase 9 HTTP 200 na VPS
- `flutter test` + `flutter analyze` (0 errors)
- APK debug no SM-A105M (`RX8M70CLXKP`)

### Limitações reais

- Histórico `briefings` pode vir vazio até jobs `Daily/Weekly/MonthlyBriefJob` persistirem bullets
- “Sugestão” nos insights é rótulo de UX derivado do `type` (payload não traz campo `action`)
- Sem endpoint dedicado de oportunidades — tela filtra insights relevantes
- iOS / tablet físico não validados nesta fase (layout wide testado logicamente no painel TV da Fase 8)

## Fase 8 — CONCLUÍDA

**STATUS: CONCLUÍDA.** Gestão do mandato staff (`/v1/mandate/*` operacionais).
