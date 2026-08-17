## 1. Add PROTON_DISCORD_BRIDGE Tweak

- [x] 1.1 Declare backing `FProtonDiscordBridgeCheckBox` checkbox component on `Tgoverlayform` in `overlayunit.pas`.
- [x] 1.2 Increment `TWEAK_ROW_COUNT` from 30 to 31 and add `PROTON_DISCORD_BRIDGE=1` row to `TWEAK_ROWS` in `tweaks_md3.pas` under `TWEAK_CAT_GENERAL`.
- [x] 1.3 Map `FProtonDiscordBridgeCheckBox` in `GetTweakRowCheckBox` and instantiate it in `InitTweaksCards`.
- [x] 1.4 Add tooltip `"Works only with proton-cachyos"` in `MouseMove` handler in `tweaks_md3.pas`.
- [x] 1.5 Add `FProtonDiscordBridgeCheckBox` to `SaveTweaksConfig`, `HasTweaksEnabled`, and `LoadTweaksFromFGMod`.

## 2. Verification & Testing

- [x] 2.1 Add GUI unit test `TestProtonDiscordBridgeTweak` in `tests/gui/gui_test_cases.pas`.
- [x] 2.2 Verify compilation with `lazbuild goverlay.lpi --bm=Release`.
- [x] 2.3 Run unit tests with `make test-logic`.
- [x] 2.4 Run full GUI test suite with `make test-gui`.
