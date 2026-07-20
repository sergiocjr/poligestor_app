# Continuar projeto — PoliGestor / MandatoOS (Flutter)

> **LEITURA OBRIGATÓRIA** antes de iniciar **qualquer** nova implementação, sprint, fase ou correção.
> Sem ler este arquivo + `STATUS_PROJETO.md` + `CHANGELOG.md` + `git log -5`, **não começar código**.

**Referência oficial do aplicativo.** Atualizar ao final de toda Fase e ao encerrar o dia de trabalho.

Atualizado: 2026-07-20 (Fase 20 — Portal Administrativo Web entregue; fechamento formal pendente)

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
| Fase | **Fase 20 — Portal Administrativo Web** |
| Status formal | **EM ANDAMENTO** (Flutter/Web entregue; `/v1/platform/*` 100% 404 → Pending) |
| Entrada | Rota `/platform` (shell Web); Mais somente `kIsWeb` |
| Namespace oficial | `/api/v1/platform/*` |
| Doc da fase | [FASE_20_PORTAL_ADMINISTRATIVO_WEB.md](FASE_20_PORTAL_ADMINISTRATIVO_WEB.md) |
| Fase 19 | **EM ANDAMENTO** (`/v1/admin/*` 404) |
| Fase 18 | **EM ANDAMENTO** (`/v1/ai/*` sync parcial) |
| Fase 17 | **CONCLUÍDA** (pendência A10 física) |
| Fase 21 | **Não iniciar** sem pedido explícito |

---

## Git

| Campo | Valor |
|-------|--------|
| Branch | `master` |
| Último commit | `092e333` — feat Fase 20 Portal Administrativo Web |
| Push | origin/master |
| Dispositivo | SM-A105M `RX8M70CLXKP` (não exigido nesta fase Web) |

### Navegação

- Gabinete staff: `/home/dashboard` (inalterado)
- Portal do Cidadão: `/citizen/*` (inalterado)
- Portal administrativo Web: `/platform`
- Fase 19 Administração (app): `/home/system-admin` (`/v1/admin/*`)

---

## Telas (Fase 20)

Painel geral · Empresas · Gabinetes · Usuários · Perfis e permissões · Planos · Licenciamento · Assinaturas · Cobranças · Faturas · Pagamentos · Consumo por gabinete · Limites dos planos · Métricas · Monitoramento · Saúde dos serviços · Registros · Auditoria · Sessões · Integrações · Webhooks · Configurações globais · Configurações por tenant · Suporte · Chamados · Base de conhecimento · Comunicados · Releases · Manutenções · Relatórios · Exportações · Busca · Filtros.

Material 3 · rail/gaveta responsiva · PT-BR · cache `pg_plat_*` · realtime (`MandateRefreshController`).

---

## Contratos LIVE consumidos (Fase 20)

| Método | Path | Status VPS |
|--------|------|------------|
| — | `/v1/platform/*` | **Nenhum LIVE** (todos 404; `kPlatformLiveSlugs` vazio) |

---

## Deep Links

```
poligestor://platform/...
poligestor://portal-admin/...
poligestor://portal-administrativo/...
poligestor://admin-web/...
```

---

## Pendências reais (fechamento formal)

1. Backend publicar `/v1/platform/*`.
2. Sync LIVE (chips Ativo) + auditoria payloads 200/201/202.
3. Fechamento formal das Fases 11, 12, 15, 16, 18 e 19 (quando solicitado).

## Próxima Fase

**Fase 21 — não iniciar** sem pedido explícito.
