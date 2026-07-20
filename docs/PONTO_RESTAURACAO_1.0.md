# Ponto de restauração 1.0 — pré-auditoria final

Atualizado: 2026-07-20

## Propósito

Este snapshot marca a **versão base estável** do PoliGestor Flutter **antes** da auditoria final das Fases 1–24.

Use este ponto para retornar caso a auditoria ou correções subsequentes introduzam regressões.

## Identificadores

| Campo | Valor |
|-------|--------|
| Tag Git | `v1.0-final-pre-auditoria` |
| Commit | `a20587f` |
| Branch | `master` |
| Versão app (`pubspec.yaml`) | **1.0.0+2** |
| Versão APK | **1.0.0+2** (`app-debug.apk` / `app-release.apk`) |
| Versão Web | **1.0.0+2** (`build/web`) |
| Repositório | `https://github.com/sergiocjr/poligestor_app.git` |

## Escopo funcional congelado

- Fases 1–24 implementadas no Flutter conforme `docs/STATUS_PROJETO.md` na data desta tag.
- Consumo LIVE-only da VPS `https://poligestor.onnexis.com.br/api`.
- Última entrega major: **Fase 24 — Notícias Regionais** (sync LIVE parcial `/v1/news/*`).

## Como restaurar

```powershell
cd C:\src\poligestor_app
git fetch origin --tags
git checkout v1.0-final-pre-auditoria
# ou criar branch a partir da tag:
git checkout -b restore-pre-auditoria v1.0-final-pre-auditoria
```

Rebuild após checkout:

```powershell
flutter pub get
flutter build apk --debug
flutter build web
```

## Artefatos de build (referência)

| Artefato | Caminho |
|----------|---------|
| APK debug | `build/app/outputs/flutter-apk/app-debug.apk` |
| APK release | `build/app/outputs/flutter-apk/app-release.apk` |
| Web | `build/web/` |

## Observações

- Tag criada **antes** de `docs/AUDITORIA_FINAL.md`.
- Após restauração, revisar `docs/CONTINUAR_PROJETO.md` e `docs/CHANGELOG.md` da tag — não misturar docs pós-auditoria sem merge consciente.
