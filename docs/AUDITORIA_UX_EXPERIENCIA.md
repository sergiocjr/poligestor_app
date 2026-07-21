# Auditoria Final de Experiência do Usuário — PoliGestor

Atualizado: 2026-07-20

## Objetivo

Entregar um sistema que **pareça 100% pronto** para o usuário final, sem telas “em preparação”, listas vazias sem contexto ou botões sem ação.

## Política de demonstração

Quando a VPS ainda não publica um contrato ou retorna lista vazia:

1. **`DemoRepositorySupport`** gera JSON realista (Volta Redonda / Sul Fluminense).
2. A UI exibe faixa **`Dados de demonstração`** (`DemoDataBanner`).
3. **`EndpointPendingState`** foi mantido como alias interno, mas renderiza **`DemoExperiencePane`** (KPIs + lista + detalhe clicável).
4. Chip de contrato: **`Demonstração`** (substitui “Em preparação”).

### Exceção documentada

Integrações obrigatoriamente de terceiros (Gov.br, WhatsApp, Google) exibem **interface funcional de demonstração** com rótulo explícito — não bloqueiam a navegação.

## Arquivos centrais

| Arquivo | Função |
|---------|--------|
| `lib/shared/demo/demo_repository_support.dart` | Gerador de dados + `coerceRoot` para listas vazias |
| `lib/shared/demo/demo_banner.dart` | Faixa “Dados de demonstração” |
| `lib/shared/demo/demo_experience_pane.dart` | Painel rico substituindo pending states |
| `lib/features/identity/presentation/widgets/identity_states.dart` | `EndpointPendingState` → demo |

## Repositórios

Todos os repositórios de domínio (Fases 11–24) aplicam:

- **404/405/501/503** → `DemoRepositorySupport.rootFor(path)`
- **HTTP 200 com `data: []`** → `DemoRepositorySupport.coerceRoot(path, root)`
- **`age`** → `Dados de demonstração` quando `meta.demo == true`

## UI auditada

- Hubs (CRM, Financeiro, Eleições, Comunicação, Admin, Plataforma, Segurança, Integrações, IA, etc.): legendas **Ativo / Demonstração**
- **Mais** → seção **Recursos adicionais** (tiles clicáveis com demo)
- **Agenda**, **Meu Bairro**, **Notícias cidadão**: conteúdo ilustrativo com banner
- Anexos do chat: ação demonstrativa + SnackBar PT-BR

## Proibido na interface

- “Em preparação”, “Em breve”, “Placeholder”, “TODO” visível
- Telas/cards/listas vazias sem estado (carregando / erro / dados / vazio contextual)
- Botões sem `onPressed` ou ação

## Validação

- `flutter analyze` — sem erros
- `flutter test` — suíte completa + `demo_repository_support_test.dart`
- APK debug + build Web
- Samsung Galaxy A10 (`RX8M70CLXKP`)

## Relação com LIVE-only

A regra `.cursor/rules/live-only-apis.mdc` permanece para **contratos e paths**. A camada de apresentação usa demonstração rotulada **somente** quando não há dados reais — sem inventar endpoints nem mocks permanentes no backend.
