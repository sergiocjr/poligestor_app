# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 23 — Homologação Final CONCLUÍDA · **1.0.0+2**)

---

## Leitura obrigatória ao iniciar qualquer tarefa

1. **`docs/CONTINUAR_PROJETO.md`** (este arquivo) — **sempre primeiro**
2. `docs/STATUS_PROJETO.md`
3. `docs/CHANGELOG.md`
4. Últimos commits: `git log -5 --oneline`
5. Regras: `.cursor/rules/live-only-apis.mdc`, `fases-completas.mdc`, `flutter-device-a10.mdc`, `pt-br-ui.mdc`

---

## Fase atual

| Campo | Valor |
|-------|--------|
| Fase | **Fase 23 — Homologação Final** |
| Status formal | **CONCLUÍDA** |
| Versão | **1.0.0+2** |
| Doc da fase | [FASE_23_HOMOLOGACAO_FINAL.md](FASE_23_HOMOLOGACAO_FINAL.md) |
| Release | [RELEASE_NOTES.md](RELEASE_NOTES.md) |
| Checklist | [CHECKLIST_HOMOLOGACAO.md](CHECKLIST_HOMOLOGACAO.md) |
| Fase 22 | **CONCLUÍDA** |
| Novos módulos | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | (atualizar após push Fase 23) |
| Push | origin/master |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação

- Integrações: Mais → `/home/integrations`
- Segurança: Mais → `/home/security`
- Portal Web: `/platform` (Web)
- Cidadão: `/citizen/*`

---

## Validação 1.0

| Item | Resultado |
|------|-----------|
| `flutter analyze` | Sem errors/warnings (infos de estilo) |
| `flutter test` | 333/333 |
| APK release | OK (`app-release.apk` ~62 MB) |
| Web release | OK (`build/web`) |
| A10 | install + deep links OK |
| Emulador | Não iniciado |

---

## Pendências reais (pós-1.0)

1. Aceite funcional do produto / publicação loja e hospedagem Web.
2. Backend publicar contratos ainda 404 (security, admin, platform, search/filters de integrações, etc.).
3. Fechamento formal opcional das fases EM ANDAMENTO quando a VPS sincronizar.

## Próximo passo

Manutenção e sync LIVE sob demanda. **Sem nova fase de módulos** sem pedido explícito.
