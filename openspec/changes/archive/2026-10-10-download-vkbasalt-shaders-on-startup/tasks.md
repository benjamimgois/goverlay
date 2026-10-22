# Tasks

## 1. Startup Verification & Download of vkBasalt Shaders

- [x] 1.1 Implement `CheckAndInstallVkBasaltShaders` in `optiscaler_update.pas` using `RunCurlWithProgress` and `ExtractTarArchive` targeting `VKBASALTFOLDER + 'reshade-shaders'`, and update `HasMissingMandatoryLibraries` to check `GetVkBasaltConfigDir + '/reshade-shaders'`.
- [x] 1.2 Update `TStartupDownloadThread.Execute` in `overlayunit.pas` to invoke `CheckAndInstallVkBasaltShaders` with progress range 95%–99% and ensure shaders are populated into `aveffectsListbox` upon completion.
- [x] 1.3 Add a GUI test verifying that missing vkBasalt shaders are reported by `HasMissingMandatoryLibraries` and properly installed, and verify `make test` passes cleanly.

## Workflow follow-up

- Archive the change after implementation and validation.
