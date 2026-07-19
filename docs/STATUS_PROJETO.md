# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-18

## Resumo

| Área | Status |
|------|--------|
| Auth dual (staff / portal) | Concluído |
| Portal do cidadão | Concluído |
| Protocolos / conversa / avaliação | Concluído |
| Assistente IA (via Laravel) | Concluído |
| **Fase 7 — FCM + Reverb + deep links** | **CONCLUÍDA** |
| Fase 8 — Mandato | Em implementação |
| Fase 9+ | Não iniciada |

## Fase 7 — CONCLUÍDA

### Entregue

- Firebase Cloud Messaging real (Android)
- Registro / remoção de dispositivos
- Centro de avisos (filtros, paginação, ler todas)
- Preferências de notificação remotas
- Deep links `poligestor://…`
- Reverb (WSS) + auth de canais privados
- Fallback REST + polling
- Validação em aparelho físico SM-A105M

### Validação física

- Aparelho: Samsung SM-A105M (`RX8M70CLXKP`)
- Push real recebido e exibido
- Toque abriu a tela correta
- Token FCM real (sem install-id)

### Limitações reais

- iOS / APNs não validados
- `google-services.json` fora do Git (política do projeto)
- Envio FCM no servidor depende de `FCM_MODE` / chaves no backend (fora do escopo Flutter)

## Fase 8

Módulo Mandato (staff): visão executiva, agenda, bairros, assuntos, equipe, busca, relatórios, mapa, painel TV, briefing IA — APIs `/v1/mandate/*`.
