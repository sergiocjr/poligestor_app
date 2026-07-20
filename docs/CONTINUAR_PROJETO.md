# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 19 — Administração do Sistema entregue no Flutter; fechamento formal pendente)

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
| Fase | **Fase 19 — Administração do Sistema** |
| Status formal | **EM ANDAMENTO** (Flutter entregue; `/v1/admin/*` 100% 404 → Pending) |
| Hub | Mais → Administração do Sistema (`/home/system-admin`) |
| Namespace oficial | `/api/v1/admin/*` |
| Doc da fase | [FASE_19_ADMINISTRACAO_SISTEMA.md](FASE_19_ADMINISTRACAO_SISTEMA.md) |
| Fase 18 | **EM ANDAMENTO** (`/v1/ai/*` sync parcial) |
| Fase 17 | **CONCLUÍDA** (pendência A10 física) |
| Fase 16 | **EM ANDAMENTO** (`/v1/crm/*` 404) |
| Fase 15 | **EM ANDAMENTO** (`/v1/communication/*` 404) |
| Fase 14 | **CONCLUÍDA** |
| Fase 20 | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | `a78ceec` — feat Fase 19 Administração do Sistema |
| Push | origin/master |
| Dispositivo | SM-A105M `RX8M70CLXKP` |

### Navegação Gabinete

- Inicial: `/home/dashboard` (Gabinete)
- Abas: Gabinete · Protocolos · Agenda · Mandato · Mais
- Administração do Sistema: Mais → hub `/home/system-admin`
- IA Avançada: Mais → `/home/advanced-ai`
- Assistente Inteligente (Sprint 10.5): Mais → `/home/chat`

---

## Telas (Fase 19)

Painel administrativo · Empresas · Gabinetes · Usuários · Perfis · Papéis · Permissões · Equipes · Departamentos · Configurações · Licenciamento · Assinaturas · Registros · Auditoria · Sessões · Chaves de API · Integrações · Webhooks · Cópia de segurança · Monitoramento · Saúde do sistema · Configuração de e-mail · Configuração de notificações · Configuração de armazenamento · Relatórios · Exportações · Pesquisa · Filtros.

Material 3 · cards clicáveis · PT-BR · responsivo · cache `pg_adm_*` · offline · realtime (`MandateRefreshController`).

---

## Contratos LIVE consumidos (Fase 19)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/admin/*` | **Nenhum LIVE** (todos 404; `kAdminLiveSlugs` vazio) |

---

## EndpointPendingState (28)

`dashboard`, `companies`, `offices`, `users`, `profiles`, `roles`, `permissions`, `teams`, `departments`, `settings`, `licensing`, `subscriptions`, `logs`, `audit`, `sessions`, `api-keys`, `integrations`, `webhooks`, `backup`, `monitoring`, `health`, `email-settings`, `notification-settings`, `storage-settings`, `reports`, `exports`, `search`, `filters`.

---

## Deep Links

```
poligestor://system-admin/...
poligestor://administracao/...
poligestor://administracao-sistema/...
poligestor://admin-sistema/...
```

---

## Samsung Galaxy A10

| Campo | Valor |
|-------|--------|
| Dispositivo oficial | SM-A105M — `RX8M70CLXKP` |
| Emulador | **Proibido** |
| Validação APK Fase 19 | OK (hub + EndpointPendingState) |

---

## Pendências reais (fechamento formal)

1. Backend publicar `/v1/admin/*`.
2. Sync LIVE (chips Ativo) + auditoria payloads 200.
3. Fechamento formal das Fases 11, 12, 15, 16 e 18 (quando solicitado).
4. Validação física A10 da Fase 17 (se ainda pendente).

## Próxima Fase

**Fase 20 — não iniciar** sem pedido explícito.
