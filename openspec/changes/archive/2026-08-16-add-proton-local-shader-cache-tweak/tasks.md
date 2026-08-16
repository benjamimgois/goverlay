## 1. Add PROTON_LOCAL_SHADER_CACHE Tweak

- [x] 1.1 Declare backing `FProtonLocalShaderCacheCheckBox` checkbox component on `Tgoverlayform` in `overlayunit.pas`.
- [x] 1.2 Increment `TWEAK_ROW_COUNT` from 29 to 30 and add `PROTON_LOCAL_SHADER_CACHE=1` row to `TWEAK_ROWS` in `tweaks_md3.pas` under `TWEAK_CAT_PERF`.
- [x] 1.3 Map `FProtonLocalShaderCacheCheckBox` in `GetTweakRowCheckBox` and instantiate it in `InitTweaksCards`.
- [x] 1.4 Add tooltip `"Works only with proton-cachyos"` in `MouseMove` handler in `tweaks_md3.pas`.
- [x] 1.5 Add `FProtonLocalShaderCacheCheckBox` to `SaveTweaksConfig`, `HasTweaksEnabled`, and `LoadTweaksFromFGMod`.

## 2. Verification & Testing

- [x] 2.1 Verify compilation with `lazbuild goverlay.lpi --bm=Release`.
- [x] 2.2 Run unit tests with `make test-logic`.
- [x] 2.3 Run full GUI test suite with `make test-gui`.
