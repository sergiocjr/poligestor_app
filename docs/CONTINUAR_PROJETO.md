# Continuar projeto — PoliGestor / MandatoOS (Flutter)

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase.

Atualizado: 2026-07-20

---

## Leitura obrigatória ao iniciar qualquer tarefa

1. `docs/CONTINUAR_PROJETO.md` (este arquivo)
2. `docs/STATUS_PROJETO.md` (STATUS do projeto)
3. `docs/CHANGELOG.md`
4. Últimos commits (`git log -5 --oneline`)

---

## Fase atual

| Campo | Valor |
|-------|--------|
| Fase | **Fase 14 — Gestão Financeira do Mandato** |
| Status formal | **CONCLUÍDA** |
| Hub | Mais → Gestão Financeira (`/home/finance`) |
| Namespace oficial | `/api/v1/finance/*` (sem aliases inventados) |
| Doc da fase | [FASE_14_GESTAO_FINANCEIRA.md](FASE_14_GESTAO_FINANCEIRA.md) |
| Fase 13 | **CONCLUÍDA** |
| Fase 12 | Flutter entregue (LIVE parcial); fechamento formal ainda pendente |
| Fase 11 | Flutter entregue; fechamento formal ainda pendente |
| Fase 15 | **Não iniciada** (bloqueada até pedido explícito) |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | `fdcd345` — conclui Fase 14 sync LIVE `/v1/finance/*` |
| Push | Sim (`origin/master`) |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- Gestão Financeira: Mais → hub `/home/finance`

---

## Telas (Fase 14)

Painel financeiro · Indicadores · Saldo · Receitas · Despesas · Transações · Pagamentos · Contas bancárias · Categorias · Centros de custo · Fornecedores · Contratos · Reembolsos · Adiantamentos · Verbas · Orçamento · Execução orçamentária · Prestação de contas · Comprovantes · Anexos · Aprovações · Conciliação · Fluxo de caixa · Contas a pagar · Contas a receber · Alertas · Histórico · Filtros · Pesquisa · Relatórios · Exportação.

Material 3 · cards clicáveis · PT-BR · responsivo (1 coluna no A10).

---

## Contratos LIVE consumidos (Fase 14)

| Método | Path | Status VPS |
|--------|------|------------|
| GET | `/v1/finance/dashboard` | **LIVE** (401 sem token) |
| GET | `/v1/finance/categories` | **LIVE** (401 sem token) |
| GET | `/v1/finance/cost-centers` | **LIVE** (401 sem token) |
| GET | `/v1/finance/alerts` | **LIVE** (401 sem token) |
| GET | `/v1/finance/reports` | **LIVE** (401 sem token) |
| GET | `/v1/finance/accounts` | **LIVE** (401; hub Contas bancárias) |
| GET | `/v1/finance/cashflow` | **LIVE** (401; hub Fluxo de caixa) |
| GET | `/v1/finance/transactions` | **LIVE** (401) |
| GET | `/v1/finance/payments` | **LIVE** (401) |

Paths do hub ainda sem rota publicada permanecem em `EndpointPendingState` (critério 3).

---

## Cache / Offline / Realtime

| Camada | Implementação |
|--------|----------------|
| Cache | `pg_fin_{tenant}_*` |
| Offline | Cache em falha de rede (quando houver payload) |
| Realtime | `MandateRefreshController` |

---

## Deep Links

```
poligestor://finance/...
poligestor://financeiro/...
poligestor://gestao-financeira/...
poligestor://financas/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 14 | **OK** (login + hub + chips Ativo + painel) |

---

## Pendências

1. Fechamento formal das Fases 11 e 12 (quando solicitado).
2. **Não iniciar Fase 15** sem pedido explícito.

## Próxima Fase

**Fase 15 — não iniciada.**