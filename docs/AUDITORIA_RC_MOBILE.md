# Auditoria RC Mobile — PoliGestor 1.0.0+4

Atualizado: 2026-07-21

## Escopo

Auditoria Release Candidate do app Flutter sem alteração de arquitetura, APIs, namespaces ou remoção de funcionalidades.

---

## Itens corrigidos

| # | Área | Correção |
|---|------|----------|
| 1 | Design system | `lib/shared/widgets/pg_design_system.dart` — `PgStatusChip`, `PgStandardAppBar`, `PgSearchField`, `PgHubModuleTile`, `pgFormatResolutionHours`, bottom sheet padrão |
| 2 | Hubs (18 módulos) | Altura de grid aumentada (`136/124px`); títulos 3 linhas sem ellipsis |
| 3 | AppBars de listas | Títulos com 2 linhas (`softWrap`) |
| 4 | Mandato / dashboards | `0.0 h` → `—`; rótulos KPI 2 linhas; chip `Informativo` padronizado |
| 5 | Perfil | `GET /v1/auth/profile`; merge com sessão; CPF/telefone da API; skeleton + refresh + erro amigável |
| 6 | Sessões | Dedupe por `session_id`; ordenação por último acesso; cards com Dispositivo/IP/Sistema/Atual |
| 7 | Protocolo detalhe | Seções Categoria e Origem; layout descrição preservado |
| 8 | AuthUser | Campo `phone` parseado do JSON |
| 9 | UX demo | Mantida política “Dados de demonstração” (sem “Em preparação” visível) |

---

## Problemas encontrados (app)

| Problema | Status RC |
|----------|-----------|
| Títulos truncados em hubs | **Corrigido** (altura + softWrap) |
| KPI `0.0 h` / “Prazo de atendim...” | **Corrigido** |
| Perfil sem sync API | **Corrigido** (`getProfile`) |
| Sessões duplicadas | **Corrigido** (dedupe repo) |
| Tela branca | **Não reproduzida** — splash/erro/vazio cobertos; monitorar rota específica se persistir |
| Padronização total cards/botões/search | **Parcial** — design system criado; migração gradual nos 23 módulos |
| Lint zero warnings | **Pendente** — ~50 avisos info/warning legados (imports, prefer_*) |

---

## Pendências reais da VPS

Ver [AUDITORIA_FINAL.md](AUDITORIA_FINAL.md). Resumo:

- `/v1/works/*`, `/v1/automations/*` — majoritariamente 404
- `/v1/news/recent|feed|search|filters` — 404 (fallback local)
- Subpaths CRM, Comunicação, Admin, Plataforma, Segurança — 404 exceto `dashboard`
- OAuth nativo, register/forgot — backend parcial

---

## Endpoints ainda inexistentes (404 confirmado)

| Namespace | Exemplos 404 |
|-----------|----------------|
| works | dashboard, listas, search |
| automations | CRUD completo |
| news | recent, feed, search, filters |
| integrations | search, filters |
| communication/crm/admin/platform/security | subpaths além de dashboard |
| elections | 31 paths |
| ai | search, settings parciais |

---

## Testes executados

| Teste | Resultado |
|-------|-----------|
| `flutter analyze` | **0 erros** (~50 warnings info) |
| `flutter test` | **344 OK** |
| `flutter build web` | **OK** (`build/web`) |
| `flutter build apk --debug` | **OK** (`app-debug.apk`) |
| Samsung A10 `RX8M70CLXKP` | **N/A nesta sessão** (build gerado; instalação manual) |

---

## Artefatos

- APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Web: `build/web`
- Versão: **1.0.0+4**

---

## Garantias

- Nenhuma funcionalidade inventada
- Nenhum contrato HTTP alterado
- Nenhum namespace modificado
- Demonstração rotulada mantida onde VPS não publica dados
