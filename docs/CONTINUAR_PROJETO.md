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
| Status formal | **EM ANDAMENTO** (Flutter sincronizado com probe; backend incompleto → não fecha pelos 15 critérios) |
| Hub | Mais → Inteligência Territorial (`/home/territorial-intelligence`) |
| Namespace oficial | `/api/v1/intelligence/*` (sem aliases) |
| Doc da fase | [FASE_12_INTELIGENCIA_TERRITORIAL.md](FASE_12_INTELIGENCIA_TERRITORIAL.md) |
| Fase 11 | Flutter entregue; fechamento formal ainda pendente |
| Fase 13 | **Bloqueada** |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | `9ebba50` — Fase 12 sync LIVE Inteligência Territorial |
| Push | Sim (`origin/master`) |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- Inteligência Territorial: Mais → hub `/home/territorial-intelligence`

---

## Telas (Fase 12)

Painel BI · Painel Analítico · Indicadores-chave · Indicadores · Gráficos · Mapas de calor · Mapa territorial · Bairros · Regiões · Zonas eleitorais · Lideranças · Demandas · Obras · Protocolos · Atendimentos · Comparativos · Evolução · Tendências · Projeções · Filtros · Exportações.

Material 3 · Android · Tablet · Web · PT-BR · responsivo (1 coluna no A10).

---

## Contratos LIVE consumidos (Fase 12)

Probe 2026-07-20 **sem token** (401 = rota publicada; 404 = pendente):

| Path | Status VPS | App |
|------|------------|-----|
| `/v1/intelligence/dashboard` | **401 LIVE** | Consome |
| `/v1/intelligence/kpis` | **401 LIVE** | Consome |
| `/v1/intelligence/charts` | **401 LIVE** | Consome |
| `/v1/intelligence/neighborhoods` | **401 LIVE** | Consome |
| `/v1/intelligence/regions` | **401 LIVE** | Consome |
| `/v1/intelligence/trends` | **401 LIVE** | Consome |
| `/v1/intelligence/projections` | **401 LIVE** | Consome |
| Demais paths do namespace | **404** | `EndpointPendingState` |

---

## EndpointPendingState

`bi`, `indicators`, `heatmap`, `map`, `electoral-zones`, `leaderships`, `demands`, `works`, `protocols`, `attendances`, `comparatives`, `evolution`, `filters`, `exports`.

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
| Validação APK Fase 12 | APK debug instalado nesta entrega |

---

## Pendências reais (fechamento formal)

1. Backend publicar paths ainda em 404 e completar domínio.
2. PHPUnit do domínio no backend.
3. Auditoria Backend ↔ Flutter após payloads 200 autenticados.
4. Fechamento formal da Fase 11.

## Próxima Fase

**Fase 13 — bloqueada** até os 15 critérios da Fase 12.
