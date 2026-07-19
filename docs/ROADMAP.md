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
| **10.4** | Central de Comunicação | **EM ENTREGA** (canais/templates/campanhas LIVE) |
| 10.5 | — | **Não iniciada** |
| Próximo | Conversas/fila/operadores quando VPS publicar + OAuth nativo | Em aberto |

## Retomada

1. VPS: publicar conversas / fila / operadores no namespace PoliGestor (`/v1/conversations` etc.)
2. Flutter: ligar aba Conversas nos contratos reais (sem mock)
3. OAuth SDKs nativos + APNs (fora do escopo 10.4)

## Sprint 10.4 (em entrega)

**Central de Comunicação** exclusiva PoliGestor. LIVE: channels, templates, campaigns. Pendente VPS: conversations/queue/operators — UI com estado indisponível honesto.

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
