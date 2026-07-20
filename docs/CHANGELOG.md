# Changelog — PoliGestor Flutter

## [Auditoria Final Fases 1–24] — 2026-07-20

### Added

- Tag Git `v1.0-final-pre-auditoria` (baseline pré-auditoria)
- [PONTO_RESTAURACAO_1.0.md](PONTO_RESTAURACAO_1.0.md)
- [AUDITORIA_FINAL.md](AUDITORIA_FINAL.md)

### Changed

- Sync imediato: `dashboard` LIVE em Fases 15, 16, 19, 20, 21 (`k*LiveSlugs`)
- Status formal alinhado ao critério 100% funcional (Fases 17, 24 → EM ANDAMENTO)
- `STATUS_PROJETO.md`, `CONTINUAR_PROJETO.md`, `ROADMAP.md` atualizados
- Testes Fases 15–21 atualizados

### Validation

- `flutter test`: 340 OK · APK + Web OK · A10 install OK

## [Fase 24 — Notícias Regionais] — 2026-07-20

### Added

- Card de notícias regionais na home do Gabinete (3–5 itens; destaque de menções)
- Hub `/home/news` (recentes, menções ao político, favoritos, alertas, busca, filtros)
- Detalhe com metadados, abrir original, compartilhar (copiar link), favoritos
- Cache `pg_news_*` sem corpo da matéria, pull-to-refresh, realtime
- Deep links `poligestor://news|noticias|noticias-regionais|regional-news/...`
- Testes `test/fase24_regional_news_test.dart`
- Documentação `docs/FASE_24_NOTICIAS_REGIONAIS.md`

### Changed

- Sync LIVE `/v1/news/*`: dashboard, mentions, favorites, alerts, sources, `/{article_id}`
- `EndpointPendingState` removido dos contratos publicados
- Recentes/feed/search/filters: fallback local enquanto paths agregados permanecem 404

### Notes

- `kNewsLiveSlugs`: 6 slugs LIVE; Pending só em recent, feed, search, filters
- Sem cópia integral da matéria no app
- Fase 24 sync LIVE parcial (6 endpoints); fechamento formal pendente paths agregados

## [1.0.0+2 — Fase 23 Homologação Final] — 2026-07-20

### Changed

- Homologação completa para produção (sem novos módulos)
- Correção `MandateIndicatorCard` (layout com altura ilimitada)
- Auditoria PT-BR e hubs mais altos no A10
- Remoção de código morto e anexos “Em breve” desabilitados
- Versão `1.0.0+2`

### Added

- `docs/RELEASE_NOTES.md`
- `docs/CHECKLIST_HOMOLOGACAO.md`
- `docs/FASE_23_HOMOLOGACAO_FINAL.md`

### Notes

- Fase 23 **CONCLUÍDA**; app pronto para aceite de produção 1.0
- Pendências de backend (404) permanecem com `EndpointPendingState`

## [Fase 22 — Integrações LIVE sync] — 2026-07-20

### Changed

- `kIntegrationsLiveSlugs` sincronizado com contratos LIVE da VPS (dashboard, health/status, settings/config, sync, history, logs, provedores, webhooks, catalog, providers)
- Paths oficiais alinhados: `health`, `settings`, `senado`, `esic`, `outlook`
- Parser de payloads (summary, live_providers, sync_runs, provider único)
- Configuração via GET/PUT `/settings`; sync POST 202
- Fase 22 marcada **CONCLUÍDA** (Pending apenas pesquisa/filtros)

### Notes

- Sem mocks; `EndpointPendingState` só em search/filters
- Fase 23 não iniciada

## [Fase 22 — Integrações] — 2026-07-20

### Added

- Hub `/home/integrations` (painel, status, configuração, sincronizações, histórico, registros, Gov.br, Câmara Municipal, Assembleia Legislativa, Câmara dos Deputados, Senado Federal, Diário Oficial, Portal da Transparência, e-SIC, Ouvidoria, Google Calendar, Outlook Calendar, Gmail, WhatsApp, Telegram, Firebase Push, APIs externas, webhooks, pesquisa, filtros)
- Namespace oficial `/v1/integrations/*` com `EndpointPendingState` (probe VPS 404 em todos)
- Cache `pg_int_*` (strip de segredos), realtime, Material 3, responsivo
- Deep links `poligestor://integrations|integracoes|integracao|central-integracoes/...`
- Testes `test/fase22_integrations_test.dart`
- Documentação `docs/FASE_22_INTEGRACOES.md`

### Notes

- `kIntegrationsLiveSlugs` vazio até a VPS publicar
- Independente de `/v1/admin/*` e `/v1/platform/*`
- Fase 23 não iniciada

## [Fase 21 — Segurança e Privacidade] — 2026-07-20

### Added

- Hub `/home/security` (MFA ativação/confirmação, recuperação de conta, sessões, encerramento remoto, histórico de acessos, dispositivos, alteração/políticas de senha, tokens/chaves de API, alertas, privacidade, consentimentos, termos, política de privacidade, solicitação/exportação/correção de dados, exclusão de conta, preferências, histórico de consentimentos, incidentes)
- Namespace oficial `/v1/security/*` com `EndpointPendingState` (probe VPS 404 em todos)
- Cache seguro `pg_sec_*` (strip de segredos), mascaramento de e-mail/CPF, realtime
- Deep links `poligestor://security|seguranca|privacidade|security-privacy/...`
- Testes `test/fase21_security_privacy_test.dart`
- Documentação `docs/FASE_21_SEGURANCA_PRIVACIDADE.md`

### Notes

- Tokens já em `FlutterSecureStorage` (`token_storage.dart`) — sem texto puro
- Independente de `/account/sessions` (`/v1/auth/sessions`)
- `kSecurityLiveSlugs` vazio até a VPS publicar
- Fase 22 não iniciada

## [Fase 20 — Portal Administrativo Web] — 2026-07-20

### Added

- Portal Web em `/platform` (painel geral, empresas, gabinetes, usuários, perfis/permissões, planos, licenciamento, assinaturas, cobranças, faturas, pagamentos, consumo, limites, métricas, monitoramento, saúde, registros, auditoria, sessões, integrações, webhooks, configurações globais/tenant, suporte, chamados, base de conhecimento, comunicados, releases, manutenções, relatórios, exportações, busca, filtros)
- Namespace oficial `/v1/platform/*` com `EndpointPendingState` (probe VPS 404 em todos)
- Shell responsivo (NavigationRail desktop / gaveta tablet), cache `pg_plat_*`, realtime
- Deep links `poligestor://platform|portal-admin|portal-administrativo|admin-web/...`
- Entrada em Mais somente na Web (`kIsWeb`) — Gabinete mobile e Cidadão inalterados
- Testes `test/fase20_platform_admin_test.dart`
- Documentação `docs/FASE_20_PORTAL_ADMINISTRATIVO_WEB.md`

### Notes

- Independente da Fase 19 (`/v1/admin/*`)
- `kPlatformLiveSlugs` vazio até a VPS publicar contratos
- Fase 21 não iniciada

## [Fase 19 — Administração do Sistema] — 2026-07-20

### Added

- Hub `/home/system-admin` (painel administrativo, empresas, gabinetes, usuários, perfis, papéis, permissões, equipes, departamentos, configurações, licenciamento, assinaturas, registros, auditoria, sessões, chaves de API, integrações, webhooks, cópia de segurança, monitoramento, saúde do sistema, configuração de e-mail/notificações/armazenamento, relatórios, exportações, pesquisa, filtros)
- Namespace oficial `/v1/admin/*` com `EndpointPendingState` (probe VPS 404 em todos)
- Cache `pg_adm_*`, realtime via `MandateRefreshController`, cards clicáveis
- Deep links `poligestor://system-admin|administracao|administracao-sistema|admin-sistema/...`
- Testes `test/fase19_system_admin_test.dart`
- Documentação `docs/FASE_19_ADMINISTRACAO_SISTEMA.md`

### Notes

- `kAdminLiveSlugs` vazio até a VPS publicar contratos
- Fechamento formal pendente (backend 404)
- Fase 20 não iniciada

## [Fase 18 — IA Avançada] — 2026-07-20

### Added

- Hub `/home/advanced-ai` (conversa, conversas, secretária, assessores, analistas, planejamento, resumos, sugestões, histórico, biblioteca de prompts, avaliação, configurações, pesquisa)
- Namespace oficial `/v1/ai/*` — endpoints LIVE + papéis via `/v1/ai/agents`
- Cache `pg_aai_*`, realtime via `MandateRefreshController`, cards clicáveis
- Deep links `poligestor://advanced-ai|ia-avancada|ia_avancada/...`
- Testes `test/fase18_advanced_ai_test.dart`
- Documentação `docs/FASE_18_IA_AVANCADA.md`

### Notes

- Independente do Sprint 10.5 Assistente Inteligente (`/home/chat`)
- Pending: `financial-analyst`, `settings`, `search`
- Validação A10 (`RX8M70CLXKP`) OK; Fase 19 não iniciada

## [Fase 17 — Gestão Eleitoral] — 2026-07-20

### Added

- Hub `/home/elections` (painel eleitoral, pré-campanha, campanhas, candidatos, coordenação, equipes, cabos eleitorais, voluntários, lideranças, apoiadores, metas, regiões, bairros, zonas/seções/colégios eleitorais, mapa, agenda, eventos, caminhadas, reuniões, visitas, comícios, mobilizações, materiais, estoque, distribuição, solicitações, pesquisas, cenários, intenção de voto, rejeição, comparativos, projeções, desempenho regional, prestação de contas, receitas, despesas, doações, fornecedores, comprovantes, relatórios, exportações, pesquisa, filtros)
- Namespace oficial `/v1/elections/*` — auditoria auth: **14 LIVE (HTTP 200)** + 31 Pending (404)
- Cache `pg_elec_*`, realtime via `MandateRefreshController`, cards clicáveis
- Deep links `poligestor://elections|gestao-eleitoral|gestao_eleitoral|eleitoral/...`
- Testes `test/fase17_elections_test.dart`
- Documentação `docs/FASE_17_GESTAO_ELEITORAL.md`

### Changed

- Auditoria LIVE: confirmação HTTP 200 nos 14 paths publicados; parsing de `summary`/agregados no painel
- Fase marcada **CONCLUÍDA** (pendência: validação física A10)

### Notes

- LIVE: `dashboard`, `campaigns`, `candidates`, `teams`, `goals`, `regions`, `neighborhoods`, `map`, `events`, `material-requests`, `projections`, `accountability`, `receipts`, `reports`
- `EndpointPendingState` apenas nos 31 paths ainda 404
- Fase 18 não iniciada

## [Fase 16 — CRM Político] — 2026-07-20

### Added

- Hub `/home/crm` (painel, líderes, apoiadores, eleitores, voluntários, equipe, entidades, associações, igrejas, empresas, influenciadores, segmentação, etiquetas, grupos, regiões, bairros, zonas eleitorais, histórico de relacionamento, interações, visitas, ligações, mensagens, reuniões, demandas/protocolos vinculados, campanhas, tarefas, lembretes, nível de apoio, potencial de influência, relacionamentos, importação, exportação, pesquisa, filtros, indicadores, relatórios)
- Namespace oficial `/v1/crm/*` com `EndpointPendingState` (probe VPS 404)
- Cache `pg_crm_*`, realtime via `MandateRefreshController`, cards clicáveis
- Deep links `poligestor://crm|crm-politico|crm_politico/...`
- Testes `test/fase16_crm_test.dart`
- Documentação `docs/FASE_16_CRM_POLITICO.md`

### Notes

- `kCrmLiveSlugs` vazio até a VPS publicar contratos
- Fechamento formal pelos 15 critérios pendente (backend 404)
- Fase 17 entregue no Flutter (ver entrada acima)

## [Fase 15 — Comunicação Institucional] — 2026-07-20

### Added

- Hub `/home/institutional-communication` (feed, comunicados, campanhas, biblioteca de mídia, publicações, agenda, notificação push, e-mail, WhatsApp, histórico, pesquisa, filtros, compartilhamento, relatórios)
- Namespace oficial `/v1/communication/*` com `EndpointPendingState` (probe VPS 404)
- Cache `pg_ic_*`, realtime via `MandateRefreshController`, cards clicáveis
- Deep links `poligestor://institutional-communication|comunicacao-institucional|comunicacao_institucional/...`
- Testes `test/fase15_institutional_communication_test.dart`
- Documentação `docs/FASE_15_COMUNICACAO_INSTITUCIONAL.md`

### Notes

- Central de Comunicação (Sprint 10.4) permanece em `/home/communication` com namespaces distintos
- Fechamento formal pelos 15 critérios pendente (backend 404)
- Fase 16 não iniciada

## [Encerramento do dia — continuidade Fase 14] — 2026-07-20

### Docs

- `CONTINUAR_PROJETO.md` reescrito (UTF-8): leitura **obrigatória** antes de qualquer implementação
- Snapshot do dia: Fase 14 CONCLUÍDA; analyze/test/web/APK/A10; commits; push
- Contratos LIVE F14 + `EndpointPendingState` restantes listados
- Próxima: **Fase 15 — Comunicação Institucional** (não iniciada)
- Checklist de retomada para amanhã
- `STATUS_PROJETO.md` atualizado com bloco de encerramento do dia

### QA (encerramento)

- `flutter analyze --no-fatal-infos`: 0 errors, 0 warnings, 37 infos
- `flutter test` Fase 13+14: 15/15 OK
- `flutter build web --release`: OK
- APK debug no A10: validação OK

## [Fase 14 — CONCLUÍDA / sync LIVE `/v1/finance/*`] — 2026-07-20

### Changed

- Fase 14 marcada **CONCLUÍDA** (backend sincronizado; A10 validado)
- LIVE: `dashboard`, `categories`, `cost-centers`, `alerts`, `reports`, `accounts`, `cashflow`, `transactions`, `payments`
- Paths publicados: contas → `/v1/finance/accounts`; fluxo → `/v1/finance/cashflow`
- Hub: Transações e Pagamentos; chips **Ativo** nos LIVE
- Docs `STATUS_PROJETO`, `CONTINUAR_PROJETO`, `FASE_14`, `CHANGELOG` atualizados
- Fase 15 **não iniciada**

## [Fase 14 — sync LIVE parcial `/v1/finance/*`] — 2026-07-20

### Changed

- Probe VPS: 5 paths LIVE (`dashboard`, `categories`, `cost-centers`, `alerts`, `reports` → HTTP 401 sem token)
- Hub com chips **Ativo** / **Em preparação** alinhados ao probe
- `kFinanceLiveSlugs` atualizado; `EndpointPendingState` só no restante 404
- Docs `CONTINUAR_PROJETO`, `STATUS_PROJETO`, `FASE_14`, `CHANGELOG` atualizados

### Notes

- Paths 404 permanecem em `EndpointPendingState`
- Fechamento formal pelos 15 critérios ainda pendente (backend incompleto)

## [Fase 14 — Gestão Financeira do Mandato] — 2026-07-20

### Added

- Hub `/home/finance` (painel, indicadores, saldo, receitas, despesas, contas bancárias, categorias, centros de custo, fornecedores, contratos, reembolsos, adiantamentos, verbas, orçamento, execução, prestação de contas, comprovantes, anexos, aprovações, conciliação, fluxo de caixa, contas a pagar/receber, alertas, histórico, filtros, pesquisa, relatórios, exportação)
- Namespace oficial `/v1/finance/*` com `EndpointPendingState` (probe VPS 404)
- Cache `pg_fin_*`, realtime via `MandateRefreshController`, cards clicáveis
- Deep links `poligestor://finance|financeiro|gestao-financeira|financas/...`
- Testes `test/fase14_finance_test.dart`
- Documentação `docs/FASE_14_GESTAO_FINANCEIRA.md`

### Notes

- Fechamento formal pelos 15 critérios pendente (backend 404)

## [Fase 13 — sync LIVE `/v1/documents/*`] — 2026-07-20

### Changed

- Probe VPS: todos os paths do hub `/v1/documents/*` → **HTTP 401** (LIVE)
- Chips do hub **Ativo**; `EndpointPendingState` fora do fluxo normal
- Lista oficial: `GET /v1/documents/list`
- Docs e STATUS: Fase 13 sincronizada Backend ↔ Flutter

## [Fase 13 — Gestão Documental] — 2026-07-20

### Added

- Hub `/home/documents` (lista, pesquisa, filtros, categorias, favoritos, histórico, linha do tempo, visualizador PDF, assinaturas, aprovações, compartilhamento, modelos, download, upload, anexos)
- Namespace oficial `/v1/documents/*` com `EndpointPendingState` (probe VPS 404 em todos os paths)
- Cache `pg_docs_*`, realtime via `MandateRefreshController`, cards clicáveis
- Deep links `poligestor://documents|documentos|gestao-documental/...`
- Testes `test/fase13_documents_test.dart`
- Documentação `docs/FASE_13_GESTAO_DOCUMENTAL.md`

### Notes

- Mais → Gestão Documental (substitui stub “Documentos / Em breve”)
- Sync LIVE posterior: ver entrada `[Fase 13 — sync LIVE /v1/documents/*]`

## [Fase 12 — sync LIVE Inteligência Territorial] — 2026-07-20

### Changed

- Probe VPS: 7 paths LIVE (`dashboard`, `kpis`, `charts`, `neighborhoods`, `regions`, `trends`, `projections` → HTTP 401 sem token)
- Hub com chips **Ativo** / **Em preparação** alinhados ao probe
- Parsing de listas ampliado (`neighborhoods`, `regions`, `charts`, `trends`, …)
- Painel BI com atalhos clicáveis, refresh e estados de cache
- Docs `CONTINUAR_PROJETO`, `STATUS_PROJETO`, `FASE_12`, `CHANGELOG` atualizados

### Notes

- Paths 404 permanecem em `EndpointPendingState`
- Fechamento formal pelos 15 critérios ainda pendente (backend incompleto)

## [Revisão UX/UI Gabinete] — 2026-07-20

### Fixed / Improved

- Faixa branca sob status bar removida (shell sem SafeArea no body; AppBar + `SystemUiOverlayStyle`)
- Dashboard Gabinete com hierarquia, tipografia e cards clicáveis no padrão do Início Cidadão
- Agenda staff: `GET /v1/mandate/agenda` (LIVE); 404 → `EndpointPendingState`; detalhe em sheet
- Protocolos: `AppErrorState`/`AppEmptyState`; detalhe com mensagens, histórico e anexos
- Cards informativos vs acionáveis; bairros sem `Navigator.push` (sheet); bottom bar A10
- APK debug no SM-A105M (`RX8M70CLXKP`)

## [Fase 12 — Inteligência Territorial] — 2026-07-20

### Added

- Hub `/home/territorial-intelligence` (painel BI, painel analítico, KPIs, indicadores, gráficos, mapas de calor, mapa, bairros, regiões, zonas eleitorais, lideranças, demandas, obras, protocolos, atendimentos, comparativos, evolução, tendências, projeções, filtros, exportações)
- Namespace oficial `/v1/intelligence/*` com `EndpointPendingState` (probe VPS 404 em todos os paths)
- Cache `pg_ti_*`, realtime via `MandateRefreshController`, filtros locais
- Deep links `poligestor://territorial-intelligence|inteligencia-territorial|...`
- Testes `test/fase12_territorial_intelligence_test.dart`
- Documentação `docs/FASE_12_INTELIGENCIA_TERRITORIAL.md` + `docs/CONTINUAR_PROJETO.md`

### Notes

- Aba Inteligência (Fase 9) em `/home/intelligence` permanece em `/v1/mandate/*`
- Fase 13 não iniciada; fechamento formal da Fase 12 pendente dos 15 critérios

## [Fase 11 — Gestão Institucional / Painel de Eventos] — 2026-07-20

### Added

- Hub `/home/events` (painel, eventos, agenda, calendário, audiências, reuniões, participantes, convites, presença, check-in/out, QR Code, galeria, fotos, vídeos, documentos, certificados, linha do tempo, mapa, indicadores, relatórios, pesquisa)
- Namespace oficial `/v1/events` — lista e detalhe LIVE; demais paths preparados com `EndpointPendingState` ou fallback local
- Cache `pg_events_*`, realtime via `MandateRefreshController`, filtros locais
- Deep links `poligestor://events|eventos|painel-eventos`
- Testes `test/fase11_events_test.dart`
- Documentação `docs/FASE_11_EVENTOS.md`
- Modelo de entrega por **Fases completas** (sem subdivisão em 11.1/11.2/…)

### Not started

- Fase 12

## [Sprint 11.0 — sync VPS `/v1/grants/*`] — 2026-07-19

### Changed

- Sincronização do namespace oficial `/v1/grants/*` (substitui paths legados `/v1/agreements/*` e `/v1/convenios/*`)
- `EndpointPendingState` removido dos domínios com HTTP 200 (painel, convênios, projetos, execução, prestação de contas, linha do tempo, documentos, relatórios)
- Hub com chips **Ativo** / **Em preparação** conforme probe LIVE
- Parsers ajustados para payload `kpis`/`summary` do painel e campos LIVE de convênios/linha do tempo

## [Sprint 11.0 — Painel de Convênios] — 2026-07-19

### Added

- Hub `/home/agreements` (painel, convênios, recursos, projetos, execução, prestação de contas, cronograma, linha do tempo, documentos, anexos, indicadores, relatórios, pesquisa)
- Contratos preparados `/v1/agreements/*` com `EndpointPendingState` honesto (namespace ainda ausente na VPS)
- Cache `pg_agree_*`, realtime via `MandateRefreshController`, filtros locais nas listas
- Deep links `poligestor://agreements|convenios|painel-convenios`
- Testes `test/sprint110_agreements_test.dart`

### Not started

- Sprint 11.1

## [Sprint 10.9 — Painel Obras] — 2026-07-19

### Added

- Hub `/home/works` (painel, obras, demandas, fiscalizações, cronograma, mapa, linha do tempo, fotos, anexos, checklist, indicadores, relatórios, pesquisa)
- Contratos preparados `/v1/works/*` com `EndpointPendingState` honesto (namespace ainda ausente na VPS)
- Reuso do mapa do mandato LIVE (`/v1/mandate/map`) na tela de mapa
- Cache `pg_works_*`, realtime via `MandateRefreshController`, filtros locais nas listas
- Deep links `poligestor://works|obras|painel-obras`
- Testes `test/sprint109_works_test.dart`

### Fixed

- Redirect do `GoRouter` para converter intents `poligestor://…` em rotas internas (`/home/works/…`), evitando `Page Not Found` no deep link Android
- Hub Painel Obras: 1 coluna no telefone (A10) e títulos com ellipsis — elimina `BOTTOM OVERFLOWED` nos cards

### Not started

- Sprint 11.0

## [Sprint 10.8 — Painel Parlamentar] — 2026-07-19

### Added

- Hub `/home/parliament` (painel, projetos de lei, indicações, requerimentos, moções, emendas, agenda, sessões, votações, base de apoio, demandas, pesquisa)
- Contratos LIVE `/v1/parliament/*` com cache `pg_parl_*` e realtime
- Pending: promessas, pesquisa dedicada, linha do tempo, histórico, anexos
- Deep links `poligestor://parliament|parlamentar|legislativo|painel-parlamentar`
- Testes `test/sprint108_parliament_test.dart`

### Not started

- Sprint 10.9

## [Idioma PT-BR na interface] — 2026-07-19

### Changed

- Regra permanente `.cursor/rules/pt-br-ui.mdc`: UI só em Português do Brasil
- Helpers `lib/shared/i18n/ui_labels.dart` (severidade, status, prioridade, tendência, chips)
- Textos de Estratégia, Automação, Assistente, Equipe Virtual, Inteligência, Comunicação, Mais e Conta traduzidos (ex.: Painel, Mapa de calor, Análises, Resumos, Registros, Linha do tempo, Transferências, Modelos, Ativo/Em preparação)

## [Sprint 10.7 — Painel Estratégico] — 2026-07-19

### Added

- Hub `/home/strategy` (dashboard, KPIs, heatmap, tendências, alertas, regiões, bairros, previsões, relatórios, mapa)
- Contratos LIVE `/v1/strategy/*` com cache `pg_strategy_*` e realtime via `MandateRefreshController`
- Pending honesto: metas, comparativos, indicadores, predições, mapa dedicado
- Reuso do mapa/bairros/relatórios do Mandato (sem duplicar regra)
- Deep links `poligestor://strategy|estrategia|strategic|painel-estrategico`
- Docs `docs/INTEGRACOES.md`; testes `test/sprint107_strategy_test.dart`

### Not started

- Sprint 10.8

## [Sprint 10.6 — Central de Automação] — 2026-07-19

### Added

- Hub `/home/automation` (dashboard, execuções, alertas, agentes, logs, métricas, histórico, autonomia)
- Reuso LIVE Equipe Virtual + `/v1/ai/team` sem duplicar regra de negócio
- Pending honesto: `/v1/automations*`, aprovações, agenda, editor (10 passos), escrita de autonomia com confirmação
- Cache por tenant `pg_auto_*`; deep links `poligestor://automation|automacao|automations`
- Testes `test/sprint106_automation_test.dart`

### Not started

- Sprint 10.7

## [Sprint 10.5 — Assistente Inteligente] — 2026-07-19

### Added

- Hub IA em `/home/chat` (rota legada Mais → Assistente Inteligente)
- LIVE: chat gabinete (`POST /v1/ai/chat`), conversas, briefing/briefings, insights
- Prepared + `EndpointPendingState`: resumo semanal, sugestões, prioridades, perguntas, favoritos, compartilhar
- Cache `pg_sa_*`, deep links `poligestor://assistant|assistente|chat|ai`
- Regra permanente LIVE-only em `.cursor/rules/live-only-apis.mdc`
- Testes `test/sprint105_smart_assistant_test.dart`

## [Sprint 10.4 — CONCLUÍDA] — 2026-07-19

### Status

- Sprint 10.4 marcada como **CONCLUÍDA** (canais, templates, campanhas + omnichannel conversations/queue/operators LIVE)

## [Sprint 10.4 sync — omnichannel LIVE] — 2026-07-19

### Changed

- Conversas / fila / operadores passam a consumir `GET /v1/omnichannel/conversations|queue|operators` (HTTP 200)
- Removido `EndpointPendingState` dessas três rotas; aba Conversas lista KPIs, operadores e conversas

## [Sprint 10.4 — Central de Comunicação] — 2026-07-19

### Added

- Feature `communication/` (PoliGestor only): modelos, cache, repository, hub Material 3
- LIVE: `GET /v1/channels`, `/v1/templates` (+ detalhe), `/v1/campaigns` (+ detalhe)
- Filtros `search` / `status` / `channel_type` / `sort` conforme contrato VPS
- Entrada staff em Mais; rotas `/home/communication/*`; deep links `poligestor://communication|comunicacao|comms`
- Testes `test/sprint104_communication_test.dart`

### Pending (VPS — sem mock)

- Conversas `/v1/conversations`, fila `/v1/queue`, operadores `/v1/operators`
- Preview/métricas de campanha quando publicados na API deste produto

### Isolation

- Nenhum código, API, DB, Redis, Reverb ou módulo de NexChat / NexISP / GestFin

## [Portal/Protocolos — auditoria] — 2026-07-19

### Improved

- Status: `status_label` LIVE + rótulos Novo / Em execução / Aguardando cidadão / Arquivado
- Timeline agrupada por data (cards)
- Lista cidadão: search + sort nos contratos LIVE
- Rating: fallback `/rating` e `/rate` quando `can_rate` sem link
- Anexos: PDF/áudio/vídeo + thumbnail; NPS UI preparada

### Pending

- 500 intermitente na listagem portal (VPS)
- Share nativo; filtros período na UI; paridade staff list

## [Sprint 10.2 Fechamento APK/OAuth] — 2026-07-19

### Fixed

- Build Android (AGP 9 + Flutter 3.44): aplicar `org.jetbrains.kotlin.android` no `:app` com `android.builtInKotlin=false` / `android.newDsl=false`
- OAuth POST trata 501/503 como indisponível; providers desabilitados não geram sessão

### Validated

- `flutter build apk --debug` + install SM-A105M; org → branding → login → perfil → sessões → troca org → logout
- Providers LIVE coerentes: password ok; google/apple/govbr disabled/ready=false; POST 501
- Portal profile/sessions/linked-accounts 200; staff profile/linked 403 (portal-only)

### Pending

- Credenciais OAuth reais + SDKs nativos; APNs; CPF demo válido; sync linked em modo staff

## [Sprint 10.2 Validação Final] — 2026-07-19

### Changed / Completed

- Revalidação VPS: resolve, branding e providers agora LIVE (HTTP 200)
- Parsing do contrato real (`organization`, `logo_path`, `is_enabled`/`ready`)
- Branding dinâmico (cores + logo de rede) na UX de login
- Providers externos só quando `enabled` + `ready`; OAuth aplica tokens na sessão
- Cache identity isolado por tenant; troca de org limpa tokens e caches
- Cadastro exige organização; respeita `registration_enabled`
- Testes de contrato LIVE em `test/sprint102_identity_test.dart`
- STATUS atualizado com classificação integrado / aguardando / iOS

### Pending (histórico — parcialmente resolvido no fechamento APK/OAuth)

- Apple/Google SDKs nativos + APNs (credenciais externas)
- QR camera nativo (deep link já funciona)

## [Sprint 10.2] — 2026-07-19 — CONCLUÍDA (Flutter)

### Added

- Fluxo org-first: `/org` → branding → `/login` (staff/portal)
- `lib/features/identity/` (models, cache, repository, TenantController, UI)
- `lib/features/account/` (sessions LIVE, perfil, linked accounts preparados)
- Cadastro, recuperação de senha, OAuth Google/Apple/Gov.br — estrutura + estados reais
- Branding dinâmico (`AppTheme.lightFromBranding`)
- Deep links `poligestor://org|tenant/{slug}`; intent-filters Android; URL scheme iOS
- Testes `test/sprint102_identity_test.dart`

### Integrated (HTTP 200)

- `/v1/auth/me`, `/v1/auth/sessions`, `DELETE /v1/auth/sessions/{id}`
- Login/refresh existentes

### Pending backend

- Resolve/branding/providers/register/forgot e espelhos portal ainda 500/404 — app conecta automaticamente quando HTTP 200

## [Sprint 10.1 Final] — 2026-07-19 — CONCLUÍDA

### Added / Completed

- Integração completa dos contratos REST da Equipe Virtual disponibilizados na VPS
- Telas: root/dashboard, agentes (+ sub-rotas), tarefas, execuções, hand-offs, timeline, alertas, métricas, auditoria, logs, pesquisa, memória, aprendizado, fila, eventos
- Remoção de estados “Endpoint indisponível” e de stubs 404
- Hand-offs via `GET /v1/virtual-team/handoffs`
- Refresh em tempo real via Reverb → `MandateRefreshController`
- Testes atualizados em `test/sprint101_virtual_team_test.dart`

### APIs (todas HTTP 200 na VPS)

- `/v1/virtual-team` e `/dashboard|/agents|/agents/{slug}`
- `/v1/virtual-team/agents/{slug}/tasks|executions|logs|metrics|timeline`
- `/v1/virtual-team/tasks|executions|events|memory|learning|queue`
- `/v1/virtual-team/logs|audit|search|metrics|timeline|alerts|handoffs`

## [Sprint 9.5] — 2026-07-19 — CONCLUÍDA

### Fixed / Improved

- Coalesce `NotificationsController.refresh` + debounce Reverb + throttle mandate bump
- AppSync resume soft (`onAuthenticated(soft: true)`) evita refresh/FCM duplicados
- Push ignora refresh de inbox quando Reverb está conectado
- Insights sem `generate=1` em refreshes passivos
- FCM token em FlutterSecureStorage; CPF mascarado no cache/perfil
- Login demo gated por `kDebugMode`
- Mais: itens órfãos “Em breve”; mapa do mandato funcional
- Semantics em indicadores/insights; dispose Push no app; remove `MandateStaleBanner`

### Tests

- `test/sprint95_hardening_test.dart`

### Validated

- `flutter test` 153 · analyze 0 errors · SM-A105M

## [Fase 9] — 2026-07-19 — CONCLUÍDA

### Added

- Feature `lib/features/intelligence/` (models, cache, repository, pages, widgets)
- Aba Inteligência no `HomeShell` + rotas `/home/intelligence/*` (staff only)
- Dashboard inteligente, briefing, insights, tendências, oportunidades, resumos e análises
- Paths `analytics` / `trends` / `insights` / `briefings` em `AuthMode`
- Testes `test/phase9_intelligence_test.dart`

### Changed

- Chat IA movido para a tela Mais (bottom bar: Protocolos, Agenda, Mandato, Inteligência, Mais)
- Documentação STATUS / ROADMAP / README / arquitetura

### Validated

- APIs Fase 9 HTTP 200; build debug no SM-A105M

### Known limitations

- Briefings históricos dependem dos jobs do backend
- Oportunidades = recorte de insights (sem rota própria na API)

## [Fase 8] — 2026-07-18 — CONCLUÍDA

### Added

- Feature `lib/features/mandate/` (models, cache, repository, pages, widgets)
- Aba Mandato no `HomeShell` + rotas `/home/mandate/*` (staff only)
- Overview executiva, briefing, pontos de atenção
- Agenda, bairros, assuntos, equipe, pesquisa (debounce), relatórios, mapa, painel TV
- `MandateRefreshController` ligado a resume (`AppSyncController`) e eventos Reverb
- Testes unitários/widget `test/phase8_mandate_test.dart`

### Changed

- Paths `/v1/mandate/*` em `AuthMode`
- Documentação STATUS / ROADMAP / README / arquitetura

### Validated

- Todos os endpoints mandato HTTP 200 na VPS
- Build debug no SM-A105M

### Known limitations

- Exportação de relatórios e mapa cartográfico dependem de campos futuros da API
- iOS não validado

## [Fase 7] — 2026-07-18 — CONCLUÍDA

### Added

- Firebase Core + Messaging (Android)
- Registro FCM em login; `DELETE …/devices/current` no logout
- Cliente Reverb/Pusher (`web_socket_channel`) + auth `/broadcasting/auth`
- Deep links `poligestor://protocols/{id}` e `poligestor://notifications`
- Preferências remotas `notification-preferences`
- Inbox: unread-count, filtros, paginação, POST read / read-all
- Polling REST 20s no detalhe do protocolo (fallback)
- Documentação de arquitetura / status / roadmap

### Validated

- Samsung SM-A105M: push real, deep link, FCM token real

### Known limitations

- iOS push não validado
