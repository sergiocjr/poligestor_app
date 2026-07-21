# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> ## LEITURA OBRIGATÓRIA
>
> **Este arquivo deve ser lido antes de qualquer nova implementação**, correção, sprint ou fase.
> Sem ler **este arquivo** + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não iniciar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: **2026-07-21** (sync catálogo LIVE c29c2ad — eliminação de UI em preparação)

---

## Estado atual do aplicativo

| Campo | Valor |
|-------|--------|
| Versão | **1.0.0+6** |
| Commit | **`a528f15`** — `feat(sync): eliminar UI em preparação e consumir catálogo LIVE c29c2ad` |
| Branch | `master` |
| API | `https://poligestor.onnexis.com.br/api` (exclusivamente LIVE) |
| Catálogo backend | **c29c2ad** (`FLUTTER_LIVE_CONTRACTS_SYNC.md`) |
| `EndpointPendingState` | **0** no código |
| `/v1/events/viewer` | **não consumido** |
| Chips de hub | **Ativo** em todos os cards (sem “Demonstração” / “Em preparação”) |
| Injeção demo em LIVE vazio | **desligada** (`coerceRoot` preserva resposta real) |
| Status formal do produto | **EM ANDAMENTO** — aceite loja / validação visual completa A10 pendente |

---

## Leitura obrigatória ao iniciar qualquer tarefa

1. **`docs/CONTINUAR_PROJETO.md`** (este arquivo) — **sempre primeiro**
2. `docs/STATUS_PROJETO.md`
3. `docs/CHANGELOG.md`
4. `docs/RELEASE_NOTES.md`
5. Últimos commits: `git log -5 --oneline`
6. Regras: `.cursor/rules/live-only-apis.mdc`, `fases-completas.mdc`, `flutter-device-a10.mdc`, `pt-br-ui.mdc`

---

## Resultado da sincronização com a VPS (2026-07-21)

| Item | Resultado |
|------|-----------|
| Probe autenticado (prioritário) | Paths críticos **HTTP 200** (finance, CRM, security, automation, events, works, admin, platform, parliament, strategy, communication, intelligence) |
| Namespace automação | **`/v1/automation/*`** singular (não `/v1/automations`) |
| Remapeamentos AuthMode | payees, budgets, cabinets, campaign-promises, hearings, invitations, statistics, MFA, recovery, keys, etc. |
| Testes de contrato | **142** OK (fases 11–22 + sprints 106–110) |
| APK A10 | **1.0.0+6** debug instalado · `br.com.onnexis.poligestor_app` · `RX8M70CLXKP` |
| Web | **1.0.0+6** (mesmo `pubspec.yaml`; build release não repetido hoje) |

Doc inventário: [INVENTARIO_ENDPOINT_PENDING.md](INVENTARIO_ENDPOINT_PENDING.md)

---

## Contratos LIVE consumidos (resumo)

15 arquivos `*_contracts.dart` + `automation_contracts.dart`. Todos os cards de hub marcados LIVE; consumo via `AuthMode` remapeado ao catálogo c29c2ad.

| Módulo | Slugs LIVE (hub) | Namespace principal |
|--------|------------------:|---------------------|
| Automação | 19 | `/v1/automation/*` |
| Admin | 35 | `/v1/admin/*` |
| Plataforma | 34 | `/v1/platform/*` |
| Segurança | 44 | `/v1/security/*` |
| CRM | 38 | `/v1/crm/*` |
| Eleições | 48 | `/v1/elections/*` |
| Financeiro | 31 | `/v1/finance/*` |
| Documentos | 29 | `/v1/documents/*` |
| Inteligência territorial | 26 | `/v1/intelligence/*` |
| IA avançada | 31 | `/v1/ai/*` |
| Integrações | 30 | `/v1/integrations/*` |
| Eventos | 22 | `/v1/events/*` |
| Comunicação | 16 | `/v1/communication/*` |
| Obras | 13 | `/v1/works/*` |
| Notícias | 12 | `/v1/news/*` |

**Aliases:** vários slugs de UI compartilham o mesmo endpoint oficial (ex.: receitas/despesas → `transactions`; líderes/apoiadores → `contacts`). Isso evita telas “em preparação” sem inventar paths.

---

## Dados de demonstração suportados

| Aspecto | Comportamento atual |
|---------|---------------------|
| Resposta LIVE vazia | Exibe **estado vazio** real (`AppEmptyState`) — **sem** preencher com fictício |
| `meta.demo=true` na API | Rotulado como “Dados de referência” (`DemoRepositorySupport`) |
| `DemoExperiencePane` | **Removido** das telas de módulos; arquivo legado mantido sem uso na UX principal |
| Portal cidadão (bairro) | Conteúdo ilustrativo local (`MockNewsCatalog`) em telas específicas |
| Assistente (anexos) | Opções de exemplo no compositor (imagem/PDF/local/áudio) — sem upload real |

---

## Melhorias de UX/UI realizadas (2026-07-21)

- Chip de contrato: **sempre “Ativo”** (`uiContractChip`)
- Remoção de SoftNotice “Demonstração / contrato publicado / aguardando VPS” nos hubs
- Remoção de painéis `DemoExperiencePane` e mensagens “aguardando contrato ativo”
- Erros 401: mensagem **“Sessão expirada. Entre novamente.”**
- Telas LIVE: lista vazia ou erro com retry — nunca tela “preparada”
- Automação, Parlamento (promessas), Estratégia (comparativos), Eventos (agenda/calendário): rotas consumindo API real
- IA: correção de paths 404 (`/v1/ai/dashboard`, `/v1/ai/hub`, specialists, analyses)

---

## Fases e sprints — status resumido

| Grupo | Status |
|-------|--------|
| Fases 1–9, 13, 14, 22, 23 | **CONCLUÍDAS** (domínio base / homologação) |
| Fases 11–12, 15–21, 24 | **EM ANDAMENTO** formal (critério fase completa: APK visual + PHPUnit backend) |
| Sprints 10.5–11.0 | **EM ANDAMENTO** formal; Flutter **sincronizado** ao catálogo c29c2ad |
| Sprint 10.6 Automação | Flutter **LIVE** em `/v1/automation/*`; escrita `autonomy-write` ainda sem POST publicado |

Detalhe: [STATUS_PROJETO.md](STATUS_PROJETO.md) · [AUDITORIA_FINAL.md](AUDITORIA_FINAL.md)

---

## Pendências reais

1. **Validação visual A10** de todos os hubs pós-sync (navegação card a card).
2. **`flutter test` suíte completa** (~348) após bump `1.0.0+6`.
3. **Build Web release** com artefato `1.0.0+6`.
4. **Aliases de hub:** alguns cards usam endpoint agregado do catálogo — publicar paths dedicados na VPS se o backend quiser 1:1.
5. **OAuth nativo** register/forgot (Sprint 10.2 backend).
6. **Notícias:** `/v1/news/recent|feed` podem 404 — app usa menções + busca local.
7. **Automação:** escrita de autonomia (`autonomy-write`) sem contrato POST.
8. **Aceite produção / loja** (pós-1.0).

---

## Próximos passos recomendados

1. Rodar `flutter test` completo + `flutter analyze` e corrigir regressões.
2. Validar no A10 (`RX8M70CLXKP`) todos os hubs staff — sem chip “Demonstração” e sem banner demo.
3. Build APK release + Web release `1.0.0+6`.
4. Se a VPS publicar path dedicado para um card com alias, atualizar **somente** o getter `AuthMode` correspondente.
5. Atualizar `INVENTARIO_ENDPOINT_PENDING.md` após novo probe backend.

---

## Git e dispositivo

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Versão APK / Web | **1.0.0+6** |
| Push | `origin/master` |
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |

### Navegação rápida

- Notícias: Gabinete + Mais → `/home/news`
- Integrações: `/home/integrations`
- Segurança: `/home/security`
- Automação: `/home/automation`

---

## Ponto de restauração 1.0 (pré-auditoria)

| Campo | Valor |
|-------|--------|
| Tag | `v1.0-final-pre-auditoria` → commit `a20587f` |
| Doc | [PONTO_RESTAURACAO_1.0.md](PONTO_RESTAURACAO_1.0.md) |
