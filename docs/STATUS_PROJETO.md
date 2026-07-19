# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 10.5 — Assistente Inteligente)

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
| Sprint 10.5 — Assistente Inteligente | **EM ENTREGA** |
| Sprint 10.6 | **Não iniciada** |

## Sprint 10.4 — Central de Comunicação

**STATUS: CONCLUÍDA.**

Produto exclusivo **PoliGestor/MandatoOS**. Isolamento absoluto: sem NexChat, NexISP, GestFin nem recursos compartilhados ONNEXIS.

### Integrado (contratos LIVE 200)

| Recurso | Contrato | App |
|---------|----------|-----|
| Canais | `GET /v1/channels` | Aba Canais |
| Templates | `GET /v1/templates`, `GET /v1/templates/{id}` | Lista + detalhe; filtros `channel_type`, `search` |
| Campanhas | `GET /v1/campaigns`, `GET /v1/campaigns/{id}` | Lista + detalhe; filtros `status`, `search`, `sort` |
| Conversas | `GET /v1/omnichannel/conversations` | Aba Conversas |
| Fila | `GET /v1/omnichannel/queue` | KPIs na aba Conversas |
| Operadores | `GET /v1/omnichannel/operators` | Lista na aba Conversas |

Cache offline: `CommunicationCache` (`pg_comms_*`). Refresh: `MandateRefreshController`.

Entrada: **Mais → Central de Comunicação** (`/home/communication`). Staff only. Deep link: `poligestor://communication/...`.

## Sprint 10.5 — Assistente Inteligente

Hub em **Mais → Assistente Inteligente** (`/home/chat`). Isolamento PoliGestor; regra LIVE-only permanente.

### LIVE

| Recurso | Contrato | Rota app |
|---------|----------|----------|
| Chat do Gabinete | `POST /v1/ai/chat` | `/home/chat/gabinete` |
| Histórico | `GET /v1/ai/conversations` | `/home/chat/history` |
| Briefings | `GET /v1/mandate/briefings` | `/home/chat/briefings` |
| Resumo do dia | `GET /v1/mandate/briefing` | `/home/chat/summary/daily` |
| Insights | `GET /v1/mandate/insights` | `/home/chat/insights` |

### Preparado (EndpointPendingState)

| Recurso | Path esperado |
|---------|---------------|
| Resumo semanal | `/v1/mandate/summary/weekly` |
| Sugestões | `/v1/mandate/suggestions` |
| Prioridades | `/v1/mandate/priorities` |
| Perguntas | `/v1/ai/questions` |
| Favoritos | `/v1/ai/favorites` |
| Compartilhar | `/v1/ai/share` |

Deep links: `poligestor://assistant|assistente|chat|ai/...`.

## Qualidade

- `flutter analyze` — 0 issues (Sprint 10.5)
- `flutter test` — **191 passed**
- APK debug + web + install **SM-A105M** (`RX8M70CLXKP`)
- Device: Hub Assistente Inteligente + EndpointPending (Sugestões) + Briefings LIVE
- Nenhum emulador

## Repositório

- https://github.com/sergiocjr/poligestor_app
- Tag anterior: `sprint-10.2-final` @ `d01613c`
