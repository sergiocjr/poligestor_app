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

## Fase 10+

Não iniciada.
