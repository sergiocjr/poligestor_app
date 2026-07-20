# Fase 14 — Gestão Financeira do Mandato

Atualizado: 2026-07-20

## Escopo

Módulo completo de Gestão Financeira no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/finance/*`

Sem aliases. Sem mocks. Sem alteração de backend. Sem inventar APIs.

## Hub

**Mais → Gestão Financeira** (`/home/finance`)

## Probe VPS (2026-07-20, sem token)

Todos os paths `/v1/finance/*` retornaram **404**. UI completa com `EndpointPendingState`.

| Path | Status |
|------|--------|
| `/v1/finance/dashboard` | Preparado (404) |
| `/v1/finance/indicators` | Preparado (404) |
| `/v1/finance/balance` | Preparado (404) |
| `/v1/finance/revenues` | Preparado (404) |
| `/v1/finance/expenses` | Preparado (404) |
| `/v1/finance/bank-accounts` | Preparado (404) |
| `/v1/finance/categories` | Preparado (404) |
| `/v1/finance/cost-centers` | Preparado (404) |
| `/v1/finance/suppliers` | Preparado (404) |
| `/v1/finance/contracts` | Preparado (404) |
| `/v1/finance/refunds` | Preparado (404) |
| `/v1/finance/advances` | Preparado (404) |
| `/v1/finance/funds` | Preparado (404) |
| `/v1/finance/budget` | Preparado (404) |
| `/v1/finance/budget-execution` | Preparado (404) |
| `/v1/finance/accountability` | Preparado (404) |
| `/v1/finance/receipts` | Preparado (404) |
| `/v1/finance/attachments` | Preparado (404) |
| `/v1/finance/approvals` | Preparado (404) |
| `/v1/finance/reconciliation` | Preparado (404) |
| `/v1/finance/cash-flow` | Preparado (404) |
| `/v1/finance/payables` | Preparado (404) |
| `/v1/finance/receivables` | Preparado (404) |
| `/v1/finance/alerts` | Preparado (404) |
| `/v1/finance/history` | Preparado (404) |
| `/v1/finance/filters` | Preparado (404) |
| `/v1/finance/search` | Preparado (404) |
| `/v1/finance/reports` | Preparado (404) |
| `/v1/finance/exports` | Preparado (404) |

Quando a VPS publicar HTTP 200 (ou 401 sem token = LIVE), marcar chips **Ativo** e remover `EndpointPendingState` do fluxo.

## Flutter

- Feature: `lib/features/finance/`
- Cache: `pg_fin_{tenant}_*`
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://finance|financeiro|gestao-financeira|financas/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)

## Critério de encerramento

Ver 15 critérios em `.cursor/rules/fases-completas.mdc`. Backend ainda 404 → Fase **não fechada formalmente**.
