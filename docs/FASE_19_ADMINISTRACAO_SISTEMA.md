# Fase 19 — Administração do Sistema

Atualizado: 2026-07-20

## Escopo

Módulo completo de Administração do Sistema no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/admin/*`

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

## Hub

**Mais → Administração do Sistema** (`/home/system-admin`)

## Telas

Painel administrativo · Empresas · Gabinetes · Usuários · Perfis · Papéis · Permissões · Equipes · Departamentos · Configurações · Licenciamento · Assinaturas · Registros · Auditoria · Sessões · Chaves de API · Integrações · Webhooks · Cópia de segurança · Monitoramento · Saúde do sistema · Configuração de e-mail · Configuração de notificações · Configuração de armazenamento · Relatórios · Exportações · Pesquisa · Filtros

## Auditoria VPS (2026-07-20, autenticado)

**Todos os paths `/v1/admin/*` do hub retornaram HTTP 404.**

`kAdminLiveSlugs` permanece **vazio**. UI completa com chips **Em preparação** e `EndpointPendingState`.

| Path | Status |
|------|--------|
| `/v1/admin/dashboard` | Preparado (404) |
| `/v1/admin/companies` | Preparado (404) |
| `/v1/admin/offices` | Preparado (404) |
| `/v1/admin/users` | Preparado (404) |
| `/v1/admin/profiles` | Preparado (404) |
| `/v1/admin/roles` | Preparado (404) |
| `/v1/admin/permissions` | Preparado (404) |
| `/v1/admin/teams` | Preparado (404) |
| `/v1/admin/departments` | Preparado (404) |
| `/v1/admin/settings` | Preparado (404) |
| `/v1/admin/licensing` | Preparado (404) |
| `/v1/admin/subscriptions` | Preparado (404) |
| `/v1/admin/logs` | Preparado (404) |
| `/v1/admin/audit` | Preparado (404) |
| `/v1/admin/sessions` | Preparado (404) |
| `/v1/admin/api-keys` | Preparado (404) |
| `/v1/admin/integrations` | Preparado (404) |
| `/v1/admin/webhooks` | Preparado (404) |
| `/v1/admin/backup` | Preparado (404) |
| `/v1/admin/monitoring` | Preparado (404) |
| `/v1/admin/health` | Preparado (404) |
| `/v1/admin/email-settings` | Preparado (404) |
| `/v1/admin/notification-settings` | Preparado (404) |
| `/v1/admin/storage-settings` | Preparado (404) |
| `/v1/admin/reports` | Preparado (404) |
| `/v1/admin/exports` | Preparado (404) |
| `/v1/admin/search` | Preparado (404) |
| `/v1/admin/filters` | Preparado (404) |

Quando a VPS publicar (HTTP 401 sem token ou 200 autenticado), marcar chips **Ativo** em `kAdminLiveSlugs` e retirar `EndpointPendingState` do fluxo normal.

## Flutter

- Feature: `lib/features/system_admin/`
- Cache: `pg_adm_{tenant}_*`
- Offline: cache em falha de rede
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://system-admin|administracao|administracao-sistema|admin-sistema/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo (A10)

## Status formal

**EM ANDAMENTO** (Flutter entregue; backend 100% 404 → Pending).

Validação A10 (`RX8M70CLXKP`): hub + `EndpointPendingState` OK.

**Fase 20 — não iniciada.**
