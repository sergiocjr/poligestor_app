# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-20 (Fase 11 — Gestão Institucional / Painel de Eventos CONCLUÍDA)

## Resumo

| Área | Status |
|------|--------|
| Auth dual (staff / portal) | Concluído |
| Portal do cidadão / Protocolos | Concluído + auditoria/hardening |
| Assistente IA (via Laravel) | Concluído |
| Fase 7 — FCM + Reverb + deep links | CONCLUÍDA |
| Fase 8 — Mandato (staff) | CONCLUÍDA |
| Fase 9 — Inteligência do mandato | CONCLUÍDA |
| Sprint 9.5 — Hardening produção | CONCLUÍDA |
| Sprint 10.1 — Equipe Virtual | CONCLUÍDA (Final) |
| Sprint 10.2 — Identidade / Auth / Multi-tenant | **FECHADA** |
| Sprint 10.4 — Central de Comunicação | **CONCLUÍDA** |
| Sprint 10.5 — Assistente Inteligente | **CONCLUÍDA** |
| Sprint 10.6 — Automação Inteligente | **CONCLUÍDA** |
| Sprint 10.7 — Painel Estratégico | **CONCLUÍDA** |
| Sprint 10.8 — Painel Parlamentar | **CONCLUÍDA** |
| Sprint 10.9 — Painel Obras | **CONCLUÍDA** |
| Sprint 11.0 — Painel de Convênios | **CONCLUÍDA** |
| **Fase 11 — Gestão Institucional (Eventos)** | **CONCLUÍDA** |
| Fase 12 | **Não iniciada** |

> A partir da Fase 11, o desenvolvimento passa a ser por **Fases completas** (domínio inteiro), sem subdivisão artificial em sprints 11.1 / 11.2 / …

## Fase 11 — Painel de Eventos

Hub próprio em **Mais → Painel de Eventos** (`/home/events`).

Namespace oficial `/v1/events` (lista e detalhe LIVE; demais subdomínios preparados com `EndpointPendingState` ou fallback local sobre a lista). Interface em PT-BR.

### Telas

Painel · Lista · Detalhes · Agenda · Calendário · Audiências · Reuniões · Participantes · Convites · Presença · Check-in · Check-out · QR Code · Galeria · Fotos · Vídeos · Documentos · Certificados · Linha do Tempo · Mapa · Indicadores · Relatórios · Pesquisa · Filtros.

### Domínios

| Recurso | Contrato | Rota | App |
|---------|----------|------|-----|
| Painel | `/v1/events` (agregado) + `/v1/events/dashboard` preparado | `/home/events/dashboard` | Ativo |
| Eventos | `/v1/events` (+ `/{id}`) | `/home/events/list` | Ativo |
| Agenda | UI sobre `/v1/events` | `/home/events/agenda` | Ativo |
| Calendário | UI sobre `/v1/events` | `/home/events/calendar` | Ativo |
| Audiências | filtro `type=appointment` / path preparado | `/home/events/audiences` | Ativo |
| Reuniões | filtro `type=meeting` / path preparado | `/home/events/meetings` | Ativo |
| Participantes | `/v1/events/participants` | `/home/events/participants` | Pending |
| Convites | `/v1/events/invites` | `/home/events/invites` | Pending |
| Presença | `/v1/events/attendance` | `/home/events/attendance` | Pending |
| Check-in / Check-out | `/v1/events/check-in` · `/check-out` | `/home/events/check-in` · `check-out` | Pending |
| QR Code | `/v1/events/qr-code` | `/home/events/qr-code` | Pending |
| Galeria / Fotos / Vídeos | `/gallery` · `/photos` · `/videos` | rotas homônimas | Pending |
| Documentos / Certificados | `/documents` · `/certificates` | rotas homônimas | Pending |
| Linha do Tempo / Mapa | `/timeline` · `/map` | rotas homônimas | Pending |
| Indicadores / Relatórios | `/indicators` · `/reports` | rotas homônimas | Pending |
| Pesquisa | local + `/v1/events/search` preparado | `/home/events/search` | Ativo (local) |

Cache: `pg_events_{tenant}_*`. Realtime: `MandateRefreshController`. Deep links: `poligestor://events|eventos|painel-eventos/...`.

Documentação detalhada: [FASE_11_EVENTOS.md](FASE_11_EVENTOS.md).

## Sprint 11.0 — Painel de Convênios

Hub **Mais → Painel de Convênios** (`/home/agreements`). Namespace LIVE `/v1/grants/*`.

## Idioma (regra permanente)

Interface exclusivamente em **Português do Brasil**. Ver `.cursor/rules/pt-br-ui.mdc`.

## Qualidade

- `flutter analyze` / `flutter test` / APK debug + web OK
- Instalação no SM-A105M: requer aparelho conectado via USB (ADB)
- Nenhum emulador
- Fase 12 não iniciada

## Repositório

- https://github.com/sergiocjr/poligestor_app
