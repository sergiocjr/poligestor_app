# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 16 — CRM Político entregue no Flutter; fechamento formal pendente)

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
| Fase | **Fase 16 — CRM Político** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; `/v1/crm/*` 100% 404 → Pending) |
| Hub | Mais → CRM Político (`/home/crm`) |
| Namespace oficial | `/api/v1/crm/*` |
| Doc da fase | [FASE_16_CRM_POLITICO.md](FASE_16_CRM_POLITICO.md) |
| Fase 15 | **EM ANDAMENTO** (Flutter entregue; `/v1/communication/*` 404) |
| Fase 14 | **CONCLUÍDA** |
| Fase 13 | **CONCLUÍDA** |
| Fases 11–12 | Flutter entregue; fechamento formal ainda pendente |
| Fase 17 | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | `cf7cae9` — Fase 16 CRM Político |
| Push | Pendente |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- CRM Político: Mais → hub `/home/crm`
- Comunicação Institucional: Mais → hub `/home/institutional-communication`
- Central de Comunicação (Sprint 10.4): Mais → `/home/communication` (namespace distinto)

---

## Telas (Fase 16)

Painel · Líderes · Apoiadores · Eleitores · Voluntários · Equipe · Entidades · Associações · Igrejas · Empresas · Influenciadores · Segmentação · Etiquetas · Grupos · Regiões · Bairros · Zonas eleitorais · Histórico de relacionamento · Interações · Visitas · Ligações · Mensagens · Reuniões · Demandas vinculadas · Protocolos vinculados · Campanhas · Tarefas · Lembretes · Nível de apoio · Potencial de influência · Relacionamentos · Importação · Exportação · Pesquisa · Filtros · Indicadores · Relatórios.

Material 3 · cards clicáveis · PT-BR · responsivo (1 coluna no A10) · cache `pg_crm_*` · offline · realtime (`MandateRefreshController`).

---

## Contratos LIVE consumidos (Fase 16)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/crm/*` | **Nenhum LIVE** (todos 404 em 2026-07-20) |

---

## EndpointPendingState

Todos os paths do hub: `dashboard`, `leaders`, `supporters`, `voters`, `volunteers`, `team`, `entities`, `associations`, `churches`, `companies`, `influencers`, `segmentation`, `tags`, `groups`, `regions`, `neighborhoods`, `electoral-zones`, `relationship-history`, `interactions`, `visits`, `calls`, `messages`, `meetings`, `linked-demands`, `linked-protocols`, `campaigns`, `tasks`, `reminders`, `support-level`, `influence-potential`, `relationships`, `import`, `export`, `search`, `filters`, `indicators`, `reports`.

---

## Deep Links

```
poligestor://crm/...
poligestor://crm-politico/...
poligestor://crm_politico/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 16 | Pendente nesta entrega de wiring |

---

## Pendências reais (fechamento formal)

1. Backend publicar `/v1/crm/*`.
2. Sync LIVE (chips Ativo) + auditoria payloads 200.
3. Fechamento formal das Fases 11, 12 e 15 (quando solicitado).

## Próxima Fase

**Fase 17 — não iniciar** sem pedido explícito.