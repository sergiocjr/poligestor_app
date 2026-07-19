# Status do projeto — PoliGestor Flutter

Atualizado: 2026-07-18

## Resumo

| Área | Status |
|------|--------|
| Auth dual (staff / portal) | Concluído |
| Portal do cidadão | Concluído |
| Protocolos / conversa / avaliação | Concluído |
| Assistente IA (via Laravel) | Concluído |
| Fase 7 — FCM + Reverb + deep links | CONCLUÍDA |
| **Fase 8 — Mandato (staff)** | **CONCLUÍDA** |
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

## Fase 8 — CONCLUÍDA

### Entregue

- Aba **Mandato** no shell staff (`/home/mandate/*`); cidadão não vê o módulo
- APIs exatas: `executive`, `briefing`, `agenda`, `neighborhoods`, `subjects`, `team`, `search`, `reports`, `map`, `tv`
- Overview com indicadores, pontos de atenção, resumo do dia e hub interno
- Cache local carimbado + refresh no resume / realtime (`MandateRefreshController`)
- Relatórios listam linhas da API; exportação só quando o backend expor links
- Testes `test/phase8_mandate_test.dart` + `flutter analyze` sem errors

### Validação

- Endpoints `/v1/mandate/*` responderam **HTTP 200** com login staff (`admin@demo.local`)
- Build debug instalável no SM-A105M (`RX8M70CLXKP`)
- Parsing defensivo alinhado aos payloads reais da VPS

### Limitações

- Mapa cartográfico depende de coordenadas; hoje concentra por bairro via API
- Exportação PDF/Excel/CSV aguarda URLs/jobs no payload de `reports`
- iOS não validado nesta fase
