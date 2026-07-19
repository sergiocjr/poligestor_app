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
| **10.2** | Identidade, autenticação e multi-tenant | **VALIDAÇÃO FINAL (Flutter)** |
| Próximo | SDKs OAuth nativos + validação visual device | Em aberto |
| 10+ | Evoluções restantes | Em aberto |

## Retomada (amanhã)

1. Backend: migrations `tenant_domains` / `tenant_branding` + endpoints 500 → 200
2. Backend: providers, register, forgot/reset, OAuth (staff + portal)
3. Flutter: validar branding real, resolve remoto e fluxos sociais no SM-A105M (app já plugado)

## Sprint 10.2 (Flutter fechado — pendências na VPS)

Fluxo org-first, branding dinâmico, sessão/perfil/recuperação. App pronto; backend ainda precisa estabilizar resolve/branding/providers/register/forgot/OAuth.

## Sprint 10.1 (fechada)

**STATUS: CONCLUÍDA (Final).** Centro operacional Equipe Virtual com REST `/api/v1/virtual-team/*` integrado sem mocks.

## Sprint 9.5 (fechada)

**STATUS: CONCLUÍDA.** Hardening de produção.

## Fase 9 (fechada)

**STATUS: CONCLUÍDA.** Módulo Inteligência.

## Fase 8 (fechada)

**STATUS: CONCLUÍDA.** Mandato operacional staff.
