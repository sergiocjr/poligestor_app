# Auditoria Final — Fases 1 a 24

---

## Registro diário — 2026-07-21

| Campo | Valor |
|-------|--------|
| **Data** | 2026-07-21 |
| **Commit** | `a528f15` — `feat(sync): eliminar UI em preparação e consumir catálogo LIVE c29c2ad` |
| **Branch** | `master` |
| **Versão APK** | **1.0.0+6** (debug validado no A10) |
| **Versão Web** | **1.0.0+6** (`pubspec.yaml`; build release pendente) |
| **Catálogo backend** | c29c2ad |

### Resumo das alterações do dia

1. **UX:** eliminação de chips “Demonstração”, SoftNotice “aguardando VPS” e painéis `DemoExperiencePane` nos módulos staff.
2. **AuthMode:** remapeamento massivo ao catálogo LIVE (automation singular, payees, budgets, cabinets, campaign-promises, hearings, invitations, statistics, MFA, recovery, keys, IA dashboard, etc.).
3. **Contratos:** expansão de `k*LiveSlugs` em 15 módulos + `automation_contracts.dart`.
4. **Repositórios:** sem injeção demo em LIVE vazio; consumo HTTP direto nos cards de hub.
5. **Automação:** LIVE em `/v1/automation/dashboard`, `rules`, `executions`, `approvals`, `alerts`, `metrics`, `schedules`, `logs`, `agents`.
6. **IA:** correção de paths 404 (`/v1/ai/dashboard`, `/v1/ai/hub`; specialists/analyses).
7. **Testes:** 142 testes de contrato OK.
8. **A10:** APK debug instalado e aberto (`RX8M70CLXKP`).
9. **Documentação:** `CONTINUAR_PROJETO`, `STATUS_PROJETO`, `CHANGELOG`, `RELEASE_NOTES`, `INVENTARIO_ENDPOINT_PENDING`.

### Métricas pós-sync

| Métrica | Resultado |
|---------|-----------|
| `EndpointPendingState` | **0** |
| Chips “Demonstração” / “Em preparação” | **0** |
| `/v1/events/viewer` consumido | **Não** |
| Arquivos `*_contracts.dart` | **15** |

### Pendências reais remanescentes

- Validação visual hub-a-hub no A10.
- `flutter test` suíte completa pós-+6.
- Build Web release `1.0.0+6`.
- Aliases de hub (vários cards → mesmo endpoint agregado).
- `autonomy-write` automação sem POST.
- Aceite produção / loja.

---

## Auditoria histórica (2026-07-20)

Atualizado: 2026-07-20

**Versão auditada:** `1.0.0+2` · **Tag base:** `v1.0-final-pre-auditoria` · **Commit pós-sync:** ver `git log -1`

## Escopo

Auditoria completa do aplicativo Flutter PoliGestor/MandatoOS antes do aceite de produção 1.0, cobrindo implementações das Fases 1–24 e módulos Sprint 10.x.

**VPS:** `https://poligestor.onnexis.com.br/api` (probe autenticado durante auditoria)

**Critério CONCLUÍDA:** domínio **100% funcional** — todos os contratos publicados consumidos; sem `EndpointPendingState` desnecessário no fluxo principal; sem placeholders bloqueando UX.

---

## Resumo executivo

| Métrica | Resultado |
|---------|-----------|
| `EndpointPendingState` (widgets) | **88** usos em **23** módulos |
| `TODO` / `FIXME` em `lib/` | **0** |
| Contratos `*_contracts.dart` | **12** arquivos |
| Slugs LIVE catalogados | **~97+** |
| Sync imediato na auditoria | **dashboard LIVE** Fases 15, 16, 19, 20, 21 (`k*LiveSlugs`) |
| Novos LIVE detectados (não consumidos antes) | `/v1/communication/dashboard`, `/v1/crm/dashboard`, `/v1/admin/dashboard`, `/v1/security/dashboard`, `/v1/platform/dashboard`, `/v1/events/dashboard`, `/v1/grants/dashboard` |
| Ponto de restauração | [PONTO_RESTAURACAO_1.0.md](PONTO_RESTAURACAO_1.0.md) |

---

## Tabela — Fase | Status | Pendências

| Fase | Escopo | Status | Pendências |
|------|--------|--------|------------|
| **1** | Base / shell / navegação | **CONCLUÍDA** | — |
| **2** | Autenticação staff + portal | **CONCLUÍDA** | Register/forgot OAuth nativo (Sprint 10.2 backend) |
| **3** | Protocolos cidadão | **CONCLUÍDA** | — |
| **4** | Portal do cidadão | **CONCLUÍDA** | Conteúdos extras bairro "Em breve" |
| **5** | Assistente IA (Laravel) | **CONCLUÍDA** | Anexos chat (imagem/doc/local/áudio) desabilitados |
| **6** | Atendimento / avaliação / conversa | **CONCLUÍDA** | — |
| **7** | FCM + Reverb + deep links | **CONCLUÍDA** | — |
| **8** | Gestão do mandato (staff) | **CONCLUÍDA** | — |
| **9** | Inteligência do mandato | **CONCLUÍDA** | — |
| **10** | *(não numerada)* | **N/A** | Entregas nos Sprints 10.1–11.0 (abaixo) |
| **11** | Painel de Eventos | **EM ANDAMENTO** | `/v1/events/dashboard` **LIVE** (sync OK); participantes/convites/check-in/QR/galeria/etc. **404** |
| **12** | Inteligência Territorial | **EM ANDAMENTO** | **7 LIVE** (`dashboard`, kpis, charts, neighborhoods, regions, trends, projections); resto **404** |
| **13** | Gestão Documental | **CONCLUÍDA** | **15 LIVE**; fallback Pending residual em paths raros |
| **14** | Gestão Financeira | **CONCLUÍDA** | **9 LIVE**; entradas hub sem contrato ainda **404** (Pending honesto) |
| **15** | Comunicação Institucional | **EM ANDAMENTO** | **`dashboard` LIVE** sincronizado; feed/campanhas/mídia/etc. **404**; hub **sem card Painel** |
| **16** | CRM Político | **EM ANDAMENTO** | **`dashboard` LIVE** sincronizado; líderes/apoiadores/segmentos/etc. **404** |
| **17** | Gestão Eleitoral | **EM ANDAMENTO** | **14 LIVE**; **31 paths 404**; revalidação A10 pendente |
| **18** | IA Avançada | **EM ANDAMENTO** | **9+ LIVE** (`chat`, conversations, agents…); financial-analyst/settings/search **404** |
| **19** | Administração do Sistema | **EM ANDAMENTO** | **`dashboard` LIVE** sincronizado; users/roles/logs/etc. **404** |
| **20** | Portal Administrativo Web | **EM ANDAMENTO** | **`dashboard` LIVE** sincronizado; demais **404** |
| **21** | Segurança e Privacidade | **EM ANDAMENTO** | **`dashboard` VPS LIVE** catalogado; hub **sem rota `/dashboard`**; MFA/sessões/etc. **404** |
| **22** | Integrações | **CONCLUÍDA** | **25 LIVE**; search/filters **404** (Pending documentado) |
| **23** | Homologação Final | **CONCLUÍDA** | Versão **1.0.0+2**; processo, não domínio |
| **24** | Notícias Regionais | **EM ANDAMENTO** | **6 LIVE**; recent/feed/search/filters **404** (fallback local) |

### Módulos Sprint (entre Fase 9 e 11)

| Sprint | Status | Pendências |
|--------|--------|------------|
| 9.5 Hardening | **CONCLUÍDA** | — |
| 10.1 Equipe Virtual | **CONCLUÍDA** | `/v1/virtual-team/*` LIVE |
| 10.2 Identidade/Auth | **FECHADA (Flutter)** | OAuth nativo; register/forgot backend |
| 10.4 Central Comunicação | **CONCLUÍDA** | LIVE channels/templates/campaigns |
| 10.5 Assistente Inteligente | **EM ANDAMENTO** | **6 Pending** (summary, suggestions, priorities, questions, favorites, share) |
| 10.6 Automação | **EM ANDAMENTO** | `/v1/automations*` **404** |
| 10.7 Painel Estratégico | **EM ANDAMENTO** | metas/comparativos/indicadores/mapa **404** |
| 10.8 Painel Parlamentar | **EM ANDAMENTO** | promises/search/timeline **404** |
| 10.9 Painel Obras | **EM ANDAMENTO** | `/v1/works/*` **404** (maior gap) |
| 11.0 Painel Convênios | **EM ANDAMENTO** | `/v1/grants/dashboard` **LIVE**; subpaths parciais |

---

## Achados por categoria

### 1. EndpointPendingState

- **Total:** 88 widgets em 23 módulos — **legítimo** onde VPS retorna 404/405/501/503.
- **Desnecessário removido na auditoria:** chips/dashboard Fases 15–21 após sync `dashboard` LIVE.
- **Maiores concentrações:** `works` (8), `security_privacy` (8), `advanced_ai` (7), `integrations` (6), `smart_assistant` (6).

### 2. Contratos LIVE não consumidos (corrigidos parcialmente)

| Path VPS (200) | Antes | Ação auditoria |
|----------------|-------|----------------|
| `/v1/communication/dashboard` | `kInstitutionalCommunicationLiveSlugs` vazio | **+dashboard** (hub ainda sem card) |
| `/v1/crm/dashboard` | vazio | **+dashboard** |
| `/v1/admin/dashboard` | vazio | **+dashboard** |
| `/v1/platform/dashboard` | vazio | **+dashboard** |
| `/v1/security/dashboard` | vazio | **+dashboard** (sem rota Flutter) |
| `/v1/events/dashboard` | repo já chamava | **OK** — passa a responder 200 |
| `/v1/grants/dashboard` | parcial | documentado |

### 3. Endpoints 404 ainda publicados

Probe confirma **404** em: `/v1/works/*`, `/v1/news/recent|feed|search|filters`, `/v1/integrations/search|filters`, subpaths majoritários de communication/crm/admin/security/platform.

### 4. Telas "Em preparação"

Chips **Em preparação** corretos nos hubs com slug não-LIVE. Legendas explicativas em finance, elections, integrations, advanced_ai, territorial_intelligence, security, admin, platform, crm, institutional_communication.

### 5. Botões sem ação / placeholders

| Local | Tipo | Avaliação |
|-------|------|-----------|
| `more_page.dart` | Notificações, Carteira Digital, Scanner QR | **Intencional** ("Em breve") |
| `chat_composer.dart` | 4 tipos de anexo | **Intencional** |
| `onPressed: null` literal | — | **Nenhum** (só guards `_busy`) |

### 6. Overflow / layout

Fase 23 homologou zero overflow no A10. Nenhuma regressão reportada nesta auditoria estática.

### 7. TODO / FIXME

**Zero** ocorrências em `lib/`.

### 8. Documentação desatualizada (corrigida)

- `STATUS_PROJETO.md`: trechos "Fase 23 não iniciada" / "Fase 17 não iniciada" removidos.
- `ROADMAP.md`: Fase 13 "Bloqueada" → **CONCLUÍDA**.
- Status formal alinhado ao critério 100% funcional.

---

## Validação técnica (pós-auditoria)

| Item | Resultado |
|------|-----------|
| `flutter analyze` (Fase 15–21 sync) | OK |
| `flutter test` | **340** testes OK |
| APK debug | OK |
| Web release | OK |
| A10 `RX8M70CLXKP` | Instalação OK |
| Emulador | Não iniciado |
| `gradlew --stop` + cleanup | OK |

---

## Recomendações pós-auditoria

1. **Não marcar CONCLUÍDA** Fases 15–21, 24, 17 até backend publicar domínio completo.
2. Adicionar cards **Painel** nos hubs Fase 15 e 21 para consumir `dashboard` LIVE.
3. Priorizar publicação `/v1/works/*` (Sprint 10.9) e subpaths `/v1/news/recent|feed`.
4. Revalidar **Samsung Galaxy A10** para Fases 11, 15–21, 24 após próximo sync backend.
5. Restaurar baseline: `git checkout v1.0-final-pre-auditoria` se regressão crítica.

---

## Referências

- [PONTO_RESTAURACAO_1.0.md](PONTO_RESTAURACAO_1.0.md)
- [STATUS_PROJETO.md](STATUS_PROJETO.md)
- [CONTINUAR_PROJETO.md](CONTINUAR_PROJETO.md)
- [INTEGRACOES.md](INTEGRACOES.md)
