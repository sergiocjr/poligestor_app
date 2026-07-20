# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 15 — Comunicação Institucional entregue no Flutter; fechamento formal pendente)

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
| Fase | **Fase 15 — Comunicação Institucional** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; `/v1/communication/*` 100% 404 → Pending) |
| Hub | Mais → Comunicação Institucional (`/home/institutional-communication`) |
| Namespace oficial | `/api/v1/communication/*` |
| Doc da fase | [FASE_15_COMUNICACAO_INSTITUCIONAL.md](FASE_15_COMUNICACAO_INSTITUCIONAL.md) |
| Fase 14 | **CONCLUÍDA** |
| Fase 13 | **CONCLUÍDA** |
| Fases 11–12 | Flutter entregue; fechamento formal ainda pendente |
| Fase 16 | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | `94d677c` — Fase 15 Comunicação Institucional |
| Push | Sim (`origin/master`) |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- Comunicação Institucional: Mais → hub `/home/institutional-communication`
- Central de Comunicação (Sprint 10.4): Mais → `/home/communication` (namespace distinto)

---

## Telas (Fase 15)

Feed de notícias · Comunicados · Campanhas · Biblioteca de mídia · Publicações · Agenda de publicações · Notificação push · E-mail · WhatsApp · Histórico · Pesquisa · Filtros · Compartilhamento · Relatórios.

Material 3 · cards clicáveis · PT-BR · responsivo (1 coluna no A10) · cache `pg_ic_*` · offline · realtime (`MandateRefreshController`).

---

## Contratos LIVE consumidos (Fase 15)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/communication/*` | **Nenhum LIVE** (todos 404 em 2026-07-20) |

---

## EndpointPendingState

Todos os paths do hub: `feed`, `announcements`, `campaigns`, `media`, `publications`, `schedule`, `push`, `email`, `whatsapp`, `history`, `search`, `filters`, `share`, `reports`.

---

## Deep Links

```
poligestor://institutional-communication/...
poligestor://comunicacao-institucional/...
poligestor://comunicacao_institucional/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 15 | APK instalado (Success); UI hub a revalidar quando ADB voltar |

---

## Pendências reais (fechamento formal)

1. Backend publicar `/v1/communication/*`.
2. Sync LIVE (chips Ativo) + auditoria payloads 200.
3. Fechamento formal das Fases 11 e 12 (quando solicitado).

## Próxima Fase

**Fase 16 — não iniciar** sem pedido explícito.