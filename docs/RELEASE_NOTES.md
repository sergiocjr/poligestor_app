# Notas de versão — PoliGestor / MandatoOS 1.0.0+6

**Versão:** `1.0.0+6`  
**Data:** 2026-07-21  
**Commit:** `a528f15`  
**Catálogo backend:** c29c2ad  

## Resumo

Sincronização definitiva do aplicativo Flutter com o catálogo LIVE publicado na VPS. **Todos os cards de hub exibem “Ativo”** e consomem a API real — sem telas “Em preparação”, “Demonstração” ou mensagens “aguardando contrato na VPS”.

## Destaques desta versão

### Sincronização LIVE (c29c2ad)

- Namespace **Automação** migrado para `/v1/automation/*` (singular)
- Remapeamento de paths em Financeiro, CRM, Admin, Plataforma, Segurança, Eventos, Parlamento, Estratégia, Obras, Convênios, IA e Inteligência Territorial
- **15** arquivos de contratos `*_contracts.dart` + automação
- `/v1/events/viewer` permanece **proibido**

### Experiência do usuário

- Chip de contrato: sempre **Ativo**
- Remoção de avisos “Demonstração / contrato publicado” nos hubs
- Listas LIVE vazias: estado vazio honesto (sem dados fictícios automáticos)
- Erro de sessão (401): mensagem clara para novo login
- Telas de módulos sem painel “aguardando VPS”

### Módulos com consumo LIVE ampliado

- Automação (dashboard, regras, execuções, aprovações, alertas, métricas, agendas, agentes)
- Gestão Financeira, CRM, Eleições, Documentos, Comunicação Institucional
- Administração, Plataforma, Segurança, Integrações
- Eventos, Obras, Convênios, Parlamento, Estratégia, IA Avançada, Inteligência Territorial, Notícias

## Dados de demonstração

| Situação | Comportamento |
|----------|---------------|
| API retorna lista vazia | Tela vazia (“Nenhum registro encontrado”) |
| API marca `meta.demo=true` | Rótulo “Dados de referência” |
| Portal cidadão (bairro) | Conteúdo ilustrativo local em telas específicas |

## Pendências conhecidas

1. Validação visual completa no Samsung Galaxy A10 (todos os hubs).
2. Suíte completa `flutter test` (~348) após bump +6.
3. Build Web release `1.0.0+6`.
4. Alguns cards de hub usam **alias** para endpoint agregado do catálogo (ex.: vários cards CRM → `/contacts`).
5. Escrita de autonomia na automação (`autonomy-write`) sem POST publicado.
6. OAuth nativo register/forgot (backend Sprint 10.2).
7. Aceite produção / publicação em loja.

## Validação

| Item | Resultado |
|------|-----------|
| Testes de contrato (fases 11–22 + sprints) | **142/142** |
| `flutter analyze` (escopo alterado) | Sem erros |
| APK debug A10 `RX8M70CLXKP` | Instalado + aberto |
| Probe VPS (paths críticos) | HTTP 200 |
| Emulador | Não utilizado |

## Instalação

- Android: `build/app/outputs/flutter-apk/app-debug.apk` (debug validado) / release pendente
- Web: artefatos em `build/web/` (rebuild pendente para +6)
- Dispositivo oficial de QA: SM-A105M via USB ADB (`RX8M70CLXKP`)

## Continuidade

Leia **obrigatoriamente** antes de qualquer implementação:

1. `docs/CONTINUAR_PROJETO.md`
2. `docs/STATUS_PROJETO.md`
3. `docs/CHANGELOG.md`
