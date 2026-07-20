# Fase 18 — IA Avançada

Atualizado: 2026-07-20

## Escopo

Módulo completo de IA Avançada no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/ai/*`

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

Independente do Sprint 10.5 Assistente Inteligente (`/home/chat`).

## Hub

**Mais → IA Avançada** (`/home/advanced-ai`)

## Telas

Conversa com IA · Conversas · Secretária Virtual · Assessor Parlamentar · Analista Político · Analista Financeiro · Assessor de Comunicação · Assessor Jurídico · Planejamento estratégico · Resumos do dia · Resumos · Sugestões inteligentes · Histórico · Biblioteca de prompts · Avaliação · Configurações · Pesquisa

## Auditoria VPS (2026-07-20, autenticado)

### Endpoints dedicados LIVE

| Path | Método | Status |
|------|--------|--------|
| `/v1/ai/chat` | POST | LIVE (201) |
| `/v1/ai/conversations` | GET | LIVE (200) |
| `/v1/ai/history` | GET | LIVE (200) |
| `/v1/ai/briefings` | GET | LIVE (200) |
| `/v1/ai/prompts` | GET | LIVE (200) |
| `/v1/ai/agents` | GET | LIVE (200) |
| `/v1/ai/summary` | POST | LIVE (422 sem corpo válido / rota ativa) |
| `/v1/ai/suggestions` | POST | LIVE (422 sem corpo válido / rota ativa) |
| `/v1/ai/feedback` | POST | LIVE (201) |
| `/v1/ai/team` | GET | LIVE (200) — fora do hub |
| `/v1/ai/handoffs` | GET | LIVE (200) — fora do hub |

### Papéis via `GET /v1/ai/agents` + `POST /v1/ai/chat`

| Hub | agent_slug | Status |
|-----|------------|--------|
| Secretária Virtual | `secretary` | Ativo |
| Assessor Parlamentar | `parliamentary_advisor` | Ativo |
| Analista Político | `analyst` | Ativo |
| Assessor de Comunicação | `communication` | Ativo |
| Assessor Jurídico | `legal` | Ativo |
| Planejamento estratégico | `strategy` | Ativo |

### Em preparação (`EndpointPendingState`)

| Path | Status |
|------|--------|
| `/v1/ai/financial-analyst` | 404 (sem agente no catálogo) |
| `/v1/ai/settings` | 404 |
| `/v1/ai/search` | 404 |
| `/v1/ai/secretary` (path dedicado) | 404 — UI usa `/agents` |
| demais paths dedicados de papéis | 404 — UI usa `/agents` |

## Flutter

- Feature: `lib/features/advanced_ai/`
- Cache: `pg_aai_{tenant}_*`
- Offline: cache em falha de rede
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://advanced-ai|ia-avancada|ia_avancada/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)

## Status formal

**EM ANDAMENTO** (Flutter entregue; sync LIVE parcial).

Validação A10 (`RX8M70CLXKP`): hub + Conversa OK.

**Fase 19 — não iniciada.**
