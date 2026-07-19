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
| **10.2** | Identidade, autenticação e multi-tenant | **CONCLUÍDA (Flutter)** |
| 10+ | Evoluções restantes | Em aberto |

## Sprint 10.2 (Flutter fechado — pendências na VPS)

Fluxo org-first, branding dinâmico, sessão/perfil/recuperação. App pronto; backend ainda precisa estabilizar resolve/branding/providers/register/forgot/OAuth (ver relatório de endpoints).

## Sprint 10.1 (fechada)

**STATUS: CONCLUÍDA (Final).**

Centro operacional Equipe Virtual com todos os endpoints REST `/api/v1/virtual-team/*` (root, ops, governança e sub-rotas de agente) integrados sem mocks.

## Sprint 9.5 (fechada)

**STATUS: CONCLUÍDA.**

Hardening de produção: sync/realtime, segurança (FCM/CPF), UX Mais, a11y, dispose, testes.

## Fase 9 (fechada)

**STATUS: CONCLUÍDA.**

Módulo Inteligência consumindo `/api/v1/mandate/{briefing,analytics,trends,insights,briefings}`.

## Fase 8 (fechada)

**STATUS: CONCLUÍDA.** Mandato operacional staff.

## Fase 10+

Continuar conforme contratos VPS e prioridades do produto.
