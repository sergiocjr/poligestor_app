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
| Fase | **Fase 13 — Gestão Documental** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; `/v1/documents/*` 100% 404 → Pending; fechamento pelos 15 critérios pendente) |
| Hub | Mais → Gestão Documental (`/home/documents`) |
| Namespace oficial | `/api/v1/documents/*` (sem aliases) |
| Doc da fase | [FASE_13_GESTAO_DOCUMENTAL.md](FASE_13_GESTAO_DOCUMENTAL.md) |
| Fase 12 | Flutter entregue (LIVE parcial); fechamento formal ainda pendente |
| Fase 11 | Flutter entregue; fechamento formal ainda pendente |
| Fase 14 | **Bloqueada** |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Working tree | Commit + push desta entrega Fase 13 |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- Gestão Documental: Mais → hub `/home/documents`

---

## Telas (Fase 13)

Documentos · Pesquisa · Filtros · Categorias · Favoritos · Histórico · Linha do tempo · Visualizador PDF · Assinaturas · Aprovações · Compartilhamento · Modelos · Download · Upload · Anexos.

Material 3 · cards clicáveis · Android · Tablet · Web · PT-BR · responsivo (1 coluna no A10).

---

## Contratos LIVE consumidos (Fase 13)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/documents/*` | **Nenhum LIVE** (todos 404 em 2026-07-20) |

---

## EndpointPendingState

Todos: `list` (`/v1/documents`), `search`, `filters`, `categories`, `favorites`, `history`, `timeline`, `viewer`, `signatures`, `approvals`, `share`, `templates`, `download`, `upload`, `attachments`.

---

## Cache / Offline / Realtime

| Camada | Implementação |
|--------|----------------|
| Cache | `pg_docs_{tenant}_*` |
| Offline | Cache em falha de rede (quando houver payload) |
| Realtime | `MandateRefreshController` |

---

## Deep Links

```
poligestor://documents/...
poligestor://documentos/...
poligestor://gestao-documental/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 13 | APK debug instalado nesta entrega |

---

## Pendências reais (fechamento formal)

1. Backend publicar `/v1/documents/*`.
2. PHPUnit do domínio no backend.
3. Auditoria Backend ↔ Flutter após HTTP 200.
4. Fechamento formal das Fases 11 e 12.

## Próxima Fase

**Fase 14 — bloqueada** até os 15 critérios da Fase 13.
