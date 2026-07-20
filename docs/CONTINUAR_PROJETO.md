# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (encerramento do dia — Fase 14 CONCLUÍDA; Fase 15 **não iniciada**)

---

## Leitura obrigatória ao iniciar qualquer tarefa

1. **`docs/CONTINUAR_PROJETO.md`** (este arquivo) — **sempre primeiro**
2. `docs/STATUS_PROJETO.md`
3. `docs/CHANGELOG.md`
4. Últimos commits: `git log -5 --oneline`
5. Regras: `.cursor/rules/live-only-apis.mdc`, `fases-completas.mdc`, `flutter-device-a10.mdc`, `pt-br-ui.mdc`

---

## Snapshot do dia (2026-07-20)

| Campo | Valor |
|-------|--------|
| Fase encerrada hoje | **Fase 14 — Gestão Financeira do Mandato** → **CONCLUÍDA** |
| Próxima Fase | **15 — Comunicação Institucional** (**não iniciar** sem pedido explícito) |
| Branch | `master` |
| Push | **Sim** (`origin/master`) |
| Dispositivo | SM-A105M `RX8M70CLXKP` (sem emulador) |

### Últimos commits

| Hash | Mensagem |
|------|----------|
| `1483c10` | docs: corrige encoding e hash fdcd345 no CONTINUAR_PROJETO |
| `fdcd345` | feat: conclui Fase 14 com sync LIVE /v1/finance/* |
| `0f1f010` | docs: atualiza CONTINUAR_PROJETO com hash da Fase 14 |
| `360128e` | feat: Fase 14 Gestão Financeira com namespace /v1/finance/* |
| `066c38a` | fix: sincroniza Fase 13 com contratos LIVE /v1/documents/* |

---

## Qualidade (rodado no encerramento do dia)

| Item | Resultado |
|------|-----------|
| `flutter analyze --no-fatal-infos` | **OK** — 0 errors, 0 warnings, 37 infos pré-existentes |
| `flutter test` (Fase 13 + 14) | **OK** — 15/15 testes passaram |
| `flutter build web --release` | **OK** — `build/web` gerado |
| APK debug | **OK** — `build/app/outputs/flutter-apk/app-debug.apk` (~181 MB, 2026-07-20 02:52) |
| Validação A10 | **OK** — install `-r`, login staff Admin Demo, hub Gestão Financeira, chips **Ativo** nos LIVE, Painel financeiro abriu, sem overflow/emulador |

---

## Status formal das Fases

| Fase | Status |
|------|--------|
| 11 — Gestão Institucional (Eventos) | EM ANDAMENTO (Flutter entregue; fechamento formal pendente) |
| 12 — Inteligência Territorial | EM ANDAMENTO (LIVE parcial) |
| 13 — Gestão Documental | **CONCLUÍDA** |
| 14 — Gestão Financeira | **CONCLUÍDA** |
| 15 — Comunicação Institucional | **Não iniciada** |

---

## Telas implementadas até a Fase 14

### Gabinete (shell)
Gabinete (painel) · Protocolos · Agenda · Mandato · Mais

### Mais (hubs de domínio até F14)
- Assistente Inteligente · Equipe Virtual · Central de Automação
- Painel Estratégico · Painel Parlamentar · Painel Obras · Painel de Convênios · Painel de Eventos
- **Gestão Financeira** · **Gestão Documental** · **Inteligência Territorial** · Central de Comunicação

### Fase 14 — Gestão Financeira (`/home/finance`)
Painel financeiro · Indicadores · Saldo · Receitas · Despesas · **Transações** · **Pagamentos** · Contas bancárias · Categorias · Centros de custo · Fornecedores · Contratos · Reembolsos · Adiantamentos · Verbas · Orçamento · Execução orçamentária · Prestação de contas · Comprovantes · Anexos · Aprovações · Conciliação · Fluxo de caixa · Contas a pagar · Contas a receber · Alertas · Histórico · Filtros · Pesquisa · Relatórios · Exportação

### Fase 13 — Gestão Documental (`/home/documents`)
Lista · Pesquisa · Filtros · Categorias · Favoritos · Histórico · Linha do tempo · Visualizador · Assinaturas · Aprovações · Compartilhamento · Modelos · Download · Upload · Anexos

### Fase 12 — Inteligência Territorial (`/home/territorial-intelligence`)
Painel BI e demais entradas do hub (LIVE parcial / Pending conforme probe)

Material 3 · cards clicáveis · PT-BR · responsivo (1 coluna no A10).

---

## Contratos LIVE consumidos (Fase 14)

Namespace: `https://poligestor.onnexis.com.br/api/v1/finance/*`

| Método | Path | Hub / uso |
|--------|------|-----------|
| GET | `/v1/finance/dashboard` | Painel financeiro |
| GET | `/v1/finance/categories` | Categorias |
| GET | `/v1/finance/cost-centers` | Centros de custo |
| GET | `/v1/finance/alerts` | Alertas |
| GET | `/v1/finance/reports` | Relatórios |
| GET | `/v1/finance/accounts` | Contas bancárias |
| GET | `/v1/finance/cashflow` | Fluxo de caixa |
| GET | `/v1/finance/transactions` | Transações |
| GET | `/v1/finance/payments` | Pagamentos |

Chips **Ativo** nesses slugs (`kFinanceLiveSlugs`).

### Também LIVE (Fase 13, referência)
Namespace `/v1/documents/*` — hub documental completo (probe 401).

---

## EndpointPendingState restantes (Fase 14)

Ainda **404** na VPS (chip **Em preparação** + `EndpointPendingState` ao abrir):

`indicators`, `balance`, `revenues`, `expenses`, `suppliers`, `contracts`, `refunds`, `advances`, `funds`, `budget`, `budget-execution`, `accountability`, `receipts`, `attachments`, `approvals`, `reconciliation`, `payables`, `receivables`, `history`, `filters`, `search`, `exports`

Fallback: qualquer LIVE que volte a responder 404/405/501/503.

Fases 11/12 ainda têm paths Pending próprios (ver docs das fases).

---

## Cache / Offline / Realtime (F14)

| Camada | Implementação |
|--------|----------------|
| Cache | `pg_fin_{tenant}_*` |
| Offline | Cache em falha de rede (quando houver payload) |
| Realtime | `MandateRefreshController` |

Deep links: `poligestor://finance|financeiro|gestao-financeira|financas/...`

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação Fase 14 | **Concluída com sucesso** (login, navegação Mais → Gestão Financeira, LIVE/Pending, sem overflow) |

---

## Próxima Fase

### Fase 15 — Comunicação Institucional

- **Status:** não iniciada
- **Não implementar** até pedido explícito do dono do projeto
- Antes de começar: reler este arquivo + regras LIVE-only + validar contratos na VPS

---

## Checklist para retomada amanhã

1. [ ] Ler **obrigatoriamente** `docs/CONTINUAR_PROJETO.md` (este arquivo)
2. [ ] Ler `docs/STATUS_PROJETO.md` e `docs/CHANGELOG.md`
3. [ ] `git pull` e `git log -5 --oneline`
4. [ ] Confirmar A10: `adb devices` → `RX8M70CLXKP` (sem emulador)
5. [ ] Se for Fase 15: **aguardar pedido explícito**; probe VPS do namespace oficial antes de codar
6. [ ] Não inventar APIs; só LIVE `https://poligestor.onnexis.com.br/api`
7. [ ] UI 100% PT-BR; limpar Gradle/Java ao terminar (`scripts/flutter_cleanup.ps1`)
8. [ ] Pendências abertas (fora F15): fechamento formal Fases 11 e 12, se solicitado

---

## Git (estado ao encerrar o dia)

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| HEAD | `8100a21` — continuidade do dia |
| Push | Sim (`origin/master`) |