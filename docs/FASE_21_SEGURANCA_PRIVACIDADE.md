# Fase 21 — Segurança e Privacidade

Atualizado: 2026-07-20

## Escopo

Experiência de segurança e privacidade no Flutter, consumindo **exclusivamente**:

`https://poligestor.onnexis.com.br/api/v1/security/*`

Independente de `/v1/auth/sessions` (conta) e das Fases 19/20 (`/v1/admin/*`, `/v1/platform/*`).

Sem aliases inventados. Sem mocks. Sem alteração de backend neste repositório.

## Hub

**Mais → Segurança e Privacidade** (`/home/security`)

Acesso: staff e portal autenticados.

## Telas (22)

Ativação de autenticação em duas etapas · Confirmação de autenticação em duas etapas · Recuperação segura de conta · Sessões ativas · Encerramento remoto de sessões · Histórico de acessos · Dispositivos conectados · Alteração de senha · Políticas de senha · Tokens e chaves de API · Alertas de segurança · Privacidade · Consentimentos · Termos de uso · Política de privacidade · Solicitação de dados · Exportação de dados · Correção de dados · Exclusão de conta · Preferências de privacidade · Histórico de consentimentos · Incidentes e avisos

## Auditoria VPS (2026-07-20, autenticado)

**Todos os paths `/v1/security/*` do hub retornaram HTTP 404** (GET e POST).

`kSecurityLiveSlugs` permanece **vazio**. UI com chips **Em preparação** e `EndpointPendingState` (short-circuit local).

## Segurança local

- Tokens de acesso/refresh: `FlutterSecureStorage` via `lib/core/storage/token_storage.dart` (já existente; não armazena token em texto puro)
- Cache `pg_sec_*`: remove chaves sensíveis (`token`, `password`, `secret`, `api_key`, etc.) antes de gravar
- Modelos: e-mail e CPF mascarados na apresentação
- Sem `print`/`debugPrint` de credenciais

## Flutter

- Feature: `lib/features/security_privacy/`
- Realtime: `MandateRefreshController`
- Deep links: `poligestor://security|seguranca|privacidade|security-privacy/...`
- UI 100% PT-BR, Material 3, cards clicáveis, responsivo

## Status formal

**EM ANDAMENTO** (Flutter entregue; backend 100% 404 → Pending).

Validação A10 (`RX8M70CLXKP`): hub + Pending OK; emulador não iniciado.

**Fase 22 — não iniciada.**
