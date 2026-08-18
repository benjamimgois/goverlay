## 1. bgmod Wrapper Integration

- [x] 1.1 Add `GOVERLAY_LOSSLESS` parsing under `[Config]` in `bgmod.lpr`
- [x] 1.2 Export all `LSFGVK_*` environment variables in `bgmod.lpr` when `GOVERLAY_LOSSLESS` is enabled

## 2. Lossless Scaling Tab Persistence

- [x] 2.1 Update `GetConfigFile` in `lossless_scaling_tab.pas` to resolve active `bgmod.conf`
- [x] 2.2 Implement `SaveLosslessConfig` to write `GOVERLAY_LOSSLESS=1` in `[Config]` and `LSFGVK_*` in `[Env]`
- [x] 2.3 Implement cleanup in `SaveLosslessConfig` to delete `LSFGVK_*` keys and write `GOVERLAY_LOSSLESS=0` when disabled
- [x] 2.4 Implement `LoadLosslessConfig` to read `GOVERLAY_LOSSLESS` and `LSFGVK_*` values from `bgmod.conf`

## 3. Verification and Testing

- [x] 3.1 Verify compilation of GOverlay and `bgmod` wrapper
- [x] 3.2 Update GUI test cases in `gui_test_cases.pas` to validate `bgmod.conf` `[Config]` and `[Env]` roundtrip
- [x] 3.3 Run test suite and manual verification
