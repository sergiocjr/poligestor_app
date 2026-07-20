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
| Fase | **Fase 12 — Inteligência Territorial** |
| Status formal | **EM ANDAMENTO** (Flutter entregue com namespace preparado; fechamento pelos 15 critérios pendente) |
| Hub | Mais → Inteligência Territorial (`/home/territorial-intelligence`) |
| Namespace oficial | `/api/v1/intelligence/*` (sem aliases) |
| Doc da fase | [FASE_12_INTELIGENCIA_TERRITORIAL.md](FASE_12_INTELIGENCIA_TERRITORIAL.md) |
| Fase 11 | Flutter entregue; fechamento formal ainda pendente (A10 / backend eventos / HTTP 500) |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit (pré-Fase 12) | `d0bfbef` — Fase 11 Eventos |
| Push | Atualizar após commit da Fase 12 |
| Working tree | Inclui entrega Fase 12 + docs de continuidade |

### Últimos commits (antes desta entrega)

```
d0bfbef feat: Fase 11 Painel de Eventos com namespace LIVE /v1/events
42999c9 sync: Sprint 11.0 Painel de Convênios para namespace LIVE /v1/grants/*
948ac2b feat: add Sprint 11.0 Agreements Panel with prepared /v1/agreements APIs
c5cfc09 feat: add Sprint 10.9 Works Panel with prepared /v1/works APIs
d0b1d6b feat: add Sprint 10.8 Parliamentary Panel with LIVE parliament APIs
```

---

## Telas concluídas (Fase 12 — UI pronta)

Rotas sob `/home/territorial-intelligence` — **todas Em preparação** (probe 404):

Painel BI · Painel Analítico · Indicadores-chave · Indicadores · Gráficos · Mapas de calor · Mapa territorial · Bairros · Regiões · Zonas eleitorais · Lideranças · Demandas · Obras · Protocolos · Atendimentos · Comparativos · Evolução · Tendências · Projeções · Filtros · Exportações.

Material 3 · Android · Tablet · Web · PT-BR · responsivo (1 coluna no A10).

---

## Contratos LIVE consumidos (Fase 12)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/intelligence/*` | **Nenhum LIVE** (todos 404 em 2026-07-20) |

Quando a VPS publicar HTTP 200, remover `EndpointPendingState` e marcar chips **Ativo**.

---

## EndpointPendingState

Todos os paths `/v1/intelligence/{dashboard,bi,kpis,indicators,charts,heatmap,map,neighborhoods,regions,electoral-zones,leaderships,demands,works,protocols,attendances,comparatives,evolution,trends,projections,filters,exports}`.

---

## Cache / Offline / Realtime

| Camada | Implementação |
|--------|----------------|
| Cache | `pg_ti_{tenant}_*` |
| Offline | Cache em falha de rede (quando houver payload) |
| Realtime | `MandateRefreshController` |

---

## Deep Links

```
poligestor://territorial-intelligence/...
poligestor://inteligencia-territorial/...
poligestor://intelligence-territorial/...
poligestor://painel-inteligencia-territorial/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 12 | APK instalado no A10 (RX8M70CLXKP); navegação Gabinete validada 2026-07-20 |

---

## Material 3

Hub grid responsivo, chips **Em preparação**, listas e painel Material 3.

---

## Pendências reais

1. Backend publicar `/v1/intelligence/*` (hoje 100% 404).
2. Validar APK no A10.
3. PHPUnit do domínio no backend.
4. Auditoria Backend ↔ Flutter após publicação LIVE.
5. Fechamento formal da Fase 11 (critérios restantes).

---

## Próxima Fase

| Campo | Valor |
|-------|--------|
| Fase 13 | **Bloqueada** até Fase 12 formalmente concluída (15 critérios) |

---

## Regras permanentes

- Fases completas: `.cursor/rules/fases-completas.mdc`
- LIVE-only: `.cursor/rules/live-only-apis.mdc`
- PT-BR: `.cursor/rules/pt-br-ui.mdc`
- A10 + limpeza: `.cursor/rules/flutter-device-a10.mdc`
- Gradle/Java: `.cursor/rules/gradle-memory-cleanup.mdc`

---

## Checklist de retomada

```text
[ ] Ler docs/CONTINUAR_PROJETO.md
[ ] Ler docs/STATUS_PROJETO.md
[ ] Ler docs/CHANGELOG.md
[ ] git log -5 --oneline && git status -sb
[ ] Probe VPS /v1/intelligence/*
[ ] adb devices — somente A10
[ ] analyze + test + apk + web
[ ] Instalar no A10
[ ] Limpeza gradlew + flutter_cleanup.ps1
[ ] Atualizar CONTINUAR_PROJETO.md + STATUS + CHANGELOG
[ ] Commit + push
[ ] Relatório dos 15 critérios
```

---

## Links

- [STATUS_PROJETO.md](STATUS_PROJETO.md)
- [CHANGELOG.md](CHANGELOG.md)
- [FASE_12_INTELIGENCIA_TERRITORIAL.md](FASE_12_INTELIGENCIA_TERRITORIAL.md)
- [FASE_11_EVENTOS.md](FASE_11_EVENTOS.md)
- Repo: https://github.com/sergiocjr/poligestor_app
