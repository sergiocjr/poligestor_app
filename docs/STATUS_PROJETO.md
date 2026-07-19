# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (Sprint 10.4 — Central de Comunicação)

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
| Sprint 10.4 — Central de Comunicação | **SINCRONIZADA** (LIVE omnichannel) |
| Sprint 10.5 | **Não iniciada** |

## Sprint 10.4 — Central de Comunicação

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

## Qualidade

- `flutter analyze` — 0 errors/warnings nos arquivos da sync
- `flutter test` — **185 passed**
- APK debug + install **SM-A105M** (`RX8M70CLXKP`)
- Device UI Conversas: fila KPIs + operadores LIVE + lista vazia honesta
- Nenhum emulador

## Repositório

- https://github.com/sergiocjr/poligestor_app
- Tag anterior: `sprint-10.2-final` @ `d01613c`
