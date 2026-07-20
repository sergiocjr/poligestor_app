# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 17 — Gestão Eleitoral: 14 LIVE + 31 Pending; fechamento formal pendente)

---

## Leitura obrigatória ao iniciar qualquer tarefa

1. **`docs/CONTINUAR_PROJETO.md`** (este arquivo) — **sempre primeiro**
2. `docs/STATUS_PROJETO.md`
3. `docs/CHANGELOG.md`
4. Últimos commits: `git log -5 --oneline`
5. Regras: `.cursor/rules/live-only-apis.mdc`, `fases-completas.mdc`, `flutter-device-a10.mdc`, `pt-br-ui.mdc`

---

## Fase atual

| Campo | Valor |
|-------|--------|
| Fase | **Fase 17 — Gestão Eleitoral** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; 14 LIVE / 31 Pending) |
| Hub | Mais → Gestão Eleitoral (`/home/elections`) |
| Namespace oficial | `/api/v1/elections/*` |
| Doc da fase | [FASE_17_GESTAO_ELEITORAL.md](FASE_17_GESTAO_ELEITORAL.md) |
| Fase 16 | **EM ANDAMENTO** (Flutter entregue; `/v1/crm/*` 404) |
| Fase 15 | **EM ANDAMENTO** (Flutter entregue; `/v1/communication/*` 404) |
| Fase 14 | **CONCLUÍDA** |
| Fase 13 | **CONCLUÍDA** |
| Fases 11–12 | Flutter entregue; fechamento formal ainda pendente |
| Fase 18 | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | (pendente — entrega Fase 17) |
| Push | Pendente |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- Gestão Eleitoral: Mais → hub `/home/elections`
- CRM Político: Mais → hub `/home/crm`
- Comunicação Institucional: Mais → hub `/home/institutional-communication`
- Central de Comunicação (Sprint 10.4): Mais → `/home/communication` (namespace distinto)

---

## Telas (Fase 17)

Painel eleitoral · Pré-campanha · Campanhas · Candidatos · Coordenação · Equipes · Cabos eleitorais · Voluntários · Lideranças · Apoiadores · Metas eleitorais · Regiões · Bairros · Zonas eleitorais · Seções eleitorais · Colégios eleitorais · Mapa eleitoral · Agenda de campanha · Eventos · Caminhadas · Reuniões · Visitas · Comícios · Mobilizações · Materiais de campanha · Estoque · Distribuição · Solicitações de material · Pesquisas eleitorais · Cenários · Intenção de voto · Rejeição · Comparativos · Projeções · Desempenho por região · Prestação de contas · Receitas · Despesas · Doações · Fornecedores · Comprovantes · Relatórios · Exportações · Pesquisa · Filtros.

Material 3 · cards clicáveis · PT-BR · responsivo (1 coluna no A10) · cache `pg_elec_*` · offline · realtime (`MandateRefreshController`).

---

## Contratos LIVE consumidos (Fase 17)

| Método | Path | Status VPS |
|--------|------|------------|
| GET | `/v1/elections/dashboard` | LIVE (401) |
| GET | `/v1/elections/campaigns` | LIVE (401) |
| GET | `/v1/elections/candidates` | LIVE (401) |
| GET | `/v1/elections/teams` | LIVE (401) |
| GET | `/v1/elections/goals` | LIVE (401) |
| GET | `/v1/elections/regions` | LIVE (401) |
| GET | `/v1/elections/neighborhoods` | LIVE (401) |
| GET | `/v1/elections/map` | LIVE (401) |
| GET | `/v1/elections/events` | LIVE (401) |
| GET | `/v1/elections/material-requests` | LIVE (401) |
| GET | `/v1/elections/projections` | LIVE (401) |
| GET | `/v1/elections/accountability` | LIVE (401) |
| GET | `/v1/elections/receipts` | LIVE (401) |
| GET | `/v1/elections/reports` | LIVE (401) |

---

## EndpointPendingState (31)

`pre-campaign`, `coordination`, `canvassers`, `volunteers`, `leaders`, `supporters`, `electoral-zones`, `electoral-sections`, `polling-stations`, `campaign-agenda`, `walks`, `meetings`, `visits`, `rallies`, `mobilizations`, `campaign-materials`, `inventory`, `distribution`, `polls`, `scenarios`, `vote-intention`, `rejection`, `comparatives`, `regional-performance`, `revenues`, `expenses`, `donations`, `suppliers`, `exports`, `search`, `filters`.

---

## Deep Links

```
poligestor://elections/...
poligestor://gestao-eleitoral/...
poligestor://gestao_eleitoral/...
poligestor://eleitoral/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 17 | OK (hub + Painel LIVE + deep link) |

---

## Pendências reais (fechamento formal)

1. Backend publicar os 31 paths restantes de `/v1/elections/*`.
2. Sync LIVE (chips Ativo) + auditoria payloads 200.
3. Fechamento formal das Fases 11, 12, 15 e 16 (quando solicitado).

## Próxima Fase

**Fase 18 — não iniciar** sem pedido explícito.