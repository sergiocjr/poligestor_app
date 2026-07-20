# Fase 14 — Gestão Financeira do Mandato

Atualizado: 2026-07-20 (**CONCLUÍDA**)

## Escopo

Módulo completo de Gestão Financeira no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/finance/*`

Sem mocks. Sem alteração de backend neste repositório. Sem inventar APIs.

## Hub

**Mais → Gestão Financeira** (`/home/finance`)

## Probe VPS (2026-07-20, sem token) — sincronizado

| Path | Status | Hub |
|------|--------|-----|
| `/v1/finance/dashboard` | **LIVE** (401) | Painel financeiro |
| `/v1/finance/categories` | **LIVE** (401) | Categorias |
| `/v1/finance/cost-centers` | **LIVE** (401) | Centros de custo |
| `/v1/finance/alerts` | **LIVE** (401) | Alertas |
| `/v1/finance/reports` | **LIVE** (401) | Relatórios |
| `/v1/finance/accounts` | **LIVE** (401) | Contas bancárias |
| `/v1/finance/cashflow` | **LIVE** (401) | Fluxo de caixa |
| `/v1/finance/transactions` | **LIVE** (401) | Transações |
| `/v1/finance/payments` | **LIVE** (401) | Pagamentos |

Demais entradas do hub (ex.: `balance`, `revenues`, `exports`, …) ainda **404** → chip Em preparação + `EndpointPendingState` (fallback também se a VPS voltar a 404/405/501/503).

## Flutter

- Feature: `lib/features/finance/`
- Contratos: `kFinanceLiveSlugs` em `finance_contracts.dart`
- Cache: `pg_fin_{tenant}_*`
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://finance|financeiro|gestao-financeira|financas/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)

## Encerramento

Backend domínio concluído e sincronizado · Flutter consome LIVE disponíveis · A10 validado · documentação atualizada · commit/push nesta entrega.
