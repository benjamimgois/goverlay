# Tasks: Auto-Update OptiPatcher Rolling Release on OptiScaler Tab Open

- [x] 1. Implement Async OptiPatcher Check & Download (`optiscaler_update.pas`)
  - [x] 1.1 Add `CheckAndUpdateOptiPatcherAsync` procedure to check remote `optiscaler/OptiPatcher` commit date.
  - [x] 1.2 Implement file download and multi-directory sync for `OptiPatcher.asi` (`optiscaler/plugins/`, `.bgmod_original/plugins/`, `bgmod/plugins/`).
  - [x] 1.3 Update `optipatcher=rolling-YYYY.MM.DD` key in `goverlay.vars` and refresh Software Status label.

- [x] 2. Integrate Tab Switch Trigger (`overlayunit.pas`)
  - [x] 2.1 Trigger `CheckAndUpdateOptiPatcherAsync` when switching to `optiscalerTabSheet`.

- [x] 3. Verification & Testing
  - [x] 3.1 Verify release build compilation with `lazbuild goverlay.lpi --bm=Release --widgetset=qt6`.
  - [x] 3.2 Test tab switch behavior and verify OptiPatcher version update.
