# Notas de versão — PoliGestor / MandatoOS 1.0.0

**Versão:** `1.0.0+2`  
**Data:** 2026-07-20  
**Fase:** 23 — Homologação Final  

## Resumo

Primeira versão de produção do aplicativo Flutter PoliGestor/MandatoOS, com operação em campo (staff/gabinete) e portal do cidadão, consumindo exclusivamente a API LIVE `https://poligestor.onnexis.com.br/api`.

## Destaques

- Autenticação dual (staff / portal) com tokens em armazenamento seguro
- Portal do cidadão: protocolos, conversa, anexos, notificações, perfil
- Gabinete: mandato, inteligência, equipe virtual, automação, estratégia, parlamento, obras, convênios, eventos
- Módulos institucionais: documentos, finanças, comunicação, CRM, gestão eleitoral, IA avançada
- Administração do sistema, portal administrativo Web, segurança/privacidade, central de integrações
- Push (Firebase), realtime (Reverb), deep links `poligestor://…`
- Cache offline por módulo, estados de carregamento/vazio/erro e `EndpointPendingState` onde o contrato ainda não foi publicado
- UI 100% Português do Brasil, Material 3, responsiva (A10 e Web)

## Correções da homologação (Fase 23)

- Correção de layout em `MandateIndicatorCard` (flex com altura ilimitada)
- Auditoria PT-BR (Baixar/Enviar, Lista de verificação, Versões, Indicadores, etc.)
- Remoção de código morto (`citizen_chat_page`, `LoadingView`, `ErrorView`)
- Anexos “Em breve” do assistente desabilitados (sem ação enganosa)
- Altura de cards de hub aumentada em telas estreitas (A10)
- Build number `+2` para o pacote de homologação

## Pendências conhecidas (não bloqueiam 1.0)

Contratos ainda em preparação (404) em partes de: segurança (`/v1/security/*`), admin (`/v1/admin/*`), platform (`/v1/platform/*`), comunicação institucional, CRM, inteligência territorial (parcial), integrações (`search`/`filters`), e demais chips **Em preparação** documentados por fase.

## Validação

| Item | Resultado |
|------|-----------|
| `flutter analyze` | Sem erros/warnings (apenas infos de estilo) |
| `flutter test` | 333/333 |
| APK release | OK |
| Web release | OK |
| Samsung Galaxy A10 `RX8M70CLXKP` | OK |
| Emulador | Não utilizado |

## Instalação

- Android: APK release gerado em `build/app/outputs/flutter-apk/`
- Web: artefatos em `build/web/`
- Dispositivo oficial de QA: SM-A105M via USB ADB

## Contato / continuidade

Ver `docs/CONTINUAR_PROJETO.md`, `docs/STATUS_PROJETO.md` e `docs/CHECKLIST_HOMOLOGACAO.md`.
