# Roadmap — PoliGestor Flutter

| Fase | Escopo | Status |
|------|--------|--------|
| 1–5 | Base, auth, protocolos, cidadão | Concluída |
| 6 | Atendimento / avaliação / conversa | Concluída |
| 7 | FCM, notificações, Reverb, deep links | CONCLUÍDA |
| 8 | Gestão do mandato (dashboard staff) | CONCLUÍDA |
| 9 | Inteligência do mandato (briefing/insights/trends) | CONCLUÍDA |
| 9.5 | Hardening completo (produção) | CONCLUÍDA |
| 10.1 | Equipe Virtual (agentes / operação) | CONCLUÍDA (Final) |
| **10.2** | Identidade, autenticação e multi-tenant | **FECHADA (Flutter)** |
| **10.4** | Central de Comunicação | **CONCLUÍDA** |
| **10.5** | Assistente Inteligente | **CONCLUÍDA** |
| **10.6** | Automação Inteligente | **CONCLUÍDA** |
| **10.7** | Painel Estratégico | **CONCLUÍDA** |
| **10.8** | Painel Parlamentar | **CONCLUÍDA** |
| **10.9** | Painel Obras | **CONCLUÍDA** |
| **11.0** | Painel de Convênios | **CONCLUÍDA** |
| **Fase 11** | Gestão Institucional — Painel de Eventos | **EM ANDAMENTO** |
| Fase 12 | **Inteligência Territorial** | **EM ANDAMENTO** (Flutter; 7 LIVE) |
| Fase 13 | Gestão Documental | **CONCLUÍDA** |
| Próximo | OAuth nativo + detalhe de conversa omnichannel (se VPS publicar mensagens) | Em aberto |

## Retomada

1. OAuth SDKs nativos + APNs (fora do escopo 10.4)
2. Detalhe de conversa omnichannel quando a VPS publicar contrato de mensagens

## Modelo de entrega (a partir da Fase 11)

Desenvolvimento por **Fases completas** (domínio inteiro). Não subdividir artificialmente em Sprint 11.1 / 11.2 / …

## Fase 11 (EM ANDAMENTO)

Painel de Eventos em `/home/events`. Namespace oficial `/v1/events` (lista/detalhe LIVE). Flutter entregue; fechamento formal pelos 15 critérios ainda pendente. Ver [FASE_11_EVENTOS.md](FASE_11_EVENTOS.md) e `.cursor/rules/fases-completas.mdc`.

## Sprint 11.0 (CONCLUÍDA)

Painel de Convênios em `/home/agreements`. Namespace LIVE `/v1/grants/*`.

## Sprint 10.9 (CONCLUÍDA)

Painel Obras em `/home/works`. Namespace preparado `/v1/works/*` com EndpointPendingState; mapa reusa mandato LIVE.

## Sprint 10.8 (CONCLUÍDA)

Painel Parlamentar em `/home/parliament`. LIVE `/v1/parliament/*`; pending: promises/search/timeline/history/attachments.

## Sprint 10.7 (CONCLUÍDA)

Painel Estratégico em `/home/strategy`. LIVE `/v1/strategy/*`; pending: goals/compare/indicators/predictions/map dedicado. Reuso mandato/inteligência.

## Sprint 10.6 (CONCLUÍDA)

Central de Automação em `/home/automation`. LIVE via Virtual Team; `/v1/automations*` preparado com EndpointPendingState.

## Sprint 10.5 (CONCLUÍDA)

Hub Assistente Inteligente em `/home/chat`. LIVE: chat, conversations, briefing(s), insights. Pending: summary/weekly, suggestions, priorities, questions, favorites, share.

## Sprint 10.4 (CONCLUÍDA)

**Central de Comunicação** exclusiva PoliGestor. LIVE: channels, templates, campaigns + omnichannel conversations/queue/operators.

## Sprint 10.2 (Flutter fechado — pendências OAuth nativo)

Fluxo org-first, branding dinâmico, sessão/perfil/recuperação. App pronto; backend ainda precisa estabilizar resolve/branding/providers/register/forgot/OAuth.

## Sprint 10.1 (fechada)

**STATUS: CONCLUÍDA (Final).** Centro operacional Equipe Virtual com REST `/api/v1/virtual-team/*` integrado sem mocks.

## Sprint 9.5 (fechada)

**STATUS: CONCLUÍDA.** Hardening de produção.

## Fase 9 (fechada)

**STATUS: CONCLUÍDA.** Módulo Inteligência.

## Fase 8 (fechada)

**STATUS: CONCLUÍDA.** Mandato operacional staff.
