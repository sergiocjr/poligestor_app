# PoliGestor App (Flutter)

Aplicativo mobile do **PoliGestor** — operação em campo (staff) e portal do cidadão.

- **API:** `https://poligestor.onnexis.com.br/api`
- **Repositório:** [github.com/sergiocjr/poligestor_app](https://github.com/sergiocjr/poligestor_app)

> No emulador Android, **nunca** use `localhost`. Se a API estiver neste PC, use `10.0.2.2`.
> Com a API na VPS, use o domínio HTTPS público (padrão do app).
> Validação de dispositivo: usar o aparelho físico **Samsung SM-A105M** (não abrir emulador nas rotinas oficiais).

## Rodar (dispositivo físico)

```powershell
$env:PATH = "C:\src\flutter\bin;$env:PATH"
cd C:\src\poligestor_app
flutter pub get
flutter devices
# Preferir o wrapper (cleanup ao parar):
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_run_a10.ps1
# Ou direto:
flutter run -d RX8M70CLXKP
```

Contas demo (após selecionar organização, ex.: `demo`):

| Persona  | E-mail               | Senha    | Modo    |
|----------|----------------------|----------|---------|
| Operador | `admin@demo.local`   | password | Staff   |
| Cidadão  | `cidadao@demo.local` | password | Portal  |

## Fases / Sprints

| Fase | Tema | Status |
|------|------|--------|
| 1–6 | Auth, cidadão, protocolos, assistente | Concluídas |
| **7** | Push FCM, notificações, Reverb, deep links | **CONCLUÍDA** |
| **8** | Módulo Mandato (gestão staff) | **CONCLUÍDA** |
| **9** | Inteligência do mandato | **CONCLUÍDA** |
| **9.5** | Hardening produção | **CONCLUÍDA** |
| **10.1** | Equipe Virtual | **CONCLUÍDA** |
| **10.2** | Identidade / Auth / Multi-tenant | **FECHADA (Flutter + APK SM-A105M)** |
| **10.4** | Central de Comunicação | **CONCLUÍDA** |
| **10.5** | Assistente Inteligente | **CONCLUÍDA** |
| **10.6** | Automação Inteligente | **CONCLUÍDA** |
| **10.7** | Painel Estratégico | **CONCLUÍDA** |
| **10.8** | Painel Parlamentar | **CONCLUÍDA** |
| **10.9** | Painel Obras | **CONCLUÍDA** |
| **11.0** | Painel de Convênios | **CONCLUÍDA** |
| 11.1 | — | **Não iniciada** |

## Sprint 10.2 — Identidade (FECHADA)

Fluxo **org-first** (`/org` → branding → `/login`) com contratos LIVE da VPS:

- Resolve / branding / providers LIVE
- OAuth externos **desabilitados** na VPS (`ready=false`; POST 501) — UI sem botões sociais
- Cadastro / forgot / reset / perfil / sessões / linked accounts (portal 200; staff profile/linked 403)
- APK debug no **SM-A105M**; toolchain AGP 9.0.1 / Gradle 9.1.0 / Kotlin 2.3.20 / Java target 17
- Cache por tenant; deep links `poligestor://org/{slug}`

Detalhes: [STATUS](docs/STATUS_PROJETO.md).

## Fase 11 — Painel de Eventos

Staff — **Mais → Painel de Eventos** (`/home/events`): painel, eventos, agenda, calendário, audiências, reuniões, presença, galeria e demais domínios. Namespace oficial `/v1/events` (lista/detalhe LIVE; demais preparados). Ver [docs/FASE_11_EVENTOS.md](docs/FASE_11_EVENTOS.md).

## Sprint 11.0 — Painel de Convênios

Staff — **Mais → Painel de Convênios** (`/home/agreements`): painel, convênios, recursos, projetos, execução, prestação de contas, cronograma, documentos e indicadores. Namespace LIVE `/v1/grants/*` (pending em recursos, cronograma, anexos, indicadores e pesquisa).

## Sprint 10.9 — Painel Obras

Staff — **Mais → Painel Obras** (`/home/works`): painel, obras, demandas, fiscalizações, cronograma, mapa, fotos, anexos, checklist, indicadores e relatórios. Namespace `/v1/works/*` preparado (EndpointPending); mapa reusa mandato LIVE.

## Sprint 10.8 — Painel Parlamentar

Staff — **Mais → Painel Parlamentar** (`/home/parliament`): painel, projetos de lei, sessões, votações e demandas LIVE (`/v1/parliament/*`).

## Sprint 10.7 — Painel Estratégico

Staff — **Mais → Painel Estratégico** (`/home/strategy`): KPIs, heatmap, tendências, alertas, regiões, bairros, previsões LIVE (`/v1/strategy/*`); metas/comparativos preparados.

## Sprint 10.6 — Central de Automação

Staff — **Mais → Central de Automação** (`/home/automation`): dashboard/execuções/alertas/agentes LIVE (via Equipe Virtual); automações/aprovações/agenda preparados.

## Sprint 10.5 — Assistente Inteligente

Staff — **Mais → Assistente Inteligente** (`/home/chat`):

- Hub com Chat, Briefings, Resumo do dia/semana, Sugestões, Prioridades, Insights, Perguntas, Histórico, Favoritos, Compartilhar
- LIVE + pending honesto conforme VPS; deep links `poligestor://assistant/...`

## Sprint 10.4 — Central de Comunicação (CONCLUÍDA)

Staff — **Mais → Central de Comunicação** (`/home/communication`):

- **LIVE:** canais, templates, campanhas + omnichannel (`/v1/omnichannel/conversations|queue|operators`)
- Filtros LIVE: `search`, `status`, `channel_type`, `sort`
- Cache offline local (`pg_comms_*`) + refresh via `MandateRefreshController`
- Isolamento absoluto: nenhum código/DB/API de NexChat, NexISP, GestFin ou outros produtos ONNEXIS
- Deep links `poligestor://communication/...`

## Sprint 10.1 — Equipe Virtual (CONCLUÍDA Final)

Staff — **Mais → Equipe Virtual** (`/home/virtual-team/*`):

- Dashboard, agentes + sub-rotas, tarefas, execuções, hand-offs, timeline, alertas, métricas, auditoria, logs, pesquisa, memória, aprendizado, fila, eventos
- Integração completa dos contratos VPS; refresh via Reverb/MandateRefresh
- Deep links `poligestor://virtual-team/...`

## Fase 7 — comunicação em tempo real (CONCLUÍDA)

Validado no **Samsung SM-A105M**:

- Firebase Android + `google-services.json` (não versionado)
- Token FCM real e registro em `POST /v1/.../devices/register`
- Remoção em logout: `DELETE /v1/.../devices/current`
- Push foreground / background / encerrado
- Deep links `poligestor://protocols/{id}` e `poligestor://notifications`
- WebSocket Reverb (`wss://…/app/{key}`) + auth `/broadcasting/auth`
- Fallback REST + polling 20s na tela de detalhe

### Limitações iOS

- Push iOS / APNs **não** validados nesta fase
- `GoogleService-Info.plist` e fluxo APNs ficam para configuração futura

## Fase 8 — Mandato (CONCLUÍDA)

Staff only — aba **Mandato**: visão geral, agenda, bairros, assuntos, equipe, pesquisa, relatórios, mapa, TV.

## Fase 9 — Inteligência (CONCLUÍDA)

Staff only — aba **Inteligência**: dashboard, briefing, insights, tendências, analytics, briefings.

## Sprint 9.5 — Hardening (CONCLUÍDA)

Produção: sync coalescido, FCM seguro, CPF mascarado, UX Mais, a11y básica, dispose.

## Estrutura

```
lib/
  core/           # config, api, auth, storage, theme, router, realtime
  features/
    identity/       # Sprint 10.2 — org + branding
    account/        # Sprint 10.2 — perfil / sessões
    auth/
    citizen/
    protocols/
    agenda/
    notifications/
    mandate/        # Fase 8
    intelligence/   # Fase 9
    virtual_team/   # Sprint 10.1
    communication/  # Sprint 10.4 — canais / templates / campanhas
    smart_assistant/# Sprint 10.5 — hub IA / chat gabinete
    automation/     # Sprint 10.6 — Central de Automação
    strategy/       # Sprint 10.7 — Painel Estratégico
    parliament/     # Sprint 10.8 — Painel Parlamentar
    works/          # Sprint 10.9 — Painel Obras
    agreements/     # Sprint 11.0 — Painel de Convênios
    events/         # Fase 11 — Painel de Eventos
    home/
    more/
    assistant/
  shared/widgets/
docs/             # STATUS, CHANGELOG, ROADMAP, arquitetura
scripts/          # flutter_run_a10.ps1, flutter_cleanup.ps1
```

## Documentação

- [STATUS do projeto](docs/STATUS_PROJETO.md)
- [CHANGELOG](docs/CHANGELOG.md)
- [ROADMAP](docs/ROADMAP.md)
- [Arquitetura Flutter](docs/ARQUITETURA_FLUTTER.md)

## Retomada amanhã

1. Acompanhar estabilização VPS dos endpoints 10.2 (500/404 → 200)
2. Validar branding real + resolve remoto no SM-A105M
3. Validar cadastro / forgot / providers sociais quando publicados
