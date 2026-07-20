# Continuar projeto ? PoliGestor / MandatoOS (Flutter)

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
| Fase | **Fase 14 ? Gestão Financeira do Mandato** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; `/v1/finance/*` 100% 404 ? Pending) |
| Hub | Mais ? Gestão Financeira (`/home/finance`) |
| Namespace oficial | `/api/v1/finance/*` (sem aliases) |
| Doc da fase | [FASE_14_GESTAO_FINANCEIRA.md](FASE_14_GESTAO_FINANCEIRA.md) |
| Fase 13 | **CONCLUÍDA** (documentos LIVE sincronizados) |
| Fase 12 | Flutter entregue (LIVE parcial); fechamento formal ainda pendente |
| Fase 11 | Flutter entregue; fechamento formal ainda pendente |
| Fase 15 | **Bloqueada** |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | ver `git log` (Fase 14) |
| Push | Sim (`origin/master`) |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- Gestão Financeira: Mais ? hub `/home/finance`

---

## Telas (Fase 14)

Painel financeiro · Indicadores · Saldo · Receitas · Despesas · Contas bancárias · Categorias · Centros de custo · Fornecedores · Contratos · Reembolsos · Adiantamentos · Verbas · Orçamento · Execução orçamentária · Prestação de contas · Comprovantes · Anexos · Aprovações · Conciliação · Fluxo de caixa · Contas a pagar · Contas a receber · Alertas · Histórico · Filtros · Pesquisa · Relatórios · Exportação.

Material 3 · cards clicáveis · PT-BR · responsivo (1 coluna no A10).

---

## Contratos LIVE consumidos (Fase 14)

| Método | Path | Status VPS |
|--------|------|------------|
| ? | `/v1/finance/*` | **Nenhum LIVE** (todos 404 em 2026-07-20) |

---

## EndpointPendingState

Todos os paths do hub `/v1/finance/{dashboard,indicators,balance,revenues,expenses,bank-accounts,categories,cost-centers,suppliers,contracts,refunds,advances,funds,budget,budget-execution,accountability,receipts,attachments,approvals,reconciliation,cash-flow,payables,receivables,alerts,history,filters,search,reports,exports}`.

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
| Dispositivo oficial | SM-A105M ? `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 14 | APK debug instalado nesta entrega |

---

## Pendências reais (fechamento formal)

1. Backend publicar `/v1/finance/*`.
2. PHPUnit do domínio no backend.
3. Auditoria Backend ? Flutter após HTTP 200.
4. Fechamento formal das Fases 11 e 12.

## Próxima Fase

**Fase 15 ? bloqueada** até os 15 critérios da Fase 14.
