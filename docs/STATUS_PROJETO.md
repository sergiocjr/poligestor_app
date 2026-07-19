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
| **Fase 9 — Inteligência do mandato** | **CONCLUÍDA** |
| **Sprint 9.5 — Hardening produção** | **CONCLUÍDA** |
| Fase 10+ | Não iniciada |

## Fase 8 — CONCLUÍDA

**STATUS: CONCLUÍDA.** Gestão do mandato staff (`/v1/mandate/*` operacionais).

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

## Fase 10+

Não iniciada.
