# Fase 20 — Portal Administrativo Web

Atualizado: 2026-07-20

## Escopo

Interface administrativa da **plataforma** (Web), consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/platform/*`

Independente da Fase 19 (`/v1/admin/*`) e das experiências de Gabinete (`/home/*`) e Portal do Cidadão (`/citizen/*`).

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

## Entrada

- Rota dedicada: `/platform` (shell próprio com NavigationRail / gaveta)
- Login staff continua em `/home/dashboard` (Gabinete inalterado)
- Em Mais: atalho **somente na Web** (`kIsWeb`) → Portal administrativo

## Telas (33)

Painel geral · Empresas · Gabinetes · Usuários · Perfis e permissões · Planos · Licenciamento · Assinaturas · Cobranças · Faturas · Pagamentos · Consumo por gabinete · Limites dos planos · Métricas · Monitoramento · Saúde dos serviços · Registros · Auditoria · Sessões · Integrações · Webhooks · Configurações globais · Configurações por tenant · Suporte · Chamados · Base de conhecimento · Comunicados · Releases · Manutenções · Relatórios · Exportações · Busca · Filtros

## Auditoria VPS (2026-07-20, autenticado)

**Todos os paths `/v1/platform/*` do hub retornaram HTTP 404.**

`kPlatformLiveSlugs` permanece **vazio**. UI com chips **Em preparação** e `EndpointPendingState` (short-circuit local antes da rede).

## Flutter

- Feature: `lib/features/platform_admin/`
- Cache: `pg_plat_{tenant}_*`
- Offline: cache em falha de rede (quando LIVE)
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://platform|portal-admin|portal-administrativo|admin-web/...`
- Layout responsivo: rail ≥900 px, gaveta &lt;900, conteúdo máx. ~1200 px
- Perfil do operador exibido no shell (sessão)

## Status formal

**EM ANDAMENTO** (Flutter/Web entregue; backend 100% 404 → Pending).

**Fase 21 — não iniciada.**
