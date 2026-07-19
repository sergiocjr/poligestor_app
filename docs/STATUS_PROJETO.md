# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-19 (auditoria Portal/Protocolos — melhorias reais)

## Resumo

| Área | Status |
|------|--------|
| Auth dual (staff / portal) | Concluído |
| Portal do cidadão / Protocolos | Concluído + **auditoria/hardening** |
| Assistente IA (via Laravel) | Concluído |
| Fase 7 — FCM + Reverb + deep links | CONCLUÍDA |
| Fase 8 — Mandato (staff) | CONCLUÍDA |
| Fase 9 — Inteligência do mandato | CONCLUÍDA |
| Sprint 9.5 — Hardening produção | CONCLUÍDA |
| Sprint 10.1 — Equipe Virtual | CONCLUÍDA (Final) |
| Sprint 10.2 — Identidade / Auth / Multi-tenant | **FECHADA** |
| Sprint 10.4 | **Não iniciada** |

## Auditoria Portal/Protocolos (pós-10.2)

Contratos LIVE: `GET /v1/portal/protocols` (+ `search`, `sort`, filtros `status` PT), detalhe com `timeline`/`comments`/`status_label`/`can_rate`.

### Melhorias realizadas (sem reescrever telas)

- Preferir `status_label` LIVE; mapa PT ampliado (Novo, Em execução, Aguardando cidadão, Arquivado…)
- Timeline com **agrupamento por data** + cards
- Lista cidadão: **pesquisa** (`search`) e **ordenação** (`sort`) via query LIVE
- Avaliação: se `can_rate` sem `links.rate`, tenta `/rating` e `/rate`
- Anexos: labels/ícones PDF/áudio/vídeo + miniatura de imagem
- NPS preparado na UI (campo `nps` opcional no payload)

### Já existia (validado, não reimplementado)

Lista/detalhe, comentários, upload foto/doc, download via URL, realtime Reverb + polling, histórico, Material 3, rating, sync.

### Pendências reais

- VPS: listagem portal ocasionalmente **HTTP 500**
- `status=open` no server retorna vazio — filtro client-side permanece
- Share nativo de anexo ausente (`share_plus`)
- Chips de período/categoria na lista ainda não
- Staff `ProtocolsPage` mais simples que o portal
- OAuth SDKs / APNs / CPF demo

## Qualidade

- `flutter analyze` — 0 errors/warnings (infos)
- `flutter test` — 174 passed
- APK debug + web + install **SM-A105M** (`RX8M70CLXKP`)
- Nenhum emulador

## Repositório

- https://github.com/sergiocjr/poligestor_app
- Tag: `sprint-10.2-final` @ `d01613c`
