## 1. Add PROTON_VKD3D_LOWLATENCY Tweak

- [x] 1.1 Add `PROTON_VKD3D_LOWLATENCY=1` row to `TWEAK_ROWS` array in `tweaks_md3.pas` with category `'Latency reduction'` and description `"[proton-cachyos] low-latency frame pacing capabilities"`.
- [x] 1.2 Declare backing `FProtonVkd3dLowLatencyCheckBox` checkbox component on `Tgoverlayform` in `overlayunit.pas` / `overlayunit.lfm`.
- [x] 1.3 Map `FProtonVkd3dLowLatencyCheckBox` in `GetTweakRowCheckBox` helper in `tweaks_md3.pas`.
- [x] 1.4 Wire INI save/load persistence and `goverlay.vars` / `bgmod.conf` export in `overlayunit.pas`.

## 2. Verification

- [x] 2.1 Run `make test` test suite to verify clean build and passing tests.
