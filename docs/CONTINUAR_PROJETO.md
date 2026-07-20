# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 18 — IA Avançada entregue no Flutter; fechamento formal pendente)

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
| Fase | **Fase 18 — IA Avançada** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; sync `/v1/ai/*` parcial) |
| Hub | Mais → IA Avançada (`/home/advanced-ai`) |
| Namespace oficial | `/api/v1/ai/*` |
| Doc da fase | [FASE_18_IA_AVANCADA.md](FASE_18_IA_AVANCADA.md) |
| Fase 17 | **CONCLUÍDA** (pendência A10 física) |
| Fase 16 | **EM ANDAMENTO** (`/v1/crm/*` 404) |
| Fase 15 | **EM ANDAMENTO** (`/v1/communication/*` 404) |
| Fase 14 | **CONCLUÍDA** |
| Fase 19 | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | (pendente — entrega Fase 18) |
| Push | Pendente |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- IA Avançada: Mais → hub `/home/advanced-ai`
- Assistente Inteligente (Sprint 10.5): Mais → `/home/chat` (namespace `/v1/ai/*` compartilhado, hub distinto)

---

## Telas (Fase 18)

Conversa com IA · Conversas · Secretária Virtual · Assessor Parlamentar · Analista Político · Analista Financeiro · Assessor de Comunicação · Assessor Jurídico · Planejamento estratégico · Resumos do dia · Resumos · Sugestões inteligentes · Histórico · Biblioteca de prompts · Avaliação · Configurações · Pesquisa.

Material 3 · cards clicáveis · PT-BR · responsivo · cache `pg_aai_*` · offline · realtime (`MandateRefreshController`).

---

## Contratos LIVE consumidos (Fase 18)

| Método | Path | Status VPS |
|--------|------|------------|
| POST | `/v1/ai/chat` | LIVE (201) |
| GET | `/v1/ai/conversations` | LIVE (200) |
| GET | `/v1/ai/history` | LIVE (200) |
| GET | `/v1/ai/briefings` | LIVE (200) |
| GET | `/v1/ai/prompts` | LIVE (200) |
| GET | `/v1/ai/agents` | LIVE (200) |
| POST | `/v1/ai/summary` | LIVE (rota ativa) |
| POST | `/v1/ai/suggestions` | LIVE (rota ativa) |
| POST | `/v1/ai/feedback` | LIVE (201) |

Papéis Ativo via agentes: secretary, parliamentary_advisor, analyst, communication, legal, strategy.

---

## EndpointPendingState

`financial-analyst`, `settings`, `search` (+ paths dedicados de papéis 404 — UI consome `/v1/ai/agents`).

---

## Deep Links

```
poligestor://advanced-ai/...
poligestor://ia-avancada/...
poligestor://ia_avancada/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 18 | OK (hub + Conversa; chips Ativo) |

---

## Pendências reais (fechamento formal)

1. Backend publicar `financial-analyst`, `settings`, `search` (quando houver).
2. Fechamento formal das Fases 11, 12, 15 e 16 (quando solicitado).
3. Validação física A10 da Fase 17 (se ainda pendente).

## Próxima Fase

**Fase 19 — não iniciar** sem pedido explícito.