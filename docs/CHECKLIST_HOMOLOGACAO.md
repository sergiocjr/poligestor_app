# Checklist de Homologação — PoliGestor 1.0

**Versão:** `1.0.0+2`  
**Data:** 2026-07-20  
**Dispositivo:** Samsung Galaxy A10 (SM-A105M) — `RX8M70CLXKP`  
**Emulador:** proibido nesta homologação  

Legenda: `[x]` ok · `[ ]` pendente · `[~]` parcial / conhecido

---

## Builds e qualidade

- [x] `flutter analyze` sem erros/warnings bloqueantes
- [x] `flutter test` (333 testes)
- [x] Build APK release
- [x] Build Web release
- [x] Versão `1.0.0+2` em `pubspec.yaml`
- [x] Sem TODO/FIXME em `lib/`
- [x] Código morto removido (export/chat legado, LoadingView/ErrorView)

## Navegação e deep links

- [x] Shell staff (Home / Mais / módulos)
- [x] Shell cidadão
- [x] Portal Web `/platform` (somente Web)
- [x] Deep links `poligestor://` (AndroidManifest + NotificationRouter)
- [x] Redirecionamento staff ↔ portal

## UX / UI

- [x] Material 3
- [x] Tipografia e ícones consistentes nos hubs
- [x] Cards com ação (InkWell/onTap) ou desabilitados honestamente
- [x] Botões com rótulos PT-BR
- [x] Overflow mitigado em hubs (extent ≥ 104 no A10; ellipsis)
- [x] Correção `MandateIndicatorCard` (Spacer em Column ilimitada)
- [x] Responsividade (coluna única no A10; grid largo na Web)

## Estados

- [x] Carregamento (skeletons / progress)
- [x] Vazio (`AppEmptyState`)
- [x] Erro com retry (`AppErrorState`)
- [x] `EndpointPendingState` apenas onde contrato não LIVE

## Offline / cache / realtime

- [x] Caches por tenant (`pg_*`)
- [x] Tokens em `FlutterSecureStorage`
- [x] Realtime Reverb + refresh de mandato
- [x] Push FCM (registro/desregistro)

## APIs

- [x] Base LIVE `https://poligestor.onnexis.com.br/api`
- [x] Sem mocks na entrega
- [x] Sem inventar paths; Pending quando 404/405/501/503
- [x] Catálogo de integrações sincronizado (Fase 22)

## Segurança

- [x] Tokens não em texto puro
- [x] Logs de debug condicionados a `kDebugMode` nas telas críticas
- [x] Mascaramento de documento/e-mail onde aplicável (Fases 9.5 / 21)
- [x] Strip de segredos em caches de segurança/integrações

## Idioma

- [x] Auditoria PT-BR (Download→Baixar, Upload→Enviar, Checklist→Lista de verificação, Releases→Versões, KPIs→Indicadores, etc.)
- [x] Marcas oficiais preservadas (Firebase, Gmail, WhatsApp, Google Calendar, API, HTTP)

## Samsung Galaxy A10

- [x] Instalação APK
- [x] Abertura via deep link hub (ex.: integrações)
- [x] Sem emulador iniciado
- [~] Percorrer manualmente todos os hubs em sessão autenticada (recomendado no aceite final)

## Flutter Web

- [x] Build release
- [x] Entrada Portal administrativo somente em `kIsWeb`
- [~] Smoke manual no Chrome pós-deploy

## Documentação

- [x] `docs/STATUS_PROJETO.md`
- [x] `docs/CHANGELOG.md`
- [x] `docs/CONTINUAR_PROJETO.md`
- [x] `docs/RELEASE_NOTES.md`
- [x] `docs/CHECKLIST_HOMOLOGACAO.md` (este arquivo)
- [x] `docs/FASE_23_HOMOLOGACAO_FINAL.md`

## Aceite produção 1.0

- [x] Homologação técnica concluída (análise + testes + builds + A10)
- [ ] Aceite funcional do produto (assinatura do responsável)
- [ ] Publicação loja / hospedagem Web (fora do escopo deste repositório)

---

## Observações

Fases com backend ainda 404 permanecem com UI preparada e chip **Em preparação**. Não bloqueiam a versão 1.0 do app Flutter.
